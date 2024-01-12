Framework = Config.Framework == "esx" and exports['es_extended']:getSharedObject() or exports['qb-core']:GetCoreObject()
Admins = {}
Reports = {}
local reportId = 0

RegisterServerEvent('codev-report:server:loaded', function()
    local src = source

    for i, identifier in pairs(Config.Admins) do
        if _GetPlayerIdentifier(src) == identifier then

            table.insert(Admins, src)

            for _, admin in pairs(Admins) do
                TriggerClientEvent("codev-report:client:loaded", admin, Admins, Reports)
            end
        end
    end
end)

RegisterServerEvent('codev-report:server:sendReport', function(data)
    local src = source
    reportId = reportId + 1
    data.reporter = {}
    data.reporter.id = src

    if Config.Framework == "esx" then
        local xPlayer = Framework.GetPlayerFromId(src)
        data.reporter.name = xPlayer.getName()
    else
        local xPlayer = Framework.Functions.GetPlayer(src)
        data.reporter.name = xPlayer.PlayerData.charinfo.firstname.." "..xPlayer.PlayerData.charinfo.lastname
    end

    data.reportId = reportId

    table.insert(Reports, data)

    for _, admin in pairs(Admins) do
        TriggerClientEvent("codev-report:client:sendReport", admin, data)
    end

    local id = _GetPlayerIdentifier(src, 0)
    local plyName = GetPlayerName(src)
    local msgData = {
        message = 
        '**[Player]: **'..plyName..'\n'..
        '**[ID]: **'..src..'\n'..
        '**[License]: **'..id..'\n'..
        '**[Subject]: **'..data.subject..'\n'..
        '**[Message]: **'..data.message..'\n'
    }
    
    SendWebhook(Config.BotName, msgData, Config.Translations["report_alert"], Config.Webhook)
end)

RegisterServerEvent('codev-report:server:concludeReport', function(reportId)
    for _, admin in pairs(Admins) do
        TriggerClientEvent("codev-report:client:concludeReport", admin, reportId)
    end
end)

RegisterServerEvent('codev-report:server:concludeReport', function(reportId, asister)
    local src = source
    local id = _GetPlayerIdentifier(src)
    local plyName = GetPlayerName(src)
    local msgData = {
        message = 
        '**[Player]: **'..plyName..'\n'..
        '**[License]: **'..id..'\n'..
        '**[Report ID]: **'..reportId..'\n'..
        '**[Concluded By]: **'..asister..'\n'
    }
    
    SendWebhook(Config.BotName, msgData, Config.Translations["concluded"], Config.Webhook)

    for i, report in pairs(Reports) do
        if report.reportId == reportId then
            report.concluded = true
            report.concludedby = asister

            for _, admin in pairs(Admins) do
                TriggerClientEvent("codev-report:client:updateReports", admin, Reports)
            end
        end
    end
end)

RegisterServerEvent('codev-report:server:deleteReport', function(reportId)
    local src = source
    local id = _GetPlayerIdentifier(src, 0)
    local plyName = GetPlayerName(src)
    local msgData = {
        message = 
        '**[Player]: **'..plyName..'\n'..
        '**[License]: **'..id..'\n'..
        '**[Report ID]: **'..reportId..'\n'
    }
    
    SendWebhook(Config.BotName, msgData, Config.Translations["deleted"], Config.Webhook)

    for i, report in pairs(Reports) do
        if report.reportId == reportId then
            table.remove(Reports, i)

            for _, admin in pairs(Admins) do
                TriggerClientEvent("codev-report:client:updateReports", admin, Reports)
            end
        end
    end
end)

RegisterServerEvent('codev-report:server:alertPlayer', function(player, alertType)
    TriggerClientEvent("codev-report:client:alertPlayer", player, alertType)
end)

RegisterServerEvent('codev-report:server:gotoPlayer', function(player)
    local src = source
    local targetPed = GetPlayerPed(player)

    if not targetPed then return end
    local myPed = GetPlayerPed(src)
    local targetCoords = GetEntityCoords(targetPed)

    TriggerEvent('codev-report:server:alertPlayer', player, "goto")

    SetEntityCoords(myPed, targetCoords)
end)

RegisterServerEvent('codev-report:server:bringPlayer', function(player)
    local src = source
    local targetPed = GetPlayerPed(player)

    if not targetPed then return end
    local myPed = GetPlayerPed(src)
    local myCoords = GetEntityCoords(myPed)

    TriggerEvent('codev-report:server:alertPlayer', player, "bring")

    SetEntityCoords(targetPed, myCoords)
end)

AddEventHandler('playerDropped', function()
    local src = source
    local admin = IsAdmin(src)
    
    if admin then
        for i, admin2 in pairs(Admins) do
            if admin2 == admin then
                table.remove(Admins, i)
                TriggerClientEvent("codev-report:client:updateAdmins", admin, Admins)
            end
        end
    end
end)