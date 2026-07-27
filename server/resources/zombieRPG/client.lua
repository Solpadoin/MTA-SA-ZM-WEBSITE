
------SMARTPHONE----

function getSmartphone()
if (menuOpened == true) then
	guiSetVisible (GUIEditor.window[1], false)
	showCursor(false);
	menuOpened = false;
elseif (menuOpened == false) then
	guiSetVisible (GUIEditor.window[1], true)
	showCursor(true);
	menuOpened = true;
else

menuOpened = true;

GUIEditor = {
    button = {},
    window = {},
	gridlist = {}
}

        GUIEditor.window[1] = guiCreateWindow(410, 214, 213, 336, "ISmart", false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.button[1] = guiCreateButton(64, 290, 84, 36, "", false, GUIEditor.window[1])
        GUIEditor.gridlist[1] = guiCreateGridList(9, 29, 194, 254, false, GUIEditor.window[1])
        guiGridListAddColumn(GUIEditor.gridlist[1], "Menu", 0.9)
        for i = 1, 5 do
            guiGridListAddRow(GUIEditor.gridlist[1])
        end
		guiGridListSetItemText(GUIEditor.gridlist[1], 3, 1, "CALL", false, false)
        guiGridListSetItemText(GUIEditor.gridlist[1], 1, 1, "GPS", false, false)
		guiGridListSetItemText(GUIEditor.gridlist[1], 4, 1, "Bank", false, false)
        guiGridListSetItemText(GUIEditor.gridlist[1], 2, 1, "Donate", false, false)
		guiGridListSetItemText(GUIEditor.gridlist[1], 0, 1, "Settings", false, false)
        GUIEditor.button[2] = guiCreateButton(158, 290, 45, 36, "->", false, GUIEditor.window[1])
        GUIEditor.button[3] = guiCreateButton(9, 290, 45, 36, "<-", false, GUIEditor.window[1])
        GUIEditor.button[4] = guiCreateButton(155, -24356, 15, 210, "", false, GUIEditor.window[1])

		showCursor(true)

		function button_CallButtonBack()
			voteBack = false;
		end

		function button_CallButtonYes()
			voteBack = true;
		end

		function button_CallReturn()
			guiSetVisible (GUIEditor.window[1], false)
			showCursor(false);
		end


		function option_ChooseElement(button)
			if guiGridListGetItemText ( GUIEditor.gridlist[1], guiGridListGetSelectedItem ( GUIEditor.gridlist[1] ), 1 ) == "CALL" then
				outputChatBox("YES")
			end

		end


		addEventHandler("onClientGUIClick",GUIEditor.button[2],button_CallButtonBack,false)
		addEventHandler("onClientGUIClick",GUIEditor.button[3],button_CallButtonYes,false)
		addEventHandler("onClientGUIClick",GUIEditor.button[4],button_CallReturn,false)
		addEventHandler("onClientGUIClick",GUIEditor.gridlist[1],option_ChooseElement,false)
		addEventHandler("onClientDoubleClick",guiGridListGetSelectedItem(GUIEditor.gridlist[1]),option_ChooseElement,false)
	end
end
bindKey ( "F2","down",getSmartphone)






function startBegginersGuide()
	local markerStart = createMarker ( 213.96013, 1886.01416, 15.0, "arrow", 2.0, 255, 0, 0, 80 )
	local count = 1;

	function MarkerHit ( hitPlayer, matchingDimension )
		if count == 1 then
			setElementPosition(markerStart, 212.22859, 1907.98767, 18.2)
			count = count + 1;
		elseif count == 2 then
			setElementPosition(markerStart, 212.22859, 1907.98767, 18.2)
			count = count + 1;
		elseif count == 3 then
			setElementPosition(markerStart, 228.03651, 1920.65479, 18.2)
			count = count + 1;
		elseif count == 4 then
			setElementPosition(markerStart, 225.56987, 1931.52197, 18.2)
			count = count + 1;
		elseif count == 5 then
			setElementPosition(localPlayer, 290.79599, -26.21757, 1001.51563)
			setElementInterior(localPlayer, 1)
			setElementPosition(markerStart, 289.19760, -25.01505, 1002.3)
			setElementInterior(markerStart, 1)
			count = count + 1;
		elseif count == 6 then
			local pedZombie = createPed(59, 289.19760, -15.01505, 1001.3)
			setElementInterior(pedZombie, 1)
			setElementRotation(pedZombie, 180)
			setElementPosition(markerStart, 289.19760, -25.01505, 1000)
			setPedAnimation(pedZombie, "WUZI", "Wuzi_Walk")
			setElementPosition(localPlayer, 289.19760, -22.01505, 1001.3)
			function endMission(killer)
				triggerServerEvent("endfirstpart", localPlayer, localPlayer )
				outputChatBox("Поздравляем! Теперь следуйте к маркеру!")
				fadeCamera ( false, 0.01, 0, 0, 0 )
				setTimer ( fadeCameraDelayed, 3000, 1, localPlayer )
				removeEventHandler("onClientPedWasted", pedZombie, endMission)
				destroyElement(pedZombie)
				setElementInterior(localPlayer, 0) setElementInterior(markerStart, 0)
				setElementPosition(localPlayer, 289.19760, -22.01505, 1001.3)
				setElementPosition(markerStart, 289.19760, -25.01505, 1000)
				setCameraMatrix(-1654.45984, 1266.64282, 23.19573, -1640.04138, 1297.42468, 7.03906)
				outputChatBox("Здесь вы можете арендовать автомобиль!",255,0,0,false)
				setTimer ( setMatrixNormal, 6000, 1, localPlayer )
				count = nil
				destroyElement(markerStart)
			end
			addEventHandler("onClientPedWasted", pedZombie, endMission)
		end
	end
	addEventHandler ( "onClientMarkerHit", markerStart, MarkerHit )
end
-- The tutorial is intentionally not registered; players spawn directly at Zone 51.


function fadeCameraDelayed(player)
      if (isElement(player)) then
            fadeCamera(true, 7)
      end
end

function setMatrixNormal(player)
	---setCameraMatrix(localPlayer,localPlayer)
	setElementPosition(localPlayer, -1648.10791, 1288.75549, 7.03906)
	setCameraTarget ( localPlayer )
	outputChatBox("[ЗАДАНИЕ]Арендуйте автомобиль!")

	secondStepMission()
end

function secondStepMission()
	function getPedInVehicle()
		removeEventHandler("onClientVehicleEnter", getRootElement(), getPedInVehicle)
		outputChatBox("[ЗАДАНИЕ]Следуйте за маркером!")
		missionContinue()
	end
	addEventHandler("onClientVehicleEnter", getRootElement(), getPedInVehicle)
end

function missionContinue()
local markerStart = createMarker ( -1680.56799, 1296.63660, 5.35118, "checkpoint", 2.0, 255, 0, 0, 80 )
local theblip = createBlipAttachedTo ( markerStart, 41 )
local count = 1;

function onMarkerHit()
	if ( count == 1 ) then
		count = count + 1
		setElementPosition(markerStart, -1771.97217, 1375.15198, 8.44877)
	elseif ( count == 2 ) then
		count = count + 1
		setElementPosition(markerStart, -1906.27185, 1327.99414, 8.45657)
	elseif ( count == 3 ) then
		count = count + 1
		setElementPosition(markerStart, -2231.80249, 1335.49670, 8.44872)
	elseif ( count == 4 ) then
		count = count + 1
		setElementPosition(markerStart, -2456.98901, 1363.36389, 8.44567)
	elseif ( count == 5 ) then
		count = count + 1
		setElementPosition(markerStart, -2668.85767, 1251.87280, 54.83936)
	elseif ( count == 6 ) then
		count = count + 1
		setElementPosition(markerStart, -2672.21533, 1872.55701, 65.85517)
	elseif ( count == 7 ) then
		count = count + 1
		setElementPosition(markerStart, -2524.19531, 2335.30786, 4.29473)
	elseif ( count == 8 ) then
		count = count + 1
		setElementPosition(markerStart, -2519.09717, 2340.46436, 4.98162)
	elseif ( count == 9 ) then
		destroyElement(markerStart)
		destroyElement(theblip)
		count = nil
		outputChatBox("Здесь вы можете поменять свой скин!")
		triggerServerEvent("endSecondPart", localPlayer, localPlayer )
	end
end
addEventHandler ( "onClientMarkerHit", markerStart, onMarkerHit )
end

--[[local screenWidth, screenHeight = guiGetScreenSize ( )

function showPlayerReputation(target)
	---if (not target == localPlayer) then
		setTimer(RenderFunction,2000,1)
		---else
		---return false
	---end
end
addEventHandler ( "onClientPlayerTarget", getRootElement(), showPlayerReputation )

function RenderFunction()
dxDrawText ( "[NEUTRAL]", screenWidth/2, screenHeight/2, screenWidth/2, screenHeight/2, tocolor ( 0, 0, 0, 255 ), 1.02, "pricedown" )
end]]---


function choose_spawnpoint ()
GUIEditor = {
    button = {},
    window = {}
}



        GUIEditor.window[1] = guiCreateWindow(373, 340, 311, 140, "Set Spawn", false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.button[1] = guiCreateButton(9, 28, 288, 34, "Spawn at Fraction", false, GUIEditor.window[1])
        GUIEditor.button[2] = guiCreateButton(9, 80, 288, 34, "Spawn on Base", false, GUIEditor.window[1])

		showCursor(true)

		function onButtonFraction()
			setElementData(localPlayer,"get_spawnpoint","fraction")
			triggerServerEvent ("server:spawnFraction", localPlayer)
			destroyElement(GUIEditor.window[1])
			showCursor(false)
		end


		function onButtonBasic()
			destroyElement(GUIEditor.window[1])
			showCursor(false)
			setElementData(localPlayer,"get_spawnpoint","standart")
			triggerEvent ("server:login", localPlayer)
		end



		addEventHandler("onClientGUIClick",GUIEditor.button[1],onButtonFraction)
		addEventHandler("onClientGUIClick",GUIEditor.button[2],onButtonBasic)
end
-- Legacy spawn chooser removed from the active event surface.



function spawnMenuChooser()


GUIEditor = {
    window = {},
    gridlist = {},
    button = {}
}

        GUIEditor.window[1] = guiCreateWindow(0.4, 0.3, 0.15, 0.29, "Choose your spawnpoint", true)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.gridlist[1] = guiCreateGridList(0.01, 0.04, 0.98, 0.75, true, GUIEditor.window[1])
        guiGridListAddColumn(GUIEditor.gridlist[1], "Spawn Position", 0.9)
        for i = 1, 5 do
            guiGridListAddRow(GUIEditor.gridlist[1])
        end
        guiGridListSetItemText(GUIEditor.gridlist[1], 0, 1, "Fraction", false, false)
        guiGridListSetItemText(GUIEditor.gridlist[1], 1, 1, "Proximity", false, false)
        guiGridListSetItemText(GUIEditor.gridlist[1], 2, 1, "Zombie", false, false)
        guiGridListSetItemText(GUIEditor.gridlist[1], 3, 1, "Zone 51", false, false)
		guiGridListSetItemText(GUIEditor.gridlist[1], 4, 1, "Organization", false, false)
        GUIEditor.button[1] = guiCreateButton(0.35, 0.83, 0.35, 0.22, "Spawn", true, GUIEditor.window[1])

		showCursor(true)

		function buttonActive()
				if (guiGridListGetItemText ( GUIEditor.gridlist[1], guiGridListGetSelectedItem ( GUIEditor.gridlist[1] ), 1 ) == "Fraction") then
					showCursor(false)
					destroyElement(GUIEditor.window[1])
					triggerEvent("server:login", localPlayer, localPlayer)
				elseif (guiGridListGetItemText ( GUIEditor.gridlist[1], guiGridListGetSelectedItem ( GUIEditor.gridlist[1] ), 1 ) == "Proximity") then
					triggerServerEvent("spawn:proximitySpawn", localPlayer, localPlayer)
					showCursor(false)
					destroyElement(GUIEditor.window[1])
				elseif (guiGridListGetItemText ( GUIEditor.gridlist[1], guiGridListGetSelectedItem ( GUIEditor.gridlist[1] ), 1 ) == "Zombie") then
					triggerEvent("server:login", localPlayer, localPlayer)
					showCursor(false)
					destroyElement(GUIEditor.window[1])
				elseif (guiGridListGetItemText ( GUIEditor.gridlist[1], guiGridListGetSelectedItem ( GUIEditor.gridlist[1] ), 1 ) == "Zone 51") then
					triggerServerEvent("spawn:spawnOnArea51", localPlayer, localPlayer)
					showCursor(false)
					destroyElement(GUIEditor.window[1])
				elseif (guiGridListGetItemText ( GUIEditor.gridlist[1], guiGridListGetSelectedItem ( GUIEditor.gridlist[1] ), 1 ) == "Organization") then
					triggerServerEvent("spawn:spawnOrganization", localPlayer, localPlayer)
					showCursor(false)
					destroyElement(GUIEditor.window[1])
				end
		end
		addEventHandler("onClientGUIClick", GUIEditor.button[1], buttonActive)
end
-- Deaths are handled by the server with a deterministic Zone 51 respawn.


function onSkinCHOOSE(x,y,z)
GUIEditor = {
    button = {},
    window = {}
}
		setElementData(localPlayer,"ped_sk", 287)
		ped = createPed ( 287 ,209.99260, 1857.59875, 13.14063,-40 )
		screenWidth, screenHeight = guiGetScreenSize ( )


        GUIEditor.window[1] = guiCreateWindow((screenWidth/2)-344/2,screenHeight-69, 344, 69, "Zombie Survival RPG", false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.button[1] = guiCreateButton(9, 30, 60, 29, "<<", false, GUIEditor.window[1])
        GUIEditor.button[2] = guiCreateButton(275, 30, 59, 29, ">>", false, GUIEditor.window[1])
        GUIEditor.button[3] = guiCreateButton(119, 29, 102, 30, "Choose skin", false, GUIEditor.window[1])

		showCursor(true)

		fadeCamera (true)
		setCameraTarget (209.99260, 1857.59875, 13.14063)
		setCameraMatrix(211.99260, 1862.59875, 13.14063,209.99260, 1857.59875, 13.14063)

		if getElementData(localPlayer,"player:acc_fraction") then
			if (getElementData(localPlayer,"player:acc_fraction") == "military") then
				skinModels = {73,61,285,287}
			elseif (getElementData(localPlayer,"player:acc_fraction") == "survivers") then
				skinModels = {46,48,49,70,71}
			elseif (getElementData(localPlayer,"player:acc_fraction") == "superHumans") then
				skinModels = {29,47}
			end
		else
			skinModels = {1,7,14,15,23,24,26}
		end


		state = 1

		function onSkinChangeLEFT()
			if state > 1 then
			state = state - 1
			skinModel = tonumber(skinModels[state])
			setElementModel(ped, skinModel)
			end
		end
		addEventHandler("onClientGUIClick",GUIEditor.button[1],onSkinChangeLEFT,false)

		function onSkinChangeRIGHT()
		if state < #skinModels then
			state = state + 1
			skinModel = tonumber(skinModels[state])
			setElementModel(ped, skinModel)
			end
		end
		addEventHandler("onClientGUIClick",GUIEditor.button[2],onSkinChangeRIGHT,false)

		function onSkinSelect()
				destroyElement(GUIEditor.window[1])
				showCursor(false)
				triggerServerEvent("on_skin_choosed",localPlayer,x,y,z,getElementModel(ped))
				destroyElement(ped)
		end
		addEventHandler("onClientGUIClick",GUIEditor.button[3],onSkinSelect,false)
end
addEvent("on_skin_choose",true)
addEventHandler("on_skin_choose",getRootElement(),onSkinCHOOSE)


local vehicleShopWindow
local vehicleShopGrid

local function closeVehicleShop()
	if isElement(vehicleShopWindow) then
		destroyElement(vehicleShopWindow)
	end
	vehicleShopWindow = nil
	vehicleShopGrid = nil
	showCursor(false)
end

function onVehicleShopCreate()
	if isPedInVehicle(localPlayer) then
		outputChatBox("[Vehicle] Leave your current vehicle to use the shop.", 255, 218, 121)
		return
	end

	if isElement(vehicleShopWindow) then
		guiBringToFront(vehicleShopWindow)
		showCursor(true)
		return
	end

	local screenWidth, screenHeight = guiGetScreenSize()
	vehicleShopWindow = guiCreateWindow((screenWidth - 330) / 2, (screenHeight - 460) / 2, 330, 460, "Zombie RPG - Vehicle Shop", false)
	guiWindowSetSizable(vehicleShopWindow, false)
	vehicleShopGrid = guiCreateGridList(12, 30, 306, 365, false, vehicleShopWindow)
	guiGridListAddColumn(vehicleShopGrid, "Vehicle", 0.62)
	guiGridListAddColumn(vehicleShopGrid, "Price", 0.28)

	local cars = {{579,1500},{400,3500},{404,4500},{489,5500},{505,6000},{479,7000},{442,7100},{458,8200},{602,9800},{496,12000},{401,41000}}
	for _, vehicleData in ipairs(cars) do
		local row = guiGridListAddRow(vehicleShopGrid)
		guiGridListSetItemText(vehicleShopGrid, row, 1, getVehicleNameFromModel(vehicleData[1]), false, false)
		guiGridListSetItemText(vehicleShopGrid, row, 2, "$" .. vehicleData[2], false, true)
		guiGridListSetItemData(vehicleShopGrid, row, 1, vehicleData[1])
	end

	local buyButton = guiCreateButton(12, 407, 145, 40, "Buy selected", false, vehicleShopWindow)
	local closeButton = guiCreateButton(173, 407, 145, 40, "Close", false, vehicleShopWindow)
	addEventHandler("onClientGUIClick", closeButton, closeVehicleShop, false)
	addEventHandler("onClientGUIClick", buyButton, function()
		local row = guiGridListGetSelectedItem(vehicleShopGrid)
		if row == -1 then
			outputChatBox("[Vehicle] Select a vehicle first.", 255, 218, 121)
			return
		end

		local model = tonumber(guiGridListGetItemData(vehicleShopGrid, row, 1))
		if model then
			triggerServerEvent("trigger_buy_car", localPlayer, model)
			closeVehicleShop()
		end
	end, false)
	showCursor(true)
end
addEvent("on_marker_client_hit",true)
addEventHandler ( "on_marker_client_hit", getRootElement(),onVehicleShopCreate )


function fileWriteNewCars_gov()
	local x,y,z = getElementPosition(localPlayer)
	local r1,r2,r3 = getElementRotation(localPlayer)
	local vehicle = getPedOccupiedVehicle (localPlayer)
	local ID = getElementModel (vehicle)
	outputChatBox("veh = createVehicle("..ID..","..x..","..y..","..z..","..r1..","..r2..","..r3..")")
end
addCommandHandler("agov",fileWriteNewCars_gov)


function openWeaponCraftMenu(materials)
GUIEditor = {
    gridlist = {},
    window = {},
    button = {}
}
if GUIEditor.window[1] then
guiSetVisible(GUIEditor.window[1],true)
showCursor(true)
else
		screenWidth, screenHeight = guiGetScreenSize ( )
        GUIEditor.window[1] = guiCreateWindow(screenWidth/3, screenHeight/3, 261, 354, "Craft menu", false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.gridlist[1] = guiCreateGridList(10, 31, 241, 275, false, GUIEditor.window[1])
        guiGridListAddColumn(GUIEditor.gridlist[1], "Weapon:", 0.5)
        guiGridListAddColumn(GUIEditor.gridlist[1], "Price[for 30 ammo]", 0.5)
        guiGridListAddRow(GUIEditor.gridlist[1])
        GUIEditor.button[1] = guiCreateButton(10, 318, 83, 26, "Craft", false, GUIEditor.window[1])
        GUIEditor.button[2] = guiCreateButton(172, 318, 74, 26, "Exit", false, GUIEditor.window[1])

		showCursor(true)

		local weapons = {{4,15},{9,20},{22,25},{23,25},{24,35},{25,50},{29,50},{30,60},{31,65},{34,70},{35,100}}

		for i,v in ipairs (weapons) do
		local weaponName = getWeaponNameFromID (v[1])
		local row = guiGridListAddRow (GUIEditor.gridlist[1])
		guiGridListSetItemText (GUIEditor.gridlist[1], row, 1, weaponName, false, true)
		guiGridListSetItemText (GUIEditor.gridlist[1], row, 2, tostring(v[2]), false, true)
		end

		function closeMenu()
			guiSetVisible(GUIEditor.window[1],false)
			showCursor(false)
		end
		addEventHandler("onClientGUIClick",GUIEditor.button[2],closeMenu)

		function OnBuyButtonClicked ()
		    if (guiGridListGetSelectedItem (GUIEditor.gridlist[1])) then
			local WeaponName = guiGridListGetItemText (GUIEditor.gridlist[1], guiGridListGetSelectedItem (GUIEditor.gridlist[1]), 1)
			local WeaponCost = guiGridListGetItemText (GUIEditor.gridlist[1], guiGridListGetSelectedItem (GUIEditor.gridlist[1]), 2)
			triggerServerEvent ("trigger_craft_weapon", localPlayer, WeaponName, tonumber(WeaponCost))
			guiSetVisible(GUIEditor.window[1],false)
			showCursor(false)
			end
		end
		addEventHandler("onClientGUIClick",GUIEditor.button[1],OnBuyButtonClicked)
	end
end
addEvent("open_menu_craft",true)
addEventHandler("open_menu_craft",getRootElement(),openWeaponCraftMenu)


local personalVehicleWindow

local function closePersonalVehicleMenu()
	if isElement(personalVehicleWindow) then
		destroyElement(personalVehicleWindow)
	end
	personalVehicleWindow = nil
	showCursor(false)
end

function onVehicleMenu(model, spawned)
	closePersonalVehicleMenu()
	local screenWidth, screenHeight = guiGetScreenSize()
	personalVehicleWindow = guiCreateWindow((screenWidth - 320) / 2, (screenHeight - 150) / 2, 320, 150, "Personal Vehicle", false)
	guiWindowSetSizable(personalVehicleWindow, false)
	guiCreateLabel(14, 30, 292, 24, getVehicleNameFromModel(tonumber(model)) or "Owned vehicle", false, personalVehicleWindow)

	local spawnButton = guiCreateButton(14, 66, 92, 38, spawned and "Respawn" or "Spawn", false, personalVehicleWindow)
	local destroyButton = guiCreateButton(114, 66, 92, 38, "Remove", false, personalVehicleWindow)
	local closeButton = guiCreateButton(214, 66, 92, 38, "Close", false, personalVehicleWindow)
	guiSetEnabled(destroyButton, spawned == true)

	addEventHandler("onClientGUIClick", spawnButton, function()
		triggerServerEvent("player:vehicle_spawn", localPlayer)
		closePersonalVehicleMenu()
	end, false)
	addEventHandler("onClientGUIClick", destroyButton, function()
		triggerServerEvent("player:vehicle_destroy", localPlayer)
		closePersonalVehicleMenu()
	end, false)
	addEventHandler("onClientGUIClick", closeButton, closePersonalVehicleMenu, false)
	showCursor(true)
end
addEvent("vehicle:menu",true)
addEventHandler ( "vehicle:menu", getRootElement(),onVehicleMenu )

addEventHandler("onClientRender", getRootElement(), function()

for k,player in ipairs(getElementsByType("player")) do

if getElementHealth(player) >= 1 then

local width, height = guiGetScreenSize ()

local lx, ly, lz = getWorldFromScreenPosition ( width/2, height/2, 10 )

setPedLookAt(player, lx, ly, lz)

end

end

end)

function onSkladMenuOpen (ammo,medkit)
GUIEditor = {
    tab = {},
    tabpanel = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {}
}

if GUIEditor.window[1] then
guiSetVisible(GUIEditor.window[1],true)
showCursor(true)
else

		sWidth,sHeight = guiGetScreenSize()

        GUIEditor.window[1] = guiCreateWindow(sWidth/3,sHeight/3, 260, 326, "", false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.tabpanel[1] = guiCreateTabPanel(10, 23, 239, 262, false, GUIEditor.window[1])

        GUIEditor.tab[1] = guiCreateTab("Sell", GUIEditor.tabpanel[1])

        GUIEditor.label[1] = guiCreateLabel(72, 10, 172, 15, "Your resources", false, GUIEditor.tab[1])
        guiLabelSetColor(GUIEditor.label[1], 41, 247, 7)
        GUIEditor.label[2] = guiCreateLabel(4, 27, 235, 15, "__________________________________________", false, GUIEditor.tab[1])
        GUIEditor.edit[1] = guiCreateEdit(81, 51, 71, 19, "", false, GUIEditor.tab[1])
        GUIEditor.label[3] = guiCreateLabel(10, 52, 81, 18, "GUN AMMO:", false, GUIEditor.tab[1])
        GUIEditor.button[1] = guiCreateButton(164, 52, 65, 18, "Sell", false, GUIEditor.tab[1])
        GUIEditor.label[4] = guiCreateLabel(10, 92, 40, 16, "Medkit", false, GUIEditor.tab[1])
        GUIEditor.button[2] = guiCreateButton(165, 95, 65, 18, "Sell", false, GUIEditor.tab[1])
        GUIEditor.edit[2] = guiCreateEdit(83, 146, 71, 20, "", false, GUIEditor.tab[1])
        GUIEditor.label[5] = guiCreateLabel(10, 146, 93, 15, "Veh elem.", false, GUIEditor.tab[1])
        GUIEditor.button[3] = guiCreateButton(165, 148, 64, 18, "Sell", false, GUIEditor.tab[1])
        GUIEditor.label[6] = guiCreateLabel(0, 187, 239, 15, "_________________________________________", false, GUIEditor.tab[1])

        GUIEditor.tab[2] = guiCreateTab("Buy", GUIEditor.tabpanel[1])

		GUIEditor.gridlist[1] = guiCreateGridList(23, 35, 194, 167, false, GUIEditor.tab[2])
        guiGridListAddColumn(GUIEditor.gridlist[1], "Goods", 0.5)
        guiGridListAddColumn(GUIEditor.gridlist[1], "Price", 0.5)
        GUIEditor.button[5] = guiCreateButton(62, 210, 110, 18, "Buy", false, GUIEditor.tab[2])


        GUIEditor.button[4] = guiCreateButton(147, 294, 96, 22, "Exit", false, GUIEditor.window[1])

		showCursor(true)

		guiSetText ( GUIEditor.edit[1],ammo )

		function startExitFromThisMenu()
			guiSetVisible(GUIEditor.window[1],false)
			showCursor(false)
		end
		addEventHandler("onClientGUIClick", GUIEditor.button[4],startExitFromThisMenu)

		function selluserammo()
			if ammo >= 1 then
				triggerServerEvent("shop:sellmaterials",localPlayer,guiGetText(GUIEditor.edit[1]))
				guiSetVisible(GUIEditor.window[1],false)
				showCursor(false)
			else
				outputChatBox("Не достаточно материалов!")
			end
		end
		addEventHandler("onClientGUIClick",GUIEditor.button[1],selluserammo,false)

		function sellusermedkit()
			if medkit == 1 then
				triggerServerEvent("shop:sellmedkit",localPlayer)
				guiSetVisible(GUIEditor.window[1],false)
				showCursor(false)
			else
				outputChatBox("У вас нет аптечки!")
			end
		end
		addEventHandler("onClientGUIClick",GUIEditor.button[2],sellusermedkit,false)

		local guns_to_sell = {{22,200},{16,350},{17,550},{30,800}}

		for i,v in ipairs (guns_to_sell) do
		local weaponName = getWeaponNameFromID (v[1])
		local row = guiGridListAddRow (GUIEditor.gridlist[1])
		guiGridListSetItemText (GUIEditor.gridlist[1], row, 1, weaponName, false, true)
		guiGridListSetItemText (GUIEditor.gridlist[1], row, 2, tostring(v[2]), false, true)
		end

		function OnBuyButtonClicked ()
		    if (guiGridListGetSelectedItem (GUIEditor.gridlist[1])) then
			local WeaponName = guiGridListGetItemText (GUIEditor.gridlist[1], guiGridListGetSelectedItem (GUIEditor.gridlist[1]), 1)
			local WeaponCost = guiGridListGetItemText (GUIEditor.gridlist[1], guiGridListGetSelectedItem (GUIEditor.gridlist[1]), 2)
			triggerServerEvent ("trigger_sklad_buy_goods", localPlayer,localPlayer, WeaponName, tonumber(WeaponCost))
			guiSetVisible(GUIEditor.window[1],false)
			showCursor(false)
			end
		end
		addEventHandler("onClientGUIClick",GUIEditor.button[5],OnBuyButtonClicked,false)
	end
end
addEvent("open:sklad_menu",true)
addEventHandler("open:sklad_menu",getRootElement(getThisResource()),onSkladMenuOpen)

function onMissionWasCalled(level)
if not getElementData(localPlayer,"is_mission_compiting") then
GUIEditor = {
    gridlist = {},
    window = {},
    button = {}
}
        GUIEditor.window[1] = guiCreateWindow(371, 201, 308, 411, "Missions[Zombie Survival RPG]", false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.gridlist[1] = guiCreateGridList(40, 25, 230, 324, false, GUIEditor.window[1])
        guiGridListAddColumn(GUIEditor.gridlist[1], "Mission", 0.9)
        for i = 1, 3 do
            guiGridListAddRow(GUIEditor.gridlist[1])
        end
        guiGridListSetItemText(GUIEditor.gridlist[1], 0, 1, "Transport[3 level]", false, false)
        guiGridListSetItemColor(GUIEditor.gridlist[1], 0, 1, 79, 251, 3, 255)
        guiGridListSetItemText(GUIEditor.gridlist[1], 1, 1, "Scouting[4 level]", false, false)
        guiGridListSetItemColor(GUIEditor.gridlist[1], 1, 1, 245, 253, 27, 255)
        guiGridListSetItemText(GUIEditor.gridlist[1], 2, 1, "Kill a 'Super Zombie' [5 level]", false, false)
        guiGridListSetItemColor(GUIEditor.gridlist[1], 2, 1, 254, 42, 25, 255)
        GUIEditor.button[1] = guiCreateButton(105, 363, 96, 32, "Ok", false, GUIEditor.window[1])
		showCursor(true)

		function onButtonWasClicked()
			if (guiGridListGetSelectedItem (GUIEditor.gridlist[1])) then
				local MissionName = guiGridListGetItemText(GUIEditor.gridlist[1], guiGridListGetSelectedItem (GUIEditor.gridlist[1]), 1)
				if (MissionName == "Transport[3 level]") then
					triggerServerEvent ("trigger_mission_first", localPlayer)
					triggerEvent("trigger_miss_first_client",localPlayer)
					destroyElement(GUIEditor.window[1])
					showCursor(false)
				elseif (MissionName == "Scouting[4 level]") then
					if (level >= 4) then
					triggerEvent("trigger_miss_secound_elements",localPlayer)
					destroyElement(GUIEditor.window[1])
					showCursor(false)
					else
					outputChatBox("Вы пока не можете взять данную миссию.")
					end
				else
					outputChatBox("Эта миссия не доступна!")
					destroyElement(GUIEditor.window[1])
					showCursor(false)
				end
				else
				destroyElement(GUIEditor.window[1])
				showCursor(false)
			end
		end
		addEventHandler("onClientGUIClick",GUIEditor.button[1],onButtonWasClicked,false)
		else
			outputChatBox("[ОШИБКА] Вы уже взяли миссию!")
		end
end
addEvent("marker:mission_user_call",true)
addEventHandler("marker:mission_user_call",getRootElement(getThisResource()),onMissionWasCalled)

function mission_first_event_triggered()
	local mission_pos = math.random(1,3)
	if (mission_pos == 1) then
		local Mission = createMarker (423.42151, 2536.49976,17.14844,"arrow", 1.2, 255, 255, 0, 50 )
		local blip = createBlipAttachedTo ( Mission, 41 )
		setElementData(localPlayer,"is_mission_compiting",true)
		triggerEvent("trigger:mission_hit_marker",localPlayer,Mission,blip)
	elseif (mission_pos == 2) then
		local Mission = createMarker (-1522.14587, 481.63043, 8.18750,"arrow", 1.2, 255, 255, 0, 50 )
		local blip = createBlipAttachedTo ( Mission, 41 )
		setElementData(localPlayer,"is_mission_compiting",true)
		triggerEvent("trigger:mission_hit_marker",localPlayer,Mission,blip)
	elseif (mission_pos == 3) then
		local Mission = createMarker (1865.36450, 2775.78052, 12.34375,"arrow", 1.2, 255, 255, 0, 50 )
		local blip = createBlipAttachedTo ( Mission, 41 )
		setElementData(localPlayer,"is_mission_compiting",true)
		triggerEvent("trigger:mission_hit_marker",localPlayer,Mission,blip)
	end
end
addEvent("trigger_miss_first_client",true)
addEventHandler("trigger_miss_first_client",getRootElement(getThisResource()),mission_first_event_triggered)

function mission_marker_complete_reguired(marker,blip)

	function onClientMarkerWillHit(player)
		removeEventHandler("onClientMarkerHit", marker, onClientMarkerWillHit)
		outputChatBox("Вы выполнили задание! Поздравляем!")
		destroyElement(marker)
		destroyElement(blip)
		triggerServerEvent("fist_mission_give_reward",localPlayer)
	end
	addEventHandler ("onClientMarkerHit", marker, onClientMarkerWillHit )
end
addEvent("trigger:mission_hit_marker",true)
addEventHandler("trigger:mission_hit_marker",getRootElement(getThisResource()),mission_marker_complete_reguired)

function missions_secound_element_starts()
	local Mission_start = createMarker (-2598.67334, 2266.33423, 9.21094,"arrow", 1.2, 255, 255, 0, 50 )
	local blip = createBlipAttachedTo ( Mission_start, 41 )

	function onClientMarkerWillHit(player)
		removeEventHandler("onClientMarkerHit", Mission_start, onClientMarkerWillHit)
		outputChatBox("Езжайте к следующей точке!")
		destroyElement(Mission_start)
		destroyElement(blip)
		triggerServerEvent("secound_mission_server_start",localPlayer)
		triggerEvent("secound_mission_client_start",localPlayer)
	end
	addEventHandler ("onClientMarkerHit", Mission_start, onClientMarkerWillHit )
end
addEvent("trigger_miss_secound_elements",true)
addEventHandler("trigger_miss_secound_elements",getRootElement(getThisResource()),missions_secound_element_starts)

function missions_secound_continue_1()
	local Mission_mark1 = createMarker (2333.09229, 61.57598 ,27.70579,"arrow", 1.2, 255, 255, 0, 50 )
	local Mission_mark2 = createMarker (378.19397, -113.70730, 1001.49219,"arrow", 1.2, 255, 255, 0, 50 )
	local blip = createBlipAttachedTo ( Mission_mark1, 41 )

	function onClientMarkerWillHit(player)
		setElementPosition (localPlayer, 369.06158, -114.57669, 1001.49951 )
		setElementInterior (localPlayer, 5 )
		setElementDimension(localPlayer, 1 )
	end
	addEventHandler ("onClientMarkerHit", Mission_mark1, onClientMarkerWillHit )

	function onClientMarker2WillHit(player)
		outputChatBox("Вы взяли ресурсы. Отвезите их обратно на базу!")
		destroyElement(Mission_mark2)
		removeEventHandler("onClientMarkerHit", Mission_mark2, onClientMarker2WillHit)
		local mission_exit = createMarker(372.34970, -133.52217, 1002.49219,"arrow", 1.2, 255, 255, 0, 50 )
		setElementInterior (mission_exit, 5 )
		setElementDimension(mission_exit, 1 )

		function onMarkerWasHit()
			removeEventHandler("onClientMarkerHit", Mission_mark1, onClientMarkerWillHit)
			removeEventHandler("onClientMarkerHit", Mission_mark2, onClientMarker2WillHit)
			removeEventHandler("onClientMarkerHit", mission_exit, onMarkerWasHit)
			destroyElement(Mission_mark1)
			destroyElement(blip)
			destroyElement(mission_exit)

			setElementPosition(localPlayer,2335.68408, 74.89070, 26.48230)
			setElementInterior (localPlayer, 0 )
			setElementDimension(localPlayer, 0 )
			local Mission = createMarker(-2488.46484, 2295.30884, 5.98438,"arrow", 1.2, 255, 255, 0, 50 )
			local blip = createBlipAttachedTo ( Mission, 41 )
			triggerEvent("mission_secound_soon_end",localPlayer,Mission,blip)
		end
		addEventHandler ("onClientMarkerHit", mission_exit,onMarkerWasHit)
	end
	addEventHandler ("onClientMarkerHit", Mission_mark2, onClientMarker2WillHit )
end
addEvent("secound_mission_client_start",true)
addEventHandler("secound_mission_client_start",getRootElement(getThisResource()),missions_secound_continue_1)


function mission_secound_start_to_end(marker,blip)

	function onClientMarkerWillHit(player)
		destroyElement(marker)
		destroyElement(blip)
		triggerServerEvent("give_reward_secound_mission",localPlayer)
	end
	addEventHandler ("onClientMarkerHit", marker, onClientMarkerWillHit )
end
addEvent("mission_secound_soon_end",true)
addEventHandler("mission_secound_soon_end",getRootElement(getThisResource()),mission_secound_start_to_end)



function openMenuCraftClient(vehicleParts,armorParts,bandagesParts)

GUIEditor = {
    tab = {},
    tabpanel = {},
    button = {},
    window = {},
    gridlist = {}
}
        GUIEditor.window[1] = guiCreateWindow(389, 246, 283, 400, "CRAFT MENU[Zombie Survival RPG]", false)
        guiWindowSetSizable(GUIEditor.window[1], false)

        GUIEditor.tabpanel[1] = guiCreateTabPanel(11, 29, 257, 321, false, GUIEditor.window[1])

        GUIEditor.tab[1] = guiCreateTab("Vehicles", GUIEditor.tabpanel[1])

        GUIEditor.gridlist[1] = guiCreateGridList(6, 8, 241, 236, false, GUIEditor.tab[1])
        guiGridListAddColumn(GUIEditor.gridlist[1], "Vehicles", 0.5)
        guiGridListAddColumn(GUIEditor.gridlist[1], "Materials", 0.5)
        GUIEditor.button[1] = guiCreateButton(71, 253, 110, 34, "Craft", false, GUIEditor.tab[1])

        GUIEditor.tab[2] = guiCreateTab("Armor", GUIEditor.tabpanel[1])

        GUIEditor.gridlist[2] = guiCreateGridList(5, 9, 247, 241, false, GUIEditor.tab[2])
        guiGridListAddColumn(GUIEditor.gridlist[2], "Armor Type", 0.5)
        guiGridListAddColumn(GUIEditor.gridlist[2], "Materials", 0.5)
        GUIEditor.button[2] = guiCreateButton(70, 257, 123, 30, "Craft", false, GUIEditor.tab[2])

        GUIEditor.tab[3] = guiCreateTab("Bandages", GUIEditor.tabpanel[1])

        GUIEditor.gridlist[3] = guiCreateGridList(4, 9, 248, 248, false, GUIEditor.tab[3])
        guiGridListAddColumn(GUIEditor.gridlist[3], "Craft Type", 0.5)
        guiGridListAddColumn(GUIEditor.gridlist[3], "Materials", 0.5)
        GUIEditor.button[3] = guiCreateButton(72, 262, 116, 25, "Craft", false, GUIEditor.tab[3])


        GUIEditor.button[4] = guiCreateButton(218, 364, 55, 26, "Exit", false, GUIEditor.window[1])

		showCursor(true)

		---- ELEMENTS ----

		local Vehicles = {{481,50},{509,50},{471,250},{572,400},{461,550}}
		local Armors   = {{25,25},{50,45},{75,65},{100,90}}
		local Bandages = {{1,15},{2,30},{3,45},{4,60},{5,70}}

		for i,v in ipairs (Vehicles) do
		local veh = getVehicleNameFromModel (v[1])
		local row = guiGridListAddRow (GUIEditor.gridlist[1])
		guiGridListSetItemText (GUIEditor.gridlist[1], row, 1, veh, false, true)
		guiGridListSetItemText (GUIEditor.gridlist[1], row, 2, tostring(v[2]), false, true)
		end

		for i,v in ipairs (Armors) do
		local row = guiGridListAddRow (GUIEditor.gridlist[2])
		guiGridListSetItemText (GUIEditor.gridlist[2], row, 1, tostring(v[1]), false, true)
		guiGridListSetItemText (GUIEditor.gridlist[2], row, 2, tostring(v[2]), false, true)
		end

		for i,v in ipairs (Bandages) do
		local row = guiGridListAddRow (GUIEditor.gridlist[3])
		guiGridListSetItemText (GUIEditor.gridlist[3], row, 1, tostring(v[1]), false, true)
		guiGridListSetItemText (GUIEditor.gridlist[3], row, 2, tostring(v[2]), false, true)
		end


		---- BUTTONS ----
		function onButtonVehiclesClicked()
			if (guiGridListGetSelectedItem (GUIEditor.gridlist[1])) then
				local VehicleName = guiGridListGetItemText (GUIEditor.gridlist[1], guiGridListGetSelectedItem (GUIEditor.gridlist[1]), 1)
				local VehicleCost = guiGridListGetItemText (GUIEditor.gridlist[1], guiGridListGetSelectedItem (GUIEditor.gridlist[1]), 2)
				if (tonumber(vehicleParts) >= tonumber(VehicleCost)) then
					local vehID	= getVehicleModelFromName (VehicleName)
					triggerServerEvent ("crafting_menu:vehicle", localPlayer, vehID, tonumber(VehicleCost))
					destroyElement(GUIEditor.window[1])
					showCursor(false)
				else
					outputChatBox("Не достаточно материалов!")
				end
			end
		end
		addEventHandler("onClientGUIClick", GUIEditor.button[1], onButtonVehiclesClicked, false)

		function onButtonArmorClicked()


		end
		addEventHandler("onClientGUIClick", GUIEditor.button[2], onButtonArmorClicked, false)

		function onButtonBandagesClicked()


		end
		addEventHandler("onClientGUIClick", GUIEditor.button[3], onButtonBandagesClicked, false)

		function onButtonExitClicked()
		destroyElement(GUIEditor.window[1])
		showCursor(false)
		end
		addEventHandler("onClientGUIClick", GUIEditor.button[4], onButtonExitClicked, false)



end
addEvent("open_craft_menu",true)
addEventHandler("open_craft_menu",getRootElement(getThisResource()),openMenuCraftClient)

g_loc_root = getRootElement ()


function shootProjectile()
if isPedInVehicle ( localPlayer ) then
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if (getElementModel (vehicle) == 601) then
		if(vehicle)then
			if getElementData(vehicle,"rocket_ammo") > 0 then

					local target = getPedTarget(localPlayer)
					local x, y, z = getElementPosition(vehicle)
					local w, h = guiGetScreenSize ()
					local x, y, z = getWorldFromScreenPosition ( w/2, h/2, 10 )
						local fire = createProjectile(vehicle,19,x,y,z,200,target)
						setElementData(vehicle,"rocket_ammo",getElementData(vehicle,"rocket_ammo")-1)
			else
				outputChatBox("Out of Ammo!")
			end
		end
	end
end
end

bindKey("mouse2", "down", shootProjectile)

function onCapacityGive(veh)
local vehicle = getPedOccupiedVehicle(localPlayer)
	if (getElementModel (vehicle) == 601) then
		setElementData(vehicle,"rocket_ammo",8)
	end
end
addEventHandler("onClientPlayerVehicleEnter",getRootElement(),onCapacityGive)
