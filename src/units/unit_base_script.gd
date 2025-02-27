class_name Class_UnitBase
extends Node2D


# Sprite Refs
@onready 
var selection_sprite: Sprite2D = $SelectionSprite
@onready 
var sprite: Sprite2D = $Sprite


@onready 
var yap_text: RichTextLabel = $YapText

@export
var max_action_points: int
var min_action_points: int = 0
var current_action_points: int

# NOTE:
# Unit will not move at all if speed is below 5???
@export
var move_speed: int
var velocity: Vector2
var final_move_target: Vector2
var current_move_target: Vector2
var move_path: Array


var has_reported: bool = false


var selected: bool


func _ready() -> void:
	current_action_points = max_action_points


func _process(_delta) -> void:
	#yap(str(global_position))
	if final_move_target:
		execute_move_action(_delta)


# Selection related functions
func select() -> void:
	selected = true
	selection_sprite.visible = true


func deselect() -> void:
	selected = false
	selection_sprite.visible = false


# Action points related functions
func reset_action_points() -> void:
	current_action_points = max_action_points


func subtract_action_points(total: int) -> void:
	var final_action_points: int = current_action_points - total
	current_action_points = clamp(final_action_points, min_action_points, max_action_points)


func has_enough_action_points(cost: int) -> bool:
	if current_action_points >= cost:
		return true
	
	return false


# Movement Related Functions
func initialize_movement(path: Array, move_tar: Vector2) -> void:
	set_path(path)
	set_move_target(move_tar)


func move_target_reached() -> bool:
	if global_position == final_move_target:
		return true
	
	return false


func set_path(path: Array) -> void:
	# We don't need the first point of this array,
	# as it's just the units current position.
	#if path.size() > 0:
		#path.erase(path.front())
	move_path = path


func set_move_target(tar: Vector2) -> void:
	final_move_target = tar


func move_to_pos() -> void:
	global_position = move_path.front()
	move_path.erase(move_path.front())


func yap(text: String) -> void:
	yap_text.text = "[center]" + text


func calc_move_dir(target: Vector2) -> Vector2:
	var dir: Vector2
	
	dir = global_position.direction_to(target)
	dir = Vector2(sign(dir.x), sign(dir.y))
	
	return dir


func get_next_path_location() -> Vector2:
	return move_path.front()


func execute_move_action(_delta: float) -> void:
	if !move_target_reached() && move_path.size() > 0:
		var max_target_distance: float = 0.8
		
		if global_position != current_move_target:
			current_move_target = get_next_path_location()
			
			var move_dir: Vector2 = calc_move_dir(current_move_target)
			velocity = move_speed * move_dir * _delta
			
			
			## These are different move options I experimented with.
			## This one specifically led to a lot of jittering, so I scrapped it, but
			## it could be made to work. Just didn't want to bother with it anymore.
			#var desired_x_pos = move_toward(global_position.x, current_move_target.x, move_speed * _delta)
			#var desired_y_pos = move_toward(global_position.y, current_move_target.y, move_speed * _delta)
			#global_position = lerp(global_position, Vector2(desired_x_pos, desired_y_pos), 1)
			
			
			## This gives a much smoother look to the movement.
			## There is still some jittering due to the snapping we do at the end;
			## however, this is also dependent on the speed. It's less noticable at
			## a higher speed value, but it also moves A LOT quicker.
			## Just something to consider.
			var desired_position: Vector2 = global_position + velocity
			var speed: float = 1.2
			global_position = lerp(global_position, desired_position, speed)
			
			
			## This option leads to a more snap based look. Play around with
			## the weight value to see how it affects the overall look.
			## The quicker the value; the quicker the unit moves.
			#var snap_speed: float = 0.2
			#global_position = lerp(global_position, current_move_target, snap_speed)
			
			
			# This prevents the unit from constantly overshooting the position, thus resulting
			# in a never ending loop of the unit quickly jittering back and forth near the
			# target position.
			# Basically: if the unit is close enough to the target, then it just snaps to it.
			if global_position.distance_to(current_move_target) <= max_target_distance:
				global_position = current_move_target
			
			
			## This is snap based movement. Useful if you want the unit to snap
			## from tile to tile instead of having a smoother more natural travel.
			#global_position = Vector2(
				#snapped(global_position.x, 16),
				#snapped(global_position.y, 16)
			#)
		else:
			move_path.erase(move_path.front())
			
			if move_path.size() > 0:
				current_move_target = get_next_path_location()
			
	#else:
		#final_move_target = Vector2.ZERO
		#current_move_target = Vector2.ZERO

