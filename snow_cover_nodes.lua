

-- the general node definition for all these snow tops (only name and nodebox vary)
moresnow.register_snow_top = function( node_name, fixed_nodebox )
	minetest.register_node( node_name, {
		description = "Snow",
		tiles = {"default_snow.png"},  
--		tiles = {"moreautumn.png"},
		inventory_image = "default_snowball.png",
		wield_image = "default_snowball.png",
		is_ground_content = true,
		paramtype = "light",
		paramtype2 = "facedir",
		buildable_to = true,
		drawtype = "nodebox",
		freezemelt = "default:water_flowing",
		node_box = {
			-- leveled would not work well in this situation
			type = "fixed",
			fixed = fixed_nodebox,
		},
		drop = "default:snow",
		groups = {crumbly=3,falling_node=1, melts=1, float=1, not_in_creative_inventory=1},
		sounds = default.node_sound_dirt_defaults({
			footstep = {name="default_snow_footstep", gain=0.25},
			dug = {name="default_snow_footstep", gain=0.75},
		}),
		on_construct = moresnow.on_construct,
	})
end

-- now that on_construct has been defined, we can start creating the actual nodes
minetest.registered_nodes[ 'default:snow' ].on_construct = moresnow.on_construct;

-- the nodebox for this snow node lies one node DEEPER than the node the snow is in;
-- thus, nodebox-like nodes covered by snow may look less strange
moresnow.register_snow_top( "moresnow:snow_top", {{-0.5, -1.5, -0.5,  0.5, -1.5+2/16, 0.5}} );
moresnow.register_snow_top( "moresnow:snow_stair_top", {
				{-0.5,      -1.0,      -0.5,       0.5, -1.0+2/16,  0},
				{-0.5,      -0.5,       0,         0.5, -0.5+2/16,  0.5},
				{-0.5,      -1.0+2/16,    0-1/32,  0.5, -0.5,       0  },
				{-0.5,      -1.5,      -0.5-1/32,  0.5, -1.0,      -0.5},
		});
moresnow.register_snow_top( "moresnow:snow_slab_top", { {-0.5, -1.0, -0.5, 0.5, -1.0+2/16, 0.5}});
moresnow.register_snow_top( "moresnow:snow_outer_stair_top", {
			        {-0.5, -1.0, -0.5,   0, -1.0+2/16, 0  },
			        {-0.5, -0.5,    0,   0, -0.5+2/16, 0.5},
			        {   0, -1.0, -0.5, 0.5, -1.0+2/16, 0.5},

				{-0.5,      -1.0+2/16,    0-1/32,  0,   -0.5,       0  },
				{-0.5,      -1.5,      -0.5-1/32,  0.5, -1.0,      -0.5},

				{0,         -1.0+2/16,    0,    0+1/32, -0.5,       0.5},
				{0.5,       -1.5,      -0.5,  0.5+1/32, -1.0,       0.5},
		});
moresnow.register_snow_top( "moresnow:snow_inner_stair_top", {
			        {   0, -1.0, -0.5, 0.5, -1.0+2/16, 0  },

			        {   0, -0.5,    0, 0.5, -0.5+2/16, 0.5},
			        {-0.5, -0.5, -0.5, 0,   -0.5+2/16, 0.5},

				{   0,      -1.0+2/16,  0-1/32, 0.5,    -0.5,       0 },
				{   0,      -1.0+2/16, -0.5,    0+1/32, -0.5,        0},
		});


moresnow.register_shape = function( shape, new_name )
	
	local detail = 16;

	local slopeboxedge = {};
	for i = 0, detail-1 do

		if(     shape==1 ) then -- slope; normal roof shingles
			slopeboxedge[i+1]={                      -0.5,  (i/detail)-1.5+(1.25/detail),            (i/detail)-0.5,
			                                          0.5,  (i/detail)-1.5+(1.25/detail)+(1/detail), (i/detail)-0.5+(1/detail)};

		elseif( shape==2 ) then -- outer corner
			slopeboxedge[i+1]={                      -0.5,  (i/detail)-1.5+(1.25/detail),            (i/detail)-0.5,
			                               0.5-(i/detail),  (i/detail)-1.5+(1.25/detail)+(1/detail), (i/detail)-0.5+(1/detail)};

			slopeboxedge[i+detail*1]={     0.5-(i/detail),  (i/detail)-1.5+(1.25/detail)-(1/detail), 0.5,
			                    0.5-(i/detail)+(1/detail),  (i/detail)-1.5+(1.25/detail),            -0.5+(i/detail)           };


		elseif( shape==3 ) then -- inner corner
			local v = detail-i;
			slopeboxedge[i+1]={            (i/detail)-0.5,  (v/detail)-1.5+(1.25/detail)-(1/detail), -0.5+(1/detail-(1/detail)), 
			                    (i/detail)-0.5+(1/detail),  (v/detail)-1.5+(1.25/detail),            0.5-(i/detail)            };

			slopeboxedge[i+detail*1]={                0.5,  (v/detail)-1.5+(1.25/detail),            0.5-(i/detail),
			                              -0.5+(i/detail),  (v/detail)-1.5+(1.25/detail)+(1/detail), 0.5-(i/detail)+(1/detail) };
		end
        end

	moresnow.register_snow_top( new_name, slopeboxedge );
end

-- only add these if either technic (with its cnc machine) or homedecor (with shingles) are installed
if(    minetest.get_modpath( 'homedecor' )
    or minetest.get_modpath( 'technic' )) then
	moresnow.register_shape( 1, 'moresnow:snow_ramp_top' );
	moresnow.register_shape( 2, 'moresnow:snow_ramp_outer_top');
	moresnow.register_shape( 3, 'moresnow:snow_ramp_inner_top');
end

