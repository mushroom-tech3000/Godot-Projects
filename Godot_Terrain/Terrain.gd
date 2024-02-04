extends Node3D


var widthHeight = 50
var vertices = PackedVector3Array()
var UVs = PackedVector2Array()
var normals = PackedVector3Array()
var heightData = {}

var grassMaterial = preload("res://materials/terrainMaterial.tres")
var waterMaterial = preload("res://materials/water.tres")

var waterHeight = 0
var lowestGround = - 5
var lowestWater = -15

var noise = FastNoiseLite.new()

func _ready():
    randomize()
    noise.set_noise_type(noise.TYPE_PERLIN)
    noise.set_seed(randf())
    position.x -= widthHeight / 2
    position.z -= widthHeight / 2
    makeWaterMesh()
    createRandomMap()
        
func createRandomMap():
    heightData = {}
    for x in range(0,widthHeight + 2):
        for y in range(0,widthHeight + 2):
            heightData[Vector2(x,y)] = noise.get_noise_2d(x, y) * 20
            #heightData[Vector2(x,y)] = sin(x) + sin(y) * 10
    makeMapMesh()	
    
func _process(delta):
    pass
    #updateMesh()
    
        
func updateMesh():
    for x in range(0,widthHeight):
        for y in range(0,widthHeight):
            heightData[Vector2(x,y)] += randf_range(-0.1, 0.1)	
    makeMapMesh()			
        
        
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
    var v1b = Vector3(-0.01, lowestWater, -0.01)
    var v2b = Vector3(widthHeight + 0.01, lowestWater, -0.01)	
    var v3b = Vector3(widthHeight + 0.01, lowestWater, widthHeight + 0.01)
    var v4b = Vector3(-0.01, lowestWater, widthHeight + 0.01)
    createTriangle(v1, v2b, v2)
    createTriangle(v1, v1b, v2b)
    createTriangle(v2, v3b, v3)
    createTriangle(v2, v2b, v3b)	
    createTriangle(v3, v4b, v4)
    createTriangle(v3, v3b, v4b)		
    createTriangle(v4, v1b, v1)
    createTriangle(v4, v4b, v1b)		
    var tmpMesh = makeMesh(waterMaterial)
    $MeshInstance3DWater.mesh = tmpMesh
        
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
    var tmpMesh = makeMesh(grassMaterial)
    $MeshInstance3D.mesh = tmpMesh
    var shape = ConcavePolygonShape3D.new()
    shape.set_faces(tmpMesh.get_faces())
    $MeshInstance3D/StaticBody3D/CollisionShape3D.shape = shape	
    resetArrays()	
    for y in range(0, widthHeight):
        calculatedFixedXSide(0, y, true)
    for y in range(0, widthHeight):
        calculatedFixedXSide(widthHeight, y, false)
    for x in range(0, widthHeight):
        calculatedFixedYSide(x, 0, false)	
    for x in range(0, widthHeight):	
        calculatedFixedYSide(x, widthHeight, true)
    tmpMesh = makeMesh(grassMaterial)
    $MeshInstance3DSides.mesh = tmpMesh

func calculatedFixedXSide(x, y, flip):
    if heightData[Vector2(x, y)] < waterHeight && heightData[Vector2(x, y + 1)] < waterHeight: return
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
    print("x:" + str(x) + " y:" + str(y))
    if heightData[Vector2(x, y)] < waterHeight && heightData[Vector2(x + 1, y)] < waterHeight: return
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
    UVs.push_back(Vector2(vert1.x/10, -vert1.z/10))
    UVs.push_back(Vector2(vert2.x/10, -vert2.z/10))
    UVs.push_back(Vector2(vert3.x/10, -vert3.z/10))
    var side1 = vert1-vert2
    var side2 = vert3-vert1
    var normal = side1.cross(side2).normalized()
    for i in range(0,3):
        normals.push_back(normal)
