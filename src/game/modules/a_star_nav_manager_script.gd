class_name Class_AStarNavManager
extends Node2D


@export
var tilemap: TileMap


var a_star_grid: AStarGrid2D

@export
var path_layer: int
@export
var possible_move_locations_layer: int
var possible_move_locations: Array




func initialize(_tilemap: TileMap) -> void:
	# Create the AStarGrid
	# Assign our tilemap
	a_star_grid = AStarGrid2D.new()
	tilemap = _tilemap
	initialize_a_star_grid()
	update_a_star_grid()


func initialize_a_star_grid() -> void:
	a_star_grid.cell_size = tilemap.tile_set.tile_size
	a_star_grid.region.size = tilemap.get_used_rect().size
	a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	a_star_grid.update()


func update_a_star_grid() -> void:
	# For every possible point in our AStarGrid,
	# get that point's data from the tilemap.
	#
	# Use custom data to either assign that point as a 
	# "solid", i.e. a barrier, or to add a travel weight.
	for x_point in a_star_grid.size.x:
		for y_point in a_star_grid.size.y:
			var pos: Vector2 = Vector2(x_point, y_point)
			
			var pos_source_id: int = tilemap.get_cell_source_id(0, pos)
			# NOTE:
			# By creating a tile outside of the used tilemap bounds (even in on another layer),
			# we essentially create an issue where these non-used tiles will return an error,
			# as they are null. 
			# Simple fix is to extend the tilemap slightly or maybe create an "out of bounds"
			# tile, so that we will always have it covered. 
			# Idk, get creative, but if you get a "null" error here, then that's probably the cause.
			if pos_source_id >= 0:
				var custom_data = tilemap.get_cell_tile_data(0, pos).get_custom_data("TerrainType")
				# If our source id is < 0, then it isn't a valid tile. 
				# In other words, it has no tile i.e. it's empty.
				match custom_data:
					"barrier":
						a_star_grid.set_point_solid(pos, true)
					"water":
						a_star_grid.set_point_solid(pos, true)
					"ground":
						a_star_grid.set_point_weight_scale(pos, 3.0)
					
					"river":
						a_star_grid.set_point_weight_scale(pos, 5.0)
				
				
				# We need to do this because the roads are on a different layer from
				# the rest of the map, but they should still be taken into
				# account. It should also come after, as to overwrite any data
				# set by the code above.
				#
				# This is really only necessary if things such as roads or oter tyle types
				# can be added during runtime. So for example, roads being built during a match.
				if tilemap.get_cell_source_id(1, pos) >= 0:
					var custom_data_roads = tilemap.get_cell_tile_data(1, pos).get_custom_data("TerrainType")
					match custom_data_roads:
						"road":
							a_star_grid.set_point_weight_scale(pos, 1.0)
				
				
				
				
				
				#if pos_source_id >= 0:
					#if custom_data == "water":
						#a_star_grid.set_point_solid(pos, true)
			else:
				# If the source ID is not greater than one, then it should be solid.
				a_star_grid.set_point_solid(pos, true)


func pos_is_in_bounds(pos: Vector2) -> bool:
	if a_star_grid.is_in_bounds(pos.x, pos.y):
		return true
	
	return false


func clear_possible_move_location() -> void:
	tilemap.clear_layer(possible_move_locations_layer)

# This function will caluclate a path to every point in the AStarGrid,
# as long as it is reachable to the unit (in other words: path cannot be  empty).
func calc_possible_move_locations(unit_location: Vector2, available_ap: int) -> void:
	for x_point in a_star_grid.size.x:
		for y_point in a_star_grid.size.y:
			var point: Vector2 = Vector2(x_point, y_point)
			var pos_source_id: int = tilemap.get_cell_source_id(0, point)
			
			# ???
			# Maybe:
			# We need to conver the point to the local coords of the
			# tilemap, but then we also need to get its position in the global.
			point = tilemap.to_global(tilemap.map_to_local(point))
			
			
			if pos_source_id >= 0:
				# Generates a path.
				var path: = calculate_a_star_path(unit_location, point)
				
				# Should only be done if we have a path at all.
				if !path.is_empty():
					var cost: int = calc_movement_cost(path)
					
					if available_ap >= cost:
						var tile = tilemap.local_to_map(point)
						var atlas_cords: Vector2 = Vector2(7, 3)
						
						possible_move_locations.append(point)
						tilemap.set_cell(possible_move_locations_layer, tile, 0, atlas_cords)


func calculate_a_star_path(start_location: Vector2, target: Vector2) -> Array:
	clear_path()
	#var mouse_pos: Vector2 = tilemap.local_to_map(get_global_mouse_position())
	var target_pos: Vector2 = tilemap.local_to_map(target)
	var start_pos: Vector2 = tilemap.local_to_map(start_location)
	if pos_is_in_bounds(target_pos):
		var path: Array = a_star_grid.get_point_path(start_pos, target_pos)
		return path
	
	return []


func clear_path() -> void:
	tilemap.clear_layer(path_layer)


func draw_arrow_path(path: Array) -> void:
	var atlas_coords: Vector2 = Vector2(5, 2)
	# This is needed because we have to convert our path
	# from position points into id points.
	var id_array: Array
	
	for point in path:
		var pt: Vector2 = tilemap.local_to_map(point)
		
		id_array.append(pt)
		
		tilemap.set_cell(path_layer, pt, 0, atlas_coords)
	
	tilemap.set_cells_terrain_connect(path_layer, id_array, 0, 3)


func draw_path(path: Array) -> void:
	var atlas_coords: Vector2 = Vector2(7, 4)
	
	for point in path:
		if possible_move_locations.has(point):
			
			var pt: Vector2 = tilemap.local_to_map(point)
			
			tilemap.set_cell(path_layer, pt, 0, atlas_coords)


func calc_movement_cost(path: Array) -> int:
	var final_cost: int = 0
	
	# Erases the first point in the cost array, as it will not be used.
	path.erase(path.front())
	
	for point in path:
		# NOTE:
		# Currently, the AStarGrid returns the path as position points,
		# not tile id points. So we have to convert them first.
		var tile: Vector2 = tilemap.local_to_map(point)
		
		var point_cost: int = int(a_star_grid.get_point_weight_scale(tile))
		final_cost += point_cost
	
	return final_cost

