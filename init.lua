
moresnow = {}

-- if set to true, fallen autum leaves will be supported just like snow
-- The txture and idea for them came from LazyJ.
moresnow.enable_autumnleaves = true


-- defines the on_construct function for falling/placed snow(balls)
dofile(minetest.get_modpath("moresnow")..'/snow_on_construct.lua');
-- devines the 8 types of snow covers: general nodebox snow cover, stairs, slabs,
-- outer edge stair, inner edge stair, 3x homedecor shingles/technic cnc shapes
dofile(minetest.get_modpath("moresnow")..'/snow_cover_nodes.lua');

-- some defines which fascilitate identification of nodes
moresnow.c_ignore           = minetest.get_content_id( 'ignore' );
moresnow.c_air              = minetest.get_content_id( 'default:snow' );
moresnow.c_snow             = minetest.get_content_id( 'default:snow' );
moresnow.c_snow_top         = minetest.get_content_id( 'moresnow:snow_top' );
moresnow.c_snow_stair       = minetest.get_content_id( 'moresnow:snow_stair_top' );
moresnow.c_snow_slab        = minetest.get_content_id( 'moresnow:snow_slab_top' );
moresnow.c_snow_outer_stair = minetest.get_content_id( 'moresnow:snow_outer_stair_top' );
moresnow.c_snow_inner_stair = minetest.get_content_id( 'moresnow:snow_inner_stair_top' );
moresnow.c_snow_ramp_top    = minetest.get_content_id( 'moresnow:snow_ramp_top' );
moresnow.c_snow_ramp_outer  = minetest.get_content_id( 'moresnow:snow_ramp_outer_top' );
moresnow.c_snow_ramp_inner  = minetest.get_content_id( 'moresnow:snow_ramp_inner_top' );

-- takes a look at all defined nodes after startup and stores which shape they are;
-- this is important for finding the right snow cover to put on the shape below
dofile(minetest.get_modpath("moresnow")..'/snow_analyze_shapes.lua');
-- a snow cannon that shoots snow around
dofile(minetest.get_modpath("moresnow")..'/snow_cannon.lua');


-- TODO: make the autumnleaves from LazyJ working
-- TODO: add a function to use this with voxelmanip
