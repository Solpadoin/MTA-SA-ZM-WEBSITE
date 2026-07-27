local ENDPOINT = "http://127.0.0.1:18080/api/telemetry"
local SNAPSHOT_INTERVAL = 5000

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
	{ -2441.75415, 754.66119, "Warehouse" },
	{ -2597.31299, 2364.65918, "Mission contact" }
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
		safeZones = collectSafeZones()
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
			if not responseInfo.success then
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
