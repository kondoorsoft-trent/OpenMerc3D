extends KinematicBody

onready var AnimationPlayerGun = $HUD/AnimationPlayerGun
onready var animationPlayerHealthBar = $HUD/AnimationPlayerHealth
onready var ShootSound = $HUD/ShootSound
onready var ReloadSound = $HUD/ReloadSound

onready var raycast = $HeadHitbox/Camera/RayCast
onready var camera1 = $HeadHitbox/Camera
onready var isSprintEnabled = false
onready var healthText = $HUD/HealthCurrent #TODO
onready var areaText = $HUD/AreaLabel #TODO
onready var gunSprite = $HUD/Gun #TODO
onready var AngleOfFreedom = 80
onready var jumpTimer = 0
onready var isJumping = false
onready var isDelayingJump = false
onready var jumpDelayTimer = 0
var camXSens = .1
var camYSens = .1
var moveSpeedDefault = 10
var moveSpeed = 10
var fov = 90
var viewDistanceNear = 0.05
var viewDistanceFar = 100

onready var gameFeed = $CanvasLayer/Control/GameFeed
var gravity = Vector3(0,-100,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	camera1.set_perspective(fov, viewDistanceNear, viewDistanceFar)

func _physics_process(delta):
	var velocity = Input.get_vector("leftP1", "rightP1", "forwardP1", "backP1")
	velocity = velocity.normalized()
	var velocity3D = Vector3(velocity.x , 0, velocity.y)
	velocity3D = velocity3D.rotated(Vector3(0, 1, 0), rotation.y)
	velocity.x = velocity3D.x
	velocity.y = velocity3D.z
	move_and_collide(Vector3(velocity.x, 0, velocity.y) * moveSpeed * delta)
	if isJumping == false:
		move_and_slide_with_snap(gravity * delta, Vector3(0, 0, 0), Vector3(0, 1, 0), true)
	elif jumpTimer < 5:
		move_and_slide_with_snap(Vector3(0,2000,0) * delta, Vector3(0, 0, 0), Vector3(0, 1, 0), true)
		jumpTimer += 1
		
	if !is_on_floor():
		gravity.y -= 50
	if is_on_floor():
		gravity.y = -100
	if jumpTimer >= 5:
		isJumping = false
		jumpTimer = 0
		isDelayingJump = true
		
	if isDelayingJump == true && jumpDelayTimer < 30:
		jumpDelayTimer +=1
	elif isDelayingJump == true && jumpDelayTimer >= 30:
		jumpDelayTimer = 0
		isDelayingJump = false
	
	
	#BUTTON INPUTS
	
	if Input.is_action_pressed("lookUpP1"):
		var lookIntensity = Input.get_action_strength("lookUpP1")
		$HeadHitbox/Camera.rotate_x(lookIntensity * camXSens)
	if Input.is_action_pressed("lookDownP1"):
		var lookIntensity = Input.get_action_strength("lookDownP1")
		$HeadHitbox/Camera.rotate_x(lookIntensity * camXSens * -1)
	if Input.is_action_pressed("lookLeftP1"):
		var lookIntensity = Input.get_action_strength("lookLeftP1")
		rotate_y(lookIntensity * camYSens)
	if Input.is_action_pressed("lookRightP1"):
		var lookIntensity = Input.get_action_strength("lookRightP1")
		rotate_y(lookIntensity * camYSens * -1)
	var camera_rot = $HeadHitbox/Camera.rotation_degrees
	camera_rot.x = clamp(camera_rot.x,  (AngleOfFreedom * -1) - 90, AngleOfFreedom - 90)
	$HeadHitbox/Camera.rotation_degrees = camera_rot
	
	
	
	if Input.is_action_pressed("jumpP1") && is_on_floor() && isDelayingJump == false:
		isJumping = true
		jumpTimer = 0
		
	if Input.is_action_just_pressed("crouchP1"):
		$HeadHitbox.translation.y -= .75
		moveSpeed = moveSpeedDefault / 2
	if Input.is_action_just_released("crouchP1"):
		$HeadHitbox.translation.y += .75
		moveSpeed = moveSpeedDefault
	if Input.is_action_just_pressed("sprintP1"):
		camera1.set_perspective((fov * 1.2), viewDistanceNear, viewDistanceFar)
		moveSpeed = moveSpeedDefault * 1.5
	if Input.is_action_just_released("sprintP1"):
		camera1.set_perspective(fov, viewDistanceNear, viewDistanceFar)
		moveSpeed = moveSpeedDefault
	
	
		
	if Input.is_action_just_pressed("shootP1") && !AnimationPlayerGun.is_playing():
		AnimationPlayerGun.play("Shoot")
		ShootSound.play()
		ReloadSound.play()
		
	
