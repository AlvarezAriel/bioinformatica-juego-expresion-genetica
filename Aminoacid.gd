extends Sprite


var char_representation = ""

var image_mapping = {
	"F":13,
	"L":10,
	"I":9,
	"M":12,
	"V":19,
	"S":15,
	"P":14,
	"T":16,
	"A":0,
	"Y":18,
	"H":8,
	"Q":5,
	"N":2,
	"K":11,
	"D":3,
	"E":6,
	"C":4,
	"W":17,
	"R":1,
	"G":7
}

func initialize_char(c):
	frame = image_mapping[c]
	char_representation = c

func disable():
	modulate = Color.lightslategray
