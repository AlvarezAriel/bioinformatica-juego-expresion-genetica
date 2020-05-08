extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var aminoacid = $Aminoacid

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize_char(c):
	aminoacid.initialize_char(c)
