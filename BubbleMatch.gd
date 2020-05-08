extends Node2D

var AminoContact = preload("res://AminoContact.tscn")
var Amino = preload("res://Aminoacid.tscn")
var RnaNucleotid = preload("res://RnaNucleotid.tscn")
var Codon = preload("res://Codon.tscn")

onready var container = $container
onready var codones = $codones
onready var selector = $Selector
onready var contacts = $contacts
onready var aminos = $aminos
onready var tween = $Tween
onready var holdingAmino = $Selector/AminoContact

var initial_codon_count = 8
var noice_amino_count_total = 30

enum GameState {
	INTRODUCTION,
	SELECTING_START,
	ASSIGNING_AMINOS,
	FINISHED
}

var state = GameState.SELECTING_START

var aminoacid_table = Mappings.amino_codons

var aminoacid_start = "aug"
var aminoacid_end = ["uaa","uag","uga"]

var expected_result = []
var remaining_aminos = []

var last_used_pos = 0
var selector_logical_pos = 0

var sparse_used_aminos = {
	# idx -> amino char representation
}

func random_from_list(l):
	return l[randi() % l.size()]

func _ready():
	OS.set_window_size(Vector2(1600, 1200))
	var last_pos = 0
	randomize()
	
	var noice_amino_prefix = randi() % noice_amino_count_total
	
	# Random prefix
	for n in range(0,noice_amino_prefix):
		_add_nucleotid("uagc"[randi() % 4])

	for c in aminoacid_start:
		_add_nucleotid(c)
		
	for n in range(0,initial_codon_count):
		var aminoKey = random_from_list(aminoacid_table.keys())
		expected_result.push_back(aminoKey)
		var codon = random_from_list(aminoacid_table.get(aminoKey))
		for c in codon:
			_add_nucleotid(c)
			
	for c in aminoacid_end[randi() % aminoacid_end.size()]:
		_add_nucleotid(c)
		
	#Random sufix
	for n in range(0,noice_amino_count_total - noice_amino_prefix):
		_add_nucleotid("uagc"[randi() % 4])
			
	var char_aminos = expected_result.duplicate()
	char_aminos.shuffle()
	
	var amino_pos = 0
	for a in char_aminos:
		var amino = Amino.instance()
		aminos.add_child(amino)
		amino.initialize_char(a)
		amino.position.x = amino_pos
		amino_pos += 24
		remaining_aminos.push_back(amino)
	
	holdingAmino.initialize_char("M")


func _add_nucleotid(c):
	var nucleotid = RnaNucleotid.instance()
	nucleotid.initialize_char(c)
	container.add_child(nucleotid)
	nucleotid.position.x = last_used_pos
	last_used_pos += nucleotid.get_rect().size.x
	return nucleotid

func _restart_game():
	get_tree().reload_current_scene()

func _game_over():
	_restart_game()

func _input(event):
	
	if event.is_action_pressed("ui_reset"):
		_restart_game()
	
	match state:
		GameState.SELECTING_START:
			if event.is_action_pressed("ui_left") and selector_logical_pos > 0: 
				selector_logical_pos -= 1
				selector.global_position.x = container.get_child(selector_logical_pos).global_position.x
				
			if event.is_action_pressed("ui_right") and selector_logical_pos < container.get_child_count() - 3: 
				selector_logical_pos += 1
				selector.global_position.x = container.get_child(selector_logical_pos).global_position.x
				
			if event.is_action_pressed("ui_accept"): 
				_on_start_amino_fired()

		GameState.ASSIGNING_AMINOS:		
			if event.is_action_pressed("ui_left") and selector_logical_pos > 0: 
				selector_logical_pos -= 1
				selector.global_position.x = codones.get_child(selector_logical_pos).global_position.x
				
			if event.is_action_pressed("ui_right") and selector_logical_pos < codones.get_child_count() - 1: 
				selector_logical_pos += 1
				selector.global_position.x = codones.get_child(selector_logical_pos).global_position.x
				
			if event.is_action_pressed("ui_accept"): 
				_on_amino_fired()

func _on_start_amino_fired():
	print(selector_logical_pos)
	var prefix_to_remove = []
	for n in range(0, selector_logical_pos):
		prefix_to_remove.append(container.get_child(n))
		
	for s in prefix_to_remove:
		container.remove_child(s)
	
	var nucleotids = container.get_children()
	var is_first_codon = true
	var codon_chars = []
	for n in nucleotids:
		codon_chars.push_back(n)
		if codon_chars.size() == 3:
			
			if is_first_codon:
				if aminoacid_start != codon_chars[0].char_representation + codon_chars[1].char_representation + codon_chars[2].char_representation:
					_game_over()
					
				is_first_codon = false
				
			var codon = Codon.instance()
			codones.add_child(codon)
			codon.global_position = codon_chars[0].global_position
			codon.initialize_codon(
				codon_chars[0].char_representation, 
				codon_chars[1].char_representation, 
				codon_chars[2].char_representation)
				
			codon_chars.clear()
			
	
	for c in codon_chars:
		container.remove_child(c)
	
	selector_logical_pos = 0
	state = GameState.ASSIGNING_AMINOS
	_on_amino_fired()
		
		
func _on_amino_fired():
	if not holdingAmino:
		return 
	
	if sparse_used_aminos.has(selector_logical_pos):
		return
	
	sparse_used_aminos[selector_logical_pos] = holdingAmino.aminoacid.char_representation
	
	if holdingAmino.aminoacid.char_representation != codones.get_child(selector_logical_pos).amino_char:
		print("Wrong matching!!")
	else:
		print("Matched correctly")
	
	var sendingAmino = holdingAmino
	holdingAmino = AminoContact.instance()
	
	selector.add_child(holdingAmino)
	holdingAmino.global_position = sendingAmino.global_position
	
	selector.remove_child(sendingAmino)
	contacts.add_child(sendingAmino)
	sendingAmino.global_position = holdingAmino.global_position
	
	
	tween.interpolate_property(sendingAmino, "global_position:y", holdingAmino.global_position.y, container.global_position.y + 12, 0.4, 
			Tween.TRANS_EXPO, Tween.EASE_OUT
	)

	if not remaining_aminos.empty():
		var aminoToHold = remaining_aminos.pop_front()
		aminoToHold.disable()
		holdingAmino.initialize_char(aminoToHold.char_representation)
	else:
		selector.remove_child(holdingAmino)
		holdingAmino = null
	
	tween.start()
