extends Node2D

onready var nucleotid1 = $RnaNucleotid
onready var nucleotid2 = $RnaNucleotid2
onready var nucleotid3 = $RnaNucleotid3

var matches_to_amino = ""
var char_codon = ""
var amino_char = ""

func initialize_codon(n1,n2,n3):
	nucleotid1.initialize_char(n1)
	nucleotid2.initialize_char(n2)
	nucleotid3.initialize_char(n3)
	
	char_codon = n1 + n2 + n3
	amino_char = _find_matching_amino()


func _find_matching_amino():
	for k in Mappings.amino_codons.keys():
		for codon in Mappings.amino_codons[k]:
			if codon == char_codon:
				return k
	return "M"
