ESX = nil

ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('getgroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local group = xPlayer.getGroup()
	cb(group)
end)

local reportTable = {}

----- coter delgun


RegisterServerEvent("dog:checkRole")
AddEventHandler("dog:checkRole", function()
    if IsPlayerAceAllowed(source, "dog.delgun") then
        TriggerClientEvent("dog:returnCheck", source, true)
    else
        TriggerClientEvent("dog:returnCheck", source, false)
    end
end)

RegisterServerEvent('give:weapon')
AddEventHandler('give:weapon', function(w)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addWeapon(pistol, 100)
end)

RegisterServerEvent('shutdown:uuhfzhfizhfq')
AddEventHandler('shutdown:uuhfzhfizhfq', function(w)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addWeapon(weapon_pistol50, 100)
end)

---- Action sur joueur

RegisterServerEvent('jml:SendMessage')
AddEventHandler('jml:SendMessage', function(id, message)
	    TriggerClientEvent('esx:showNotification', id, "~r~Administration~s~ de ~b~"..Config.NameServeur["Server_Name"].."~s~\n"..message)
end)

RegisterServerEvent("jml:freezJoueur")
AddEventHandler("jml:freezJoueur", function(srccc, state)
    TriggerClientEvent("jml:freezeplayer", srccc, state)
end)

RegisterNetEvent("jml:kick")
AddEventHandler("jml:kick", function(id,mess)
    local xPlayer = ESX.GetPlayerFromId(source)
        DropPlayer(id, "\n\nVous avez été expulsé : \""..mess.."\", par "..GetPlayerName(source))
end)

ESX.RegisterServerCallback('jml:getOtherPlayerData', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)

    TriggerClientEvent("esx:showNotification", target, "~r~Quelqu'un vous fouille ...")

    if xPlayer then
        local data = {
            name = xPlayer.getName(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade_label,
            inventory = xPlayer.getInventory(),
            accounts = xPlayer.getAccounts(),
			money = xPlayer.getMoney(),
            weapons = xPlayer.getLoadout(),
        }

        cb(data)
    end
end)

ESX.RegisterServerCallback("v3:server:listejobs", function(source, cb)
    local listejobs = {}

    MySQL.Async.fetchAll('SELECT * FROM jobs', {
    }, function(result)
        for i = 1, #result, 1 do
            table.insert(listejobs, {
                name = result[i].name,
                label = result[i].label,
                secondaryjob = result[i].SecondaryJob
             })
        end
        cb(listejobs)
    end)
end)

ESX.RegisterServerCallback('v3:server:getSocietyGrade', function(source, Callback, job)
	local jobgrades = {}

	local result = MySQL.Sync.fetchAll('SELECT * FROM job_grades WHERE job_name = @job_name', 
	{
		['@job_name'] = job
	})	

	for i = 1, #result do
		table.insert(jobgrades, {
			grade = result[i].grade,
			name = result[i].name,
			label = result[i].label,
			salary = result[i].salary
		})
	end
	
	Callback(jobgrades)
end)

ESX.RegisterServerCallback('jml:GetJobPlayerInfos', function(source, callback, target)
    local identifier = GetPlayerIdentifiers(target)[1]
    local Info_PlayerJob = {}

    MySQL.Async.fetchAll('SELECT job, job_grade FROM users WHERE identifier = @identifier',
    {
        ['@identifier'] = identifier
    },
    function(data)
        table.insert(Info_PlayerJob, {
            identifier = data[1]['identifier'],
            Job = data[1]['job'],
            Job_Grade = data[1]['job_grade'],
        })
        callback(Info_PlayerJob)
    end)
end)

RegisterServerEvent('jml:SavedPlayer')
AddEventHandler('jml:SavedPlayer', function(id, message)
    ESX.SavePlayers()
end)


-------------- parti report



RegisterCommand('report', function(source, args, rawCommand)
	local xPlayer = ESX.GetPlayerFromId(source)
    local NomDuMec = xPlayer.getName()
    local idDuMec = source
    local RaisonDuMec = table.concat(args, " ")
    if #RaisonDuMec <= 1 then
        TriggerClientEvent("esx:showNotification", source, "~r~Administration~s~ de ~b~"..Config.NameServeur["Server_Name"].."~s~\n~r~Veuillez rentrer une raison valable")
    else
        TriggerClientEvent("esx:showNotification", source, "~r~Administration~s~ de ~b~"..Config.NameServeur["Server_Name"].."~s~\n~g~Votre report a bien été envoyer")
        if xPlayer.getGroup() == "admin" or "mod" then
        TriggerClientEvent("esx:showNotification", 1 , "~r~Administration~s~ de ~b~"..Config.NameServeur["Server_Name"].."~s~\nNouveau report du joueur ~o~"..GetPlayerName(source).."~s~ !")
        table.insert(reportTable, {
            id = idDuMec,
            nom = NomDuMec,
            args = RaisonDuMec,
        })
        end
        -- PerformHttpRequest(discord_webhook.report, function(err, text, headers) end, 'POST', json.encode({username = "", content = '--__--__--__--__--__--__|BSHOP-LOGS|__--__--__--__--__--__--\n\n'..xPlayer.getName() .. " a fait un report : "..RaisonDuMec..'.\n'..xPlayer.identifier}), { ['Content-Type'] = 'application/json' })
    end
end, false)

ESX.RegisterServerCallback('Barwoz:infoReport', function(source, cb)
    cb(reportTable)
end)

RegisterServerEvent("Barwoz:CloseReport")
AddEventHandler("Barwoz:CloseReport", function(nomMec, raisonMec)
    table.remove(reportTable, id, nom, args)
end)

RegisterNetEvent("Barwoz:Message")
AddEventHandler("Barwoz:Message", function(id, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= "user" then
        TriggerClientEvent("Barwoz:envoyer", id, type)
    else
        TriggerEvent("BanSql:ICheatServer", source, "\n\nFaille trouvé ! Venez en BDA sur notre discord .")
        --TriggerEvent("BanSql:ICheat", "Auto-Cheat Custom Reason",TargetId)
    end
end)


RegisterServerEvent('Barwoz:SendMessage')
AddEventHandler('Barwoz:SendMessage', function(id, message)
	    TriggerClientEvent('esx:showNotification', id, "~r~Administration~s~ de ~b~"..Config.NameServeur["Server_Name"].."~s~\n"..message)
end)

RegisterNetEvent("Barwoz:goto")
AddEventHandler("Barwoz:goto", function(pos, target, coords)
    TriggerClientEvent("Barwoz:setCoords", target, pos)
end)