class_name Class_GameWorld
extends Node2D


@onready 
var tile_map: TileMap = $TileMap


# Modules
@onready
var nav_manager: Class_AStarNavManager = $AStarNavManager
@onready 
var unit_manager: Class_UnitManager = $UnitManager


func _ready() -> void:
	initialize()


func initialize() -> void:
	nav_manager.initialize(tile_map)
	unit_manager.initialize(nav_manager)

