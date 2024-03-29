extends CharacterBody3D
class_name Player

@export_category("Movement Properties")
@export var _speed: float = 6.0
@export var _jump_height: float = 5.0
@export var _aerial_influence: float = 10.0
@export var _grounded_acceleration: float = 0.21
@export var _max_speed: float = 15

@export_category("Crouching Properties")
@export var _crouch_dist: float = 0.8
@export var _stand_dist: float = 1.8
@export var _crouch_speed: float = 0.3
@export var _crouch_movement_mult: float = 0.5
@export var _cam_offset: float = -0.2

@export_category("Interacting Properties")
@export var _mouse_sensitivity: float = 3
@export var _interact_dist: float = 100

@export_category("Brain Change Properties")
@export var _disabled: bool = true
@export var _starting_player: bool
@export var _cam_material: ShaderMaterial
@export_range(11,20,1) var _vis_layer_id: int = 11

@export_category("Void Out Properties")
@export_range(0.2,1.5,0.05) var edge_margin:float = 0.5
@export_range(0,0.5,0.01) var max_safe_height:float = 0.1

var player_cam: Camera3D
@onready var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

var _crouching: bool = false
var _crouch_tween: Tween

var last_safe_pos: Vector3


func _ready():
	disable_control(not _starting_player)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_crouching = false
	player_cam = null
	
	#ground detection properties
	var raycast_dist = Vector3(0.0, max_safe_height * -1.0 - 0.5, 0.0)
	$EdgeRaycasts/CenterCast.target_position = raycast_dist
	$EdgeRaycasts/RightCast.target_position = raycast_dist
	$EdgeRaycasts/LeftCast.target_position = raycast_dist
	$EdgeRaycasts/BackCast.target_position = raycast_dist
	$EdgeRaycasts/FrontCast.target_position = raycast_dist
	
	$EdgeRaycasts/RightCast.position.x = edge_margin
	$EdgeRaycasts/LeftCast.position.x = edge_margin * -1.0
	$EdgeRaycasts/BackCast.position.z = edge_margin
	$EdgeRaycasts/FrontCast.position.z = edge_margin * -1.0
	
	
	if _starting_player:
		%MainCam.update_cull_mask(_vis_layer_id)
		adopt_main_cam(%MainCam)


func _process(delta):
	
	#Quit button NEEDS MOVING
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	#get each input relative to mouse
	var dir = Vector3()
	if Input.is_action_pressed("move_right") and not _disabled:
		#Adds relative vector of the global normalized grid
		dir += global_basis.x
	if Input.is_action_pressed("move_left") and not _disabled:
		#Adds relative vector of the global normalized grid
		dir += -global_basis.x
	if Input.is_action_pressed("move_backward") and not _disabled:
		#Adds relative vector of the global normalized grid
		dir += global_basis.z
	if Input.is_action_pressed("move_forward") and not _disabled:
		#Adds relative vector of the global normalized grid
		dir += -global_basis.z
	
	#Get initial horizontal velocity from direction
	dir = dir.normalized()
	var hvel = dir * _speed
	
	#requirements to crouch
	if Input.is_action_pressed("crouch") and is_on_floor() and not _crouching and not _disabled:
		_crouching = true
		
		var crouch_target = $CameraMarker.position
		crouch_target.y = _crouch_dist - 1
		_setup_crouch_tween(crouch_target)
	
	#requirements to uncrouch
	if not Input.is_action_pressed("crouch") and _crouching\
			and is_on_floor() and not $UncrouchShapecast.is_colliding():
		_crouching = false
		
		var stand_target = $CameraMarker.position
		stand_target.y = _stand_dist - 1
		_setup_crouch_tween(stand_target)
	
	#Move slower when crouched
	if _crouching:
		hvel *= _crouch_movement_mult
	
	if is_on_floor():
		#turn horizontal velocity into the object's velocity
		velocity.x = lerp(velocity.x,hvel.x,_grounded_acceleration)
		velocity.z = lerp(velocity.z,hvel.z,_grounded_acceleration)
	else:
		#adding influencing player's aerial momentum
		hvel = hvel.normalized()
		velocity.x += hvel.x * _aerial_influence * delta
		velocity.z += hvel.z * _aerial_influence * delta
		pass
	
	# Apply gravity
	velocity.y += delta * gravity
	
	#make sure player can't build up infinite speed
	if Vector2(velocity.x,velocity.z).length() > _speed:
		var capped_hvel = Vector2(velocity.x,velocity.z).normalized() * _speed
		velocity.x = capped_hvel.x
		velocity.z = capped_hvel.y
	if velocity.length() > _max_speed:
		velocity = velocity.normalized() * _max_speed
	
	#run collision built into CharacterBody3D
	move_and_slide()
	
	#jumping
	if is_on_floor() and Input.is_action_just_pressed("jump") and not _disabled:
		velocity.y = _jump_height


func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	if Input.is_action_just_pressed("interact") and not _disabled:
		#cast a ray from camera to find a burnable object
		var screen_center = get_viewport().size * 0.5
		var from = player_cam.project_ray_origin(screen_center)
		var to = from + player_cam.project_ray_normal(screen_center) * _interact_dist
		
		#cast ray
		var ray_query = PhysicsRayQueryParameters3D.create(from, to)
		#create bitmask for collisions, for the player's visibility layer, player layer (10) and the default layer (1) 
		ray_query.collision_mask = pow(2, _vis_layer_id-1) + pow(2, 10-1)
		#Able to hit objects through windows
		ray_query.exclude = [self] + get_tree().get_nodes_in_group("window")
		var ray_result = space_state.intersect_ray(ray_query)
		
		if ray_result:
			print("Hit " + str(ray_result.collider) + " at position " + str(ray_result.position))
			if ray_result.collider is Player:
				_transfer_main_cam(ray_result.collider as Player)
			elif ray_result.collider is LevelGoal:
				print("hit end level")
				_transfer_main_cam(ray_result.collider as LevelGoal)
		else:
			print("No object hit")
	
	#looking for last safe location to respawn player
	var is_safe: bool = true
	var center_floor_col = $EdgeRaycasts/CenterCast.get_collider()
	var right_floor_col = $EdgeRaycasts/RightCast.get_collider()
	var left_floor_col = $EdgeRaycasts/LeftCast.get_collider()
	var back_floor_col = $EdgeRaycasts/BackCast.get_collider()
	var front_floor_col = $EdgeRaycasts/FrontCast.get_collider()
	
	if center_floor_col != null:
		if center_floor_col is Door:
			is_safe = false
	else: 
		is_safe = false
	if right_floor_col != null:
		if right_floor_col is Door:
			is_safe = false
	else: 
		is_safe = false
	if left_floor_col != null :
		if left_floor_col is Door:
			is_safe = false
	else: 
		is_safe = false
	if back_floor_col != null:
		if back_floor_col is Door:
			is_safe = false
	else: 
		is_safe = false
	if front_floor_col != null:
		if front_floor_col is Door:
			is_safe = false
	else: 
		is_safe = false
	
	if not is_on_floor() and not is_on_wall():
		is_safe = false
	
	if is_safe:
		last_safe_pos = global_position
		#print(last_safe_pos)


func _unhandled_input(event):
	#Input for mouse
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not _disabled:
		#rotate whole player horizontally
		rotate_y(-event.relative.x * _mouse_sensitivity * 0.001)
		#rotate camera node vertically
		$CameraMarker.rotate_x(-event.relative.y * _mouse_sensitivity * 0.001)
		$CameraMarker.rotation.x = clamp($CameraMarker.rotation.x, -1.4, 1.4)
		#Stop euler angles enabling player cam movement
		$CameraMarker.rotation.y = 0
		$CameraMarker.rotation.z = 0
		
		#rotate the player model's head
		var model_skeleton: Skeleton3D = $PlayerModel/RootNode/Skeleton3D as Skeleton3D
		var head_bone_idx: int = model_skeleton.find_bone("mixamorig_Head")
		model_skeleton.set_bone_pose_rotation(head_bone_idx,Quaternion.from_euler($CameraMarker.rotation * -1))


func _setup_crouch_tween(target):
	#If a crouch is happening, stop it
	if _crouch_tween is Tween:
		if _crouch_tween.is_running():
			_crouch_tween.kill()
	
	#new tween
	_crouch_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	#If you are uncrouching, enable the Standing Collider immediately
	_crouch_tween.chain().tween_callback(func():
		if not _crouching:
			$StandingCollider.disabled = _crouching
	)
	#Interpolate camera height
	_crouch_tween.chain().tween_property($CameraMarker, "position", target, _crouch_speed)
	#When crouch is done, enable / disable raycasts and colliders
	_crouch_tween.chain().tween_callback(func():
		if _crouching:
			$StandingCollider.disabled = _crouching
		#enable checking for ceilings when crouching
		$UncrouchShapecast.enabled = _crouching
	)


func _transfer_main_cam(target):
	#Target variables for the animation
	var target_cam_marker:Marker3D = target.get_node("CameraMarker")
	var target_pos = target_cam_marker.global_position
	var target_rot = target_cam_marker.global_rotation
	var transition_mat = player_cam.cam_eyelids_node.material
	
	var transfer_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	transfer_tween.tween_callback(func():
			#Disable Came movement
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			#Put cam on the same parent-child heirarchy as all of ther player objects
			player_cam.reparent(get_parent(),true)
			disable_control(true)
			
			transition_mat.set_shader_parameter("close_amount", 0.0)
			transition_mat.set_shader_parameter("lid_transparency", 1.0)
	)
	transfer_tween.tween_property(player_cam,"global_position",target_pos,2.0)
	transfer_tween.parallel().tween_property(player_cam,"global_rotation",target_rot,2.0)
	#Start the eyelids closing after a time
	transfer_tween.parallel().tween_property(transition_mat,"shader_parameter/lid_transparency",0.0,0.4).set_delay(1.55)
	
	if target is Player:
		transfer_tween.tween_callback(func():
				#Transfer controll to new player object
				target.adopt_main_cam(player_cam)
				player_cam.update_cull_mask(target._vis_layer_id)
				
				($PlayerModel as Node3D).visible = true
				
				target.disable_control(false)
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				player_cam = null
		)
		#Open Eyelids
		transfer_tween.parallel().tween_property(transition_mat,"shader_parameter/close_amount",1.0,0.4)
	elif target is LevelGoal:
		transfer_tween.tween_callback(func():
				target.end_level()
		)


func adopt_main_cam(main_cam):
	#Setup functionality for taking control of camer
	player_cam = main_cam
	var temp_cam_mark = $CameraMarker
	player_cam.global_position = temp_cam_mark.global_position
	player_cam.global_rotation = temp_cam_mark.global_rotation
	player_cam.reparent(temp_cam_mark, true);
	
	($PlayerModel as Node3D).visible = false
	player_cam.lens_shader_material = _cam_material


func disable_control(disable: bool):
	_disabled = disable
	#checking for off of safe platforms dissabled when not moving
	$EdgeRaycasts/CenterCast.enabled = not disable
	$EdgeRaycasts/RightCast.enabled = not disable
	$EdgeRaycasts/LeftCast.enabled = not disable
	$EdgeRaycasts/BackCast.enabled = not disable
	$EdgeRaycasts/FrontCast.enabled = not disable


func void_out():
	var transition_mat = player_cam.cam_eyelids_node.material
	
	var respawn_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	respawn_tween.tween_callback(func():
			disable_control(true)
			player_cam.fog_cam_view(true)
			print("hit fog void")
			
			transition_mat.set_shader_parameter("close_amount", 1.0)
			transition_mat.set_shader_parameter("lid_transparency", 0.0)
	)
	respawn_tween.tween_property(transition_mat,"shader_parameter/close_amount",0.0,1.2)
	respawn_tween.tween_callback(func():
			velocity = Vector3(0,0,0)
			global_position = last_safe_pos
			
			player_cam.fog_cam_view(false)
	)
	respawn_tween.tween_property(transition_mat,"shader_parameter/close_amount",1.0,0.7).set_delay(0.4)
	respawn_tween.parallel().tween_callback(func():
			disable_control(false)
	).set_delay(0.2)


func starting_player_start_animation():
	var transition_mat = player_cam.cam_eyelids_node.material
	
	var start_tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	start_tween.tween_callback(func():
			disable_control(true)
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			
			transition_mat.set_shader_parameter("close_amount", 0.0)
			transition_mat.set_shader_parameter("lid_transparency", 0.0)
	)
	start_tween.tween_property(transition_mat,"shader_parameter/close_amount",1.0,0.6).set_delay(0.4)
	start_tween.tween_callback(func():
			disable_control(false)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	)
