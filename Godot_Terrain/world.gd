extends Node3D

var noise: FastNoiseLite = FastNoiseLite.new()
var mapBlockScene = preload("res://MapBlock.tscn")
var sidesClass = preload("res://classes/sides.gd")
var mapBlockDataClass = preload("res://classes/mapBlockData.gd")
var mapBlocksData = {}

var heights: Dictionary = {}

const EXTRA_HEIGHT = 5
const HEIGHT_VARIATION = 10

func getKey (x, y) -> String:
	return str(x) + "_" + str(y)	
	
func getMapBlockKeyFrom2DWorldPos(pos: Vector2) -> String:
	pos.x -= Global.halfMapBlockSize
	pos.y -= Global.halfMapBlockSize
	var col: int = round(pos.x / Global.mapBlockSize)
	if col == -0: col = 0
	var row: int = round(pos.y / Global.mapBlockSize)
	if row == -0: row = 0
	#print("geMapBlockKey col:", col, " row:", row)
	return getKey(col, row)

func getHeight(vertexPos: Vector2):
	return heights[vertexPos]

func _ready():
	randomize()
	noise.set_noise_type(noise.TYPE_PERLIN)
	noise.set_seed(randf())
	var count = 10
	for col in range(-count, count):
		for row in range(-count, count):
			var blockDataClass = mapBlockDataClass.new()
			blockDataClass.setup(getKey(col, row), col, row) 
			mapBlocksData[getKey(col, row)] = blockDataClass
	for key in mapBlocksData:
		createRandomMap(mapBlocksData[key])
	$Roads.addCentreRoad()

func getRequiredSides(b: Variant):
	var sides = sidesClass.new()
	if mapBlocksData.has(getKey(b.col - 1, b.row)): sides.clearLeft()
	if mapBlocksData.has(getKey(b.col + 1, b.row)): sides.clearRight()
	if mapBlocksData.has(getKey(b.col, b.row - 1)): sides.clearTop()
	if mapBlocksData.has(getKey(b.col, b.row + 1)): sides.clearBottom()
	return sides

func createRandomMap(b: Variant):
	var heightData: Dictionary = {}
	var worldX: int = b.col * Global.mapBlockSize 
	var worldY: int = b.row * Global.mapBlockSize
	for x in range(0, Global.mapBlockSize + 1):
		for y in range(0, Global.mapBlockSize + 1):
			var vertexPos = Vector2(x + worldX, y + worldY)
			var height = (noise.get_noise_2d(vertexPos.x, vertexPos.y) * HEIGHT_VARIATION) + EXTRA_HEIGHT
			heightData[Vector2(x,y)] = height
			heights[vertexPos] = height
			$Roads.addEmptyRoad(vertexPos)
	renderMapBlock(b)		
			
			
func renderMapBlock(b: Variant):
	var heightData: Dictionary = {}
	var worldX: int = b.col * Global.mapBlockSize
	var worldY: int = b.row * Global.mapBlockSize		
	for x in range(0, Global.mapBlockSize + 1):
		for y in range(0, Global.mapBlockSize + 1):
			var vertexPos = Vector2(x + worldX, y + worldY)
			heightData[Vector2(x,y)] = heights[vertexPos]
	var mapBlock = mapBlockScene.instantiate()
	mapBlock.setup(heightData, Global.mapBlockSize, getRequiredSides(b), b.col, b.row)
	mapBlock.position.x += worldX
	mapBlock.position.z += worldY
	mapBlock.name = b.key
	$MapBlocks.add_child(mapBlock)
	b.setBlock(mapBlock)


func clicked(pos: Vector3):
	terraform(pos, $TerraformController.getTerraformType())
	
func terraform(pos: Vector3, terraformType: int):
	var tc = $TerraformController
	if terraformType == tc.TERRAFORM_TYPE.NONE: return 
	if terraformType in [tc.TERRAFORM_TYPE.SMOOTH, tc.TERRAFORM_TYPE.RAISE, tc.TERRAFORM_TYPE.LOWER]: terraformArea(pos, terraformType)
	if terraformType == tc.TERRAFORM_TYPE.DITCH: terraformDitch(pos)

func terraformArea(pos: Vector3, terraformType):
	var brushSize: int = $TerraformController.getTerraformBrushSize()
	var totalPoints: int = 0
	var totalHeight: float = 0.0
	var mapBlocksAffected: Dictionary = {}
	var vertices: PackedVector2Array = []
	var offMapVertices: PackedVector2Array = []
	for x in range(-brushSize, brushSize + 1):
		for y in range(-brushSize, brushSize + 1):
			var vertexPos: Vector2 = Vector2(pos.x + x , pos.z + y)
			var mapBlockKey = getMapBlockKeyFrom2DWorldPos(vertexPos)
			vertices.append(vertexPos)
			if not heights.has(vertexPos):
				print("off map verex found:", vertexPos)
				offMapVertices.append(vertexPos)
			else:
				if mapBlocksData.has(mapBlockKey) && mapBlocksData[mapBlockKey].blockSet: mapBlocksAffected[mapBlockKey] = true	
				totalPoints += 1
				totalHeight += heights[vertexPos]
			
	var averageHeight: float = totalHeight / totalPoints	
	if abs(averageHeight) < 0.01: averageHeight = -0.01
	
	for vertexPos in offMapVertices:
		print("adding off map verex:", vertexPos)
		heights[vertexPos] = averageHeight ## add offmap vertex to main list so it can render the edges well(also if this bit of map gets added this height will be used
	
	var height: float
	var tc = $TerraformController
	match(terraformType):
		tc.TERRAFORM_TYPE.SMOOTH: height = averageHeight
		tc.TERRAFORM_TYPE.RAISE: height = averageHeight + 1
		tc.TERRAFORM_TYPE.LOWER: height = averageHeight - 1
	
	if height < Global.lowestGround: height = Global.lowestGround
	for vertexPos in vertices:
		heights[vertexPos] = height
	updateWorldBlocks(mapBlocksAffected)
	
func terraformDitch(pos:Vector3):
	var brushSize: int = $TerraformController.getTerraformBrushSize()
	var potentialVertices: PackedVector2Array = []
	var pos2d = Vector2(pos.x, pos.z)
	
	var mapBlocksAffected: Dictionary = {}
	for x in range(-brushSize, brushSize + 1):
		for y in range(-brushSize, brushSize + 1):
			var vertexPos: Vector2 = Vector2(pos.x + x , pos.z + y)	
			var distanceFromCenter = vertexPos.distance_to(pos2d)
			if distanceFromCenter > brushSize: continue
			var newDepth = pos.y - (lerp(brushSize, 0, (1.0 / brushSize) * distanceFromCenter))
			if not heights.has(vertexPos): heights[vertexPos] = 100 # set really high so always above any real land - it is about to get reduced
			if heights[vertexPos] > newDepth: heights[vertexPos] = newDepth
			var mapBlockKey = getMapBlockKeyFrom2DWorldPos(vertexPos)
			if mapBlocksData.has(mapBlockKey) && mapBlocksData[mapBlockKey].blockSet: mapBlocksAffected[mapBlockKey] = true	
	updateWorldBlocks(mapBlocksAffected)
	
	
func updateWorldBlocks(mapBlocksToUpdate: Dictionary):
	for key in mapBlocksToUpdate:
		var b = mapBlocksData[key]
		b.clearBlock()
		renderMapBlock(b)

