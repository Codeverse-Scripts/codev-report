Config = {
    Framework = "qb", -- Framework name (esx or qb)

    BotName = "CodeV Report", -- Name of the bot that will send the reports to the discord channel
    Webhook = "", -- Discord webhook link

    Admins = { -- Discord IDs of the admins
        "discord:397032581326962689",
    },

    Translations = {
        ["report"] = "Report",
        ["report_alert"] = "There is a new report!",
        ["sent"] = "Sent",
        ["report_sent"] = "Report successfully sent.",
        ["deleted"] = "Deleted",
        ["report_deleted"] = "Report successfully deleted.",
        ["bring"] = "Admin",
        ["admin_bringed"] = "An admin bringed you.",
        ["goto"] = "Admin",
        ["admin_came"] = "An admin teleported to help you.",
        ["concluded"] = "Concluded",
    },

    Notification = function(title, message, msgType, length)
        -- Your notification here
    end
}