class_name Class_Player
extends Node2D


@onready 
var selection_icon: Sprite2D = $Icon
@onready 
var cam: Camera2D = $Camera


@export
var tile_step: int = 16

@export_category("Cam Variables")
@export
var zoom_speed: float
@export
var max_cam_zoom: float
@export
var min_cam_zoom: float
@export
var cam_speed: int
var velocity: Vector2

var cam_limit_l: int
var cam_limit_r: int
var cam_limit_t: int
var cam_limit_b: int


func _ready() -> void:
	initialize()


func initialize() -> void:
	# Sets our cam limits, which will be used to clamp
	# the camera's move position
	cam_limit_t = cam.limit_top
	cam_limit_b = cam.limit_bottom
	cam_limit_l = cam.limit_left
	cam_limit_r = cam.limit_right
	


func _unhandled_input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.button_index == MOUSE_BUTTON_WHEEL_DOWN or _event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var desired_zoom: Vector2
			if _event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if zoom_speed > 0:
					zoom_speed *= -1
				
				desired_zoom = Vector2(zoom_speed + cam.zoom.x, zoom_speed + cam.zoom.y)
			elif _event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if zoom_speed < 0:
					zoom_speed *= -1
				
				desired_zoom = Vector2(zoom_speed + cam.zoom.x, zoom_speed + cam.zoom.y)
			
			var final_cam_zoom: Vector2 = Vector2(
			clamp(desired_zoom.x, min_cam_zoom, max_cam_zoom), 
			clamp(desired_zoom.y, min_cam_zoom, max_cam_zoom)
			)
			
			cam.zoom = lerp(cam.zoom, final_cam_zoom, 0.6)
			
			# NOTE:
			# My mouse's scroll wheel if broken. It scrolls both up and down when
			# trying to scroll. I mention this because there is an issue with the cam
			# zoom, where it kind of jitters. However, I'm unsure if this is an issue with
			# my mouse, or due to me using linear interpolation (I notice it more when doing this). 
			# Test it out for yourself and find out.
			#
			# No lerp:
			#cam.zoom = final_cam_zoom


func _process(_delta) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	mouse_pos = Vector2(snappedi(mouse_pos.x, tile_step), snappedi(mouse_pos.y, tile_step))
	selection_icon.global_position = mouse_pos
	
	move(_delta)
	#handle_cam_zoom()


func calc_move_dir() -> Vector2:
	return Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))


func handle_cam_zoom() -> void:
	var desired_zoom: Vector2 = Vector2(zoom_speed + cam.zoom.x, zoom_speed + cam.zoom.y)
	cam.zoom.x = clamp(cam.zoom.x, min_cam_zoom, max_cam_zoom)
	cam.zoom.y = clamp(cam.zoom.y, min_cam_zoom, max_cam_zoom)


func move(_delta: float) -> void:
	var move_dir: Vector2 = calc_move_dir()
	
	var desired_velocity: Vector2 = cam_speed * move_dir
	velocity = lerp(velocity, desired_velocity, 0.3)
	
	var final_cam_pos: Vector2 = cam.global_position + velocity * _delta
	
	cam.global_position.x = clamp(final_cam_pos.x, cam_limit_l, cam_limit_r)
	cam.global_position.y = clamp(final_cam_pos.y, cam_limit_t, cam_limit_b)



