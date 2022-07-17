extends StaticBody

onready var InteractLabel = "Press X to pick up Pulse Rifle"
onready var WeaponID = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func pick_up_and_despawn():
	print('Despawning');
