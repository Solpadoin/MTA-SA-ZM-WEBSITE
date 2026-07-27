local ENDPOINT = "http://127.0.0.1:18080/api/telemetry"
local RESULT_ENDPOINT = "http://127.0.0.1:18080/api/game/result"
local SNAPSHOT_INTERVAL = 5000
local ACTION_COSTS = {
	artillery = 50,
	airstrike = 75
}

local runtimeIds = {
	player = {},
	ped = {},
	vehicle = {},
	marker = {},
	radararea = {}
}
local nextRuntimeId = {
	player = 1,
	ped = 1,
	vehicle = 1,
	marker = 1,
	radararea = 1
}
local requestInFlight = false
local trackedAccounts = {}
local pendingActions = {}

local MARKER_LABELS = {
	{ -2519.07910, 2340.07764, "Skin shop" },
	{ -2027.85632, -41.03518, "Skin shop" },
	{ 2037.32422, 2721.28125, "Skin shop" },
	{ -27.98703, -2484.91357, "Skin shop" },
	{ -2029.76794, -121.13285, "Base exit" },
	{ -2026.54602, -101.12833, "Base entrance" },
	{ -2380.03345, 1547.13550, "Materials" },
	{ -1400.35352, 1485.85071, "Materials" },
	{ -1296.47815, 490.59604, "Materials" },
	{ 32.01396, -2657.28564, "Materials" },
	{ 2729.32690, -2451.46069, "Materials" },
	{ -1663.42090, 1208.66272, "Vehicle shop" },
	{ -2366.76050, 1535.50989, "Mutagen" },
	{ 193.36560, 1931.44556, "Zone 51 armory" },
	{ 286.46869, -86.77403, "Armory exit" },
	{ 296.40015, -80.81145, "Armory supplies" },
	{ -2444.66455, 754.34698, "Warehouse" },
	{ -2441.75415, 754.66119, "Warehouse" }
}

local SAFE_ZONE_LABELS = {
	{ -2766.10303, 2164.13672, "Northwest safe zone" },
	{ 1900.12354, 2579.84668, "Las Venturas safe zone" },
	{ -2132.88989, -280.07196, "San Fierro safe zone" },
	{ -100.48316, -2615.77588, "Southern safe zone" },
	{ 96.35453, 1795.59900, "Zone 51" }
}

local function round(value, precision)
	local multiplier = 10 ^ (precision or 0)
	return math.floor((tonumber(value) or 0) * multiplier + 0.5) / multiplier
end

local function runtimeId(element, elementType)
	local known = getElementID(element)
	if known and known ~= "" then
		return known
	end

	if not runtimeIds[elementType][element] then
		runtimeIds[elementType][element] = elementType .. "-" .. nextRuntimeId[elementType]
		nextRuntimeId[elementType] = nextRuntimeId[elementType] + 1
	end
	return runtimeIds[elementType][element]
end

local function nearestLabel(x, y, labels, fallback)
	local bestLabel = fallback
	local bestDistance = 36
	for _, item in ipairs(labels) do
		local distance = getDistanceBetweenPoints2D(x, y, item[1], item[2])
		if distance < bestDistance then
			bestDistance = distance
			bestLabel = item[3]
		end
	end
	return bestLabel
end

local function positionOf(element)
	local x, y, z = getElementPosition(element)
	return {
		x = round(x, 2),
		y = round(y, 2),
		z = round(z, 2)
	}
end

local function getAccountValue(account, key, fallback)
	if not account or isGuestAccount(account) then
		return fallback
	end
	local value = getAccountData(account, key)
	if value == false then
		return fallback
	end
	return value
end

local function collectPlayers()
	local result = {}
	for _, player in ipairs(getElementsByType("player")) do
		local account = getPlayerAccount(player)
		if not isGuestAccount(account) then
			local team = getPlayerTeam(player)
			local occupiedVehicle = getPedOccupiedVehicle(player)
			table.insert(result, {
				key = getAccountName(account),
				id = runtimeId(player, "player"),
				name = getPlayerName(player),
				online = true,
				position = positionOf(player),
				rotation = round(select(3, getElementRotation(player)), 1),
				health = round(getElementHealth(player), 1),
				armor = round(getPedArmor(player), 1),
				money = getPlayerMoney(player),
				score = tonumber(getAccountValue(account, "player:score", getElementData(player, "score"))) or 0,
				level = tonumber(getAccountValue(account, "level_of_player", 1)) or 1,
				faction = getAccountValue(account, "account::fraction", false),
				organization = getAccountValue(account, "orgname", false),
				team = team and getTeamName(team) or false,
				skin = getElementModel(player),
				interior = getElementInterior(player),
				dimension = getElementDimension(player),
				vehicle = occupiedVehicle and {
					model = getElementModel(occupiedVehicle),
					name = getVehicleName(occupiedVehicle)
				} or false
			})
		end
	end
	return result
end

local function collectTrackedAccounts()
	local result = {}
	for username in pairs(trackedAccounts) do
		local account = getAccount(username)
		if account then
			table.insert(result, {
				username = getAccountName(account),
				materials = tonumber(getAccountData(account, "materials")) or 0
			})
		end
	end
	return result
end

local function collectZombies()
	local result = {}
	for _, ped in ipairs(getElementsByType("ped")) do
		if getElementData(ped, "zombie") == true then
			local target = getElementData(ped, "target")
			table.insert(result, {
				id = runtimeId(ped, "ped"),
				position = positionOf(ped),
				rotation = round(select(3, getElementRotation(ped)), 1),
				health = round(getElementHealth(ped), 1),
				skin = getElementModel(ped),
				status = getElementData(ped, "status") or "idle",
				target = isElement(target) and getElementType(target) == "player" and getPlayerName(target) or false,
				interior = getElementInterior(ped),
				dimension = getElementDimension(ped)
			})
		end
	end
	return result
end

local function collectVehicles()
	local result = {}
	for _, vehicle in ipairs(getElementsByType("vehicle")) do
		local driver = getVehicleOccupant(vehicle, 0)
		table.insert(result, {
			id = runtimeId(vehicle, "vehicle"),
			position = positionOf(vehicle),
			rotation = round(select(3, getElementRotation(vehicle)), 1),
			model = getElementModel(vehicle),
			name = getVehicleName(vehicle),
			health = round(getElementHealth(vehicle), 1),
			owner = getElementData(vehicle, "vehicleOwner") or getElementData(vehicle, "car_owner") or false,
			driver = isElement(driver) and getPlayerName(driver) or false,
			personal = getElementData(vehicle, "personalVehicle") == true,
			rental = getElementData(vehicle, "rentcar") == true,
			crafted = getElementData(vehicle, "vehicleType:crafted") == true,
			government = getElementData(vehicle, "goverment_vehicles") == true,
			interior = getElementInterior(vehicle),
			dimension = getElementDimension(vehicle)
		})
	end
	return result
end

local function collectMarkers()
	local result = {}
	for _, marker in ipairs(getElementsByType("marker")) do
		local x, y = getElementPosition(marker)
		local red, green, blue, alpha = getMarkerColor(marker)
		table.insert(result, {
			id = runtimeId(marker, "marker"),
			label = nearestLabel(x, y, MARKER_LABELS, "Game marker"),
			position = positionOf(marker),
			type = getMarkerType(marker),
			size = round(getMarkerSize(marker), 1),
			color = { red, green, blue, alpha },
			interior = getElementInterior(marker),
			dimension = getElementDimension(marker)
		})
	end
	return result
end

local function collectSafeZones()
	local result = {}
	for _, area in ipairs(getElementsByType("radararea")) do
		if getElementData(area, "zombieProof") == true then
			local x, y = getElementPosition(area)
			local width, height = getRadarAreaSize(area)
			local red, green, blue, alpha = getRadarAreaColor(area)
			table.insert(result, {
				id = runtimeId(area, "radararea"),
				label = nearestLabel(x, y, SAFE_ZONE_LABELS, "Zombie-proof area"),
				x = round(x, 2),
				y = round(y, 2),
				width = round(width, 2),
				height = round(height, 2),
				color = { red, green, blue, alpha }
			})
		end
	end
	return result
end

local function postGameResult(payload)
	local postData = toJSON(payload, true)
	setTimer(function(data)
		fetchRemote(RESULT_ENDPOINT, {
			queueName = "zmrpg-results",
			connectionAttempts = 2,
			connectTimeout = 2500,
			method = "POST",
			postData = data,
			headers = {
				["Content-Type"] = "application/json"
			}
		}, function(responseData, responseInfo)
			if type(responseInfo) == "table" and not responseInfo.success then
				outputDebugString(
					"[zmrpg_telemetry] Result upload failed: "
						.. tostring(responseInfo.statusCode or responseInfo.failureReason)
						.. " "
						.. tostring(responseData),
					2
				)
			end
		end)
	end, 50, 1, postData)
end

local function actionBalance(action)
	local account = getAccount(action.username)
	return account and (tonumber(getAccountData(account, "materials")) or 0) or 0
end

local function failAction(action, message)
	pendingActions[action.id] = nil
	postGameResult({
		kind = "action",
		id = action.id,
		success = false,
		message = message,
		materials = actionBalance(action)
	})
end

local function nearestStrikeExecutor(x, y)
	local nearestPlayer
	local nearestDistance
	for _, player in ipairs(getElementsByType("player")) do
		if getElementInterior(player) == 0 and getElementDimension(player) == 0 then
			local playerX, playerY = getElementPosition(player)
			local distance = getDistanceBetweenPoints2D(x, y, playerX, playerY)
			if not nearestDistance or distance < nearestDistance then
				nearestPlayer = player
				nearestDistance = distance
			end
		end
	end
	return nearestPlayer
end

local function startAirstrikeAircraft(action, groundZ)
	local startX = action.x - 900
	local endX = action.x + 900
	local altitude = groundZ + 300
	local aircraft = createVehicle(520, startX, action.y, altitude, 0, 0, 270)
	if not aircraft then
		return false
	end

	setElementData(aircraft, "zmrpgStrikeAircraft", true)
	setElementData(aircraft, "vehicleOwner", action.username)
	setElementCollisionsEnabled(aircraft, false)
	setVehicleDamageProof(aircraft, true)
	setElementFrozen(aircraft, true)

	local step = 0
	setTimer(function()
		if not isElement(aircraft) then
			return
		end
		step = step + 1
		local progress = step / 100
		setElementPosition(
			aircraft,
			startX + ((endX - startX) * progress),
			action.y,
			altitude,
			false
		)
		setElementRotation(aircraft, 0, 0, 270)
		if step >= 100 then
			destroyElement(aircraft)
		end
	end, 100, 100)

	return aircraft
end

local function handleAuthenticationRequests(requests)
	if type(requests) ~= "table" then
		return
	end

	for _, request in ipairs(requests) do
		if type(request) == "table" then
			local username = tostring(request.username or "")
			local account = getAccount(username, tostring(request.password or ""))
			postGameResult({
				kind = "auth",
				id = tostring(request.id or ""),
				success = account and true or false,
				username = account and getAccountName(account) or username,
				materials = account and (tonumber(getAccountData(account, "materials")) or 0) or 0
			})
		end
	end
end

local function handleStrikeRequests(actions)
	if type(actions) ~= "table" then
		return
	end

	for _, rawAction in ipairs(actions) do
		if type(rawAction) == "table" then
			local action = {
				id = tostring(rawAction.id or ""),
				username = tostring(rawAction.username or ""),
				type = tostring(rawAction.type or ""),
				x = tonumber(rawAction.x),
				y = tonumber(rawAction.y)
			}
			local cost = ACTION_COSTS[action.type]
			if action.id == "" or action.username == "" or not cost or not action.x or not action.y then
				failAction(action, "The strike request was malformed.")
			elseif action.x < -3000 or action.x > 3000 or action.y < -3000 or action.y > 3000 then
				failAction(action, "The target is outside San Andreas.")
			elseif not pendingActions[action.id] then
				local executor = nearestStrikeExecutor(action.x, action.y)
				if not executor then
					failAction(action, "At least one player must be online to execute a strike.")
				else
					action.cost = cost
					action.executor = executor
					pendingActions[action.id] = action
					triggerClientEvent(
						executor,
						"zmrpg:prepareStrike",
						resourceRoot,
						action.id,
						action.type,
						action.x,
						action.y
					)
					setTimer(function(actionId)
						local pending = pendingActions[actionId]
						if pending then
							failAction(pending, "The target area could not be prepared in time.")
						end
					end, 15000, 1, action.id)
				end
			end
		end
	end
end

local function handleBackendCommands(responseData)
	local response = fromJSON(responseData)
	if type(response) ~= "table" then
		return
	end

	handleAuthenticationRequests(response.authRequests)
	handleStrikeRequests(response.actions)

	if type(response.accounts) == "table" then
		trackedAccounts = {}
		for _, username in ipairs(response.accounts) do
			if type(username) == "string" and username ~= "" then
				trackedAccounts[username] = true
			end
		end
	end
end

addEvent("zmrpg:strikeGroundReady", true)
addEventHandler("zmrpg:strikeGroundReady", resourceRoot, function(actionId, success, groundZ, errorMessage)
	local action = pendingActions[tostring(actionId or "")]
	if not action or client ~= action.executor then
		return
	end
	if not success then
		failAction(action, tostring(errorMessage or "Ground height could not be resolved."))
		return
	end

	groundZ = tonumber(groundZ)
	if not groundZ or groundZ < -100 or groundZ > 2000 then
		failAction(action, "The target ground height was invalid.")
		return
	end

	local account = getAccount(action.username)
	if not account then
		failAction(action, "The game account no longer exists.")
		return
	end
	local materials = tonumber(getAccountData(account, "materials")) or 0
	if materials < action.cost then
		failAction(action, "Not enough materials.")
		return
	end

	local aircraft = false
	if action.type == "airstrike" then
		aircraft = startAirstrikeAircraft(action, groundZ)
		if not aircraft then
			failAction(action, "The strike aircraft could not be created.")
			return
		end
	end

	materials = materials - action.cost
	if not setAccountData(account, "materials", materials) then
		if isElement(aircraft) then
			destroyElement(aircraft)
		end
		failAction(action, "The material balance could not be updated.")
		return
	end

	pendingActions[action.id] = nil
	triggerClientEvent(
		action.executor,
		"zmrpg:executeStrike",
		resourceRoot,
		action.id,
		action.type,
		action.x,
		action.y,
		groundZ,
		aircraft
	)
	outputChatBox(
		"[Support] "
			.. action.username
			.. " called an "
			.. (action.type == "artillery" and "artillery strike." or "airstrike."),
		root,
		255,
		196,
		92
	)
	postGameResult({
		kind = "action",
		id = action.id,
		success = true,
		message = action.type == "artillery" and "Artillery strike dispatched." or "Airstrike dispatched.",
		materials = materials
	})
end)

local function sendSnapshot()
	if requestInFlight then
		return
	end

	local payload = {
		version = 1,
		generatedAt = getRealTime().timestamp,
		server = {
			name = getServerName(),
			gameType = getGameType(),
			maxPlayers = getMaxPlayers()
		},
		players = collectPlayers(),
		zombies = collectZombies(),
		vehicles = collectVehicles(),
		markers = collectMarkers(),
		safeZones = collectSafeZones(),
		accounts = collectTrackedAccounts()
	}

	requestInFlight = true
	fetchRemote(ENDPOINT, {
		queueName = "zmrpg-telemetry",
		connectionAttempts = 1,
		connectTimeout = 2500,
		method = "POST",
		postData = toJSON(payload, true),
		headers = {
			["Content-Type"] = "application/json"
		}
	}, function(responseData, responseInfo)
		requestInFlight = false
		if type(responseInfo) == "table" then
			if responseInfo.success then
				handleBackendCommands(responseData)
			else
				outputDebugString(
					"[zmrpg_telemetry] Snapshot upload failed: "
						.. tostring(responseInfo.statusCode or responseInfo.failureReason)
						.. " "
						.. tostring(responseData),
					2
				)
			end
		elseif responseInfo ~= 0 then
			outputDebugString("[zmrpg_telemetry] Snapshot upload failed with code " .. tostring(responseInfo), 2)
		end
	end)
end

addEventHandler("onResourceStart", resourceRoot, function()
	sendSnapshot()
	setTimer(sendSnapshot, SNAPSHOT_INTERVAL, 0)
end)
