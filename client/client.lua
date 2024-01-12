Framework = Config.Framework == "esx" and exports['es_extended']:getSharedObject() or exports['qb-core']:GetCoreObject()
Admins = {}
Reports = {}
PlayerData = {}
local loggedIn = false
local uiLoaded = false

RegisterNUICallback("uiLoaded", function(_, cb)
    uiLoaded = true
    PlayerData = Config.Framework == "esx" and Framework.GetPlayerData() or Framework.Functions.GetPlayerData()
    cb(Config.Framework == "esx" and PlayerData.firstName or PlayerData.charinfo.firstname)
end)

CreateThread(function()
    while true do
        if uiLoaded and not loggedIn and next(PlayerData) then
            loggedIn = true
            TriggerServerEvent("codev-report:server:loaded")
        end

        Wait(200)
    end
end)

-- EVENTS --
RegisterNetEvent("codev-report:client:loaded", function(admins, reports)
    Admins = admins
    Reports = reports

    RegisterCommand("reports", function()
        if loggedIn then
            SetNuiFocus(1, 1)
            SendNUIMessage({
                action = "openAdminMenu",
            })
        end
    end, false)
end)

RegisterNetEvent("codev-report:client:updateAdmins", function(admins)
    Admins = admins
end)

RegisterNetEvent("codev-report:removeAdmin", function(order)
    table.remove(Admins, order)
end)

RegisterNetEvent("codev-report:client:sendReport", function(data)
    table.insert(Reports, data)
    Config.Notification(Config.Translations["report"], Config.Translations["report_alert"], "primary", 5000)
end)

RegisterNetEvent('codev-report:client:alertPlayer', function(alertType)
    if alertType == "bring" then
        Config.Notification(Config.Translations[alertType], Config.Translations["admin_bringed"], "primary", 5000)
    elseif alertType == "goto" then
        Config.Notification(Config.Translations[alertType], Config.Translations["admin_came"], "primary", 5000)
    end
end)

RegisterNetEvent('codev-report:client:updateReports', function(reports)
    Reports = reports
end)

-- NUI CALLBACKS --
RegisterNUICallback("sendReport", function(data)
    SetNuiFocus(0,0)
    TriggerServerEvent("codev-report:server:sendReport", data)
    Config.Notification(Config.Translations["sent"], Config.Translations["report_sent"], "success", 5000)
end)

RegisterNUICallback("getReports", function(_, cb)
    cb(Reports)
end)

RegisterNUICallback("bring", function(serverId)
    TriggerServerEvent("codev-report:server:bringPlayer", serverId)
end)

RegisterNUICallback("goto", function(serverId)
    TriggerServerEvent("codev-report:server:gotoPlayer", serverId)
end)

RegisterNUICallback("concludeReport", function(reportId)
    TriggerServerEvent("codev-report:server:concludeReport", reportId, Config.Framework == "esx" and PlayerData.firstName.." "..PlayerData.lastName or PlayerData.charinfo.firstname.." "..PlayerData.charinfo.lastname)
end)

RegisterNUICallback("deleteReport", function(reportId)
    Config.Notification(Config.Translations["deleted"], Config.Translations["report_deleted"], "success", 5000)
    TriggerServerEvent("codev-report:server:deleteReport", reportId)
end)

RegisterNUICallback("close", function(data)
    SetNuiFocus(0,0)
end)

-- COMMANDS --
RegisterCommand("report", function()
    if loggedIn then
        SetNuiFocus(1, 1)
        SendNUIMessage({
            action = "openReportMenu",
        })
    end
end, false)