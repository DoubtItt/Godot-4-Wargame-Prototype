class_name Class_UnitGroup
extends Node2D


var units: Array


func _ready() -> void:
	units = get_children()


func get_unit_at_pos(pos: Vector2) -> Class_UnitBase:
	for unit: Class_UnitBase in units:
		if unit.global_position == pos:
			return unit
	
	return null


func select_unit(unit: Class_UnitBase) -> void:
	unit.select()


func deselect_unit(unit: Class_UnitBase) -> void:
	unit.deselect()


func has_unit(unit: Class_UnitBase) -> bool:
	if units.has(unit):
		return true
	
	return false


func assign_move_order(unit: Class_UnitBase, path: Array, target: Vector2) -> void:
	unit.initialize_movement(path, target)

