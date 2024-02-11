extends Node3D

var widthHeight: int
var vertices: PackedVector3Array
var UVs: PackedVector2Array
var normals: PackedVector3Array
var heightData: Dictionary
var sides: Variant

const grassMaterial = preload("res://materials/terrainMaterial.tres")
const waterMaterial = preload("res://materials/water.tres")

var waterHeight: int = Global.waterHeight
var lowestGround: int = Global.lowestGround
var lowestWater: int = Global.lowestWater

var col: int
var row: int


func setup(pHeightData: Variant, pWidthHeight: int, pSides: Variant, pCol: int, pRow: int)	:
	heightData = pHeightData
	widthHeight = pWidthHeight
	sides = pSides
	col = pCol
	row = pRow
	$DebugTileSizeMarkerBase.size.x = widthHeight
	$DebugTileSizeMarkerBase.size.y = widthHeight
	$DebugTileSizeMarkerBase.position.x = widthHeight / 2
	$DebugTileSizeMarkerBase.position.z = widthHeight / 2
	$Label3D.position.x = widthHeight / 2
	$Label3D.position.z = widthHeight / 2
	$Label3D.position.y = 8
	$Label3D.text = "Col:" + str(col) + " Row:" + str(row)
	$Grass.multimesh = $Grass.multimesh.duplicate()
	makeMapMesh()
	makeWaterMesh()		
	$Grass.draw()
			

func toggleBlockLabel(state):
	$Label3D.visible = state

func toggleCornerMarkers(state):
	$DebugEdgeMarker.visible = state
		
func resetArrays():
	vertices = PackedVector3Array()
	UVs = PackedVector2Array()
	normals = PackedVector3Array()				
		
func makeWaterMesh():
	resetArrays()	
	var v1 = Vector3(-0.01, waterHeight, -0.01)
	var v2 = Vector3(widthHeight + 0.01, waterHeight, -0.01)
	var v3 = Vector3(widthHeight + 0.01, waterHeight, widthHeight + 0.01)
	var v4 = Vector3(-0.01, waterHeight, widthHeight + 0.01)
	createTriangle(v1, v2, v4)
	createTriangle(v2, v3, v4)
	if sides.any:
		var v1b = Vector3(-0.01, lowestWater, -0.01)
		var v2b = Vector3(widthHeight + 0.01, lowestWater, -0.01)	
		var v3b = Vector3(widthHeight + 0.01, lowestWater, widthHeight + 0.01)
		var v4b = Vector3(-0.01, lowestWater, widthHeight + 0.01)
		if sides.top:
			createTriangle(v1, v2b, v2)
			createTriangle(v1, v1b, v2b)
		if sides.right:
			createTriangle(v2, v3b, v3)
			createTriangle(v2, v2b, v3b)	
		if sides.bottom:
			createTriangle(v3, v4b, v4)
			createTriangle(v3, v3b, v4b)
		if sides.left:		
			createTriangle(v4, v1b, v1)
			createTriangle(v4, v4b, v1b)		
	var tmpMesh = makeMesh(waterMaterial)
	$MeshInstance3DWater.mesh = tmpMesh
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(tmpMesh.get_faces())
	$MeshInstance3DWater/StaticBody3D/CollisionShape3D.shape = shape		
		
func makeMapMesh():
	resetArrays()	
	for x in range(0, widthHeight):
		for y in range(0, widthHeight):
			var v1 = Vector3(x, heightData[Vector2(x,y)], y)
			var v2 = Vector3(x + 1, heightData[Vector2(x + 1, y)], y)	
			var v3 = Vector3(x + 1, heightData[Vector2(x + 1,y + 1)], y + 1)
			var v4 = Vector3(x, heightData[Vector2(x, y + 1)], y + 1)
			createTriangle(v1, v2, v4)
			createTriangle(v2, v3, v4)	
			#var middle = (v1 + v2 + v3 + v4) / 4.0
			if v1.y > waterHeight: $Grass.add(v1 + Vector3(randf_range(-0.3, 0.3), -0.03, randf_range(-0.3, 0.3)))
			if v2.y > waterHeight: $Grass.add(v2 + Vector3(randf_range(-0.3, 0.3), -0.03, randf_range(-0.3, 0.3)))
			if v3.y > waterHeight: $Grass.add(v3 + Vector3(randf_range(-0.3, 0.3), -0.03, randf_range(-0.3, 0.3)))
			if v4.y > waterHeight: $Grass.add(v4 + Vector3(randf_range(-0.3, 0.3), -0.03, randf_range(-0.3, 0.3)))
		
			
	var tmpMesh = makeMesh(grassMaterial)
	$MeshInstance3D.mesh = tmpMesh
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(tmpMesh.get_faces())
	$MeshInstance3D/StaticBody3D/CollisionShape3D.shape = shape	
	if not sides.any: return # no sides to draw
	resetArrays()	
	if sides.left:
		for y in range(0, widthHeight):
			calculatedFixedXSide(0, y, true)
	if sides.right:
		for y in range(0, widthHeight):
			calculatedFixedXSide(widthHeight, y, false)
	if sides.top:
		for x in range(0, widthHeight):
			calculatedFixedYSide(x, 0, false)	
	if sides.bottom:
		for x in range(0, widthHeight):	
			calculatedFixedYSide(x, widthHeight, true)
	tmpMesh = makeMesh(grassMaterial)
	$MeshInstance3DSides.mesh = tmpMesh

func calculatedFixedXSide(x, y, flip):
	#if heightData[Vector2(x, y)] < waterHeight && heightData[Vector2(x, y + 1)] < waterHeight: return
	var topRight = Vector3(x, heightData[Vector2(x, y + 1)], y + 1)
	var topLeft = Vector3(x, heightData[Vector2(x, y)], y)
	var bottomRight = Vector3(x, lowestGround, y + 1)
	var bottomLeft = Vector3(x, lowestGround, y)
	if flip:	
		createTriangle(topLeft, bottomRight, bottomLeft)
		createTriangle(topRight, bottomRight, topLeft)	
	else:
		createTriangle(topRight, bottomLeft, bottomRight)
		createTriangle(topLeft, bottomLeft, topRight)					

func calculatedFixedYSide(x, y, flip):
	#if heightData[Vector2(x, y)] < waterHeight && heightData[Vector2(x + 1, y)] < waterHeight: return
	var topRight = Vector3(x + 1, heightData[Vector2(x + 1, y)], y)
	var topLeft = Vector3(x, heightData[Vector2(x, y)], y)
	var bottomRight = Vector3(x + 1, lowestGround, y)
	var bottomLeft = Vector3(x, lowestGround, y)
	if flip:	
		createTriangle(topLeft, bottomRight, bottomLeft)
		createTriangle(topRight, bottomRight, topLeft)	
	else:
		createTriangle(topRight, bottomLeft, bottomRight)
		createTriangle(topLeft, bottomLeft, topRight)					
			
func makeMesh(material):
	var tmpMesh = ArrayMesh.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(material)
	for v in vertices.size():
		st.set_color(Color(1,1,1))
		st.set_uv(UVs[v])
		st.set_normal(normals[v])
		st.add_vertex(vertices[v])
	#st.generate_normals()
	#st.generate_tangents() # maybe don't need this
	st.commit(tmpMesh)
	return tmpMesh
			
func createTriangle(vert1, vert2, vert3):
	vertices.push_back(vert1)
	vertices.push_back(vert2)
	vertices.push_back(vert3)
	UVs.push_back(Vector2(vert1.x/.5, -vert1.z/.5))
	UVs.push_back(Vector2(vert2.x/.5, -vert2.z/.5))
	UVs.push_back(Vector2(vert3.x/.5, -vert3.z/.5))
	var side1 = vert1-vert2
	var side2 = vert3-vert1
	var normal = side1.cross(side2).normalized()
	for i in range(0,3):
		normals.push_back(normal)
