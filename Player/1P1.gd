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
onready var currentWeapon = 2
onready var shootPulseRifle = $ShootSounds/PulseRifle
onready var shootPistol = $ShootSounds/Pistol
onready var shootPumpShotgun = $ShootSounds/PumpShotgun
onready var shootSniper = $ShootSounds/Sniper
onready var interactLabel = $HUD/InteractLabel

var camXSens = .1
var camYSens = .1
var moveSpeedDefault = 10
var moveSpeed = 10
var fov = 90
var viewDistanceNear = 0.05
var viewDistanceFar = 100
var verticalGravityMultiplier = 40
var jump_speed = 15

var weaponPickupId = 0
var canPickUpWeapon = false
var mouse_sensitivity = 0.01

onready var gameFeed = $CanvasLayer/Control/GameFeed
var vertical_velocity = Vector3.DOWN

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide & capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().set_input_as_handled()

	interactLabel.set_bbcode("")
	camera1.set_perspective(fov, viewDistanceNear, viewDistanceFar)
	if currentWeapon == 0:
		AnimationPlayerGun.play("PR_Idle")
	if currentWeapon == 1:
		AnimationPlayerGun.play("PR_Idle")
	if currentWeapon == 2:
		AnimationPlayerGun.play("Pistol_Idle")
	if currentWeapon == 3:
		AnimationPlayerGun.play("Pump_Idle")
	if currentWeapon == 4:
		AnimationPlayerGun.play("Sniper_Idle")

func _input(event):
	# unlock the mouse when player wants to leave the game window
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().set_input_as_handled()
	# capture the mouse again after leaving the game window
	if event.is_action_pressed("shootP1") && Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().set_input_as_handled()
	# rotate camera to mouse position
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera1.rotate_x(-event.relative.y * mouse_sensitivity)
		var camera_rot = camera1.rotation_degrees
		camera_rot.x = clamp(camera_rot.x,  (AngleOfFreedom * -1) - 90, AngleOfFreedom - 90)
		camera1.rotation_degrees = camera_rot

func _physics_process(delta):
	var velocity = Input.get_vector("leftP1", "rightP1", "forwardP1", "backP1")
	velocity = velocity.normalized()
	var velocity3D = Vector3(velocity.x , 0, velocity.y)
	velocity3D = velocity3D.rotated(Vector3.UP, rotation.y)
	velocity.x = velocity3D.x
	velocity.y = velocity3D.z
	move_and_collide(Vector3(velocity.x, 0, velocity.y) * moveSpeed * delta)

	# fall
	vertical_velocity += verticalGravityMultiplier * delta * Vector3.DOWN
	vertical_velocity = move_and_slide_with_snap(vertical_velocity, Vector3.ZERO, Vector3.UP, true)
	
	if (is_on_floor()):
		vertical_velocity = Vector3.ZERO	
	
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
	
	
	if Input.is_action_pressed("jumpP1") && is_on_floor():
		vertical_velocity = jump_speed * Vector3.UP
		
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
	
	if currentWeapon == 0:
		pass
	if currentWeapon == 1: #Pulse Rifle
		if Input.is_action_pressed("shootP1") && !AnimationPlayerGun.is_playing():
			AnimationPlayerGun.play("PR_Shoot")
			shootSniper.play()

	if currentWeapon == 2: #Pistol
		if Input.is_action_just_pressed("shootP1") && !AnimationPlayerGun.is_playing():
			AnimationPlayerGun.play("Pistol_Shoot")
			shootPistol.play()
	if currentWeapon == 3: #Pump Shotgun
		if Input.is_action_just_pressed("shootP1") && !AnimationPlayerGun.is_playing():
			AnimationPlayerGun.play("Pump_Shoot")
			shootPumpShotgun.play()
	if currentWeapon == 4: #Sniper Rifle
		if Input.is_action_just_pressed("shootP1") && !AnimationPlayerGun.is_playing():
			AnimationPlayerGun.play("Sniper_Shoot")
			shootSniper.play()
	
	
	if canPickUpWeapon && Input.is_action_just_pressed("interactP1"):
			pickUpGun(weaponPickupId)
	
	
	
	
	
	
	
	
	
	
func pickUpGun(var newGunId):
	currentWeapon = newGunId
	if currentWeapon == 0:
		AnimationPlayerGun.play("PR_Idle")
	if currentWeapon == 1:
		AnimationPlayerGun.play("PR_Idle")
	if currentWeapon == 2:
		AnimationPlayerGun.play("Pistol_Idle")
	if currentWeapon == 3:
		AnimationPlayerGun.play("Pump_Idle")
	if currentWeapon == 4:
		AnimationPlayerGun.play("Sniper_Idle")
		
func setInteractLabel(var newText):
	interactLabel.set_bbcode("[center] " + String(newText) + "[/center]")
func clearInteractLabel():
	interactLabel.set_bbcode("")

func setPickup(var newWeaponId):
	canPickUpWeapon = true
	weaponPickupId = newWeaponId
func clearPickup():
	canPickUpWeapon = false
	weaponPickupId = 0
