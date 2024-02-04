extends Node

var key: String
var row: int
var col: int
var block: Variant = null
var blockSet = false

func setup(pKey: String, pCol: int, pRow: int):
	key = pKey
	row = pRow
	col = pCol

func setBlock(pBlock: Variant):
	block = pBlock
	blockSet = true
	
func clearBlock():
	block.name = "deleting"
	block.queue_free()
	block = null
	blockSet = false
