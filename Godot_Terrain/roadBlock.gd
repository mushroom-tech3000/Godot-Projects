extends Node3D

var vertices: PackedVector3Array
var UVs: PackedVector2Array
var normals: PackedVector3Array

const roadMaterial = preload("res://materials/pavingStones.tres")
const QUATER = 0.25
const HALF = 0.75

func setup(height, left, top, right, bottom, leftHeight, topHeight, rightHeight, bottomHeight):
	var topLeft = Vector3(-QUATER, height, -QUATER)
	var topRight = Vector3(QUATER, height, -QUATER)	
	var bottomRight = Vector3(QUATER, height, QUATER)
	var bottomLeft = Vector3(-QUATER, height, QUATER)
	createTriangle(topLeft, topRight, bottomLeft)
	createTriangle(topRight, bottomRight, bottomLeft)	
	
	if left:
		var left_top = Vector3(-HALF, leftHeight, -QUATER)
		var left_bottom = Vector3(-HALF, leftHeight, QUATER)
		createTriangle(left_top, topLeft, bottomLeft)
		createTriangle(bottomLeft, left_bottom, left_top)	
		
	if right:
		var right_top = Vector3(HALF, rightHeight, -QUATER)
		var right_bottom = Vector3(HALF, rightHeight, QUATER)
		createTriangle(right_top, right_bottom, bottomRight)
		createTriangle(bottomRight, topRight, right_top)				
			
	if top:
		var top_left = Vector3(-QUATER, topHeight, -HALF)
		var top_right = Vector3(QUATER, topHeight, -HALF)
		createTriangle(top_left, top_right, topRight)
		createTriangle(topRight, topLeft, top_left)	

	if bottom:
		var bottom_left = Vector3(-QUATER, bottomHeight, HALF)
		var bottom_right = Vector3(QUATER, bottomHeight, HALF)
		createTriangle(bottomLeft, bottomRight, bottom_right)
		createTriangle(bottom_right, bottom_left, bottomLeft)			

	var tmpMesh = makeMesh(roadMaterial)
	$MeshInstance3D.mesh = tmpMesh
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(tmpMesh.get_faces())
	$MeshInstance3D/StaticBody3D/CollisionShape3D.shape = shape	
	
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
