extends WorldEnvironment

var TreeScene = preload("res://tree.tscn")

func _ready():
	var num_trees = 100
	for i in range(num_trees):
		var tree = TreeScene.instantiate()
		var location_planted = Vector3(randf_range(-20,20),0, randf_range(-20,20))
		tree.position = location_planted
		add_child(tree)
		print("adding tree", location_planted)
