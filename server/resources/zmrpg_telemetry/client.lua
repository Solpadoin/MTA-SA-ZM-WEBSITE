local ARTILLERY_ROUNDS = 150
local ARTILLERY_INTERVAL = 67
local ARTILLERY_HALF_SIZE = 150

local function targetGroundZ(x, y, fallback)
	local ground = getGroundPosition(x, y, 1500)
	if ground == false then
		return fallback
	end
	return ground
end

local function createDescendingRocket(x, y, groundZ)
	local projectile = createProjectile(
		localPlayer,
		19,
		x,
		y,
		groundZ + 1500,
		1,
		nil,
		90,
		0,
		0,
		0,
		0,
		-10
	)
	if projectile then
		setProjectileCounter(projectile, 3000)
	end
end

local function executeArtillery(x, y, groundZ)
	local rounds = 0
	setTimer(function()
		rounds = rounds + 1
		local rocketX = x + math.random(-ARTILLERY_HALF_SIZE, ARTILLERY_HALF_SIZE)
		local rocketY = y + math.random(-ARTILLERY_HALF_SIZE, ARTILLERY_HALF_SIZE)
		createDescendingRocket(rocketX, rocketY, targetGroundZ(rocketX, rocketY, groundZ))
	end, ARTILLERY_INTERVAL, ARTILLERY_ROUNDS)
end

local function executeAirstrike(x, y, groundZ, aircraft)
	if not isElement(aircraft) then
		return
	end

	for rocketIndex = 1, 10 do
		setTimer(function()
			if not isElement(aircraft) then
				return
			end
			local planeX, planeY, planeZ = getElementPosition(aircraft)
			local targetX = x + math.random(-60, 60)
			local targetY = y + math.random(-60, 60)
			local targetZ = targetGroundZ(targetX, targetY, groundZ)
			local deltaX = targetX - planeX
			local deltaY = targetY - planeY
			local deltaZ = targetZ - planeZ
			local distance = math.sqrt((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ))
			if distance < 1 then
				return
			end
			local speed = 5
			local projectile = createProjectile(
				localPlayer,
				19,
				planeX,
				planeY,
				planeZ - 1,
				1,
				nil,
				0,
				0,
				0,
				(deltaX / distance) * speed,
				(deltaY / distance) * speed,
				(deltaZ / distance) * speed
			)
			if projectile then
				setProjectileCounter(projectile, 4000)
			end
		end, 2800 + ((rocketIndex - 1) * 350), 1)
	end
end

addEvent("zmrpg:prepareStrike", true)
addEventHandler("zmrpg:prepareStrike", resourceRoot, function(actionId, actionType, x, y)
	x = tonumber(x)
	y = tonumber(y)
	if not x or not y then
		triggerServerEvent(
			"zmrpg:strikeGroundReady",
			resourceRoot,
			actionId,
			false,
			false,
			"Invalid strike coordinates."
		)
		return
	end

	enginePreloadWorldArea(x, y, 1000, "collisions")
	setTimer(function()
		local groundZ = getGroundPosition(x, y, 1500)
		if groundZ == false then
			triggerServerEvent(
				"zmrpg:strikeGroundReady",
				resourceRoot,
				actionId,
				false,
				false,
				"Ground collision could not be loaded."
			)
			return
		end
		triggerServerEvent("zmrpg:strikeGroundReady", resourceRoot, actionId, true, groundZ)
	end, 500, 1)
end)

addEvent("zmrpg:executeStrike", true)
addEventHandler("zmrpg:executeStrike", resourceRoot, function(actionId, actionType, x, y, groundZ, aircraft)
	x = tonumber(x)
	y = tonumber(y)
	groundZ = tonumber(groundZ)
	if not x or not y or not groundZ then
		return
	end

	if actionType == "artillery" then
		executeArtillery(x, y, groundZ)
	elseif actionType == "airstrike" then
		executeAirstrike(x, y, groundZ, aircraft)
	end
end)
