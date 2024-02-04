extends Node


enum TERRAFORM_TYPE {NONE, SMOOTH, DITCH, RAISE, LOWER}

var terraformType: int
var terraformBrushSize: int


func setTerraformType(num: int):
	terraformType = num
	print("terraform type now " + str(terraformType))
	
func setTerraformBrushSize(num: int):
	terraformBrushSize = num
	print("terraform brushsize now " + str(terraformBrushSize))

func getTerraformBrushSize() -> int:
	return terraformBrushSize
	
func getTerraformType() -> int:
	return terraformType
