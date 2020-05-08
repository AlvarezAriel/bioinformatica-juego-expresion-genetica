extends Node2D


onready var nucleotid_path = $Path2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var n = $nucleotids.get_children()
	var index = 0
	for nucleotid in n:
		nucleotid.index = index
		nucleotid.position = nucleotid_path.curve.get_point_position(index)
		index += 1 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	var n = $nucleotids.get_children()
	for nucleotid in n:
		nucleotid.moveTo(nucleotid_path.curve.get_point_position(nucleotid.index))
		nucleotid.index +=1
		if nucleotid.index >= nucleotid_path.curve.get_point_count():
			nucleotid.index = 0
