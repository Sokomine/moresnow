

if(moresnow.enable_wool_cover) then
	local dyes = {"white", "grey", "dark_grey", "black",
			"violet", "blue", "cyan", "dark_green", "green",
			"yellow", "brown", "orange", "red", "magenta", "pink",
			-- wool has 15 colors - we have to cover 64 hues
			"bonus"}
	for i, dye in ipairs(dyes) do
		local dye_item = "dye:"..dye
		if(dye == "bonus") then
			dye_item = "wool:white"
		end
		-- 64 colors - a standard palette has 256. thus, *4
		local c = (i-1)*4
		minetest.register_craft({
			output = minetest.itemstring_with_palette("moresnow:wool_multicolor", c),
			recipe = {{"moresnow:wool_multicolor", dye_item, ""}},
			replacements = {{"", dye_item, ""}},
		})
		-- get the other four color variants each:
		-- based on darkest color from the respective wool variant:
		minetest.register_craft({
			output = minetest.itemstring_with_palette("moresnow:wool_multicolor", (c+16)),
			recipe = {{"moresnow:wool_multicolor", dye_item, "dye:black",}},
			replacements = {{"", dye_item, "dye:black"}},
		})
		-- based on color by standard name (i.e. "red"):
		minetest.register_craft({
			output = minetest.itemstring_with_palette("moresnow:wool_multicolor", (c+32)),
			recipe = {{"moresnow:wool_multicolor", dye_item, "dye:grey",}},
			replacements = {{"", dye_item, "dye:grey"}},
		})
		-- pastel colors:
		minetest.register_craft({
			output = minetest.itemstring_with_palette("moresnow:wool_multicolor", (c+48)),
			recipe = {{"moresnow:wool_multicolor", dye_item, "dye:white",}},
			replacements = {{"", dye_item, "dye:white"}},
		})
	end
end
