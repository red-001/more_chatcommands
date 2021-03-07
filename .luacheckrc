read_globals = {
	-- Defined by Minetest
	"vector", "PseudoRandom", "VoxelArea",
	minetest = {
		fields = {
			chat_send_player = {
				read_only = false
			}
		},
		other_fields = true
	}
}
