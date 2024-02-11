extends Node3D

var roads: Dictionary = {}
var directions = ["top", "bottom", "right", "left"]
var vertexDirections = [Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1)]
var roadBlockScene = preload("res://roadBlock.tscn")
const ROAD_HEIGHT = 0.06
var roadConstructors = []
var maxConstructors = 10

func getOppositeDirection(direction: String):
	if direction == "left": return "right"
	if direction == "right": return "left"
	if direction == "top": return "bottom"
	if direction == "bottom": return "top"	

func modifyVertexPosByDirection(vertexPos: Vector2, direction: String) -> Vector2:
	if direction == "left": return Vector2(vertexPos.x - 1, vertexPos.y)
	if direction == "right": return Vector2(vertexPos.x + 1, vertexPos.y)
	if direction == "top": return Vector2(vertexPos.x, vertexPos.y - 1)
	if direction == "bottom": return Vector2(vertexPos.x, vertexPos.y + 1)
	assert(false, "modifyVertexPosByDirection invalid direction:" + str(direction))	
	return Vector2()

func getRoadHeight(x, y):
	var vertexPos = Vector2(x, y)
	if not vertexPos in roads: return null
	return roads[vertexPos]["height"]

func addEmptyRoad(vertexPos:Vector2):
	var height = get_parent().getHeight(vertexPos) + ROAD_HEIGHT
	roads[vertexPos] = {"top":false, "bottom":false, "right":false, "left":false, "scene":null, "height":height}

func addCentreRoad():
	var vertexPos = Vector2(0, 0)
	var direction = directions[randi() % directions.size()]
	addRoadConstructor(vertexPos, direction)
	
func addRoad(vertexPos:Vector2, direction: String):
	roads[vertexPos][direction] = true
	redrawRoadIfExists(vertexPos)
	var connectingRoadVertexPos = modifyVertexPosByDirection(vertexPos, direction)
	roads[connectingRoadVertexPos][getOppositeDirection(direction)] = true
	redrawRoadIfExists(connectingRoadVertexPos)

func redrawRoadIfExists(vertexPos: Vector2):
	if not vertexPos in roads: return
	var road = roads[vertexPos]
	var x = vertexPos.x
	var y = vertexPos.y	
	if road["scene"] != null:
		road["scene"].name = "deleting"
		road["scene"].queue_free()
	var roadInstance = roadBlockScene.instantiate()
	roadInstance.name = "road_x" + str(x) + "_y" + str(y)
	roadInstance.position = Vector3(vertexPos.x, 0, vertexPos.y)
	roadInstance.setup(road["height"], road["left"], road["top"], road["right"], road["bottom"], getRoadHeight(x - 1, y), getRoadHeight(x, y - 1), getRoadHeight(x + 1, y), getRoadHeight(x, y + 1))
	$RoadInstances.add_child(roadInstance)
	roads[vertexPos]["scene"] = roadInstance	

func addRoadConstructor(vertexPos:Vector2, direction: String):
	roadConstructors.append({"vertexPos": vertexPos, "direction":direction})

	
func canRoadBeBuilt(vertexPos: Vector2, direction: String):
	if not vertexPos in roads: return false
	if roads[vertexPos]["height"] <= Global.waterHeight + ROAD_HEIGHT: return
	var nextVertexPos = modifyVertexPosByDirection(vertexPos, direction)
	if not nextVertexPos in roads: return false
	if roads[nextVertexPos]["height"] <= Global.waterHeight + ROAD_HEIGHT: return
	return true
	
func processRoadConstructors():
	var oldRoadConstructors = roadConstructors
	print(oldRoadConstructors.size())
	roadConstructors = []
	for c in oldRoadConstructors:
		var vertexPos = c["vertexPos"]
		var direction = c["direction"]
		if not canRoadBeBuilt(vertexPos, direction): continue
		if roads[vertexPos][direction]: continue # road already going in this direction
		var nextVertexPos = modifyVertexPosByDirection(vertexPos, direction)
		if not roads[nextVertexPos][getOppositeDirection(direction)] and not roads[nextVertexPos][direction]: 
			addRoadConstructor(nextVertexPos, direction)
		addRoad(vertexPos, direction)
		if oldRoadConstructors.size() < maxConstructors && randf() < 0.1: # maybe make a road branch
			var newDirection = directions[randi() % directions.size()]
			if newDirection == direction: continue # same direction
			if newDirection == getOppositeDirection(direction): continue # same direction
			addRoadConstructor(vertexPos, newDirection)

func _on_timer_timeout():
	processRoadConstructors()
