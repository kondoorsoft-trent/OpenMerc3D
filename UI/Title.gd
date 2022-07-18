extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	Globals.p1Name = $Control/LineEdit.get_text()
	Globals.pushTextToFeed(Globals.p1Name + " has entered the game.")
	get_tree().change_scene("res://Levels/TestMap.tscn")


func _on_LineEdit_text_entered(new_text):
	Globals.p1Name = $Control/LineEdit.get_text()
	Globals.pushTextToFeed(Globals.p1Name + " has entered the game.")
	get_tree().change_scene("res://Levels/TestMap.tscn")
