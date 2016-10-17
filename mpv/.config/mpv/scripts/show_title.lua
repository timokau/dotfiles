function on_pause_change(name, value)
	if value == true then
		-- name = mp.get_property_osd("filename")
		title = mp.get_property_osd("media-title")
		mp.osd_message(title, 300)
		-- mp.set_property("fullscreen", "no")
	else
		mp.osd_message("")
	end
end
mp.observe_property("pause", "bool", on_pause_change)
