
jukebox_list={
"1",
"2",
"3",
"4",
"5",
"6",
"7",
"8",
"9",
"10",
"11",
"12",
"13",
"14",
"15",
"16"
}

jukeboxloop={}

minetest.register_node("jukebox:juke", {
    description = "Juke",
	alpha=50,
		drawtype = "mesh",
            mesh= "juke.obj",
            tiles = {"juke_on.png"},
	paramtype = "light",
    paramtype2 = "facedir",
    automatic_rotate = true,
    sunlight_propagates = true,
	walkable = true,
	pointable = true,
	collision_box = {
	        type = "fixed",
            fixed = { -0.4, -0.5, -0.2, 0.4,1.19,0.4}},
	    selection_box = {
	        type = "fixed",
            fixed = { -0.4, -0.5, -0.2, 0.4,1.19,0.4}
	      --fixed = { -0.5, 0.35, -0.5, 0.5,1.5, 0.5},
	    },--                          largdx  h
		groups = {mesecon=1,snappy=2,cracky=3,oddly_breakable_by_hand=3, not_in_creative_inventory=0},
	sounds = default.node_sound_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local but="button[2,0.1;4,1;stop;STOP!] button[3,2.2;2,1.5;loop;Loop] button_exit[2,4.5;4,2;exit;EXIT]"
		local x=-0
		local y=1
        
		meta:set_string("infotext", "Jukebox")
		meta:set_int("loop", 0)
		for i, list in pairs(jukebox_list) do
			but=but.. "button[" .. x .. "," .. y ..";1,1.2;play"..i..";"..i.."]"
			x=x+1
			if x==8 then
			x=0
			y=y+2.5
			end
		end
       		meta:set_string("formspec",
			"size[8.0,6.5]" .. but ..
         "background[-0,-0;8,6.5;juke_bag.png]"
         )
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local id=minetest.pos_to_string(pos)
		local sound={}
		if fields.loop then
			if meta:get_int("loop")==0 then
				meta:set_int("loop",1)
				minetest.chat_send_player(sender:get_player_name(), "Looping: on")
			else
				meta:set_int("loop",0)
				minetest.chat_send_player(sender:get_player_name(), "Looping: off")
				if jukeboxloop[id] then
					minetest.sound_stop(jukeboxloop[id])
					jukeboxloop[id]=nil
				end
			end
			return true
		end

		if fields.stop then
			if jukeboxloop[id] then
				minetest.sound_stop(jukeboxloop[id])
				jukeboxloop[id]=nil
			end
			return true
		end
		for i, list in pairs(jukebox_list) do
			if fields["play" ..i] then
				if jukeboxloop[id] then
					minetest.sound_stop(jukeboxloop[id])
					jukeboxloop[id]=nil
				end
				meta:set_int("last",i)
				if meta:get_int("loop")==0 then
					jukeboxloop[id]=minetest.sound_play(jukebox_list[i], {pos=pos, gain = 1.0, max_hear_distance = 15,})
				else
					jukeboxloop[id]=minetest.sound_play(jukebox_list[i], {pos=pos, gain = 1.0, max_hear_distance = 15,loop=true})
				end
				return true
			end
		end
	end,

		mesecons = {effector = {
		action_on = function(pos, node)
			local meta = minetest.get_meta(pos)
			local last=meta:get_int("last")
			local id=minetest.pos_to_string(pos)
			meta:set_int("playing",1)

			if jukeboxloop[id] then
				minetest.sound_stop(jukeboxloop[id])
				jukeboxloop[id]=nil
			end


			if meta:get_int("loop")==0 then
				jukeboxloop[id]=minetest.sound_play(jukebox_list[last], {pos=pos, gain = 1.0, max_hear_distance = 15,})
			else
				jukeboxloop[id]=minetest.sound_play(jukebox_list[last], {pos=pos, gain = 1.0, max_hear_distance = 15,loop=true})
			end
		end
,
		action_off = function(pos, node)
			local meta = minetest.get_meta(pos)
			local id=minetest.pos_to_string(pos)
			if meta:get_int("playing")==1 and jukeboxloop[id] then
				minetest.sound_stop(jukeboxloop[id])
				meta:set_int("playing",0)
				return true
			end
		end
}},
})
