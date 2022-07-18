extends Node

var p1Name = 'Player 1'
var p2Name = 'Player 2'
var p3Name = 'Player 3'
var p4Name = 'Player 4'

var feedLine1 = 'Player 1 absolutely demolished Player 2'
var feedLine2 = 'Picked up a silenced pistol'
var feedLine3 = 'Player 3 is on a KILLING SPREE'
var feedLine4 = 'Troop Transporter has respawned'
var feedLine5 = 'Player 3: This is a terrible game'

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func pushTextToFeed(var newText):
	feedLine1 = feedLine2
	feedLine2 = feedLine3
	feedLine3 = feedLine4
	feedLine4 = feedLine5
	feedLine5 = newText
	
func clearTextFeed():
	feedLine1 = ''
	feedLine2 = ''
	feedLine3 = ''
	feedLine4 = ''
	feedLine5 = ''
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
