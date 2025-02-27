class_name Class_UnitManager
extends Node2D


var nav_manager: Class_AStarNavManager


@export
var tile_step: int

var unit_groups: Array
var active_unit: Class_UnitBase
var current_group: Class_UnitGroup


func _ready() -> void:
	unit_groups = get_children()


func initialize(_nav_manager: Class_AStarNavManager) -> void:
	nav_manager = _nav_manager


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset_scene"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("escape"):
		if active_unit:
			deselect_active_unit()
	
	if event is InputEventMouseButton:
		var mouse_pos: Vector2 = snap_mouse_pos()
		if Input.is_action_just_pressed("right_click"):
			if active_unit:
				give_unit_move_order(mouse_pos)
				deselect_active_unit()
		
		if Input.is_action_just_pressed("left_click"):
			if active_unit:
				deselect_active_unit()
			
			active_unit = set_active_unit(mouse_pos)


func _process(_delta: float) -> void:
	if active_unit:
		var mouse_pos: Vector2 = snap_mouse_pos()
		var path: Array = nav_manager.calculate_a_star_path(active_unit.global_position, mouse_pos)
		nav_manager.draw_path(path)


func snap_mouse_pos() -> Vector2:
	var mouse_pos: Vector2 = get_global_mouse_position()
	
	mouse_pos = Vector2(snappedi(mouse_pos.x, tile_step), snappedi(mouse_pos.y, tile_step))
	
	return mouse_pos


func set_active_unit(pos: Vector2) -> Class_UnitBase:
	for group: Class_UnitGroup in unit_groups:
		var unit: Class_UnitBase = group.get_unit_at_pos(pos)
		if unit:
			group.select_unit(unit)
			current_group = group
			var available_ap: int = unit.current_action_points
			nav_manager.calc_possible_move_locations(unit.global_position, available_ap)
			
			return unit
	return null


func deselect_active_unit() -> void:
	current_group.deselect_unit(active_unit)
	nav_manager.clear_path()
	nav_manager.clear_possible_move_location()
	
	active_unit = null


func give_unit_move_order(target_position: Vector2) -> void:
	var path: Array = nav_manager.calculate_a_star_path(active_unit.global_position, target_position)
	var cost: int = nav_manager.calc_movement_cost(path)
	
	if active_unit.has_enough_action_points(cost):
		current_group.assign_move_order(active_unit, path, target_position)

