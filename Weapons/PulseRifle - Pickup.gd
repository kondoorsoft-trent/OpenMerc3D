extends StaticBody


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body.has_method("setInteractLabel"):
		body.setInteractLabel("Press X to pick up Pulse Rifle")
		body.setPickup(1)



func _on_Area_body_exited(body):
	if body.has_method("setInteractLabel"):
		body.clearInteractLabel()
		body.clearPickup()
