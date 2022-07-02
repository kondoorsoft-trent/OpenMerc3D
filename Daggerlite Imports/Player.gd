extends KinematicBody


var move_speed = Globals.gMoveSpeed
const look_sens = 0.5
var playerMaxHealth = Globals.gPlayerMaxHealth
var playerHealth = Globals.gPlayerHealth
const faction = "ally"
var playerGold = Globals.gPlayerGold
var playerDamage = Globals.gPlayerDamage
var weaponSheath = false
var overworldPosition = Globals.gOverworldPosition
var overworldHeading = Globals.gOverworldHeading

onready var playerMovement = true
onready var anim_player = $AnimationPlayer
onready var anim_player2 = $AnimationPlayerSword
onready var raycast = $RayCast
onready var collision1 = $CollisionShape
onready var camera1 = $Camera
onready var isSprintEnabled = false
onready var frontTouch = $TouchMeFront
onready var healthText = $CanvasLayer/Control/HealthCurrent
onready var maxHealthText = $CanvasLayer/Control/HealthMax
onready var moneyText =$CanvasLayer/Control/Money
onready var areaText = $CanvasLayer/Control/AreaLabel
onready var magicSound = $MagicSound
onready var swordSound = $SwordSound
onready var rightHand = $CanvasLayer/Control/Sprite
onready var leftHand = $CanvasLayer/Control/Sprite2
onready var SwordHitbox = $SwordZone/CollisionShape
onready var swordConnectSound = $SwordConnectSound 
onready var magicDamage
var meleeDamage
onready var animationPlayerHealthBar = $AnimationPlayerHealthBar
onready var gameFeed = $CanvasLayer/Control/GameFeed

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	yield(get_tree(), "idle_frame")
	get_tree().call_group("enemies", "set_player", self)
	anim_player2.play("idle")
	readCachedData()
	magicDamage = playerDamage
	meleeDamage = magicDamage * 3
func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= look_sens * event.relative.x
		rotation_degrees.x -= look_sens * event.relative.y



func _process(delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	if Input.is_action_pressed("restart"):
		die()
	gameFeed.set_bbcode(String(Globals.feedLine4 + "\n" + Globals.feedLine3 + "\n" + Globals.feedLine2 + "\n" + Globals.feedLine1))


func _physics_process(delta):
	var move_vec = Vector3()
	var gravity_vec = Vector3()
	
	if(playerMovement == true):
		if Input.is_action_pressed("ui_up"):
			move_vec.z -= 1
		if Input.is_action_pressed("ui_down"):
			move_vec.z += 1
		if Input.is_action_pressed("ui_left"):
			move_vec.x -= 1
		if Input.is_action_pressed("ui_right"):
			move_vec.x += 1
	if Input.is_action_pressed("look_left"):
		rotation_degrees.y += 3
	if Input.is_action_pressed("look_right"):
		rotation_degrees.y -= 3	
	if Input.is_action_pressed("look_up"):
			rotation_degrees.x += 3
	if Input.is_action_pressed("look_down"):
			rotation_degrees.x -= 3
	if Input.is_action_just_pressed("toggle_sprint"):
		move_speed = 15
	if Input.is_action_just_released("toggle_sprint"):
		move_speed = 10
	if Input.is_action_pressed("reset_look"):
		rotation_degrees.x = 0
		rotation_degrees.z = 0

	magicDamage = playerDamage * 1
	meleeDamage = magicDamage * 3
	
	
	#Health bar calculations below
	
	if playerHealth / playerMaxHealth == 1:
		animationPlayerHealthBar.play("100")
	if float(playerHealth) / float(playerMaxHealth) >= .9 && float(playerHealth) / float(playerMaxHealth) < 1:
		animationPlayerHealthBar.play("90")
	if float(playerHealth) / float(playerMaxHealth) >= .8 && float(playerHealth) / float(playerMaxHealth) < .9:
		animationPlayerHealthBar.play("80")
	if float(playerHealth) / float(playerMaxHealth) >= .7 && float(playerHealth) / float(playerMaxHealth) < .8:
		animationPlayerHealthBar.play("70")
	if float(playerHealth) / float(playerMaxHealth) >= .6 && float(playerHealth) / float(playerMaxHealth) < .7:
		animationPlayerHealthBar.play("60")
	if float(playerHealth) / float(playerMaxHealth) >= .5 && float(playerHealth) / float(playerMaxHealth) < .6:
		animationPlayerHealthBar.play("50")
	if float(playerHealth) / float(playerMaxHealth) >= .4 && float(playerHealth) / float(playerMaxHealth) < .5:
		animationPlayerHealthBar.play("40")
	if float(playerHealth) / float(playerMaxHealth) >= .3 && float(playerHealth) / float(playerMaxHealth) < .4:
		animationPlayerHealthBar.play("30")
	if float(playerHealth) / float(playerMaxHealth) >= .2 && float(playerHealth) / float(playerMaxHealth) < .3:
		animationPlayerHealthBar.play("20")
	if float(playerHealth) / float(playerMaxHealth) >= .1 && float(playerHealth) / float(playerMaxHealth) < .2:
		animationPlayerHealthBar.play("10")
	
	
	
	
	healthText.set_bbcode("" + String(playerHealth) + "")
	maxHealthText.set_text(String(playerMaxHealth))
	moneyText.set_bbcode("[center] " + String(playerGold) + " [/center]")
	

	
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)

	gravity_vec.y -= 3200
	
	move_and_slide_with_snap(gravity_vec * delta, Vector3(0, 0, 0), Vector3(0, 1, 0), true)
	move_and_collide(move_vec * move_speed * delta)


	if Input.is_action_pressed("Magic1") and !anim_player.is_playing(): #Magic Flash Attack
		anim_player.play("Magic Fire")
		magicSound.play()
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("takeDamage"):
			Globals.pushText("Your magic fire sears! (" + String(magicDamage) + " pts)")
			coll.takeDamage(magicDamage)
			
	if Input.is_action_pressed("Melee1") and !anim_player2.is_playing(): #Sword Swing Attack
		anim_player2.play("Sword Swing")
		swordSound.play()
		SwordHitbox.disabled = false
	
			
	if playerHealth <= 0:
		die()


			
func takeDamage(hitAmount):
	playerHealth -= hitAmount

func die():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()


func _on_Area_body_entered(body): #do damage with the sword
	if body.has_method("takeDamage") and SwordHitbox.disabled == false:
		swordConnectSound.play()
		Globals.pushText("You slash your blade! (" + String(meleeDamage) + " pts)")
		body.takeDamage(meleeDamage)
		SwordHitbox.disabled = true
		

func _on_AnimationPlayerSword_animation_finished(anim_name):
	SwordHitbox.disabled = true
	
func setPlayerOverworldCoords(var x, var y, var z, var heading):
	overworldPosition = Vector3(x,y,z)
	overworldHeading = Vector3(0,heading,0)
func getPlayerOverworldCoords():
	return overworldPosition
func getPlayerOverworldHeading():
	return overworldHeading

func cachePlayerData():
	Globals.gPlayerHealth = playerHealth
	Globals.gPlayerMaxHealth = playerMaxHealth
	Globals.gPlayerDamage = playerDamage
	Globals.gPlayerGold = playerGold
	Globals.gOverworldPosition = overworldPosition
	Globals.gOverworldHeading = overworldHeading
	Globals.gMoveSpeed = move_speed
func readCachedData():	
	playerHealth = Globals.gPlayerHealth
	playerMaxHealth = Globals.gPlayerMaxHealth
	playerDamage = Globals.gPlayerDamage
	playerGold = Globals.gPlayerGold
	overworldPosition = Globals.gOverworldPosition
	overworldHeading = Globals.gOverworldHeading
	move_speed = Globals.gMoveSpeed

func setRegion(var RegionName):
	areaText.set_bbcode("[center]" + RegionName + "[/center]")
	
