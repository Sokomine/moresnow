
moresnow = {}

-- the nodebox for this snow node lies one node DEEPER than the node the snow is in;
-- thus, nodebox-like nodes covered by snow may look less strange
minetest.register_node("moresnow:snow_top", {
	description = "Snow",
	tiles = {"default_snow.png"},
	inventory_image = "default_snowball.png",
	wield_image = "default_snowball.png",
	is_ground_content = true,
	paramtype = "light",
	buildable_to = true,
	leveled = 7,
	drawtype = "nodebox",
	freezemelt = "default:water_flowing",
	node_box = {
		-- leveled would not work well in this situation
		type = "fixed",
		fixed = {
			{-0.5, -1.5, -0.5,  0.5, -1.5+2/16, 0.5},
		},
	},
	drop = "default:snow",
	groups = {crumbly=3,falling_node=1, melts=1, float=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.25},
		dug = {name="default_snow_footstep", gain=0.75},
	}),
})


minetest.register_node("moresnow:snow_stair_top", {
	description = "Snow",
--	tiles = {"default_snow.png","default_snow.png","default_ice.png","default_snow.png"},
	tiles = {"default_snow.png"},
	inventory_image = "default_snowball.png",
	wield_image = "default_snowball.png",
	is_ground_content = true,
	paramtype = "light",
	paramtype2 = "facedir",
	buildable_to = true,
	leveled = 7,
	drawtype = "nodebox",
	freezemelt = "default:water_flowing",
	node_box = {
		type = "fixed",
		fixed = {
				{-0.5,      -1.0,      -0.5,       0.5, -1.0+2/16,  0},
				{-0.5,      -0.5,       0,         0.5, -0.5+2/16,  0.5},
				{-0.5,      -1.0+2/16,    0-1/32,  0.5, -0.5,       0  },
				{-0.5,      -1.5,      -0.5-1/32,  0.5, -1.0,      -0.5},
		},
	},
	drop = "default:snow",
	groups = {crumbly=3,falling_node=1, melts=1, float=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.25},
		dug = {name="default_snow_footstep", gain=0.75},
	}),
})


minetest.register_node("moresnow:snow_slab_top", {
	description = "Snow",
--	tiles = {"default_snow.png","default_snow.png","default_ice.png","default_snow.png"},
	tiles = {"default_snow.png"},
	inventory_image = "default_snowball.png",
	wield_image = "default_snowball.png",
	is_ground_content = true,
	paramtype = "light",
	paramtype2 = "facedir",
	buildable_to = true,
	leveled = 7,
	drawtype = "nodebox",
	freezemelt = "default:water_flowing",
	node_box = {
		type = "fixed",
		fixed = {
			        {-0.5, -1.0, -0.5, 0.5, -1.0+2/16, 0.5},
		},
	},
	drop = "default:snow",
	groups = {crumbly=3,falling_node=1, melts=1, float=1},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_snow_footstep", gain=0.25},
		dug = {name="default_snow_footstep", gain=0.75},
	}),
})


-- find out which nodes are stairs and which are slabs (those are handled diffrently by our snow here);
-- this is necessary in order to determine which shape the snow on top of the node will take
-- (of course this only works for a few shapes and does not even take rotation into consideration)
moresnow.snow_cover = {};

-- identify stairs and slabs (roughly!) by their nodeboxes
moresnow.identify_stairs_and_slabs = function()

	local c_snow_stair = minetest.get_content_id( 'moresnow:snow_stair_top' );
	local c_snow_slab  = minetest.get_content_id( 'moresnow:snow_slab_top' );
	local c_snow_top   = minetest.get_content_id( 'moresnow:snow_top' );
	local c_snow       = minetest.get_content_id( 'default:snow' );

	for n,v in pairs( minetest.registered_nodes ) do

		local id = minetest.get_content_id( n );

		if( v and v.drawtype and v.drawtype == 'nodebox' and v.node_box
		      and v.node_box.type and v.node_box.type=='fixed'
		      and v.node_box.fixed ) then

			local nb = v.node_box.fixed;

			-- might be a slab (or something which has a sufficiently similar surface compared to a slab)
			if(    ( #nb == 1
			         and math.max( nb[1][2], nb[1][5])==0 
				 and math.abs( nb[1][4] - nb[1][1] ) >= 0.9
				 and math.abs( nb[1][6] - nb[1][3] ) >= 0.9 )
		
			    or ( type( nb[1] )~='table'
				and #nb == 6
				and math.max( nb[2], nb[5] )==0 
				and math.abs( nb[4]-nb[1] ) >= 0.9 
				and math.abs( nb[6]-nb[3] ) >= 0.9 ))  then

				moresnow.snow_cover[ id ] = c_snow_slab;

			-- might be a stair
			elseif( #nb == 2 ) then
				local c = { math.min( nb[1][1], nb[1][4] ), math.min( nb[1][2], nb[1][5] ), math.min( nb[1][3], nb[1][4] ),
				            math.max( nb[1][1], nb[1][4] ), math.max( nb[1][2], nb[1][5] ), math.max( nb[1][3], nb[1][4] ),
				            math.min( nb[2][1], nb[2][4] ), math.min( nb[2][2], nb[2][5] ), math.min( nb[2][3], nb[2][4] ),
				            math.max( nb[2][1], nb[2][4] ), math.max( nb[2][2], nb[2][5] ), math.max( nb[2][3], nb[2][4] ) };

				if(   ((  c[ 5]==0   and c[11]==0.5)
			            or (  c[ 5]==0.5 and c[11]==0  ))
				      and math.abs( c[ 4]-c[1]) >= 0.9
				      and math.abs( c[10]-c[7]) >= 0.9 ) then

					moresnow.snow_cover[ id ] = c_snow_stair;
				else
					moresnow.snow_cover[ id ] = c_snow_top;
				end
			else 
				moresnow.snow_cover[ id ] = c_snow_top;
			end

		-- add snow to the bottom of the node below; it will look acceptable, provided there is a solid node below
		elseif( v and v.drawtype
		          and (   v.drawtype == 'fencelike' or v.drawtype=='plantlike'
			       or v.drawtype == 'signlike'  or v.drawtype=='torchlike' )) then

			moresnow.snow_cover[ id ] = c_snow_top;
	
		-- nodes where a snow cover would not fit (rails for example would get invisible)
		elseif( v and v.drawtype
		          and (   v.drawtype == 'airlike'   or v.drawtype=='liquid'   
			       or v.drawtype == 'raillike'  or v.drawtype=='flowingliquid' )) then

			moresnow.snow_cover[ id ] = c_air;
		else
			moresnow.snow_cover[ id ] = c_snow;
		end
	end
end

-- search for stairs and slabs after all nodes have been generated
minetest.after( 0, moresnow.identify_stairs_and_slabs );

minetest.registered_nodes[ 'default:snow' ].on_construct = function( pos )
	
	local posb = {x=pos.x, y=pos.y-1, z=pos.z};
	local node  = minetest.get_node( posb );
	if( node and node.name and minetest.registered_nodes[ node.name ] ) then

		local suggested = moresnow.snow_cover[ minetest.get_content_id( node.name )];
		-- if it is some solid node, keep the snow cover
		if( not( suggested )) then
			-- change the node below if it's some kind of dirt
			if( node.name == 'default:dirt_with_grass' or node.name == 'default:dirt' ) then
				minetest.set_node( posb, {name="default:dirt_with_snow"});
			end
			return;
		end

		suggested = minetest.get_name_from_content_id( suggested );

		-- snow_top is a special node suitable for nodeboxes; BUT: it only looks acceptable if the
		-- node below that nodebox/torch/fence/etc is a solid one
		if( suggested and suggested == 'moresnow:snow_top' ) then
			local node2      = minetest.get_node( {x=pos.x, y=pos.y-2, z=pos.z});
			-- no information about the node below available - we don't know what to do
			if( not( node ) or node.name == 'air' or node.name == 'ignore' ) then
				-- TODO: in such a case it would help to drop the node and let it fall until it hits something
				return;
			end
			local suggested2 = moresnow.snow_cover[ minetest.get_content_id( node2.name )];
			-- give up
			if( not( suggested2 )) then
				return;
			end
			suggested2 = minetest.get_name_from_content_id( suggested2 );
			-- if the node below this one can't handle a normal snow cover, we can't put a snow top on our node either
			if( suggested2 ~= 'default:snow' ) then
				return;
			end
			
		end 

		if( suggested and suggested ~= 'default:snow') then
			minetest.set_node( pos, { name = suggested, param2 = node.param2} );
		end
	end
end
