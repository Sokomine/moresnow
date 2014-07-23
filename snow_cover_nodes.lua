

-- the general node definition for all these snow tops (only name and nodebox vary)
moresnow.register_snow_top = function( node_name, fixed_nodebox )
	minetest.register_node( 'moresnow:snow_'..node_name, {
		description = "Snow",
		tiles = {"default_snow.png"},  
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
		on_construct = function( pos )
			return moresnow.on_construct_snow( pos, 'moresnow:snow_'..node_name );
		end,
	})


	if( moresnow.enable_autumnleaves ) then
	   minetest.register_node( 'moresnow:autumnleaves_'..node_name, {
		description = "fallen leaves",
		tiles = {"moreautumn.png"},
		inventory_image = "moreautumn.png",
		wield_image = "moreautumn.png",
		is_ground_content = true,
		paramtype = "light",
		paramtype2 = "facedir",
		buildable_to = true,
		drawtype = "nodebox",
		node_box = {
			-- leveled would not work well in this situation
			type = "fixed",
			fixed = fixed_nodebox,
		},
		drop = "moresnow:autumnleaves",
		groups = {falling_node=1, float=1, not_in_creative_inventory=1, snappy=3, flammable=2, leaves=1, not_in_creative_inventory=1},
		sounds = default.node_sound_leaves_defaults(),
		on_construct = function( pos )
			return moresnow.on_construct_leaves( pos, 'moresnow:autumnleaves_'..node_name );
		end,
	  })
	end
end

-- define the leaves
if( moresnow.enable_autumnleaves ) then
	minetest.register_node( "moresnow:autumnleaves", {
		description = "fallen leaves",
		tiles = {"moreautumn.png"},
		inventory_image = "moreautumn.png",
		wield_image = "moreautumn.png",
		is_ground_content = true,
		paramtype = "light",
--		drawtype = "allfaces_optional",
		waving = 1,
		buildable_to = true,
		leveled = 7, -- can pile up as well
		drawtype = "nodebox",
		node_box = {
				type = "leveled",
				fixed = {
						{-0.5, -0.5, -0.5,  0.5, -0.5+2/16, 0.5},
				},
		},

		groups = {falling_node=1, float=1, snappy=3, flammable=2, leaves=1},
		sounds = default.node_sound_leaves_defaults(),
		on_construct = function( pos )
			return moresnow.on_construct_leaves( pos, 'moresnow:autumnleaves' );
		end,
	})
end


-- now that on_construct has been defined, we can start creating the actual nodes
minetest.registered_nodes[ 'default:snow' ].on_construct = function( pos )
			return moresnow.on_construct_snow( pos, 'default:snow' );
		end

-- the nodebox for this snow node lies one node DEEPER than the node the snow is in;
-- thus, nodebox-like nodes covered by snow may look less strange
moresnow.register_snow_top( "top", {{-0.5, -1.5, -0.5,  0.5, -1.5+2/16, 0.5}} );
moresnow.register_snow_top( "stair_top", {
				{-0.5,      -1.0,      -0.5,       0.5, -1.0+2/16,  0},
				{-0.5,      -0.5,       0,         0.5, -0.5+2/16,  0.5},
				{-0.5,      -1.0+2/16,    0-1/32,  0.5, -0.5,       0  },
				{-0.5,      -1.5,      -0.5-1/32,  0.5, -1.0,      -0.5},
		});
moresnow.register_snow_top( "slab_top", { {-0.5, -1.0, -0.5, 0.5, -1.0+2/16, 0.5}});

-- these shapes exist in moreblocks only
if( minetest.get_modpath( 'moreblocks' )) then
	moresnow.register_snow_top( "outer_stair_top", {
			        {-0.5, -1.0, -0.5,   0, -1.0+2/16, 0  },
			        {-0.5, -0.5,    0,   0, -0.5+2/16, 0.5},
			        {   0, -1.0, -0.5, 0.5, -1.0+2/16, 0.5},

				{-0.5,      -1.0+2/16,    0-1/32,  0,   -0.5,       0  },
				{-0.5,      -1.5,      -0.5-1/32,  0.5, -1.0,      -0.5},

				{0,         -1.0+2/16,    0,    0+1/32, -0.5,       0.5},
				{0.5,       -1.5,      -0.5,  0.5+1/32, -1.0,       0.5},
		});
	moresnow.register_snow_top( "inner_stair_top", {
			        {   0, -1.0, -0.5, 0.5, -1.0+2/16, 0  },

			        {   0, -0.5,    0, 0.5, -0.5+2/16, 0.5},
			        {-0.5, -0.5, -0.5, 0,   -0.5+2/16, 0.5},

				{   0,      -1.0+2/16,  0-1/32, 0.5,    -0.5,       0 },
				{   0,      -1.0+2/16, -0.5,    0+1/32, -0.5,        0},
		});
end


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
	moresnow.register_shape( 1, 'ramp_top' );
	moresnow.register_shape( 2, 'ramp_outer_top');
	moresnow.register_shape( 3, 'ramp_inner_top');
end

