extends CharacterBody3D

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
@export var _interact_dist: float = 5

@onready var player_cam = $Camera3D
@onready var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

var _crouching: bool = false
var _crouch_tween: Tween

var _disable_move: bool


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_crouching = false
	_disable_move = false


func _process(delta):
	#Quit button NEEDS MOVING
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	#get each input relative to mouse
	var dir = Vector3()
	if Input.is_action_pressed("move_right") and not _disable_move:
		#Adds relative vector of the global normalized grid
		dir += global_basis.x
	if Input.is_action_pressed("move_left") and not _disable_move:
		#Adds relative vector of the global normalized grid
		dir += -global_basis.x
	if Input.is_action_pressed("move_backward") and not _disable_move:
		#Adds relative vector of the global normalized grid
		dir += global_basis.z
	if Input.is_action_pressed("move_forward") and not _disable_move:
		#Adds relative vector of the global normalized grid
		dir += -global_basis.z
	
	#Get initial horizontal velocity from direction
	dir = dir.normalized()
	var hvel = dir * _speed
	
	#requirements to crouch
	if Input.is_action_pressed("crouch") and is_on_floor() and not _crouching and not _disable_move:
		_crouching = true
		
		var crouch_target = player_cam.position
		crouch_target.y = _crouch_dist - 1
		_setup_crouch_tween(crouch_target)
	
	#requirements to uncrouch
	if not Input.is_action_pressed("crouch") and _crouching\
			and is_on_floor() and not $UncrouchShapecast.is_colliding():
		_crouching = false
		
		var stand_target = player_cam.position
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
	if is_on_floor() and Input.is_action_just_pressed("jump") and not _disable_move:
		velocity.y = _jump_height


func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	if Input.is_action_just_pressed("interact"):
		#cast a ray from camera to find a burnable object
		var screen_center = get_viewport().size * 0.5
		var from = player_cam.project_ray_origin(screen_center)
		var to = from + player_cam.project_ray_normal(screen_center) * _interact_dist
		
		#cast ray
		var ray_query = PhysicsRayQueryParameters3D.create(to,from)
		var ray_result = space_state.intersect_ray(ray_query)
		
		if ray_result:
			print("Hit " + str(ray_result.collider) + " at position " + str(ray_result.position))
			#DO INTERACTION THINGS HERE
		else:
			print("No object hit")



func _unhandled_input(event):
	#Input for mouse
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#rotate whole player horizontally
		rotate_y(-event.relative.x * _mouse_sensitivity * 0.001)
		#rotate camera node vertically
		player_cam.rotate_x(-event.relative.y * _mouse_sensitivity * 0.001)
		player_cam.rotation.x = clamp(player_cam.rotation.x, -1.4, 1.4)
		#Stop euler angles enabling player cam movement
		player_cam.rotation.y = 0
		player_cam.rotation.z = 0
		#print(player_cam.rotation)


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
	_crouch_tween.chain().tween_property(player_cam, "position", target, _crouch_speed)
	#When crouch is done, enable / disable raycasts and colliders
	_crouch_tween.chain().tween_callback(func():
		if _crouching:
			$StandingCollider.disabled = _crouching
		#enable checking for ceilings when crouching
		$UncrouchShapecast.enabled = _crouching
	)

