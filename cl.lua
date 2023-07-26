ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(100)
	end
	while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)
	
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

ListJobServer, ListGradeServer = {}, {}

function RefreshJobServer()
	ESX.TriggerServerCallback("v3:server:listejobs", function(resultjob)
		ListJobServer = resultjob
	end)
end
function RefreshGradeServer(job)
	ESX.TriggerServerCallback('v3:server:getSocietyGrade', function(resultgrade)
		ListGradeServer = resultgrade
	end, job)
end


local ServersIdSession = {}
CreateThread(function()
    while true do
        Wait(500)
        for k,v in pairs(GetActivePlayers()) do
            local found = false
            for _,j in pairs(ServersIdSession) do
                if GetPlayerServerId(v) == j then
                    found = true
                end
            end
            if not found then
                table.insert(ServersIdSession, GetPlayerServerId(v))
            end
        end
    end
end)
local PlayerData = {}
local PlayerInventory, GangInventoryItem, GangInventoryWeapon, PlayerWeapon = {}, {}, {}, {}
local TempListJoueurs = {}
local Items = {}      -- Item que le joueur possède (se remplit lors d'une fouille)
local Armes = {}    -- Armes que le joueur possède (se remplit lors d'une fouille)
local ArgentSale = {}  -- Argent sale que le joueur possède (se remplit lors d'une fouille)
local ArgentBank = {}  -- Argent sale que le joueur possède (se remplit lors d'une fouille)
local function getPlayerInv(player)
	Items = {}
	Armes = {}
	ArgentSale = {}
	ArgentBank = {}

	ESX.TriggerServerCallback('jml:getOtherPlayerData', function(data)
	for i=1, #data.accounts, 1 do
		if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
			table.insert(ArgentSale, {
				label    = ESX.Math.Round(data.accounts[i].money),
				value    = 'black_money',
				itemType = 'item_account',
				amount   = data.accounts[i].money
			})

			break
		end
	end
	for i=1, #data.accounts, 1 do
		if data.accounts[i].name == 'bank' and data.accounts[i].money > 0 then
			table.insert(ArgentBank, {
				label    = ESX.Math.Round(data.accounts[i].money),
				value    = 'bank',
				itemType = 'item_account',
				amount   = data.accounts[i].money
			})

			break
		end
	end
		for i=1, #data.weapons, 1 do
			table.insert(Armes, {
				label    = ESX.GetWeaponLabel(data.weapons[i].name),
				value    = data.weapons[i].name,
				right    = data.weapons[i].ammo,
				itemType = 'item_weapon',
				amount   = data.weapons[i].ammo
			})
		end
		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(Items, {
					label    = data.inventory[i].label,
					right    = data.inventory[i].count,
					value    = data.inventory[i].name,
					itemType = 'item_standard',
					amount   = data.inventory[i].count
				})
			end
	end
	end, player)
end

InfosJobPlayer = {}

local function GetPlayerJob(player)
	ESX.TriggerServerCallback('jml:GetJobPlayerInfos', function(result)
		InfosJobPlayer = result
	end, player)
end

local playergroup = {}
actuelgroup = {}

reportlist = {}
reportselect = false

function getInfoReport() 
    local info = {} 
    ESX.TriggerServerCallback('Barwoz:infoReport', function(info) 
        reportlist = info 
    end) 
end

function RefreshPlayerGroup()
	ESX.TriggerServerCallback('getgroup', function(group)
		playergroup = group
	end)
end

--- Config du menu (nom menu, sous menu, couleur, text)
local ns = Config.NameServeur["Server_Name"]
local SelectedJob= {}
local List1 = 1
local List2 = 1

HMenu = {}

function LoadMenu()

	if playergroup == 'help' then
		actuelgroup = Config.MenuName[1]
	elseif playergroup == 'mod' then
		actuelgroup = Config.MenuName[2]
	elseif playergroup == 'admin' then
		actuelgroup = Config.MenuName[3]
	end

	HMenu.cm = actuelgroup.Couleur_Bouton
	cs1 = actuelgroup.Couleur_Ligne[1]
	cs2 = actuelgroup.Couleur_Ligne[2]
	cs3 = actuelgroup.Couleur_Ligne[3]
	cs4 = actuelgroup.Couleur_Ligne[4]
	TextOnService, TextNoClip, TextBlips, TextName, TextSprint, TextDelgun, labelfreez, TextFantome, TextNager, TextGodhelp ='Prendre son Service', 'Activer le '..HMenu.cm..'NoClip', 'Activer les '..HMenu.cm..'Blips', 'Activer les '..HMenu.cm..'Noms', 'Activer le '..HMenu.cm..'SuperSprint', 'Activer le '..HMenu.cm..'DelGun', 'Freeze~s~ le Joueur', 'Activer le '..HMenu.cm..'helpe Fantôme', 'Activer le '..HMenu.cm..'Sprint Nage', 'Activer l\''..HMenu.cm..'Invincibilité'

	local Title = actuelgroup.title
	HMenu.mod_menu = RageUI.CreateMenu(Title, Title)
	HMenu.action_menu = RageUI.CreateSubMenu(HMenu.mod_menu, "Action Personnel", Title)
	HMenu.joueur = RageUI.CreateSubMenu(HMenu.mod_menu, "Liste Joueurs", Title)
	HMenu.action_joueur = RageUI.CreateSubMenu(HMenu.joueur, "Action sur Joueurs", Title)
	HMenu.setjob_menu = RageUI.CreateSubMenu(HMenu.action_joueur, "SetJob Joueurs", Title)
	HMenu.inventaire_menu = RageUI.CreateSubMenu(HMenu.action_joueur, "Inventaire Joueurs", Title)
	HMenu.listejob_menu = RageUI.CreateSubMenu(HMenu.setjob_menu, "Grade Job Joueurs", Title)
	HMenu.gestionvoiture_menu = RageUI.CreateSubMenu(HMenu.mod_menu, "Gestion Voiture", Title)
	HMenu.gestionreport_menu = RageUI.CreateSubMenu(HMenu.mod_menu, "Gestion Report", Title)
	HMenu.inforeport = RageUI.CreateSubMenu(HMenu.gestionreport_menu, "Gestion Report", Title)

	HMenu.cbn1 = actuelgroup.Couleur_Banniere[1]
	HMenu.cbn2 = actuelgroup.Couleur_Banniere[2]
	HMenu.cbn3 = actuelgroup.Couleur_Banniere[3]
	HMenu.cbn4 = actuelgroup.Couleur_Banniere[4]

	HMenu.mod_menu:SetRectangleBanner(HMenu.cbn1, HMenu.cbn2, HMenu.cbn3, HMenu.cbn4)
	HMenu.action_menu:SetRectangleBanner(HMenu.cbn1, HMenu.cbn2, HMenu.cbn3, HMenu.cbn4)
	HMenu.joueur:SetRectangleBanner(HMenu.cbn1, HMenu.cbn2, HMenu.cbn3, HMenu.cbn4)
	HMenu.action_joueur:SetRectangleBanner(HMenu.cbn1, HMenu.cbn2, HMenu.cbn3, HMenu.cbn4)
	HMenu.setjob_menu:SetRectangleBanner(HMenu.cbn1, HMenu.cbn2, HMenu.cbn3, HMenu.cbn4)
	HMenu.inventaire_menu:SetRectangleBanner(HMenu.cbn1, HMenu.cbn2, HMenu.cbn3, HMenu.cbn4)
	HMenu.listejob_menu:SetRectangleBanner(HMenu.cbn1, HMenu.cbn2, HMenu.cbn3, HMenu.cbn4)
	HMenu.gestionvoiture_menu:SetRectangleBanner(HMenu.cbn1, HMenu.cbn2, HMenu.cbn3, HMenu.cbn4)
	HMenu.gestionreport_menu:SetRectangleBanner(HMenu.cbn1, HMenu.cbn2, HMenu.cbn3, HMenu.cbn4)
	HMenu.inforeport:SetRectangleBanner(HMenu.cbn1, HMenu.cbn2, HMenu.cbn3, HMenu.cbn4)

	HMenu.PedId = actuelgroup.Pedhelpel

	HMenu.mod_menu.Closed = function()
		isMenuOpen = false
	end
end

----- Fin config couleur et menu

local noclip = false
local noclip_speed = 5.0

local isMenuOpen = false
local cooldown = false

players = {}
	for _, player in pairs(GetActivePlayers()) do
	local ped = GetPlayerPed(player)
	table.insert(players, player)
end

local function Menu_mod()
	RefreshPlayerGroup()
	LoadMenu()
	while actuelgroup == nil do
		Wait(1) 
		return
	end
	while HMenu == {} do 
		Wait(1)
		return
	end

	local Style = { 
		Line = { cs1, cs2, cs3, cs4} 
	}
	local newsStyle = Style

	if playergroup == "admin" or playergroup == "mod" or playergroup == "help" then
		if isMenuOpen then
			isMenuOpen = false
			RageUI.Visible(HMenu.mod_menu, false)
		else
			isMenuOpen = true
			RageUI.Visible(HMenu.mod_menu, true)

			local SelectedPlayer = {
				name = {},
				label = {},
			}

			getInfoReport()

			CreateThread(function()
				while isMenuOpen do
					RageUI.IsVisible(HMenu.mod_menu, function()
						RageUI.Line(newsStyle)
						RageUI.Separator('Votre Steam : ~h~'..HMenu.cm..GetPlayerName(PlayerId()))
						RageUI.Separator('Votre ID : ~h~'..HMenu.cm..GetPlayerServerId(PlayerId()))
						RageUI.Separator('Votre Grade : ~h~'..HMenu.cm..playergroup)
						RageUI.Separator('Joueurs connectés : ~h~'..HMenu.cm..#players..'~s~/64')
						RageUI.Line(newsStyle)
						RageUI.Checkbox(TextOnService, nil, onService, {}, {
							onChecked = function() 
								TextOnService = '~r~Quitter son service'
								onService = true
								SetPed(HMenu.PedId)
							end,
							onUnChecked = function()
								TextOnService = 'Prendre son service'
								onService = false
								getBaseSkin()
							end
						})
						RageUI.Line(newsStyle)
						if onService == true then
							RageUI.Button('Action Personnel', nil, {RightLabel = HMenu.cm.."→→"}, true, {}, HMenu.action_menu)
							RageUI.Button('Gestion Voiture', nil, {RightLabel = HMenu.cm.."→→"}, true, {}, HMenu.gestionvoiture_menu)
							RageUI.Button('Liste Joueurs', nil, {RightLabel = HMenu.cm.."→→"}, true, {}, HMenu.joueur)
							RageUI.Line(newsStyle)
							RageUI.Button('Gestion Report', nil, {RightLabel = HMenu.cm.."→→"}, true, {
								onSelected = function()
									getInfoReport()
								end
							}, HMenu.gestionreport_menu)
							RageUI.Line(newsStyle)
						end	
					end)

					RageUI.IsVisible(HMenu.action_menu, function()
						RageUI.Line(newsStyle)
						RageUI.Separator('Votre Steam : ~h~'..HMenu.cm..GetPlayerName(PlayerId()))
						RageUI.Separator('Votre ID : ~h~'..HMenu.cm..GetPlayerServerId(PlayerId()))
						RageUI.Separator('Votre Grade : ~h~'..HMenu.cm..playergroup)
						RageUI.Separator('Joueurs connectés : ~h~'..HMenu.cm..#players..'~s~/64')
						RageUI.Line(newsStyle)	
						RageUI.Checkbox(TextNoClip, nil, onNoclip, {}, {
							onChecked = function() 
								TextNoClip = '~r~Désactiver le NoClip'
								onNoclip = true
								news_no_clip()
								ESX.ShowNotification('Vous venez ~b~d\'activer~s~ le ~r~NoClip~s~ de ~b~'..ns..'~s~ !')
							end,
							onUnChecked = function()
								TextNoClip = 'Activer le '..HMenu.cm..'NoClip'
								onNoclip = false
								news_no_clip()
								ESX.ShowNotification('Vous venez ~b~désactiver~s~ le ~r~NoClip~s~ de ~b~'..ns..'~s~ !')
							end
						})
						if playergroup == "mod" or playergroup == "admin" then
						RageUI.Checkbox(TextSprint, nil, onSprint, {}, {
							onChecked = function() 
								TextSprint = '~r~Désactiver le SuperSprint'
								onSprint = true
								SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
								ESX.ShowNotification('Vous venez ~b~d\'activer~s~ le ~r~Super Sprint~s~ de ~b~'..ns..'~s~ !')
							end,
							onUnChecked = function()
								TextSprint = 'Activer le '..HMenu.cm..'SuperSprint'
								onSprint = false
								SetRunSprintMultiplierForPlayer(PlayerId(), 1.00)
								ESX.ShowNotification('Vous venez de ~b~désactiver~s~ le ~r~Super Sprint~s~ de ~b~'..ns..'~s~ !')
							end
						})
						RageUI.Checkbox(TextDelgun, nil, onDelgun, {}, {
							onChecked = function() 
								TextDelgun = '~r~Désactiver le Delgun'
								onDelgun = true
								ExecuteCommand("delgun")
								ESX.ShowNotification('Vous venez ~b~d\'activer~s~ le ~r~DelGun~s~ de ~b~'..ns..'~s~ !')
							end,
							onUnChecked = function()
								TextDelgun = 'Activer le '..HMenu.cm..'Delgun'
								onDelgun = false
								ExecuteCommand("delgun")
								ESX.ShowNotification('Vous venez de ~b~désactiver~s~ le ~r~DelGun~s~ de ~b~'..ns..'~s~ !')
							end
						})
						RageUI.Checkbox(TextFantome, nil, onFantome, {}, {
							onChecked = function() 
								TextFantome = '~r~Désactiver le helpe Fantôme'
								onFantome = true
								SetEntityVisible(PlayerPedId(), false, false)
								ESX.ShowNotification('Vous venez ~b~d\'activer~s~ le ~r~helpe Fantôme~s~ de ~b~'..ns..'~s~ !')
							end,
							onUnChecked = function()
								TextFantome = 'Activer le '..HMenu.cm..'helpe Fantôme'
								onFantome = false
								SetEntityVisible(PlayerPedId(), true, false)
								ESX.ShowNotification('Vous venez de ~b~désactiver ~s~ le ~r~helpe Fantôme~s~ de ~b~'..ns..'~s~ !')
							end
						})

						RageUI.Checkbox(TextNager, nil, onNage, {}, {
							onChecked = function() 
								TextNager = '~r~Désactiver le Sprint Nage'
								onNage = true
								SetSwimMultiplierForPlayer(PlayerId(), 1.49)
								ESX.ShowNotification('Vous venez ~b~d\'activer~s~ le ~r~Sprint Nage~s~ de ~b~'..ns..'~s~ !')
							end,
							onUnChecked = function()
								TextNager = 'Activer le '..HMenu.cm..'Sprint Nage'
								onNage = false
								SetSwimMultiplierForPlayer(PlayerId(), 1.0)
								ESX.ShowNotification('Vous venez de ~b~désactiver ~s~ le ~r~Sprint Nage~s~ de ~b~'..ns..'~s~ !')
							end
						})

						RageUI.Checkbox(TextGodhelp, nil, onGodhelp, {}, {
							onChecked = function() 
								TextGodhelp = '~r~Désactiver l\'Invincibilité'
								onGodhelp = true
								SetEntityInvincible(PlayerPedId(), true)
								ESX.ShowNotification('Vous venez ~b~d\'activer~s~ l\'~r~Invincibilité~s~ de ~b~'..ns..'~s~ !')
							end,
							onUnChecked = function()
								TextGodhelp = 'Activer l\''..HMenu.cm..'Invincibilité'
								onGodhelp = false
								SetEntityInvincible(PlayerPedId(), false)
								ESX.ShowNotification('Vous venez de ~b~désactiver ~s~ l\'~r~Invincibilité~s~ de ~b~'..ns..'~s~ !')
							end
						})
					end

						RageUI.Button("Se donnez de la "..HMenu.cm.."Vie", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								SetEntityHealth(GetPlayerPed(-1), 200)
								ESX.ShowNotification('Vous venez de ~b~vous ~r~donnez de la vie~s~ sur ~b~'..ns..'~s~ !')
							end
						})

						RageUI.Button("Se donnez de la "..HMenu.cm.."Bouffe", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								TriggerEvent('esx_status:set', 'hunger', 1000000)
                    			TriggerEvent('esx_status:set', 'thirst', 1000000)
								ESX.ShowNotification('Vous venez de ~b~vous ~r~donnez de la bouffe~s~ sur ~b~'..ns..'~s~ !')
							end
						})

						RageUI.Button("Se téléporté sur le "..HMenu.cm.."Point", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								TeleportToWaypoint()
							end
						})

						RageUI.Button("Se "..HMenu.cm.."Revive", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								ExecuteCommand("revive")
							end
						})

						





						RageUI.Line(newsStyle)
						if playergroup == "mod" or playergroup == "admin" then
							RageUI.Checkbox(TextBlips, nil, onBlips, {}, {
								onChecked = function() 
									TextBlips = '~r~Désactiver les Blips'
									onBlips = true
									ESX.ShowNotification('Vous venez ~b~d\'activer~s~ les ~r~Blips des joueurs~s~ de ~b~'..ns..'~s~ !')
								end,
								onUnChecked = function()
									TextBlips = 'Activer les Blips'
									onBlips = false
									ESX.ShowNotification('Vous venez de ~b~désactiver ~s~ les ~r~Blips des joueurs~s~ de ~b~'..ns..'~s~ !')
								end
							})
						end
						RageUI.Checkbox(TextName, nil, onName, {}, {
							onChecked = function() 
								TextName = '~r~Désactiver les Noms'
								onName = true
								showNames(true)
								ESX.ShowNotification('Vous venez ~b~d\'activer~s~ les ~r~Noms des joueurs~s~ de ~b~'..ns..'~s~ !')
							end,
							onUnChecked = function()
								TextName = 'Activer les Noms'
								onName = false
								showNames(false)
								ESX.ShowNotification('Vous venez de ~b~désactiver ~s~ les ~r~Noms des joueurs~s~ de ~b~'..ns..'~s~ !')
							end
						})
						RageUI.Line(newsStyle)
					end)



					RageUI.IsVisible(HMenu.joueur, function()
	
						RageUI.Line(newsStyle)
						RageUI.Separator('Votre Steam : ~h~'..HMenu.cm..GetPlayerName(PlayerId()))
						RageUI.Separator('Votre ID : ~h~'..HMenu.cm..GetPlayerServerId(PlayerId()))
						RageUI.Separator('Votre Grade : ~h~'..HMenu.cm..playergroup)
						RageUI.Separator('Joueurs connectés : ~h~'..HMenu.cm..#players..'~s~/64')
						RageUI.Line(newsStyle)
						RageUI.Button("Rechercher un "..HMenu.cm.."ID",nil,{RightLabel = HMenu.cm.."→→"},true, {
							onSelected = function()
								filterid = KeyboardInput('Entrez un '..HMenu.cm..'ID~s~ (ENTRER pour tout remettre)', (''), '', 100)
								if filterid == "" then
								 ESX.ShowNotification("~r~modistration~s~ de "..HMenu.cm..ns.."~s~\nVeuillez indiquer une ~b~Valeur~s~ !")
								else
									if filterid == nil then
									  ESX.ShowNotification("~r~modistration~s~ de "..HMenu.cm..ns.."~s~\nVeuillez indiquer une ~b~Valeur~s~ !")
								   
									else
									  ESX.ShowNotification("~r~modistration~s~ de "..HMenu.cm..ns.."~s~\nVous avez chercher l'id  ~b~"..filterid.." ~s~!")
									end
								end
							end
					   })
	
					   RageUI.Line(newsStyle)

						for k,v in ipairs(ServersIdSession) do
							if GetPlayerName(GetPlayerFromServerId(v)) == "**Invalid**" then table.remove(ServersIdSession, k) end
							if filterid == nil or string.find(v,filterid) then
								RageUI.Button("["..HMenu.cm..v.. "~s~] "..GetPlayerName(GetPlayerFromServerId(v)), nil, {RightLabel = HMenu.cm.."→→"}, true, {
									onSelected = function ()
										IdSelected = v
									end
								},HMenu.action_joueur);
							end
						end
						RageUI.Line(newsStyle)
					end)


					RageUI.IsVisible(HMenu.action_joueur, function()

						RageUI.Line(newsStyle)
						RageUI.Separator('Joueurs connectés : ~h~'..HMenu.cm..#players..'~s~/64')
						RageUI.Separator("Nom : "..HMenu.cm..GetPlayerName(GetPlayerFromServerId(IdSelected)).. "~s~ | ID : "..HMenu.cm..tostring(IdSelected).."~s~")
						RageUI.Line(newsStyle)
						RageUI.Button('Se téléporter sur lui', nil , {RightLabel = HMenu.cm.."→→"}, true , {
							onSelected = function ()
								SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(IdSelected))))
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nTéléportation sur ~b~".. GetPlayerName(GetPlayerFromServerId(IdSelected)).. "~s~ effectué !")
							end
						})
	
						RageUI.Button('Téléporter sur moi', nil , {RightLabel = HMenu.cm.."→→"}, true , {
							onSelected = function ()
								ExecuteCommand('bring '..IdSelected)
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nTéléportation de ~b~".. GetPlayerName(GetPlayerFromServerId(IdSelected)).. "~s~ sur vous effectué !")
							end
						})
	
						RageUI.Button('Envoyer un Message', nil , {RightLabel = HMenu.cm.."→→"}, true , {
							onSelected = function ()
								local message_content = KeyboardInput('Inscrivez vôtre Message si-dessous :', '', 100)
								PlaySoundFrontend(-1, "CHARACTER_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
								TriggerServerEvent('jml:SendMessage', IdSelected, message_content)
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez envoyé un Message à : ~b~".. GetPlayerName(GetPlayerFromServerId(IdSelected))..' !')
							end
						})
	
						RageUI.Button('Heal '..HMenu.cm..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil , {RightLabel = HMenu.cm.."→→"}, true , {
							onSelected = function ()
								ExecuteCommand("heal " ..IdSelected)
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez soigné ~b~".. GetPlayerName(GetPlayerFromServerId(IdSelected))..' !')
							end
						})
	
						RageUI.Button('Revive '..HMenu.cm..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil , {RightLabel = HMenu.cm.."→→"}, true , {
							onSelected = function ()
								ExecuteCommand("revive " ..IdSelected)
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez réanimer ~b~".. GetPlayerName(GetPlayerFromServerId(IdSelected))..' !')
							end
						})
	
						if playergroup == "admin" or playergroup =="mod" then
						RageUI.Checkbox(HMenu.cm..labelfreez, nil, freez, {}, {
							onChecked = function()
								freez = true
								labelfreez = "~r~UnFreeze~s~ le Joueur"
								FreezeEntityPosition(IdSelected, true)
								TriggerServerEvent("jml:freezJoueur", IdSelected, true)
								ESX.ShowNotification('Vous venez de ~b~Freeze~s~~r~ '.. GetPlayerName(GetPlayerFromServerId(IdSelected))..'~s~ sur le serveur ~b~'..ns..'~s~ !')
							end,
							onUnChecked = function()
								freez = false
								labelfreez = "~g~Freeze~s~ le Joueur"
								FreezeEntityPosition(IdSelected, false)
								TriggerServerEvent("jml:freezJoueur", IdSelected, false)
								ESX.ShowNotification('Vous venez de ~b~UnFreeze~s~~r~ '.. GetPlayerName(GetPlayerFromServerId(IdSelected))..'~s~ sur le serveur ~b~'..ns..'~s~ !')
							end
						})

							RageUI.Button('Setjob '..HMenu.cm..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil , {RightLabel = HMenu.cm.."→→"}, true , {
								onSelected = function ()
									GetPlayerJob(tonumber(IdSelected))
									-- local job = KeyboardInput("Nom du job", "", 20)
									-- local grade = KeyboardInput("Grade", "", 2)
									-- ExecuteCommand("setjob "..IdSelected.. " " ..job.. " " ..grade)
									-- ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez setjob ~b~".. GetPlayerName(GetPlayerFromServerId(IdSelected))..'~s~ ~r~'..job..' !')
								end
							},HMenu.setjob_menu)
		
							RageUI.Button('Kick '..HMenu.cm..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil , {RightLabel = HMenu.cm.."→→"}, true , {
								onSelected = function ()
									local mess = KeyboardInput('Raison du kick', '', 100)
									if mess ~= nil then
										mess = tostring(mess)
										if type(mess) == 'string' then
											TriggerServerEvent("jml:kick", IdSelected, mess)
										end
									end
									ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez kick ~b~".. GetPlayerName(GetPlayerFromServerId(IdSelected))..' !')
								end
							})
		
							RageUI.Button('Ban '..HMenu.cm..GetPlayerName(GetPlayerFromServerId(IdSelected)), nil , {RightLabel = HMenu.cm.."→→"}, true , {
								onSelected = function ()
									local day = KeyboardInput("Temps du bannissement /jours", "", 3)
									local banmessage = KeyboardInput("Raison du bannissement", "", 100)
									ExecuteCommand("sqlban "..IdSelected.. " " ..day.. " " ..banmessage)
									ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez banni ~b~".. GetPlayerName(GetPlayerFromServerId(IdSelected))..' !')
								end
							})
						
						RageUI.Line(newsStyle)
							RageUI.Button('Inventaire de '..HMenu.cm..GetPlayerName(GetPlayerFromServerId(IdSelected)), "Fouille la personne en face de vous", {RightLabel = HMenu.cm.."→→"}, true, {
								onSelected = function()
									getPlayerInv(IdSelected)
							end
							}, HMenu.inventaire_menu)
						end
						RageUI.Line(newsStyle)
						
					end)

					RageUI.IsVisible(HMenu.inventaire_menu, function()
						RageUI.Line(newsStyle)
						RageUI.Separator(HMenu.cm.."↓~s~  Objet sur lui  "..HMenu.cm.."↓")
	
						for k,v  in pairs(Items) do
							RageUI.Button(v.label, nil, {RightLabel = HMenu.cm.."x"..HMenu.cm..v.right}, true, {
								onSelected = function()
							 end
							})
						end
	
						RageUI.Line(newsStyle)
						RageUI.Separator(HMenu.cm.."↓~s~  Armes sur lui  "..HMenu.cm.."↓")
	
						for k,v  in pairs(Armes) do
							RageUI.Button(v.label, nil, {RightLabel = "avec "..HMenu.cm..v.right.. "~s~ balle(s)"}, true, {
								onSelected = function()
							end
							})
						end
	
						RageUI.Line(newsStyle)
						RageUI.Separator(HMenu.cm.."↓~s~  Argents sur lui "..HMenu.cm.."↓")
					
						for k,v  in pairs(ArgentSale) do
							RageUI.Button("Argent sale : ", nil, {RightLabel = HMenu.cm..v.label.."$"}, true, {
								onSelected = function()
								end	
							})
						end

						for k,v  in pairs(ArgentBank) do
							RageUI.Button("Argent en Banque : ", nil, {RightLabel = HMenu.cm..v.label.."$"}, true, {
								onSelected = function()
								end	
							})
						end
	
						RageUI.Line(newsStyle)

						RageUI.Button("Clear Armes", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								ExecuteCommand("clearloadout " ..IdSelected.."")
							end	
						})
						RageUI.Button("Clear Objets ", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								ExecuteCommand("clearinventory " ..IdSelected.."")
							end	
						})
						RageUI.Button("Clear Inventaire", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								ExecuteCommand("clearinventory " ..IdSelected.."")
								ExecuteCommand("clearloadout " ..IdSelected.."")
							end	
						})
					end)

					RageUI.IsVisible(HMenu.setjob_menu, function()
						RefreshJobServer()
						RageUI.Line(newsStyle)
						RageUI.Separator("Nom : "..HMenu.cm..GetPlayerName(GetPlayerFromServerId(IdSelected)).. "~s~ | ID : "..HMenu.cm..tostring(IdSelected).."~s~")
						for k,v in pairs(InfosJobPlayer) do
							RageUI.Separator('Job : ~h~'..HMenu.cm..v.Job)
							RageUI.Separator('Grade : ~h~'..HMenu.cm..v.Job_Grade)
						end
						RageUI.Line(newsStyle)
						for k,v in pairs(ListJobServer) do
							if v.secondaryjob == false then
								RageUI.Button(v.label, nil, {RightLabel = HMenu.cm..v.name}, true, {
									onSelected = function()
										SelectedJob.name = v.name
										SelectedJob.label = v.label
										SelectedJob.secondary = v.secondaryjob
										RefreshGradeServer(SelectedJob.name)
									end
								}, HMenu.listejob_menu)
							elseif v.secondaryjob == true then
								RageUI.Button(v.label, nil, {RightLabel = HMenu.cm..v.name}, true, {
									onSelected = function()
										SelectedJob.name = v.name
										SelectedJob.label = v.label
										SelectedJob.secondary = v.secondaryjob
										RefreshGradeServer(SelectedJob.name)
									end
								}, HMenu.listejob_menu)
							end
						end
						RageUI.Line(newsStyle)
					end)
					RageUI.IsVisible(HMenu.listejob_menu, function()		
						RageUI.Line(newsStyle)
						RageUI.Separator("Nom : "..HMenu.cm..GetPlayerName(GetPlayerFromServerId(IdSelected)).. "~s~ | ID : "..HMenu.cm..tostring(IdSelected).."~s~")
						-- for k,v in pairs(InfosJobPlayer) do
						-- 	RageUI.Separator('Job : ~h~'..HMenu.cm..v.Job)
						-- 	RageUI.Separator('Grade : ~h~'..HMenu.cm..v.Job_Grade)
						-- end
						RageUI.Line(newsStyle)				
						for k,v in pairs(ListGradeServer) do
							if SelectedJob.secondary == false then
								RageUI.Button(v.label, nil, {RightLabel = HMenu.cm..'→→'}, true, {
									onSelected = function()
										ExecuteCommand('setjob '..tostring(IdSelected)..' '..SelectedJob.name..' '..v.grade)
										TriggerServerEvent('jml:SavedPlayer')
									end
								})
							elseif SelectedJob.secondary == true then
								RageUI.Button(v.label, nil, {RightLabel = HMenu.cm..'→→'}, true, {
									onSelected = function()
										ExecuteCommand('setjob2 '..tostring(IdSelected)..' '..SelectedJob.name..' '..v.grade)
										TriggerServerEvent('jml:SavedPlayer')
									end
								})
							end
						end
					end)

					RageUI.IsVisible(HMenu.gestionvoiture_menu, function()
						RageUI.Line(newsStyle)
						RageUI.Separator('Votre Steam : ~h~'..HMenu.cm..GetPlayerName(PlayerId()))
						RageUI.Separator('Votre ID : ~h~'..HMenu.cm..GetPlayerServerId(PlayerId()))
						RageUI.Separator('Votre Grade : ~h~'..HMenu.cm..playergroup)
						RageUI.Separator('Joueurs connectés : ~h~'..HMenu.cm..#players..'~s~/64')
						RageUI.Line(newsStyle)

						RageUI.Button("Supprimer "..HMenu.cm.."Véhicule", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								ExecuteCommand("dv")
							end	
						})
						RageUI.Button("Réparé "..HMenu.cm.."Véhicule", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								local plyVeh = GetVehiclePedIsIn(PlayerPedId(), false)
								SetVehicleFixed(plyVeh)
								SetVehicleDirtLevel(plyVeh, 0.0) 
							end	
						})
						RageUI.Button("Retourné "..HMenu.cm.."Véhicule", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								mod_vehicle_flip()
							end	
						})
						
						RageUI.Button("Spawn un "..HMenu.cm.."Véhicule", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								local vehicle = KeyboardInput("Nom du véhicule :", "", 100)
									ExecuteCommand("car "..vehicle)
									ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez fait spawn une ~b~"..vehicle..' !')
							end	
						})
						if playergroup == "admin" or playergroup =="mod" then
						RageUI.Button("Changer la plaque du "..HMenu.cm.."Véhicule", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
									local plaqueVehicule = KeyboardInput("Plaque", "", 8)
									SetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false) , plaqueVehicule)
									ESX.ShowNotification("Plaque changée en : ~g~"..plaqueVehicule)
								else
									ESX.ShowNotification("~b~Erreur\n~s~Vous n'êtes pas dans un véhicule !")
								end
							end	
						})
						RageUI.Button("Full-Custom du "..HMenu.cm.."Véhicule", nil, {RightLabel = HMenu.cm.."→→"}, true, {
							onSelected = function()
								FullVehicleBoost()
							end	
						})
					end
						RageUI.Line(newsStyle)
					end)



					RageUI.IsVisible(HMenu.gestionreport_menu, function()
						RageUI.Line(newsStyle)
						RageUI.Separator('Votre Steam : ~h~'..HMenu.cm..GetPlayerName(PlayerId()))
						RageUI.Separator('Votre ID : ~h~'..HMenu.cm..GetPlayerServerId(PlayerId()))
						RageUI.Separator('Votre Grade : ~h~'..HMenu.cm..playergroup)
						RageUI.Separator('Joueurs connectés : ~h~'..HMenu.cm..#players..'~s~/64')
						RageUI.Separator("Il y actuellement "..HMenu.cm..#reportlist.. "~s~ report")
						RageUI.Line(newsStyle)

						
						if #reportlist >= 1 then
							for k,v in pairs(reportlist) do
								RageUI.Button(HMenu.cm..v.nom.." ~s~| ID : ["..HMenu.cm..v.id.."~s~]", nil, {RightLabel = HMenu.cm.."→→"},true , {
									onSelected = function()
										nom = v.nom
										numeroreport = k
										id = v.id
										raison = v.args
									end
									
								}, HMenu.inforeport);
							end
						else
							RageUI.Separator("Aucun "..HMenu.cm.."Report")
						end
						RageUI.Line(newsStyle)
					end)

					RageUI.IsVisible(HMenu.inforeport, function()
						RageUI.Line(newsStyle)
						RageUI.Separator("Report : N°~h~"..HMenu.cm..tostring(numeroreport))
						RageUI.Separator("Nom : "..HMenu.cm..tostring(nom))
						RageUI.Separator("Raison : "..HMenu.cm..tostring(raison))
						RageUI.Line(newsStyle)
				   
					if not reportselect then 
						RageUI.Button("Prendre en "..HMenu.cm.."charge", nil, {RightLabel =  HMenu.cm.."→→"}, true, {
							onSelected = function()
								reportselect = true
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez ~b~pris~s~ le ~r~report~s~ n°~o~"..#reportlist.."~s~ de ~b~"..tostring(nom))
							end
						})
						RageUI.Line(newsStyle)
					else 
						RageUI.Button("Se téléporter sur lui", nil, {RightLabel =  HMenu.cm.."→→"}, reportselect,{
						   onSelected = function()
								SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(id))))
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nTéléportation sur ~b~".. GetPlayerName(GetPlayerFromServerId(id)).. "~s~ effectué !")
						   end
						})
	
						RageUI.Button("Téléporter sur moi", nil, {RightLabel =  HMenu.cm.."→→"}, reportselect, {
						   onSelected = function()
								ExecuteCommand('bring '..id)
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nTéléportation de ~b~".. GetPlayerName(GetPlayerFromServerId(id)).. "~s~ sur vous effectué !")
						   end
						})
	
						RageUI.Button('Heal '..HMenu.cm..GetPlayerName(GetPlayerFromServerId(id)), nil , {RightBadge = RageUI.BadgeStyle.Heart}, true , {
							onSelected = function ()
								ExecuteCommand("heal " ..id)
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez soigné ~b~".. GetPlayerName(GetPlayerFromServerId(id))..' !')
							end
						})
	
						RageUI.Button('Revive '..HMenu.cm..GetPlayerName(GetPlayerFromServerId(id)), nil , {RightBadge = RageUI.BadgeStyle.Heart}, true , {
							onSelected = function ()
								ExecuteCommand("revive " ..id)
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez réanimer ~b~".. GetPlayerName(GetPlayerFromServerId(id))..' !')
							end
						})
	
						RageUI.Button("Envoyer un message", nil, {RightLabel =  HMenu.cm.."→→"}, reportselect,{
						   onSelected = function()
								local message_content2 = KeyboardInput('Inscrivez vôtre Message si-dessous :', '', 100)
								PlaySoundFrontend(-1, "CHARACTER_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
								TriggerServerEvent('Barwoz:SendMessage', id, message_content2)
								ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nVous avez envoyé un Message à : ~b~".. GetPlayerName(GetPlayerFromServerId(id))..' !')
						   end
						})
	
						RageUI.Button("Clôturer le report N°"..HMenu.cm..#reportlist, nil, {RightLabel =  HMenu.cm.."→→"}, reportselect, {
						   onSelected = function()
							   TriggerServerEvent('Barwoz:CloseReport', nom, raison)
							   RageUI.GoBack()
							   getInfoReport() 
							   ESX.ShowNotification("~r~modistration~s~ de ~b~"..ns.."~s~\nTu as fermé le report N°~b~"..#reportlist.. "~s~ de ~r~" ..tostring(nom))
						   end
						})
						RageUI.Line(newsStyle)
					end
				end)
					Wait(0)
				end
			end)
		end
    end
end

RegisterKeyMapping("~#~{[#{~#{~{~{{~#OpenmodMenu", "Ouvrir le Menu mod", 'keyboard', touche_open_menu)

RegisterCommand("~#~{[#{~#{~{~{{~#OpenmodMenu", function()
    Menu_mod()
end)

RegisterNetEvent("Barwoz:envoyer")
AddEventHandler("Barwoz:envoyer", function(reason)
    PlaySoundFrontend(-1, "CHARACTER_SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    ESX.ShowAdvancedNotification('~r~modistration~s~ de ~b~"..Config.Text["Server_Name"]', '<C>Système', ""..reason, 'CHAR_DEFAULT', 1)
end)

function Notify(text)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(text)
	DrawNotification(false, true)
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function KeyboardInput(TextEntry, modText, MaxStringLength)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", modText, "", "", "", MaxStringLength)
	blockinput = true
	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

