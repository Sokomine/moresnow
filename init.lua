
moresnow = {}

-- defines the on_construct function for falling/placed snow(balls)
dofile(minetest.get_modpath("moresnow")..'/snow_on_construct.lua');
-- devines the 8 types of snow covers: general nodebox snow cover, stairs, slabs,
-- outer edge stair, inner edge stair, 3x homedecor shingles/technic cnc shapes
dofile(minetest.get_modpath("moresnow")..'/snow_cover_nodes.lua');
-- takes a look at all defined nodes after startup and stores which shape they are;
-- this is important for finding the right snow cover to put on the shape below
dofile(minetest.get_modpath("moresnow")..'/snow_analyze_shapes.lua');
-- a snow cannon that shoots snow around
dofile(minetest.get_modpath("moresnow")..'/snow_cannon.lua');


-- TODO: add the autumnleaves from LazyJ
-- TODO: add a function to use this with voxelmanip
