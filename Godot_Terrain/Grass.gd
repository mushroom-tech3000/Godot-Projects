extends MultiMeshInstance3D

var floatArrayData: PackedFloat32Array = PackedFloat32Array()
var count = 0

func add(pos:Vector3):
	var meshScale: float = randf_range(0.1, 0.4)
	floatArrayData.append(meshScale) # scale X
	floatArrayData.append(0)
	floatArrayData.append(0)
	floatArrayData.append(pos.x) # origin X
	floatArrayData.append(0)
	floatArrayData.append(meshScale) # scale Y
	floatArrayData.append(0)
	floatArrayData.append(pos.y) # origin Y
	floatArrayData.append(0)
	floatArrayData.append(0)
	floatArrayData.append(meshScale) # scale Z
	floatArrayData.append(pos.z) # origin Z	
	count += 1

func draw():
	multimesh.instance_count = count
	multimesh.buffer = floatArrayData
