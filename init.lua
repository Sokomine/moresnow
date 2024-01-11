
moresnow = {}

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------
-- if set to true, fallen autum leaves will be supported just like snow
-- The txture and idea for them came from LazyJ.
moresnow.enable_autumnleaves = true
-- wool is useful for covering stairs; turns them into benches;
-- change this if you want the wool functionality only for a few nodes (i.e. only white - or none at all)
moresnow.wool_dyes           =  {"white", "grey", "black", "red", "yellow", "green", "cyan", "blue",
                                "magenta", "orange", "violet", "brown", "pink", "dark_grey", "dark_green"};
-- the snow cannon allows to create snow
moresnow.enable_snow_cannon  = true
-- with this set, the snow cannon can *shoot* snowballs - which will fly a long way;
-- on servers, set this to false
moresnow.crazy_mode          = true 
-- end of configuration
--------------------------------------------------------------------------------

-- which shapes can we cover?
moresnow.shapes = {'top', 'fence_top', 'stair_top', 'slab_top',
			'panel_top', 'micro_top', 'outer_stair_top', 'inner_stair_top',
			'ramp_top', 'ramp_outer_top', 'ramp_inner_top'}

-- which snow node equivals which leaves node?
moresnow.nodetypes = {'snow','autumnleaves'}

-- adjustment for an annoying breaking change in the lua api
moresnow.get_cid = function(node_name)
	if(not(node_name)
	  or (not(minetest.registered_nodes[node_name]) and not(minetest.registered_aliases[node_name]))) then
		return nil
	end
	return minetest.get_content_id(node_name)
end

local modpath = minetest.get_modpath("moresnow")

-- defines the on_construct function for falling/placed snow(balls)
dofile(modpath..'/snow_on_construct.lua');
-- devines the 8 types of snow covers: general nodebox snow cover, stairs, slabs,
-- outer edge stair, inner edge stair, 3x homedecor shingles/technic cnc shapes
dofile(modpath..'/snow_cover_nodes.lua');
moresnow.build_translation_table();

-- some defines which fascilitate identification of nodes
moresnow.c_ignore           = moresnow.get_cid( 'ignore' );
moresnow.c_air              = moresnow.get_cid( 'air' );
moresnow.c_snow             = moresnow.get_cid( 'default:snow' );
-- create some suitable aliases
for _, v in ipairs(moresnow.shapes) do
	moresnow['c_snow_'..v] = moresnow.get_cid('moresnow:snow_'..v)
end


-- takes a look at all defined nodes after startup and stores which shape they are;
-- this is important for finding the right snow cover to put on the shape below
dofile(modpath..'/snow_analyze_shapes.lua');
-- a snow cannon that shoots snow around
if( moresnow.enable_snow_cannon ) then
	dofile(modpath..'/snow_cannon.lua');
end

