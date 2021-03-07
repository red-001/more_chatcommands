
--
-- Chat commands
--

local function execute_chatcommand(pname, cmd)
	for _,func in pairs(minetest.registered_on_chat_messages) do
		func(pname, cmd)
	end
end

minetest.register_chatcommand("run_as", {
	params = "<playername> /<command>",
	description =
		"Run a chatcommand as another player,\n" ..
		"chat messages are captured and are not sent to the other player.",
	privs = {server=true},
	func = function(name, param)
		local playername, msg = param:match"^([^ ]+) *(/.*)"
		if not playername then
			return false, "Invalid parameters (see /help run_as)."
		end

		-- capture chat messages
		local actual_chatsend = minetest.chat_send_player
		function minetest.chat_send_player(cname, chat_msg)
			if cname == playername then
				cname = name
			end
			return actual_chatsend(cname, chat_msg)
		end

		execute_chatcommand(playername, msg)

		minetest.chat_send_player = actual_chatsend
	end,
})

minetest.register_chatcommand("grantme", {
	params = "<privilege>|all",
	description = "Give privilege to yourself",
	func = function(name, param)
		if param == "" then
			return false, "Invalid parameters (see /help grantme)."
		end
		execute_chatcommand(name, "/grant "..name.." "..param)
	end,
})

minetest.register_chatcommand("grantall", {
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

		minetest.log("action", name..' granted everyone ('..param..')')
		return true, "You granted everyone: "..param
	end,
})

minetest.register_chatcommand("kickall", {
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
		minetest.log("action", log_message)
		return true, "Kicked everyone but you"
	end,
})

minetest.register_chatcommand("revokeall", {
	params = "<privilege>|all",
	description = "Revoke privilege from all other players online",
	func = function(name, param)
		if param == "" then
			return false, "Invalid parameters (see /help revokeall)"
		end
		for _,player in pairs(minetest.get_connected_players()) do
			local playername = player:get_player_name()
			if playername ~= name then
				execute_chatcommand(name, "/revoke "..playername.." "..param)
			end
		end

		minetest.log("action", name..' revoked ('..param..') from everyone')
		return true, "You revoked:"..param.." from everyone"
	end,
})

minetest.register_chatcommand("revokeme", {
	params = "<privilege>|all",
	description = "Revoke privilege from yourself",
	func = function(name, param)
		if param == "" then
			return false, "Invalid parameters (see /help revokeall)"
		end
		execute_chatcommand(name, "/revoke "..name.." "..param)
	end,
})

minetest.register_chatcommand("giveall", {
	params = "<privilege>|all",
	description = "Give item to all players online",
	func = function(name, param)
		if param == "" then
			return false, "Invalid parameters (see /help giveall)"
		end
		for _,player in pairs(minetest.get_connected_players()) do
			local playername = player:get_player_name()
			execute_chatcommand(name, "/give "..playername.." "..param)
		end

		minetest.log("action", name..' given everyone ('..param..')')
		return true, "You given everyone: "..param
	end,
})

minetest.register_chatcommand("listitems", {
	params = "<regexp>",
	description = "Find names of registered items",
	privs = {},
	func = function(_, param)
		local names = {}
		for itemname in pairs(minetest.registered_items) do
			if string.find(itemname, param) then
				names[#names+1] = itemname
			end
		end
		table.sort(names)
		-- make every second itemname red to increase readability
		for i = 2, #names, 2 do
			names[i] = minetest.colorize("#ffaaaa", names[i])
		end
		return true, table.concat(names, ", ")
	end,
})

if minetest.global_exists("worldedit") then
	local liquids
	local function get_liquids()
		if liquids then
			return liquids
		end

		local lliquids,n = {},1
		for name,def in pairs(minetest.registered_nodes) do
			if def.drawtype == "liquid"
			or def.drawtype == "flowingliquid" then
				lliquids[n] = name
				n = n+1
			end
		end

		liquids = lliquids
		return lliquids
	end

	minetest.register_chatcommand("/drain", {
		params = "",
		description = "Remove any fluid node within the WorldEdit region",
		privs = {worldedit=true},
		func = function(name)
			for _,nodename in pairs(get_liquids()) do
				execute_chatcommand(name, "//replace "..nodename.." air")
				execute_chatcommand(name, "//y")
			end
		end,
	})

	local fires
	local function get_fires()
		if fires then
			return fires
		end

		local lfires,n = {},1
		for name,def in pairs(minetest.registered_nodes) do
			if def.drawtype == "firelike" then
				lfires[n] = name
				n = n+1
			end
		end

		fires = lfires
		return lfires
	end

	minetest.register_chatcommand("/extinguish", {
		params = "",
		description = "Remove any fire node within the WorldEdit region",
		privs = {worldedit=true},
		func = function(name)
			for _,nodename in pairs(get_fires()) do
				execute_chatcommand(name, "//replace "..nodename.." air")
				execute_chatcommand(name, "//y")
			end
		end,
	})
end
