extends Sprite

class_name Nucleotid

onready var tween:Tween = $Tween

var index = 0
var char_representation = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize_char(c):
	match c:
		"a":
			frame = 0
		"g":
			frame = 1
		"u":
			frame = 2
		"c":
			frame = 3
	
	char_representation = c

func moveTo(point:Vector2):
	tween.interpolate_property(self, "position", position, point, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
