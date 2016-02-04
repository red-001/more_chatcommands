

--
-- Chat commands
--


core.register_chatcommand("grantme", {
	params = "<privilege>|all",
	description = "Give privilege to yourself",
	func = function(name, param)
		if not core.check_player_privs(name, {privs=true}) and
				not core.check_player_privs(name, {basic_privs=true}) then
			return false, "Your privileges are insufficient."
		end 
		if param == "" then 
			return false, "Invalid parameters (see /help grantme)." 
		end
		local grantprivs = core.string_to_privs(param)
		if param == "all" then
			grantprivs = core.registered_privileges
		end
		local privs = core.get_player_privs(name)
		local privs_unknown = ""
		for priv, _ in pairs(grantprivs) do
			if priv ~= "interact" and priv ~= "shout" and
					not core.check_player_privs(name, {privs=true}) then
				return false, "Your privileges are insufficient."
			end
			if not core.registered_privileges[priv] then
				privs_unknown = privs_unknown .. "Unknown privilege: " .. priv .. "\n"
			end
			privs[priv] = true
		end
		if privs_unknown ~= "" then
			return false, privs_unknown
		end
		core.set_player_privs(name, privs)
		core.log("action", name.." granted themself's: "..core.privs_to_string(grantprivs, ', '))
		return true, "Your Privileges: "
			.. core.privs_to_string(
				core.get_player_privs(name), ' ')
	end,
})

core.register_chatcommand("grantall", {
	params = "<privilege>|all",
	description = "Give privilege to all players online",
	func = function(name, param)
		if not core.check_player_privs(name, {privs=true}) and
				not core.check_player_privs(name, {basic_privs=true}) then
			return false, "Your privileges are insufficient."
		end
		
		if param == "" then
			return false, "Invalid parameters (see /help grantall)"
		end
		
		local grantprivs = core.string_to_privs(param)
		if not (param == "all") then
			local privs_unknown = ""
			for priv, _ in pairs(grantprivs) do
				if priv ~= "interact" and priv ~= "shout" and
						not core.check_player_privs(name, {privs=true}) then
					return false, "Your privileges are insufficient."
				end
				if not core.registered_privileges[priv] then
					privs_unknown = privs_unknown .. "Unknown privilege: " .. priv .. "\n"
				end
			end
			if privs_unknown ~= "" then
				return false, privs_unknown
			end
		end
		
		for _,player in ipairs(minetest.get_connected_players()) do
			local playername = player:get_player_name()
			local privs = core.get_player_privs(playername)
			if param == "all" then 
				grantprivs = core.registered_privileges
				privs = core.registered_privileges
			else
				for priv, _ in pairs(grantprivs) do
					privs[priv] = true
				end
			end
			core.set_player_privs(playername, privs)

			if playername ~= name then
				core.chat_send_player(playername, name
						.. " granted you privileges: "
						.. core.privs_to_string(grantprivs, ' '))
			end
		end
		
		core.log("action", name..' granted everyone ('..param..')')
		return true, "You granted everyone: "..core.privs_to_string(grantprivs, ' ')
	end,
})

core.register_chatcommand("kickall", {
	params = "[reason]",
	description = "kick all player but the caller",
	privs = {kick=true},
	func = function(name, reason)
		for _,player in ipairs(minetest.get_connected_players()) do
			local tokick = player:get_player_name()
			if not (tokick == name) then
				if not core.kick_player(tokick, reason) then
					minetest.log("Failed to kick player " .. tokick)
				end
			end
		end
		local log_reason = ""
		if reason then
			log_reason = " with reason \"" .. reason .. "\""
		end
		core.log("action", name .. " kicks everyone".. log_reason)
		return true, "Kicked everyone but you"
	end,
})

