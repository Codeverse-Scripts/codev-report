function IsAdmin(src)
    for _, admin in pairs(Admins) do
        if src == admin then
            return admin
        end
    end

    return false
end

function SendWebhook(botname, data, title, webhook)
    local embedMsg = {}
    local title = title
    local message = data.message

    timestamp = os.date("%c")
    embedMsg = {
        {
            ["color"] = 16711689,
            ["title"] = title,
            ["description"] =  ""..message.."",
            ["footer"] ={
                ["text"] = timestamp.." (Server Time).",
            },
        }
    }
    PerformHttpRequest(webhook,
    function(err, text, headers)end, 'POST', json.encode({username = botname, avatar_url= "" , embeds = embedMsg}), { ['Content-Type']= 'application/json' })
end

function _GetPlayerIdentifier(player)
	for i = 0, GetNumPlayerIdentifiers(player) - 1 do
		local license = GetPlayerIdentifier(player, i)

		if string.sub(license, 1, string.len("discord:")) == "discord:" then
			return license
		end
	end

    return false
end