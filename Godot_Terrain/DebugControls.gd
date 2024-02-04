extends VBoxContainer


func _ready():
	updateTerraformBrushSize()
	updateTerraformType()

func updateTerraformBrushSize():
	$TerraformBrushSizeLabel.text = "Terraform Size " + str($TerraformBrushSizeSelector.value)
	$"../../TerraformController".setTerraformBrushSize($TerraformBrushSizeSelector.value)

func updateTerraformType():
	$"../../TerraformController".setTerraformType($TerraformTypeSelector.selected)

func _on_block_labels_toggled(toggled_on):
	for mapBlock in $"../../MapBlocks".get_children():
		mapBlock.toggleBlockLabel(toggled_on)


func _on_terraform_type_selector_item_selected(index):
	updateTerraformType()


func _on_terraform_brush_size_selector_drag_ended(value_changed):
	updateTerraformBrushSize()


func _on_corner_markers_toggled(toggled_on):
	for mapBlock in $"../../MapBlocks".get_children():
		mapBlock.toggleCornerMarkers(toggled_on)
