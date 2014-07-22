
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

