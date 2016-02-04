

--
-- Chat commands
--


local function execute_chatcommand(pname, cmd)
	for _,func in pairs(minetest.registered_on_chat_messages) do
		func(pname, cmd)
	end
end

core.register_chatcommand("grantme", {
	params = "<privilege>|all",
	description = "Give privilege to yourself",
	func = function(name, param)
		if param == "" then
			return false, "Invalid parameters (see /help grantme)."
		end
		execute_chatcommand(name, "/grant "..name.." "..param)
	end,
})

core.register_chatcommand("grantall", {
	params = "<privilege>|all",
	description = "Give privilege to all players online",
	func = function(name, param)
		if param == "" then
			return false, "Invalid parameters (see /help grantall)"
		end
		for _,player in pairs(minetest.get_connected_players()) do
			local playername = player:get_player_name()
			execute_chatcommand(name, "/grant "..playername.." "..param)
		end

		core.log("action", name..' granted everyone ('..param..')')
		return true, "You granted everyone: "..param
	end,
})

core.register_chatcommand("kickall", {
	params = "[reason]",
	description = "kick all player but the caller",
	privs = {kick=true},
	func = function(name, reason)
		for _,player in pairs(minetest.get_connected_players()) do
			local tokick = player:get_player_name()
			if tokick ~= name then
				execute_chatcommand(name, "/kick "..tokick.." "..reason)
			end
		end
		local log_message = name .. " kicks everyone"
		if reason
		and reason ~= "" then
			log_message = log_message.." with reason \"" .. reason .. "\""
		end
		core.log("action", log_message)
		return true, "Kicked everyone but you"
	end,
})
