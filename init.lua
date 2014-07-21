
moresnow = {}


moresnow.on_construct = function( pos )
	
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

		-- no rule for this node
		if( not( suggested )) then
			return;
		end

		local p2 = node.param2;
		-- homedecor and technic have diffrent ideas about param2...
		local p2o = moresnow.snow_param2_offset[ minetest.get_content_id( node.name )];
		if( p2o ) then
			p2 = (p2 + p2o ) % 4;
		end

		-- if this is a stair or a roof node from homedecor or technics cnc machine;
		-- those nodes are all comparable regarding rotation
		if(     suggested == 'moresnow:snow_stair_top' or suggested == 'moresnow:snow_ramp_top' ) then
			if(     p2==5 or p2==7 or p2==9  or p2==11 or p2==12 or p2==14 or p2==16 or p2==18 ) then
				suggested = 'moresnow:snow_top';
			-- stair turned upside down
			elseif( p2==6 or p2==8 or p2==15 or p2==17 or p2==20 or p2==21 or p2==22 or p2==23) then
				suggested = 'default:snow';
			-- all these transform into stairs; however, adding the offset (our snow node lies lower than a normal node) would cause chaos
			elseif( p2 ==19) then
				p2 = 1;
			elseif( p2 ==4 ) then
			        p2 = 2;
			elseif( p2 ==13) then
			        p2 = 3;
			elseif( p2 ==10) then
			        p2 = 0;
			-- else it really is a stiar
			end
		elseif( suggested == 'moresnow:snow_slab_top' ) then
			-- vertical slab; tread as a nodebox
			if(     p2 >= 4  and p2 <= 19 ) then
				suggested = 'moresnow:snow_top';
			-- slab turned upside down
			elseif( p2 >= 20 and p2 <= 23 ) then
				suggested = 'default:snow';
			-- else it's a slab
			end
		
		elseif( suggested == 'moresnow:snow_ramp_outer_top' ) then
			-- treat like a nodebox
			if(     p2>=4    and p2 <= 19 ) then
				suggested = 'moresnow:snow_top';
			-- upside-down
			elseif( p2 >= 20 and p2 <= 23 ) then
				suggested = 'default:snow';
			end
		
		elseif( suggested == 'moresnow:snow_ramp_inner_top' ) then
			-- treat like a nodebox
			if(     p2>=4    and p2 <= 19 ) then
				suggested = 'moresnow:snow_top';
			-- upside-down
			elseif( p2 >= 20 and p2 <= 23 ) then
				suggested = 'default:snow';
			end
		end

		-- snow_top is a special node suitable for nodeboxes; BUT: it only looks acceptable if the
		-- node below that nodebox/torch/fence/etc is a solid one
		if( suggested == 'moresnow:snow_top' ) then

			local node2      = minetest.get_node( {x=pos.x, y=pos.y-2, z=pos.z});
	
			if( node2 and node2.name and node2.name == 'default:snow' ) then
				if( node2.param2 and node2.param2+8 >= 64 ) then
					minetest.set_node( {x=pos.y,y=pos.y-2, z=pos.z}, { name = 'default:snowblock' } );
					return;
				else
					if( not( node2.param2 )) then
						node2.param2 = 8;
					end
					minetest.set_node( {x=pos.x,y=pos.y-2, z=pos.z}, { name = 'default:snow', param2 = (node2.param2+8) } );
					minetest.remove_node( pos );
					return;
				end
			end
	
			-- no information about the node below available - we don't know what to do
			if( not( node2 ) or node2.name == 'air' or node2.name == 'ignore' ) then
				-- in such a case it helps to drop the snow and let it fall until it hits something
				if( node2 and node2.name == 'air' ) then
					minetest.remove_node( pos );
					spawn_falling_node( {x=pos.x, y=pos.y-2, z=pos.z}, {name="default:snow"})
				-- else we did not find a sane place for this snow; give up and remove the snow
				else
					minetest.remove_node( pos );
				end
				return;
			end
			local suggested2 = moresnow.snow_cover[ minetest.get_content_id( node2.name )];
			-- give up
			if( not( suggested2 )) then
				minetest.remove_node( pos );
				return;
			end
			suggested2 = minetest.get_name_from_content_id( suggested2 );
			-- if the node below this one can't handle a normal snow cover, we can't put a snow top on our node either
			if( suggested2 ~= 'default:snow' ) then
				minetest.remove_node( pos );
				return;
			end
			
		end 

		if( suggested ) then
			local old = minetest.get_node( pos );

			if( suggested == 'default:snow' ) then
				-- if there is snow already, make it higher
				if( old and old.name and old.name == suggested ) then
					if( old.param2 and old.param2 + 8 >= 64 ) then
						minetest.set_node( pos, { name = 'default:snowblock' } );
						-- we are done - the next snow will land on the surface of the snowblock below
						return;
--[[
						local above = minetest.get_node( {x=pos.x, y=pos.y+1, z=pos.z} );
						if( above and above.name and above.name == 'air' ) then
							minetest.set_node( {x=pos.x, y=pos.y+1, z=pos.z}, { name = 'default:snow', param2 = 8 } );
							return;
						end
--]]
					elseif( not( old.param2 ) or old.param2 < 1 ) then
						p2 = 8;
					else
						p2 = old.param2 + 1;
					end
				-- prevent the snow from getting higher
				else
					p2 = 0;
				end
			end
			if( old and old.name and (old.name ~= suggested or ( old.param2 and old.param2 ~= p2))) then
-- swap_node does not seem to affect param2
				minetest.swap_node( pos, { name = suggested, param2 = p2} );
			end
		end
	end
end

minetest.registered_nodes[ 'default:snow' ].on_construct = moresnow.on_construct;

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
	on_construct = moresnow.on_construct,
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
	on_construct = moresnow.on_construct,
})


minetest.register_node("moresnow:snow_slab_top", {
	description = "Snow",
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
	on_construct = moresnow.on_construct,
})



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

	minetest.register_node( new_name, {
		description = "Snow",
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
			fixed = slopeboxedge,
		},
		drop = "default:snow",
		groups = {crumbly=3,falling_node=1, melts=1, float=1},
		sounds = default.node_sound_dirt_defaults({
			footstep = {name="default_snow_footstep", gain=0.25},
			dug = {name="default_snow_footstep", gain=0.75},
		}),
		on_construct = moresnow.on_construct,
	})

end


-- find out which nodes are stairs and which are slabs (those are handled diffrently by our snow here);
-- this is necessary in order to determine which shape the snow on top of the node will take
-- (of course this only works for a few shapes and does not even take rotation into consideration)
moresnow.snow_cover = {};

-- homedecor and technic did not settle on common param2 interpretation :-(
moresnow.snow_param2_offset = {};

-- homedecor 3d shingles and technic cnc items are handled here
moresnow.identify_special_slopes = function( new_name, homedecor_prefix, technic_postfix, param2_offset )
	-- these nodes are only supported if homedecor and/or technic are installed
	local c_new_snow_node = minetest.get_content_id( new_name );
	if( not( c_new_snow_node )) then
		return;
	end

	local c_ignore        = minetest.get_content_id( 'ignore' );

	local homedecor_materials = {'terracotta','wood','asphalt'};
	local technic_materials   = {'dirt','wood','stone','cobble','brick','sandstone','leaves',
					'tree','steelblock','bronzeblock','stainless_steel','marble','granite'};

	for _,v in ipairs( homedecor_materials ) do
		local id = minetest.get_content_id( homedecor_prefix..v );
		-- the node has to be registered at this point; thus, the soft-dependency on homedecor and technic
		if( id and id ~= c_ignore ) then
			moresnow.snow_cover[ id ] = c_new_snow_node;
		end
	end
	for _,v in ipairs( technic_materials ) do
		local prefix = 'default:';
		if( v=='stainless_steel' or v=='marble' or v=='granite' ) then
			prefix = 'technic:';
		end

		local id = minetest.get_content_id( prefix..v..technic_postfix );
		-- the node has to be registered at this point; thus, the soft-dependency on homedecor and technic
		if( id and id ~= c_ignore ) then
			moresnow.snow_cover[                 id ] = c_new_snow_node;
			-- homedecor and technic use diffrent param2 for the same shape
			if( param2_offset ) then
				moresnow.snow_param2_offset[ id ] = param2_offset;
			end
		end
	end
end

-- identify stairs and slabs (roughly!) by their nodeboxes
moresnow.identify_stairs_and_slabs = function()

	moresnow.identify_special_slopes( 'moresnow:snow_ramp_top',       'homedecor:shingle_side_',         '_technic_cnc_slope', 0 );
	moresnow.identify_special_slopes( 'moresnow:snow_ramp_outer_top', 'homedecor:shingle_outer_corner_', '_technic_cnc_slope_edge', 1 );
	moresnow.identify_special_slopes( 'moresnow:snow_ramp_inner_top', 'homedecor:shingle_inner_corner_', '_technic_cnc_slope_inner_edge', 1 );

	-- actually, that would be homedecor.detail, but we don't want to exaggerate; 16 certainly is enough

	local c_snow_stair = minetest.get_content_id( 'moresnow:snow_stair_top' );
	local c_snow_slab  = minetest.get_content_id( 'moresnow:snow_slab_top' );
	local c_snow_top   = minetest.get_content_id( 'moresnow:snow_top' );
	local c_snow       = minetest.get_content_id( 'default:snow' );

	for n,v in pairs( minetest.registered_nodes ) do

		local id = minetest.get_content_id( n );

		if( not( id ) or moresnow.snow_cover[ id ] ) then

			-- do nothing; the node has been dealt with

		elseif( n and minetest.registered_nodes[ n ]
		      and minetest.registered_nodes[ n ].drop 
		      and minetest.registered_nodes[ n ].drop == 'default:snow' ) then

			-- no snow on snow
			

		elseif( v and v.drawtype and v.drawtype == 'nodebox' and v.node_box
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

-- only add these if either technic (with its cnc machine) or homedecor (with shingles) are installed
if(    minetest.get_modpath( 'homedecor' )
    or minetest.get_modpath( 'technic' )) then
	moresnow.register_shape( 1, 'moresnow:snow_ramp_top' );
	moresnow.register_shape( 2, 'moresnow:snow_ramp_outer_top');
	moresnow.register_shape( 3, 'moresnow:snow_ramp_inner_top');
end

-- search for stairs and slabs after all nodes have been generated
minetest.after( 0, moresnow.identify_stairs_and_slabs );


