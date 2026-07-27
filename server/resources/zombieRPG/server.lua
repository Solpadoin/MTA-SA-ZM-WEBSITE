---/// SERVER: SOURCE.

---New Code;
---newbies = createTeam("Newbies",255,255,40)
---army  =   createTeam("Rescue Team",0,255,40)
---gang1 =   createTeam("Gang 'Svoboda'",90,40,120)
---gang2 =   createTeam("Gang 'Kings of world'",150,200,300)
gov   =	  createTeam("Goverment",240,40,60)


--[[ MARKERS: SHOP ]]--

zone1 = createMarker (-2519.07910, 2340.07764, 3.7, "cylinder", 1.5, 255, 0, 0, 170 )
zone2 = createMarker (-2027.85632, -41.03518, 37.50469, "cylinder", 1.5, 255, 0, 0, 170 )
zone3 = createMarker (2037.32422, 2721.28125, 10.54356, "cylinder", 1.5, 255, 0, 0, 170 )
zone4 = createMarker (-27.98703, -2484.91357, 35.64844, "cylinder", 1.5, 255, 0, 0, 170 )
createBlipAttachedTo ( zone1, 45, 4 , 0, 0, 0, 0, 0, 500)
createBlipAttachedTo ( zone2, 45, 4 , 0, 0, 0, 0, 0, 500)
createBlipAttachedTo ( zone3, 45, 4 , 0, 0, 0, 0, 0, 500)
createBlipAttachedTo ( zone4, 45, 4 , 0, 0, 0, 0, 0, 500)


--[[ MARKERS: EXIT ]]--

zone2_ex = createMarker (-2029.76794, -121.13285, 34.0, "cylinder", 1.5, 255, 0, 0, 170 )
zone2_en = createMarker ( -2026.54602, -101.12833 ,34.16406, "cylinder", 1.5, 255, 0, 0, 170 )




battleShip1 = createObject ( 10771, 139.7001953125, -2105.30078125, 7, 0, 0, 0 )
battleShip2 = createObject ( 10770, 143, -2112.8095703125, 40.200000762939, 0, 0, 0 )
battleShip3 = createObject ( 11146, 130.6474609375, -2104.7998046875, 13.800000190735, 0, 0, 0 )
battleShip4 = createObject ( 11145, 76.7998046875, -2105.2998046875, 5.8000001907349, 0, 0, 0 )
battleShip5 = createObject ( 11149, 133.599609375, -2110.419921875, 13.479999542236, 0, 0, 0 )


----BATTLESHIP2 TO BATTLESHIP1;

local MC_X = 143-139.7001953125
local MC_Y = (-2112.8095703125) - (-2105.30078125)
local MC_Z = 40.200000762939 - 7
attachElements ( battleShip2, battleShip1,MC_X,MC_Y,MC_Z)



----

local MC2_X = 130.6474609375-139.7001953125
local MC2_Y = (-2104.7998046875) - (-2105.30078125)
local MC2_Z = 13.800000190735 - 7
attachElements ( battleShip3, battleShip1,MC2_X,MC2_Y,MC2_Z)

---

local MC3_X = 76.7998046875-139.7001953125
local MC3_Y = (-2105.2998046875) - (-2105.30078125)
local MC3_Z = 5.8000001907349 - 7
attachElements ( battleShip4, battleShip1,MC3_X,MC3_Y,MC3_Z)


----

local MC4_X = 133.599609375-139.7001953125
local MC4_Y = (-2110.419921875) - (-2105.30078125)
local MC4_Z = 13.479999542236 - 7
attachElements ( battleShip5, battleShip1,MC4_X,MC4_Y,MC4_Z)

local MainX,MainY,MainZ = getElementPosition(battleShip1)


function getShipPosition()
	if (battleShip1) then
		local x,y,z = getElementPosition(battleShip1)
		return x,y,z
	else
		return false
	end
end






--[[ SOURCE ]]--

local ZONE_51_SPAWN = { 213.81255, 1865.91699, 13.14063, 180, 287 }
local ACCOUNT_DEFAULTS = {
	["playerStatus:newbie"] = 0,
	["player:moneybalance"] = 0,
	["player:score"] = 0,
	["level_of_player"] = 1,
	["materials"] = 0,
	["account:vehicle"] = 0,
	["vehicleParts"] = 0,
	["armorParts"] = 0,
	["bandagePoints"] = 0,
	["bonusActived"] = false
}

local function initializePlayerData(player, account)
	if not isElement(player) or not account or isGuestAccount(account) then
		return false
	end

	for key, defaultValue in pairs(ACCOUNT_DEFAULTS) do
		if getAccountData(account, key) == false then
			setAccountData(account, key, defaultValue)
		end
	end

	setPlayerMoney(player, tonumber(getAccountData(account, "player:moneybalance")) or 0)
	setElementData(player, "founder_count", 0)
	setElementData(player, "medkits", 0)
	setElementData(player, "spawned_Veh", false)
	return true
end

local function spawnAtZone51(player)
	if not isElement(player) then
		return
	end

	spawnPlayer(player, ZONE_51_SPAWN[1], ZONE_51_SPAWN[2], ZONE_51_SPAWN[3], ZONE_51_SPAWN[4], ZONE_51_SPAWN[5], 0, 0)
	setCameraTarget(player, player)
	fadeCamera(player, true, 1.5)
	setPlayerTeam(player, gov)

	local red, green, blue = getTeamColor(gov)
	setPlayerNametagColor(player, red, green, blue)
	outputChatBox("[Zombie RPG] Welcome, " .. getPlayerName(player) .. ". You spawned at Zone 51.", player, 141, 255, 106)
	outputChatBox("[Zombie RPG] Use the armory marker for supplies and F4 after buying a personal vehicle.", player, 235, 235, 235)
end

function onPlayerStartedGame(previousAccount, currentAccount)
	if not initializePlayerData(source, currentAccount) then
		return
	end

	spawnAtZone51(source)
	if getResourceFromName("voice") and getResourceState(getResourceFromName("voice")) == "running" then
		exports.voice:setPlayerChannel(source)
	end
end
addEventHandler("onPlayerLogin", root, onPlayerStartedGame)

function set_user_skin(x,y,z,skinmodel)
	setElementPosition(source,x,y,z + 2)
	setPedSkin(source,skinmodel)
	fadeCamera (source, true)
	setCameraTarget (source, source)
end
addEvent("on_skin_choosed",true)
addEventHandler("on_skin_choosed", getRootElement(), set_user_skin)

call(getResourceFromName("scoreboard"),"addScoreboardColumn","score")
call(getResourceFromName("scoreboard"),"addScoreboardColumn","group")

function onPlayer_Has_Been_Wasted()
	local player = source
	outputChatBox("[Zombie RPG] Respawning at Zone 51 in 3 seconds.", player, 215, 71, 71)
	setTimer(spawnAtZone51, 3000, 1, player)
end
addEventHandler("onPlayerWasted", root, onPlayer_Has_Been_Wasted)


--[[ SOURCE CODE: MARKERS ]]--

function on_base2_exit(hitElement)
	setElementPosition(hitElement,-2026.59460 , -92.48556 , 35.32031)
end
addEventHandler( "onMarkerHit", zone2_ex , on_base2_exit)

function on_base2_enter(hitElement)
	setElementPosition(hitElement,-2030.31995, -126.93208, 35.22987)
end
addEventHandler( "onMarkerHit", zone2_en , on_base2_enter)

function on_skin_shop_open(hitElement)
	if (getElementType ( hitElement ) == "player") then
		x,y,z = getElementPosition(hitElement)
		if getAccountData(getPlayerAccount(hitElement),"account::fraction") then
				setElementData(hitElement,"player:acc_fraction",getAccountData(getPlayerAccount(hitElement),"account::fraction"))
			else
				setElementData(hitElement,"player:acc_fraction",false)
		end
		triggerClientEvent( hitElement, "on_skin_choose",hitElement,x,y - 4,z)
	end
end
addEventHandler("onMarkerHit", zone1 , on_skin_shop_open)
addEventHandler("onMarkerHit", zone2 , on_skin_shop_open)
addEventHandler("onMarkerHit", zone3 , on_skin_shop_open)
addEventHandler("onMarkerHit", zone4 , on_skin_shop_open)


function playerChat(message, messageType)
	if messageType == 0 then
        cancelEvent()
		if (getPlayerTeam (source) == false) and not getAccountData(getPlayerAccount(source), "orgname") then
			outputChatBox("#FFFFFF[#4682B4Soldier#FFFFFF]#B22222"..getPlayerName(source)..": ##FFD700"..message, root, red, green, blue, true )
		elseif (getAccountData(getPlayerAccount(source), "orgname") == nil) then
			outputChatBox("#FFFFFF[#4682B4Soldier#FFFFFF]#B22222"..getPlayerName(source)..": ##FFD700"..message, root, red, green, blue, true )
		elseif (getAccountData(getPlayerAccount(source), "orgname") == false) then
			outputChatBox("#FFFFFF[#4682B4Soldier#FFFFFF]#B22222"..getPlayerName(source)..": #FFD700"..message, root, red, green, blue, true )
		elseif (getAccountData(getPlayerAccount(source), "orgname")) then
			outputChatBox("#FFFFFF[#4682B4"..tostring(getAccountData(getPlayerAccount(source), "orgname")).."#FFFFFF]#BDB76B"..getPlayerName(source)..": #FFD700"..message, root, red, green, blue, true )
		elseif not(getPlayerTeam (source) == false) then
			if not(getPlayerTeam (source) == nil) then
				local r,g,b = getTeamColor (getPlayerTeam (source))
				outputChatBox("["..tostring(getTeamName(getPlayerTeam(source))).."]:#FFD700["..getPlayerName(source).."]: ##FFD700"..message, root, r,g,b, true )
			else
				outputChatBox("#FFD700["..getPlayerName(source).."]: ##FFD700"..message, root, r,g,b, true )
			end
		end
		outputServerLog("CHAT: "..getPlayerName(source)..": "..message)
	end
end
addEventHandler("onPlayerChat", getRootElement(), playerChat)

--------------------
materials1 = createMarker (-2380.03345, 1547.13550, 1.71719, "cylinder", 1.5, 255, 0, 0, 170 )
materials2 = createMarker (-1400.35352, 1485.85071, 6.40156, "cylinder", 1.5, 255, 0, 0, 170 )
materials3 = createMarker (-1296.47815, 490.59604, 10.49531, "cylinder", 1.5, 255, 0, 0, 170 )
materials4 = createMarker (32.01396, -2657.28564, 39.7, "cylinder", 1.5, 255, 0, 0, 170 )
materials5 = createMarker (2729.32690,-2451.46069,16.79375, "cylinder", 1.5, 255, 0, 0, 170 )

function onMaterialsTryTake(hitElement)
	if getElementType(hitElement) ~= "player" then
		return
	end

	local account = getPlayerAccount(hitElement)
	if isGuestAccount(account) then
		return
	end

	local materials = tonumber(getAccountData(account, "materials")) or 0
	if materials >= 300 then
		outputChatBox("[Crafting] Your material storage is full (300/300).", hitElement, 255, 218, 121)
		return
	end

	local amount = math.min(math.random(35, 45), 300 - materials)
	materials = materials + amount
	setAccountData(account, "materials", materials)
	outputChatBox("[Crafting] Collected " .. amount .. " materials (" .. materials .. "/300).", hitElement, 141, 255, 106)
end
addEventHandler("onMarkerHit",materials1,onMaterialsTryTake)
addEventHandler("onMarkerHit",materials2,onMaterialsTryTake)
addEventHandler("onMarkerHit",materials3,onMaterialsTryTake)
addEventHandler("onMarkerHit",materials4,onMaterialsTryTake)
addEventHandler("onMarkerHit",materials5,onMaterialsTryTake)


function checkMyMaterials(player)
	local materials = tonumber(getAccountData(getPlayerAccount(player), "materials")) or 0
	outputChatBox("[Crafting] You have " .. materials .. " materials.", player, 235, 235, 235)
end
addCommandHandler("materials",checkMyMaterials)


function craftWeaponFromMaterials(player,command,weapon,ammo)
	local materials = tonumber(getAccountData(getPlayerAccount(player), "materials")) or 0
	triggerClientEvent(player, "open_menu_craft", player, materials)
end
addCommandHandler("weapon",craftWeaponFromMaterials)


addEvent("trigger_craft_weapon",true)
local CRAFTING_PRICES = {
	[4] = 15, [9] = 20, [22] = 25, [23] = 25, [24] = 35,
	[25] = 50, [29] = 50, [30] = 60, [31] = 65, [34] = 70, [35] = 100
}

function givePlayerCraftedWeapon(weaponName)
	if client ~= source then
		return
	end

	local weaponId = getWeaponIDFromName(tostring(weaponName))
	local weaponCost = CRAFTING_PRICES[weaponId]
	if not weaponCost then
		return
	end

	local account = getPlayerAccount(source)
	local materials = tonumber(getAccountData(account, "materials")) or 0
	if materials >= weaponCost then
		setAccountData(account, "materials", materials - weaponCost)
		giveWeapon(source, weaponId, 30)
		outputChatBox("[Crafting] You crafted " .. getWeaponNameFromID(weaponId) .. " with 30 rounds.", source, 141, 255, 106)
	else
		outputChatBox("[Crafting] Not enough materials.", source, 255, 218, 121)
	end
end
addEventHandler("trigger_craft_weapon",getRootElement(),givePlayerCraftedWeapon)




function BindKeys()
	 bindKey(source, "F5", "down", showMenuOfCraftingWeapons)
end
addEventHandler("onPlayerLogin",getRootElement(),BindKeys)

function showMenuOfCraftingWeapons(player)
	triggerClientEvent(player,"open_menu_craft",player,getAccountData(getPlayerAccount(player),"materials"))
end



function closeSecondPart(player)
	givePlayerMoney(player, 5000)
	outputChatBox("Вы выполнили задания! Поздравляем! Теперь вам доступен спавн в 4 локациях.",player, 255,255,0,false)
	setAccountData(getPlayerAccount(player), "playerStatus:newbie", 0)
end
-- The legacy tutorial has been removed. Its reward events are intentionally not exposed.





----SAVE MONEY---

function onPlayerDissconnect()
	local account = getPlayerAccount(source)
	if not isGuestAccount(account) then
		setAccountData(account, "player:moneybalance", getPlayerMoney(source))
	end
end
addEventHandler("onPlayerQuit",getRootElement(),onPlayerDissconnect)



---SPAWNPOINTS----

---Proximity---

---- SECURITY CODE FOR SPECIAL PERMISSIONS ---

--- DON'T CHANGE THIS CODE! ---


function gamemodeSettings()
	setGameType ( "Zombie Mod RPG" )

	local password =   get ( "privateServer" )
	local gameSlots =  get ( "gameSlots" )

	if password and password ~= "no" then
		setServerPassword ( password )
		outputConsole("[SERVER] The password changed to: "..getServerPassword())
		outputServerLog ("[SERVER] The password changed to: "..getServerPassword())
	end

	if gameSlots and gameSlots ~= "no" then
		setMaxPlayers ( tonumber(gameSlots) or 100 )
		outputConsole("[SERVER] Max game slots changed to: "..getMaxPlayers())
		outputServerLog("[SERVER] Max game slots changed to: "..getMaxPlayers())
	end

	outputConsole("[SERVER]Resource created by 4yvak. vk.com/solpadoin")
	outputServerLog ( "[SERVER]Resource created by 4yvak. vk.com/solpadoin" )
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), gamemodeSettings)




--- AK-74M ---


setWeaponProperty(30, "poor", "weapon_range", 60)
setWeaponProperty(30, "std", "weapon_range", 100)
setWeaponProperty(30, "pro", "weapon_range", 100)

setWeaponProperty(30, "poor", "target_range", 60)
setWeaponProperty(30, "std", "target_range", 100)
setWeaponProperty(30, "pro", "target_range", 100)

setWeaponProperty(30, "poor", "damage", 33)
setWeaponProperty(30, "std", "damage", 33)
setWeaponProperty(30, "pro", "damage", 33)

setWeaponProperty(30, "poor", "accuracy", 20)
setWeaponProperty(30, "std", "accuracy", 70)
setWeaponProperty(30, "pro", "accuracy", 75)

setWeaponProperty(30, "poor", "move_speed", 2)
setWeaponProperty(30, "std", "move_speed", 2)
setWeaponProperty(30, "pro", "move_speed", 2)


--- VINTOREZ ---


setWeaponProperty(34, "poor", "weapon_range", 350)
setWeaponProperty(34, "std", "weapon_range", 350)
setWeaponProperty(34, "pro", "weapon_range", 350)

setWeaponProperty(34, "poor", "target_range", 350)
setWeaponProperty(34, "std", "target_range", 350)
setWeaponProperty(34, "pro", "target_range", 350)

setWeaponProperty(34, "poor", "damage", 150)
setWeaponProperty(34, "std", "damage", 150)
setWeaponProperty(34, "pro", "damage", 150)

setWeaponProperty(34, "poor", "accuracy", 100)
setWeaponProperty(34, "std", "accuracy", 100)
setWeaponProperty(34, "pro", "accuracy", 100)

setWeaponProperty(34, "poor", "move_speed", 1)
setWeaponProperty(34, "std", "move_speed", 1)
setWeaponProperty(34, "pro", "move_speed", 1)

setWeaponProperty(34, "poor", "maximum_clip_ammo", 1)
setWeaponProperty(34, "std", "maximum_clip_ammo", 1)
setWeaponProperty(34, "pro", "maximum_clip_ammo", 1)

--- M4A1 ---

setWeaponProperty(31, "poor", "weapon_range", 100)
setWeaponProperty(31, "std", "weapon_range", 100)
setWeaponProperty(31, "pro", "weapon_range", 100)

setWeaponProperty(31, "poor", "target_range", 100)
setWeaponProperty(31, "std", "target_range", 100)
setWeaponProperty(31, "pro", "target_range", 100)

setWeaponProperty(31, "poor", "damage", 22)
setWeaponProperty(31, "std", "damage", 22)
setWeaponProperty(31, "pro", "damage", 22)

setWeaponProperty(31, "poor", "accuracy", 100)
setWeaponProperty(31, "std", "accuracy", 100)
setWeaponProperty(31, "pro", "accuracy", 100)

setWeaponProperty(31, "poor", "move_speed", 2)
setWeaponProperty(31, "std", "move_speed", 2)
setWeaponProperty(31, "pro", "move_speed", 2)

setWeaponProperty(31, "poor", "maximum_clip_ammo", 45)
setWeaponProperty(31, "std", "maximum_clip_ammo", 45)
setWeaponProperty(31, "pro", "maximum_clip_ammo", 45)

--- MP5 ---

setWeaponProperty(29, "poor", "weapon_range", 30)
setWeaponProperty(29, "std", "weapon_range", 30)
setWeaponProperty(29, "pro", "weapon_range", 30)

setWeaponProperty(29, "poor", "target_range", 45)
setWeaponProperty(29, "std", "target_range", 45)
setWeaponProperty(29, "pro", "target_range", 45)

setWeaponProperty(29, "poor", "damage", 60)
setWeaponProperty(29, "std", "damage", 60)
setWeaponProperty(29, "pro", "damage", 60)

setWeaponProperty(29, "poor", "accuracy", 150)
setWeaponProperty(29, "std", "accuracy", 150)
setWeaponProperty(29, "pro", "accuracy", 150)

setWeaponProperty(29, "poor", "move_speed", 2.5)
setWeaponProperty(29, "std", "move_speed", 2.5)
setWeaponProperty(29, "pro", "move_speed", 2.5)

setWeaponProperty(29, "poor", "maximum_clip_ammo", 30)
setWeaponProperty(29, "std", "maximum_clip_ammo", 30)
setWeaponProperty(29, "pro", "maximum_clip_ammo", 30)




---- Pickups ----


---LOCATIONS: ----

ammobox1 = createPickup (-2454.69092, 2326.24146, 4.98438, 3, 2969, 999999 )
ammobox2 = createPickup (202.47456, 1859.20789, 13.14063, 3, 2969, 999999 )
ammobox3 = createPickup (215.33533, 1828.26599, 6.41406, 3, 2969, 999999 )
ammobox4 = createPickup (292.26279, 1906.95654, 33.67812, 3, 2969, 999999 )
ammobox5 = createPickup (331.87689, 1798.04578, 25.67820, 3, 2969, 999999 )
ammobox6 = createPickup (316.37854, 2536.79565, 16.81206, 3, 2969, 999999 )
ammobox7 = createPickup (411.11337, 2531.62573, 16.57955, 3, 2969, 999999 )

setElementData(ammobox1,"pickup:ammobox",true)
setElementData(ammobox2,"pickup:ammobox",true)
setElementData(ammobox3,"pickup:ammobox",true)
setElementData(ammobox4,"pickup:ammobox",true)
setElementData(ammobox5,"pickup:ammobox",true)
setElementData(ammobox6,"pickup:ammobox",true)
setElementData(ammobox7,"pickup:ammobox",true)

action = {
  [1] = function(x) givePlayerMoney(x, math.random(200,3000)) outputChatBox("Вы нашли [Деньги]!",x) end,
  [2] = function(x) giveWeapon(x, math.random(29,36), math.random(3,15)) outputChatBox("Вы нашли [Оружие]!",x) end,
  [3] = function(x) setPedArmor(x,100) outputChatBox("Вы нашли [Броня]!",x) end,
  [4] = function(x) setElementHealth(x,getElementHealth(x) + 100) outputChatBox("Вы нашли [Аптечка]!",x) end,
}

function onPickupAmmoBoxEnter(thePlayer)
	if (source == ammobox1 or source == ammobox2 or source == ammobox3 or source == ammobox4 or source == ammobox5 or source == ammobox6 or source == ammobox7) then
		if (getElementType(thePlayer) == "player") then
			local p_value = math.random(1,4);
			action[p_value](thePlayer)
		end
	end
end
addEventHandler("onPickupHit",getRootElement(),onPickupAmmoBoxEnter)



--- VEHICLES LOOT BOXES ---


vehiclebox1 = createPickup (161.04668, 1975.01599, 18.63326, 3, 2485, 999999 )
vehiclebox2 = createPickup (-2.88095, 1571.38000, 12.75000, 3, 2485, 999999 )
vehiclebox3 = createPickup (-2768.76855, 2494.97803, 95.73077, 3, 2485, 999999 )
vehiclebox4 = createPickup (-1535.23694, 452.71686, 7.18750, 3, 2485, 999999 )
vehiclebox5 = createPickup (1057.56873, 2756.10059, 12.52624, 3, 2485, 999999 )
vehiclebox6 = createPickup (668.45111, 329.36319, 20.22494, 3, 2485, 999999 )
vehiclebox7 = createPickup (2771.18872, 202.31377, 20.26563, 3, 2485, 999999 )
vehiclebox8 = createPickup (199.67723, -1853.84509, 3.31204, 3, 2485, 999999 )

setElementData(vehiclebox1,"pickup:vehiclebox",true)
setElementData(vehiclebox2,"pickup:vehiclebox",true)
setElementData(vehiclebox3,"pickup:vehiclebox",true)
setElementData(vehiclebox4,"pickup:vehiclebox",true)
setElementData(vehiclebox5,"pickup:vehiclebox",true)
setElementData(vehiclebox6,"pickup:vehiclebox",true)
setElementData(vehiclebox7,"pickup:vehiclebox",true)
setElementData(vehiclebox8,"pickup:vehiclebox",true)


vehicles = {
  [1] = function(x,y,z) veh = createVehicle(568, x, y, z) setElementData(veh,"vehicle:pickup",true) end,
  [2] = function(x,y,z) veh = createVehicle(424, x, y, z) setElementData(veh,"vehicle:pickup",true) end,
  [3] = function(x,y,z) veh = createVehicle(471, x, y, z) setElementData(veh,"vehicle:pickup",true) end,
  [4] = function(x,y,z) veh = createVehicle(571, x, y, z) setElementData(veh,"vehicle:pickup",true) end,
}

function onVehiclePickup(thePlayer)
if not isPedInVehicle(thePlayer) then
	if (source == vehiclebox1 or source == vehiclebox2 or source == vehiclebox3 or source == vehiclebox4 or source == vehiclebox5 or source == vehiclebox6 or source == vehiclebox7 or source == vehiclebox8) then
		if (getElementType(thePlayer) == "player") then
			local p_value = math.random(1,4);
			x,y,z = getElementPosition(thePlayer)
			vehicles[p_value](x,y,z)
		end
	end
end
end
addEventHandler("onPickupHit",getRootElement(),onVehiclePickup)


function onVehicleBlowed()
	if (getElementData(source,"vehicle:pickup",true)) then
		setElementData(source,"vehicle:pickup",false)
		destroyElement(source)
	end
end
addEventHandler("onVehicleExplode", getRootElement(), onVehicleBlowed)

veh_shop = createMarker (-1663.42090,1208.66272,6.4,"cylinder", 1.0, 255, 0, 0, 50 )
createBlipAttachedTo ( veh_shop, 55, 0.8, 0,0,0,0,0,50)

function en_markerHit(player)
	if source == veh_shop and getElementType(player) == "player" then
		triggerClientEvent ( player, "on_marker_client_hit",player)
	end
end
addEventHandler("onMarkerHit",veh_shop,en_markerHit)


local VEHICLE_CATALOG = {
	[579] = 1500,
	[400] = 3500,
	[404] = 4500,
	[489] = 5500,
	[505] = 6000,
	[479] = 7000,
	[442] = 7100,
	[458] = 8200,
	[602] = 9800,
	[496] = 12000,
	[401] = 41000
}

local function getPersonalVehicle(player)
	local vehicle = getElementData(player, "my_veh")
	if isElement(vehicle) and getElementType(vehicle) == "vehicle" then
		return vehicle
	end
	return nil
end

local function clearPersonalVehicle(player)
	local vehicle = getPersonalVehicle(player)
	if vehicle then
		destroyElement(vehicle)
	end
	setElementData(player, "my_veh", false)
	setElementData(player, "spawned_Veh", false)
end

function VehicleOnBuyTrigger(id)
	if client ~= source then
		return
	end

	id = tonumber(id)
	local cost = VEHICLE_CATALOG[id]
	local account = getPlayerAccount(source)
	if not cost or isGuestAccount(account) then
		return
	end

	if getPlayerMoney(source) < cost then
		outputChatBox("[Vehicle] Not enough money.", source, 255, 218, 121)
		return
	end

	clearPersonalVehicle(source)
	takePlayerMoney(source, cost)
	setAccountData(account, "account:vehicle", id)
	setAccountData(account, "player:moneybalance", getPlayerMoney(source))
	outputChatBox("[Vehicle] Purchased " .. getVehicleNameFromModel(id) .. " for $" .. cost .. ".", source, 141, 255, 106)
	outputChatBox("[Vehicle] Press F4 to spawn or remove your personal vehicle.", source, 235, 235, 235)
end
addEvent("trigger_buy_car",true)
addEventHandler("trigger_buy_car",getRootElement(),VehicleOnBuyTrigger)


---function setFUEL()
---	destroyElement(source)
---end
---addEventHandler("onVehicleExplode", getRootElement(), setFUEL)


addEventHandler ( "onPlayerVehicleExit", getRootElement(), function(theVehicle, leftSeat, jackerPlayer)
    if leftSeat == 0 and not jackerPlayer then
       setVehicleEngineState( theVehicle, false)
    end
end)

function user_car(thePlayer)
	local account = getPlayerAccount(thePlayer)
	local model = not isGuestAccount(account) and tonumber(getAccountData(account, "account:vehicle")) or 0
	if not model or model == 0 or not VEHICLE_CATALOG[model] then
		outputChatBox("[Vehicle] You do not own a personal vehicle. Visit the vehicle shop first.", thePlayer, 255, 218, 121)
		return
	end

	triggerClientEvent(thePlayer, "vehicle:menu", thePlayer, model, isElement(getPersonalVehicle(thePlayer)))
end
addCommandHandler("car",user_car)

function spawn_an_auto()
	if client ~= source or isPedInVehicle(source) then
		outputChatBox("[Vehicle] Leave your current vehicle before spawning your personal vehicle.", source, 255, 218, 121)
		return
	end

	local account = getPlayerAccount(source)
	local model = not isGuestAccount(account) and tonumber(getAccountData(account, "account:vehicle")) or 0
	if not VEHICLE_CATALOG[model] then
		outputChatBox("[Vehicle] You do not own a valid personal vehicle.", source, 255, 218, 121)
		return
	end

	clearPersonalVehicle(source)
	local x, y, z = getElementPosition(source)
	local _, _, rotation = getElementRotation(source)
	local radians = math.rad(rotation)
	local spawnX = x - math.sin(radians) * 4
	local spawnY = y + math.cos(radians) * 4
	local vehicle = createVehicle(model, spawnX, spawnY, z + 0.5, 0, 0, rotation)
	if not vehicle then
		outputChatBox("[Vehicle] The vehicle could not be spawned here. Move to an open area and try again.", source, 255, 218, 121)
		return
	end

	setElementInterior(vehicle, getElementInterior(source))
	setElementDimension(vehicle, getElementDimension(source))
	setElementData(vehicle, "vehicleOwner", getPlayerName(source))
	setElementData(vehicle, "personalVehicle", true)
	setElementData(source, "my_veh", vehicle)
	setElementData(source, "spawned_Veh", true)
	warpPedIntoVehicle(source, vehicle)
	outputChatBox("[Vehicle] Your " .. getVehicleNameFromModel(model) .. " is ready.", source, 141, 255, 106)
end
addEvent("player:vehicle_spawn",true)
addEventHandler("player:vehicle_spawn",getRootElement(getThisResource()),spawn_an_auto)


function destroyMyVehicle()
	if client ~= source then
		return
	end

	if not getPersonalVehicle(source) then
		outputChatBox("[Vehicle] Your personal vehicle is not spawned.", source, 255, 218, 121)
		return
	end

	clearPersonalVehicle(source)
	outputChatBox("[Vehicle] Your personal vehicle was removed.", source, 235, 235, 235)
end
addEvent("player:vehicle_destroy",true)
addEventHandler("player:vehicle_destroy",getRootElement(getThisResource()),destroyMyVehicle)

addEventHandler("onPlayerQuit", root, function()
	clearPersonalVehicle(source)
end)


function killPedByCommand(thePlayer)
killPed(thePlayer)
end
addCommandHandler("kill",killPedByCommand)

--[[
function refill_engine(thePlayer)
	if ( getPlayerMoney(thePlayer) >= 500 ) then
		fuel = getElementData(getPedOccupiedVehicle(thePlayer),"car_fuel")
		setElementData(getPedOccupiedVehicle(thePlayer),"car_fuel",fuel + 200)
		outputChatBox("Your vehicle refilled successfuly. FUEL:["..fuel.."]",thePlayer)
		takePlayerMoney(thePlayer,500)
	else
		outputChatBox("You need 500$ to refill the fuel.",thePlayer)
	end
end
addCommandHandler("refill",refill_engine)

function onVehicle_fuel_minus(ThePlayer)
fuel_get = getElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel")
if (fuel_get == false) then
setElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel",50)
fuel_get = getElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel")
outputChatBox("FUEL = [".. tostring(getElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel")).."]",ThePlayer)
	timer = setTimer ( function()
	if (isPedInVehicle(ThePlayer) == true) then
		if fuel_get > 0 then
			if (getVehicleEngineState(getPedOccupiedVehicle (ThePlayer)) == true) then
				speed = getDistanceBetweenPoints3D ( 0, 0, 0, getElementVelocity (getPedOccupiedVehicle (ThePlayer)) )
				fuel_get = getElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel") - speed*5
				setElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel",fuel_get)
			end
		else
				setVehicleEngineState(getPedOccupiedVehicle (ThePlayer),false)
				outputChatBox("No fuel. Write /refill to refill",ThePlayer,255,0,0,false)
				killTimer(timer)
		end
	end end, 12000, getElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel") + 1 )
else
	outputChatBox("FUEL = [".. tostring(getElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel")).."]",ThePlayer)
	timer = setTimer ( function()
	if (isPedInVehicle(ThePlayer) == true) then
		if fuel_get > 0 then
			if (getVehicleEngineState(getPedOccupiedVehicle (ThePlayer)) == true) then
				speed = getDistanceBetweenPoints3D ( 0, 0, 0, getElementVelocity (getPedOccupiedVehicle (ThePlayer)) )
				fuel_get = getElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel") - speed*5
				setElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel",fuel_get)
			end
		else
				setElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel",0)
				setVehicleEngineState(getPedOccupiedVehicle (ThePlayer),false)
				outputChatBox("No fuel. Write /refill to refill",ThePlayer,255,0,0,false)
				killTimer(timer)
		end
	end end, 12000, getElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel") + 1 )
	end
end
addEventHandler ( "onVehicleEnter", getRootElement(),onVehicle_fuel_minus)

function onCheckFuel_LEFT(ThePlayer)
	if (isPedInVehicle(ThePlayer) == true) then
	outputChatBox("FUEL LEFT["..getElementData(getPedOccupiedVehicle (ThePlayer),"car_fuel").."]",ThePlayer,255,255,0,false)
	end
end
addCommandHandler("fuel",onCheckFuel_LEFT)
]]--




-------------STANDART VEHICLES---------------

---------RESPAWN VEHICLES----------------

function isVehicleOccupied(vehicle)
    assert(isElement(vehicle) and getElementType(vehicle) == "vehicle", "Bad argument @ isVehicleOccupied [expected vehicle, got " .. tostring(vehicle) .. "]")
    local _, occupant = next(getVehicleOccupants(vehicle))
    return occupant and true, occupant
end

setTimer(
function()
	for k,v in ipairs(getElementsByType("vehicle")) do
		if (getElementData(v,"goverment_vehicles") == true) or (getElementData(v,"rentcar") == true) or (getElementData(v,"rew_auto") == true) then
			if not isVehicleOccupied(v) then
				respawnVehicle(v)
				if (getElementData(v,"rew_auto") == true) then
					setElementData(v,"car_owner",false)
				end
			end
		end
	end
	outputChatBox("#FFA500[SERVER] #EEDC82Машины были доставлены на свои позиции!",getRootElement(),0,0,0,true)
end
, 600000, 0)



function onVehicleFindSOmeResources(thePlayer,seat)
if seat == 0 then
	if (getElementData(source,"rew_auto") == true) then
		setVehicleEngineState(source,false )
		if getElementData(thePlayer,"founder_count") then
		if ((tonumber(getElementData(thePlayer, "founder_count")) or 0) < 6) then
			local founder = math.random(1,5)
			if founder == 1 then
				outputChatBox("#FFEBCDВы нашли оружие.",thePlayer,0,0,0,true)
				giveWeapon(thePlayer,math.random(24,32),math.random(1,15))
			elseif founder == 2 then
				outputChatBox("#FFEBCDВы ничего не нашли.",thePlayer,0,0,0,true)
			elseif founder == 3 then
				outputChatBox("#FFEBCDВы нашли аптечку. Пишите /healme что б излечить себя",thePlayer,0,0,0,true)
				setElementData(thePlayer,"medkits",1)
			elseif founder == 4 then
				outputChatBox("#FFEBCDВы нашли немного денег.",thePlayer,0,0,0,true)
				givePlayerMoney (thePlayer,math.random(50,350))
			elseif founder == 5 then
				outputChatBox("#FFEBCDВы ничего не нашли.",thePlayer,0,0,0,true)
			end
				setElementData(thePlayer, "founder_count", (tonumber(getElementData(thePlayer, "founder_count")) or 0) + 1)
			else
				outputChatBox("#EE9A00Вы не можете обыскать авто сейчас. #CD950CПопробуйте позже.",thePlayer,0,0,0,true)
		end
		else
			setElementData(thePlayer,"founder_count",1)
			if (getElementData(thePlayer,"founder_count") < 6) then
			local founder = math.random(1,5)
			if founder == 1 then
				outputChatBox("#FFEBCDВы нашли оружие.",thePlayer,0,0,0,true)
				giveWeapon(thePlayer,math.random(24,32),math.random(1,15))
			elseif founder == 2 then
				outputChatBox("#FFEBCDВы ничего не нашли.",thePlayer,0,0,0,true)
			elseif founder == 3 then
				outputChatBox("#FFEBCDВы нашли аптечку. Пишите /healme что б излечить себя",thePlayer,0,0,0,true)
				setElementData(thePlayer,"medkits",1)
			elseif founder == 4 then
				outputChatBox("#FFEBCDВы нашли немного денег.",thePlayer,0,0,0,true)
				givePlayerMoney (thePlayer,math.random(50,350))
			elseif founder == 5 then
				outputChatBox("#FFEBCDВы ничего не нашли.",thePlayer,0,0,0,true)
			end
				setElementData(thePlayer,"founder_count",getElementData(thePlayer,"founder_count") + 1)
			else
				outputChatBox("#EE9A00Вы не можете обыскать авто сейчас. #CD950CПопробуйте позже.",thePlayer,0,0,0,true)
		end
		end
	end
end
end
addEventHandler( "onVehicleEnter", getRootElement(), onVehicleFindSOmeResources)

setTimer(function()
	for k,v in ipairs(getAlivePlayers()) do
		local foundCount = tonumber(getElementData(v, "founder_count")) or 0
		if foundCount > 1 then
			setElementData(v, "founder_count", foundCount - 1)
			else
			setElementData(v,"founder_count",0)
		end
	end
 end,300000,0)

function onVehicleExitForRent(thePlayer,seat)
if seat == 0 then
	if (getElementData(source,"rentcar") == true) then
		if (getElementData(source,"car_owner") == false ) then
			setVehicleEngineState(source,false )
			if getPlayerMoney(thePlayer) > 500 then
				setVehicleEngineState(source,true)
				outputChatBox("#F4A460Вы арендовали автомобиль.",thePlayer,0,0,0,true)
				takePlayerMoney(thePlayer,500)
				setElementData(source,"car_owner",getPlayerName(thePlayer))
			else
				removePedFromVehicle (thePlayer)
				outputChatBox("#F4A460Вы не можете арендовать автомобиль. [Не хватает денег]",thePlayer,0,0,0,true)
			end

			else
			local owner = getElementData(source,"car_owner")
			if not(getPlayerName(thePlayer) == owner ) then
				removePedFromVehicle (thePlayer)
				outputChatBox("#F4A460Автомобиль арендован другим игроком.",thePlayer,0,0,0,true)
			end
		end
	end
end
end
addEventHandler( "onVehicleEnter", getRootElement(),onVehicleExitForRent)

function useMyMedkits(thePlayer)
	if (getElementData(thePlayer,"medkits") == 1) then
		outputChatBox("#FFFACDВы вылечили себя...",thePlayer,0,0,0,true)
		setElementHealth(thePlayer,getElementHealth(thePlayer) + 50)
		setElementData(thePlayer,"medkits",0)
	else
		outputChatBox("#FFFACDУ вас нет аптечек.",thePlayer,0,0,0,true)
	end
end
addCommandHandler("healme",useMyMedkits )



function BindKeys()
	 bindKey(source, "F4", "down", openSpawnMenuKeys)
end
addEventHandler("onPlayerLogin",getRootElement(),BindKeys)


function openSpawnMenuKeys(player)
	user_car(player)
end

----GOVERMENT----

---HYDRA---

h1 = createVehicle(520,329.91687,1956.97815,18.55640,0,0,90) setElementData(h1,"goverment_vehicles",true)
h2 = createVehicle(520,330.71002,1990.96289,17.64063,0,0,90) setElementData(h2,"goverment_vehicles",true)
veh5 = createVehicle(520,-1439.1021728516,501.98602294922,18.344329833984,1.2986286878586,-0.00098494789563119,279.55313110352)
setElementData(veh5,"goverment_vehicles",true)

---SWATS---
sw1 = createVehicle(601,276.70584,1955.91541,17.82183,0,0,180) setElementData(sw1,"goverment_vehicles",true)

--RUSTLERS---
rustler1 = createVehicle(476,278.33749,1992.73560,17.93995,0,0,200) setElementData(rustler1,"goverment_vehicles",true)

---Patriot---
patriot1 = createVehicle(470,233.66722,1887.66895,17.73077,0,0,0) setElementData(patriot1,"goverment_vehicles",true)
patriot2 = createVehicle(470,193.25249,1876.75903,17.64063,0,0,0) setElementData(patriot2,"goverment_vehicles",true)

--ADMIRALS&OTHERS---

adm1 = createVehicle(445,-2397.66846,2332.21240,4.68595,0,0,0) setElementData(adm1,"goverment_vehicles",true)
adm2 = createVehicle(445,-2393.66846,2332.21240,4.68595,0,0,0) setElementData(adm2,"goverment_vehicles",true)
adm3 = createVehicle(445,-2064.36670,-83.10181,35.16406,0,0,0) setElementData(adm3,"goverment_vehicles",true)
adm4 = createVehicle(445,-2068.36670,-83.10181,35.16406,0,0,0) setElementData(adm4,"goverment_vehicles",true)
adm5 = createVehicle(602,-2072.50000,-83.10181,35.16406,0,0,0) setElementData(adm5,"goverment_vehicles",true)
adm6 = createVehicle(602,-2077.36670,-83.10181,35.16406,0,0,0) setElementData(adm6,"goverment_vehicles",true)
adm7 = createVehicle(542,-2081.36670,-83.10181,35.16406,0,0,0) setElementData(adm7,"goverment_vehicles",true)
adm8 = createVehicle(542,-2085.36670,-83.10181,35.16406,0,0,0) setElementData(adm8,"goverment_vehicles",true)
adm9 = createVehicle(445,-22.67578125,-2524.75,36.723896026611,0,0,29.318695068359) setElementData(adm9,"goverment_vehicles",true)
clover1 = createVehicle(542,-2444.24146,2224.84644,4.46804,0,0,0) setElementData(adm8,"goverment_vehicles",true)
clover2 = createVehicle(542,-2447.24146,2224.84644,4.46804,0,0,0) setElementData(adm8,"goverment_vehicles",true)
clover3 = createVehicle(542,-2451.24146,2224.84644,4.46804,0,0,0) setElementData(adm8,"goverment_vehicles",true)
clover4 = createVehicle(542,-2454.24146,2224.84644,4.46804,0,0,0) setElementData(adm8,"goverment_vehicles",true)
virgo1 = createVehicle(491,-2483.21387,2224.62939,4.38130,0,0,0) setElementData(adm8,"goverment_vehicles",true)

tg1 = createVehicle(554,-142.0283203125,-2419.1513671875,32.761978149414,0,0,17.362640380859)
setElementData(tg1,"goverment_vehicles",true)

plv1 = createVehicle(598,-597.5908203125,-2749.0986328125,67.030052185059,0,0,139.47253417969)
setElementData(plv1,"goverment_vehicles",true)

veh10 = createVehicle(598,-919.10217285156,-2840.62890625,69.243537902832,2.3275866508484,-1.41690325737,145.59841918945)
setElementData(veh10,"goverment_vehicles",true)

veh11 = createVehicle(598,-1278.6264648438,-2849.7800292969,61.223224639893,9.0646324157715,-1.7415156364441,70.030296325684)
setElementData(veh11,"goverment_vehicles",true)

veh12 = createVehicle(413,-1616.0460205078,-2703.9895019531,48.64525604248,1.3480523824692,0.0017160746501759,271.64416503906)
setElementData(veh12,"goverment_vehicles",true)

veh13 = createVehicle(411,-1414.2847900391,454.51675415039,6.7202663421631,-5.0817241572076e-005,2.6896668714471e-005,149.32698059082)
setElementData(veh13,"goverment_vehicles",true)

veh14 = createVehicle(411,-1523.1318359375,681.04730224609,6.7058629989624,-8.6085638031363e-005,-1.8542074030847e-005,277.5143737793)
setElementData(veh14,"goverment_vehicles",true)

veh15 = createVehicle(433,285.69958496094,1794.859375,18.55214881897,-0.0018181294435635,-0.00011658798757708,321.1076965332)
setElementData(veh15,"goverment_vehicles",true)

veh16 = createVehicle(433,2073.7331542969,2677.8176269531,11.783824920654,-0.024839984253049,-0.3155582845211,0.66412365436554)
setElementData(veh16,"goverment_vehicles",true)

veh16 = createVehicle(433,2073.7331542969,2667.8176269531,11.783824920654,-0.024839984253049,-0.3155582845211,0.66412365436554)
setElementData(veh16,"goverment_vehicles",true)

veh17 = createVehicle(402,2004.8259277344,2746.4328613281,10.393509864807,0.030156765133142,4.7731513977051,90.670829772949)
setElementData(veh17,"goverment_vehicles",true)

----============= АРЕНДА АВТОМОБИЛЕЙ =============--------


banshee1 = createVehicle(429,-1633.521484375,1294.48046875,6.7131276130676,0,0,135) setElementData(banshee1,"rentcar",true)
banshee2 = createVehicle(429,-1637.998046875,1297.078125,6.7154927253723,0,0,135) setElementData(banshee2,"rentcar",true)
banshee3 = createVehicle(429,-1641.078125,1300.9638671875,6.7092800140381,0,0,135) setElementData(banshee3,"rentcar",true)
premier1 = createVehicle(426,-1654.986328125,1315.0732421875,6.7822856903076,0,0,135) setElementData(premier1,"rentcar",true)

veh18 = createVehicle(541,1776.8820800781,2768.9985351563,10.286186218262,0.32108011841774,-1.101788520813,166.76831054688)
setElementData(veh18,"rentcar",true)

veh19 = createVehicle(541,1673.3051757813,2717.5007324219,10.239062309265,0.48558405041695,0.00044271160732023,181.27143859863)
setElementData(veh19,"rentcar",true)

----======АВТОМОБИЛИ ДЛЯ ДОБЫЧИ РЕСУРСОВ ====--------------

---SPAWN 1---
rew_aut1 = createVehicle(451,-2424.59765625,2670.9365234375,60.697284698486,0,0,240.9585723877) setElementData(rew_aut1,"rew_auto",true)
rew_aut2 = createVehicle(470,-2429.8232421875,2669.7236328125,61.229381561279,0,0,270.17715454102) setElementData(rew_aut2,"rew_auto",true)
rew_aut3 = createVehicle(508,-2426.41015625,2665.8828125,61.473388671875,0,0,349.31289672852) setElementData(rew_aut3,"rew_auto",true)

---SPAWN 1: TO SF---
rew_aut1_1 = createVehicle(445,-2695.2802734375,1851.880859375,67.077713012695,0,0,164.52746582031) setElementData(rew_aut1_1,"rew_auto",true)
rew_aut1_2 = createVehicle(445,-2668.3525390625,1587.1103515625,63.642139434814,0,0,333.67031860352) setElementData(rew_aut1_2,"rew_auto",true)


---BONE COUNTRY----
rew_aut2_2 = createVehicle(508,-85.0107421875,1339.29296875,10.681799888611,0,0,7.2527465820313) setElementData(rew_aut2_2,"rew_auto",true)
rew_aut2_3 = createVehicle(470,-104.173828125,1336.4912109375,10.035607337952,0,0,6.2857360839844) setElementData(rew_aut2_3,"rew_auto",true)
rew_aut2_4 = createVehicle(508,107.2890625,1216.0361328125,19.82421875,0,0,266.50549316406) setElementData(rew_aut2_4,"rew_auto",true)
rew_aut2_5 = createVehicle(554,51.2939453125,1184.8779296875,18.866020202637,0,0,116.43957519531) setElementData(rew_aut2_5,"rew_auto",true)

---SPAWN 3----
rew_aut3_1 = createVehicle(554,19.646484375,-2675.171875,40.702098846436,0,0,292.26373291016) setElementData(rew_aut3_1,"rew_auto",true)

sell_material_price = 15;   ---- ЦЕНА ЗА 1 ЕДИНИЦУ ОРУЖИЯ
sell_material_price2 = 350; ---- Цена за 1 единицу аптечки.

------GREN ZONES[SAFE]-----------

safe1 = createRadarArea ( -2766.10303, 2164.13672, 500, 350, 0, 255, 0, 80 )
safe2 = createRadarArea ( 1900.12354, 2579.84668, 250, 300, 0, 255, 0, 80 )

safe3 = createRadarArea ( -2132.88989,-280.07196, 250, 300, 0, 255, 0, 80 )

safe4 = createRadarArea ( -100.48316,-2615.77588, 150, 200, 0, 255, 0, 80 )

setElementData( safe1, 'zombieProof', true )
setElementData( safe2, 'zombieProof', true )
setElementData( safe3, 'zombieProof', true )
setElementData( safe4, 'zombieProof', true )


------YELLOW ZONES[Warning]----------

warning1 = createRadarArea ( 96.35453, 1795.59900, 300, 300, 255, 255, 60, 80 )
setElementData( warning1, 'zombieProof', true )

------RED ZONES[VERY DANGEROUS]---------

dangerous_zone = createRadarArea ( -2543.87598,1508.38635, 300, 90, 255, 0, 0, 80 )
dangerous_zone_colshape = createColSphere (-2437.88623, 1554.25391, 17.32813, 140 )
mutagen_marker = createMarker (-2366.76050, 1535.50989, 1.3, "cylinder", 1.5, 255, 0, 0, 170 )

function onDangerousZoneEnter(hitElement)
	outputChatBox("#FFE4B5[ВНИМАНИЕ] #EEDD82Вы находитесь на территории зараженной зоны.",hitElement,0,0,0,true)
	outputChatBox("#EEDD82Концентрация вируса: #6B8E23[ОЧЕНЬ ОПАСНО]",hitElement,0,0,0,true)
	setElementHealth(hitElement,getElementHealth(hitElement)/2)
end
addEventHandler("onColShapeHit",dangerous_zone_colshape,onDangerousZoneEnter)

function onMarkerMutagenGett(hitElement)
	if not (getPedStat (hitElement,24) == 1000) then
		outputChatBox("#B8860B[ВНИМАНИЕ] Вы взяли мутаген. Теперь ваше здоровье увеличенно до 200.",hitElement,0,0,0,true)
		setPedStat ( hitElement, 24, 1000 )
	elseif (getElementData(hitElement,"zombie") == true) then
		outputChatBox("#8B4513Мутаген взял контроль над вами...Вы ослабели",hitElement,0,0,0,true)
		setElementData(hitElement,"zombie",false)
		setPedStat ( hitElement, 24, 350 )
		killPed(hitElement)
	else
		outputChatBox("#B4CDCD[ВНИМАНИЕ] Вы мутировали до #FF6A6Aзомби. #B4CDCDТеперь #FF6A6Aзомби #B4CDCDне будут вас атаковать. ",hitElement,0,0,0,true)
		setElementData(hitElement,"zombie",true)
		setElementHealth(hitElement,200)
		setPedArmor(hitElement,100)
	end
end
addEventHandler("onMarkerHit",mutagen_marker,onMarkerMutagenGett)

------SHOPS-------------

ammo1 = createMarker(193.36560, 1931.44556, 18.5 ,"arrow", 2.5, 255, 255, 0,170)
ammo1_exit = createMarker(286.46869, -86.77403, 1002.52289,"arrow", 1.5, 255, 255, 0,170)
setElementInterior ( ammo1_exit, 4 )
createBlipAttachedTo ( ammo1, 6, 0.8, 0,0,0,0,0,50)

ammo_box_marker = createMarker(296.40015 ,-80.81145, 1002.0253,"arrow", 1.0, 255, 255, 0,170)
setElementInterior ( ammo_box_marker, 4 )

function teleport_to_ammo(hitPlayer)
	setElementInterior(hitPlayer,4,285.80032, -84.54760, 1001.51563)
end
addEventHandler("onMarkerHit",ammo1,teleport_to_ammo)

function teleport_to_world(hitPlayer)
	setElementInterior(hitPlayer,0,188.23480, 1931.39514, 17.67192)
end
addEventHandler("onMarkerHit",ammo1_exit,teleport_to_world)

function give_ammo_toplayer(hitPlayer)
	if not(getPedWeaponSlot ( hitPlayer ) == 0) then
		if (getPedTotalAmmo (hitPlayer) >= 15 ) then
			outputChatBox("У вас уже есть оружие!",hitPlayer,255,0,0,false)
		else
			outputChatBox("#FFFFE0Вы получили #00CED1 [Спасательный набор]. #FFFFE0Используйте его мудро!",hitPlayer,0,0,0,true)
			giveWeapon (hitPlayer, getPedWeapon(hitPlayer), 120 )
			giveWeapon (hitPlayer, 4, 1)
		end
	else
			outputChatBox("У вас нет оружия! Достаньте оружие и приходите, когда патронов будет мало [<15]",hitPlayer,255,0,0,false)
	end
end
addEventHandler("onMarkerHit",ammo_box_marker,give_ammo_toplayer)

------MINIGUN GUARD------------------
guard_arena = createColSphere (114.30468, 1938.31482, 18.89757, 20 )

function onZombieColShapeHit(element)
	if (getElementData(element,"zombie") == true ) then
		triggerClientEvent(element,"set_fire_on_enemy",element,element)
	end
end
addEventHandler( "onColShapeHit", guard_arena, onZombieColShapeHit )


skladmenu = createMarker(200.49408, 1869.51514, 14.14696,"arrow", 1.5, 255, 255, 0,170)
createBlipAttachedTo ( skladmenu, 52, 1.0,0,0,0,0,0,700 )

skladmenu2 = createMarker(-2597.31006, 2357.00146 ,10.58300,"arrow", 1.5, 255, 255, 0,170)
createBlipAttachedTo ( skladmenu2, 52, 1.0,0,0,0,0,0,700 )


function marker_open_sklad_menu(player)
	ammo = getAccountData(getPlayerAccount(player),"materials")
	medkit = getElementData(player,"medkits")
	triggerClientEvent(player,"open:sklad_menu",player,ammo,medkit)
end
addEventHandler("onMarkerHit",skladmenu,marker_open_sklad_menu)
addEventHandler("onMarkerHit",skladmenu2,marker_open_sklad_menu)

-----SHOP FUNCTIONS-------

function giveMoneyForAmmo(ammo)
	local money = sell_material_price * ammo;
	givePlayerMoney(source,money)
	outputChatBox("#CDB38BВы продали материалы на общую сумму денег: #EEB422"..money,source,0,0,0,true)
	setAccountData(getPlayerAccount(source),"materials",getAccountData(getPlayerAccount(source),"materials") - ammo)
end
addEvent("shop:sellmaterials",true)
addEventHandler("shop:sellmaterials",getRootElement(getThisResource()),giveMoneyForAmmo)

function giveMoneyForMedkit(medkit)
	local money = sell_material_price2;
	givePlayerMoney(source,money)
	outputChatBox("#CDB38BВы продали аптечку за: #EEB422"..money,source,0,0,0,true)
	setElementData(source,"medkits",0)
end
addEvent("shop:sellmedkit",true)
addEventHandler("shop:sellmedkit",getRootElement(getThisResource()),giveMoneyForMedkit)

function BuyWeaponFromSklad(player,weaponName,Cost)
	if (getPlayerMoney(player) >= Cost) then
		takePlayerMoney(player,Cost)
		giveWeapon(player,getWeaponIDFromName ( weaponName ),30)
	else
		outputChatBox("Не достаточно денег!",player)
	end
end
addEvent("trigger_sklad_buy_goods",true)
addEventHandler("trigger_sklad_buy_goods",getRootElement(),BuyWeaponFromSklad)


missions_mark1 = createMarker (-2597.31299, 2364.65918, 10.48300,"arrow", 1.2, 255, 255, 0, 50 )

reguired_level = 3;					 ---- Уровень для доступа к миссиям.


mission_first_reward = 300;
mission_two_reward = 500; 		 --- Сколько заплатить за миссию.
mission_three_reward = 1500;

mission_secound_time = 60000; 	 --- Время в МС для того, что б обыскать зону.

mss_call_event = false;          --- По умолчанию...


function onPlayerMission_Marker_Hit(player)
	if getElementType(player) ~= "player" then
		return
	end

	local account = getPlayerAccount(player)
	if isGuestAccount(account) then
		return
	end

	local level = tonumber(getAccountData(account, "level_of_player")) or 1
	if level >= reguired_level then
		triggerClientEvent(player, "marker:mission_user_call", player, level)
	else
		outputChatBox("[Mission] You must be at least level " .. reguired_level .. " to accept missions.", player, 255, 218, 121)
	end
end
addEventHandler("onMarkerHit",missions_mark1,onPlayerMission_Marker_Hit)

addEvent("trigger_mission_first",true)
function mission_first_call()
	outputChatBox("[МИССИЯ] Доставьте ресурсы в указанную точку на карте(иконка 'МЕТКА')",source,255,255,0,false)
end
addEventHandler("trigger_mission_first",getRootElement(getThisResource()),mission_first_call)

function mission_first_ended()
	setElementData(source,"is_mission_compiting",nil)
	givePlayerMoney(source,mission_first_reward)
	outputChatBox("#EEE8AAВам было начислено: #6B8E23"..tostring(mission_first_reward).." денег #EEE8AAза успешное выполнение!",source,0,0,0,true)
end
addEvent("fist_mission_give_reward",true)
addEventHandler("fist_mission_give_reward",getRootElement(getThisResource()),mission_first_ended)



---- SECOUND MISSION ----

function onServerGotTriggered()
	local x,y,z = getElementPosition(source)
	local mis_veh = createVehicle (565, x, y, z, 0, 0, 0)
	warpPedIntoVehicle(source,mis_veh)
end
addEvent("secound_mission_server_start",true)
addEventHandler("secound_mission_server_start",getRootElement(getThisResource()),onServerGotTriggered)

function giveRewardForSecoundMission()
	givePlayerMoney(source,mission_two_reward)
	outputChatBox("#EEE8AAВам было начислено: #6B8E23"..tostring(mission_two_reward).." денег #EEE8AAза успешное выполнение!",source,0,0,0,true)
end
addEvent("give_reward_secound_mission",true)
addEventHandler("give_reward_secound_mission",getRootElement(getThisResource()),giveRewardForSecoundMission)


Sx,Sy,Sz = getShipPosition()

getAllFractions = {

	{"Military",Sx,Sy,Sz+15,90,287,30,24,50,25},
	{"SWAT",-2093.37695, -10.62361, 35.32031,270,285,30,24,50,100},
	{"Survivors",1618.18579,602.26251,7.78125,0,46,31,22,60,15}
}


----MAIN CORE FUNCTIONS-----

function getFractions()
	for k,v in ipairs(getAllFractions) do
		return v[1];
	end
end

---VER. 1.0---

function spawnPlayerOnFraction(player,fraction)
	if (player) then
		if (fraction) then
			if (getAccountData(getPlayerAccount(player),"fraction")) then
					local x = getAccountData(getPlayerAccount(player),"fraction:posX")
					local y = getAccountData(getPlayerAccount(player),"fraction:posY")
					local z = getAccountData(getPlayerAccount(player),"fraction:posZ")
					local rotZ = getAccountData(getPlayerAccount(player),"fraction:rotZ")
					local gamemodel = getAccountData(getPlayerAccount(player),"fraction:skinID")
					local weapon1 	= getAccountData(getPlayerAccount(player),"fraction:weapon1")
					local weapon2   = getAccountData(getPlayerAccount(player),"fraction:weapon2")
					local count1    = getAccountData(getPlayerAccount(player),"fraction:count1")
					local count2    = getAccountData(getPlayerAccount(player),"fraction:count2")
					spawnPlayer(player,x,y,z,rotZ,gamemodel)
					giveWeapon(player,weapon1,count1)
					giveWeapon(player,weapon2,count2)
				else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end


function setPlayerFraction(player,fraction)
	if (player) then
		if (fraction) then
			for k,v in ipairs(getAllFractions) do
				if (tostring(v[1]) == tostring(fraction)) then
					local x = tonumber(v[2])
					local y = tonumber(v[3])
					local z = tonumber(v[4])
					local rotZ = tonumber(v[5])
					local skinID = tonumber(v[6])
					local weapon1 = tonumber(v[7])
					local weapon2 = tonumber(v[8])
					local count1 = tonumber(v[9])
					local count2 = tonumber(v[10])
					setAccountData(getPlayerAccount(player),"fraction",tostring(v))
					setAccountData(getPlayerAccount(player),"fraction:posX",x)
					setAccountData(getPlayerAccount(player),"fraction:posY",y)
					setAccountData(getPlayerAccount(player),"fraction:posZ",z)
					setAccountData(getPlayerAccount(player),"fraction:rotZ",rotZ)
					setAccountData(getPlayerAccount(player),"fraction:skinID",skinID)
					setAccountData(getPlayerAccount(player),"fraction:weapon1",weapon1)
					setAccountData(getPlayerAccount(player),"fraction:weapon2",weapon2)
					setAccountData(getPlayerAccount(player),"fraction:count1",count1)
					setAccountData(getPlayerAccount(player),"fraction:count2",count2)
					outputChatBox("Вы были приглашены во фракцию: [" ..fraction .. "]",player)
				end
			end
		else
			return false
		end
	else
		return false
	end
end

function checkitOut(player,commHandler,argument)
	setPlayerFraction(player,argument)
end
addCommandHandler("setfr",checkitOut)



function getPlayerFraction(player)
	if (player) then
		local getFraction = getAccountData(getPlayerAccount(player),"fraction")
		if getFraction then
			return getFraction
		else return false end
	else return false end
end


function getPlayerFriendsOnline(player)
	outputChatBox("FRIENDS ONLINE:",player,255,255,0,false)
	for k,v in ipairs(getAlivePlayers()) do
		if getAccountData(getPlayerAccount(player),getPlayerName(v),true) then
			outputChatBox(getPlayerName(v),player)
		end
	end
end

function addFriendToPlayer(player,friend)
	if (friend) then
		outputChatBox("#FFFACD[MESSAGE] #FFF0F5You have received a request to add a Friend FROM:#EEE8AA["..getPlayerName(player).."]",getPlayerFromName(friend),0,0,0,true)
		outputChatBox("#FFFACD[MESSAGE] WAIT FOR ACCEPTING...",player,0,0,0,true)
		outputChatBox("#FFFACD[MESSAGE] #FFF0F5Write /friend to add "..getPlayerName(player).." to friend!",getPlayerFromName(friend),0,0,0,true)
		outputChatBox("#FFFACD[MESSAGE] #FFF0F5Write /ignore to reject the request!",getPlayerFromName(friend),0,0,0,true)
		setElementData(player,"friend:waiting",true)
		setElementData(getPlayerFromName(friend),"friend:choice",player)
	else return false
	end
end

function acceptChoice(player,commandHandler)
	if (getElementData(player,"friend:choice")) then
		setAccountData(getPlayerAccount(anyFriend),getPlayerName(player),true)
		setAccountData(getPlayerAccount(player),getPlayerName(anyFriend),true)
		outputChatBox("INVITE HAS BEEN ACCEPTED!",player)
		outputChatBox("INVITE HAS BEEN ACCEPTED!",anyFriend)
		setElementData(player,"friend:waiting",false)
		setElementData(getPlayerFromName(friend),"friend:choice",false)
	else outputChatBox("No request for friends!",player)
	end
end
addCommandHandler("friend",acceptChoice)

function ignoreChoice(player)
local anyFriend = getElementData(player,"friend:choice")
	outputChatBox("INVITE HAS BEEN CANCELLED by player!",anyFriend)
	setElementData(player,"friend:waiting",false)
	setElementData(getPlayerFromName(friend),"friend:choice",false)
end
addCommandHandler("ignore",ignoreChoice)


function isPlayerInFraction(player)
	if (getAccountData(getPlayerAccount(player),"fraction")) then
		return true
	else
		return false
	end
end


function isPlayerSuperZombie(player)
	if (getAccountData(getPlayerAccount(player),"superZombie") == false) then
		return false
		else
		return true
	end
end

function isPlayersFriendly(player,targetPlayer)
	if (getElementType(targetPlayer) == player ) then
		if (getAccountData(getPlayerAccount(player),"fraction") == getAccountData(getPlayerAccount(targetPlayer),"fraction")) then
			   return true
		else return false end
		else return false end
end

health = 0;

function cancelDamageForPlayers(player,targetPlayer)
	if (getElementType(targetPlayer) == player ) then
		health = getElementHealth(targetPlayer)
		if (getAccountData(getPlayerAccount(player),"fraction") == getAccountData(getPlayerAccount(targetPlayer),"fraction")) then
			setElementHealth(targetPlayer,health)
		end
	end
end


function invitePlayerToOrganization(member,cmd,invPlayer)
	if (getAccountData(getPlayerAccount(member), "organization")) then
		if (getAccountData(getPlayerAccount(member), "orgname") == getAccountData(getPlayerAccount(getPlayerFromName(invPlayer)),"orgname")) then
			outputChatBox("This player already in organization!",member)
			else
			outputChatBox(invPlayer.." has been invited to Organization!",member)
			outputChatBox("You have been invited to organization! Write /leave if you want to leave!", getPlayerFromName(invPlayer))
			setAccountData(getPlayerAccount(getPlayerFromName(invPlayer), "organization" , true))
			setAccountData(getPlayerAccount(getPlayerFromName(invPlayer)), "orgname" , getAccountData(getPlayerAccount(member), "orgname"))
			exports.voice:setPlayerChannel(getPlayerFromName(invPlayer),exports.voice:getPlayerChannel(member))
		end
	else
		outputChatBox("You are not a member of organization!",member)
	end
end
addCommandHandler("invite", invitePlayerToOrganization)

function kickPlayerToOrganization(member,cmd,invPlayer)
	if (getAccountData(getPlayerAccount(member), "organization")) then
		if (getAccountData(getPlayerAccount(member), "orgname") == getAccountData(getPlayerAccount(getPlayerFromName(invPlayer)),"orgname")) then
			outputChatBox(invPlayer.." has been kicked from Organization!",member)
			outputChatBox("You have been kicked from organization!", getPlayerFromName(invPlayer))
			setAccountData(getPlayerAccount(getPlayerFromName(invPlayer), "organization" , false))
			setAccountData(getPlayerAccount(getPlayerFromName(invPlayer), "orgname" , nil))
			exports.voice:setPlayerChannel(getPlayerFromName(invPlayer))
		end
	else
		outputChatBox("You are not a member of organization!",member)
	end
end
addCommandHandler("okick", kickPlayerToOrganization)


function leavePlayerOrganization(player,cmd,groupName)
	setAccountData(getPlayerAccount(player), "organization", false)
	setAccountData(getPlayerAccount(player), "orgname", false)
	outputChatBox("You left your organization!", player)
	exports.voice:setPlayerChannel(player)
end
addCommandHandler("leave", leavePlayerOrganization)


function createGroupByPlayer(player, cmd, groupName)
	if (groupName) then
		if (getPlayerMoney(player) > 15000 ) then
			takePlayerMoney(player, 15000)
			setAccountData(getPlayerAccount(player), "organization", true)
			setAccountData(getPlayerAccount(player), "orgname", groupName)
			outputChatBox("[SERVER] " .. getPlayerName(player) .. " created organization: "..groupName, getRootElement())
			outputChatBox("[CONGRATULATIONS] You are created organization: "..groupName, player)
			outputChatBox("[SERVER] Write /invite playerName , if you want to INVITE player!", player)
			outputChatBox("[SERVER] Write /okick playerName , if you want to KICK player!", player)
			outputChatBox("[SERVER] Write /settings to open settings menu!", player)

			exports.voice:setPlayerChannel(player,exports.voice:getNextEmptyChannel())
			outputChatBox("[VOICE] Voice channel connected! Your voice channel is ["..exports.voice:getPlayerChannel(player).."]", player)
			else
			outputChatBox("You need 15000$ to create GROUP!", player)
		end
	else
		outputChatBox("Write /group GroupName", player)
	end
end
addCommandHandler("group", createGroupByPlayer)

function membersOutputMessage(player)
local org = getAccountData(getPlayerAccount(player), "orgname")
outputChatBox("[Members online]: ", player)
	for k, v in ipairs(getAlivePlayers()) do
		if (getAccountData(getPlayerAccount(v), "orgname") == org) then
			outputChatBox(getPlayerName(v), player)
			for i, z in ipairs (getAttachedElements( v )) do
				if (getElementType(z) == "blip" or getElementType(z) == "marker") then
					destroyElement(z)
				end
			end
			if not getPlayerName(v) == getPlayerName(player) then
				createBlipAttachedTo(v, 0, 2, 0, 0, 255, 255, 0, 35000, player)
				local x,y,z = getElementPosition(v)
				local marker = createMarker (x,y,z, "arrow", 0.4, 0, 0, 255, 170 )
				attachElements( marker, v, 0, 0, 2 )
			end
		end
	end
end
addCommandHandler("members", membersOutputMessage)


function settingsGroupByPlayer(player, cmd, groupName)

end
addCommandHandler("settings", settingsGroupByPlayer)

function giveBonusForPlayers(thePlayer)
	if (getAccountData(getPlayerAccount(thePlayer), "bonusActived") == false) then
		setAccountData(getPlayerAccount(thePlayer), "bonusActived", true)
		givePlayerMoney(thePlayer, 16000)
		giveWeapon(thePlayer, 31, 250)
		giveWeapon(thePlayer, 35, 2)
		setAccountData(getPlayerAccount(thePlayer),"player:score", 350)
		outputChatBox("[SERVER] Игрок [ "..getPlayerName(thePlayer).." ] активировал бонус! Спасибо, что выбрали наш сервер. Приятной игры!", getRootElement())
	end
end
addCommandHandler("bonus", giveBonusForPlayers)


houseMarker = 0

----- Players Estate--------

function onPlayerWantsToBuyHouse(thePlayer)
	if (getElementType(thePlayer) == "player") then
		triggerClientEvent(thePlayer, "showHousesGUI", thePlayer)
	end
end
---addEventHandler("onMarkerHit", houseMarker, onPlayerWantsToBuyHouse)


houseDimension = 1;

function onPlayerBuyHouse(player, housePrice, houseInterior)
	if (getPlayerMoney(player) > housePrice) then
			houseDimension = getAccountData(getPlayerAccount(player), "registerID")  ---// players dimension
		else
		outputChatBox("Недостаточно средств!", player)
	end
end
addEvent("player:buyHouse", true)
addEventHandler("player:buyHouse", getRootElement(), onPlayerBuyHouse)



setFPSLimit ( 60 )
setSunColor ( 255, 0, 0, 255, 0, 0 )
setCloudsEnabled ( true )
setSunSize ( 0 )
setFogDistance ( 1 )
setMoonSize( 0 )
setSkyGradient( 30, 50, 98, 70, 0, 0 )




function warpToInts(thePlayer)
	setElementPosition(thePlayer,2151.8859863281, -119.78299713135, 4139.6000)
end
addCommandHandler("warpInt",warpToInts)


function zombie_killed_by_player(killer)
	if (getElementType(killer) == "player") then
		if getAccountData(getPlayerAccount(killer),"player:score") then
			if (getElementHealth(killer) < 20) then
				if (getElementHealth(killer) < 15) then
					setAccountData(getPlayerAccount(killer),"player:score",getAccountData(getPlayerAccount(killer),"player:score") + 50)
					setElementHealth(killer,getElementHealth(killer) + 80)
					outputChatBox(getPlayerName(killer).." убил зомби, будучи при смерти!",getRootElement(),255,0,0,false)
				else
					setAccountData(getPlayerAccount(killer),"player:score",getAccountData(getPlayerAccount(killer),"player:score") + 10)
					setElementHealth(killer,getElementHealth(killer) + 5)
				end
			else
				setAccountData(getPlayerAccount(killer),"player:score",getAccountData(getPlayerAccount(killer),"player:score") + 1)
			end
		else
			setAccountData(getPlayerAccount(killer),"player:score",0)
		end
	end
	for k,v in ipairs(getAttachedElements(source)) do
		destroyElement(v)
	end
end
addEvent("onZombieWasted",true)
addEventHandler("onZombieWasted",getRootElement(),zombie_killed_by_player)

function check_the_level(thePlayer)
	if getAccountData(getPlayerAccount(thePlayer),"player:score") then
		outputChatBox("["..getPlayerName(thePlayer).."]: Ваши очки: ["..getAccountData(getPlayerAccount(thePlayer),"player:score").."]",thePlayer,0,255,0,false)
		---triggerEvent("level_system_show", thePlayer, thePlayer )
		show_the_level(thePlayer)
	else
		setAccountData(getPlayerAccount(thePlayer),"player:score",0)
		outputChatBox("["..getPlayerName(thePlayer).."]: Ваш уровень: [1] Очки: [0]",thePlayer,0,255,0,false)
	end
end
addCommandHandler("level",check_the_level)

addEvent("level_system_show",true)

function show_the_level(player)
if getAccountData(getPlayerAccount(player),"level_of_player") then
	score = getAccountData(getPlayerAccount(player),"player:score")
	if score >= 0 and score <= 150 then
		setAccountData(getPlayerAccount(player),"level_of_player",1)
	elseif score >= 150*getAccountData(getPlayerAccount(player),"level_of_player") then
		setAccountData(getPlayerAccount(player),"level_of_player",getAccountData(getPlayerAccount(player),"level_of_player") + 1)
	end
	outputChatBox("Ваш уровень: ["..getAccountData(getPlayerAccount(player),"level_of_player").."]",player,0,255,0,false)
	else
	setAccountData(getPlayerAccount(player),"level_of_player",1)
end
end
addEventHandler("level_system_show",getRootElement(),show_the_level)


function craftItemsServer (player)
	local vehicleParts  = getAccountData(getPlayerAccount(player),"vehicleParts")
	local armorParts    = getAccountData(getPlayerAccount(player),"armorParts")
	local bandagePoints = getAccountData(getPlayerAccount(player),"bandagePoints")
	triggerClientEvent(player,"open_craft_menu",player,vehicleParts,armorParts,bandagePoints)
end
addCommandHandler("craft",craftItemsServer)


--- VEHICLE CRAFT ---

function craftVehicleFromMenu(vehID,vehCost)
	local x,y,z = getElementPosition(source)
	local rx,ry,rz = getElementRotation(source)
	setAccountData(getPlayerAccount(source),"vehicleParts",getAccountData(getPlayerAccount(source),"vehicleParts") - vehCost)

	local veh = createVehicle (vehID, x, y, z, rx, ry, rz )
	setElementData(veh,"vehicleType:crafted",true)
end
addEvent("crafting_menu:vehicle",true)
addEventHandler("crafting_menu:vehicle",getRootElement(getThisResource()),craftVehicleFromMenu)

function craftedVehicleWasBlown()
	if (getElementData(source,"vehicleType:crafted") == true) then
		destroyElement(source)
	end
end
addEventHandler("onVehicleExplode",getResourceRootElement(),craftedVehicleWasBlown)

function SetVehicleParts(thePlayer,command,count)
	outputChatBox("У вас " ..tostring(getAccountData(getPlayerAccount(thePlayer),"vehicleParts")).. " автозапчастей!",thePlayer)
end
addCommandHandler("parts",SetVehicleParts)


g_base_col = createColCuboid ( 97.3376, 1800.0384, -32.0937, 250, 280, 120 )

g_root = getRootElement ()

--rocketOne = createMarker ( -2931.5136, 454.4492, 17.3671, "corona", 1.5, 255, 0, 0, 150 ) --test marker
--rocketTwo = createMarker ( -2931.5932, 487.1994, 17.3671, "corona", 1.5, 255, 0, 0, 150 ) --test marker

function hit ( pla, dim )
		if ( getElementType ( pla ) == "player" ) then
			outputChatBox ( "Welcome, "..getPlayerName(pla).."!", pla, 0, 150, 0 )
		else
			setElementData ( pla, "inRestrictedArea", "true" )
			triggerClientEvent ( pla, "destroyTrepassor", g_root, pla )
	end
end
addEventHandler ( "onColShapeHit", g_base_col, hit )

function leave ( pla, dim )
			if ( getElementType ( pla ) == "player" ) then
				outputChatBox ( "Good Bye!", pla, 0, 100, 0 )
			else
				setElementData ( pla, "inRestrictedArea", "false" )
				triggerClientEvent ( pla, "destroyTimers", g_root, pla )
			end
end
addEventHandler ( "onColShapeLeave", g_base_col, leave )




function MoveBattleShip(player)
	bindKey ( player, "num_8", "down", func_move )
	bindKey ( player, "num_2", "down", func_moveBack )
	bindKey ( player, "num_4", "down", func_moveLeft )
	bindKey ( player, "num_6", "down", func_moveRight )
end
addCommandHandler("moveship",MoveBattleShip)

function func_move(player,key,keyState)
	local MainX,MainY,MainZ = getElementPosition(battleShip1)
	mS_rotX,mS_rotY,mS_rotZ = getElementRotation(battleShip1)
	if mS_rotZ == 0 then
		moveObject ( battleShip1, 5000, MainX+30,MainY,MainZ )
	elseif mS_rotZ > 0 and mS_rotZ < 90 then
		moveObject ( battleShip1, 5000, MainX+30,MainY+30,MainZ )
	elseif mS_rotZ > 90 and mS_rotZ < 180 then
		moveObject ( battleShip1, 5000, MainX+30,MainY+30,MainZ )
	elseif mS_rotZ > 180 and mS_rotZ < 360 then
		moveObject ( battleShip1, 5000, MainX-30,MainY-30,MainZ )
	end
end

function func_moveBack(player,key,keyState)
	local MainX,MainY,MainZ = getElementPosition(battleShip1)
	moveObject ( battleShip1, 5000, MainX-30,MainY,MainZ )
end

function func_moveLeft(player,key,keyState)
	local rx,ry,rz = getElementRotation(battleShip1)
	setElementRotation(battleShip1,rx,ry,rz+20)
end

function func_moveRight(player,key,keyState)
	local rx,ry,rz = getElementRotation(battleShip1)
	setElementRotation(battleShip1,rx,ry,rz-20)
end


function setPlayerPositionOnShip(player)
local x,y,z = getElementPosition(battleShip1)
	setElementPosition(player,x,y,z+15)
end
addCommandHandler("toShip",setPlayerPositionOnShip)



---- FUNCTIONS TO EXPORT -----
