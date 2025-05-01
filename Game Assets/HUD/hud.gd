extends CanvasLayer

var screensize: Vector2i
@onready var life_counter = $MarginContainer/LifeCounter2.get_children()
@onready var boost_counter = $MarginContainer/BoostContainer.get_children()


func update_life(value):
	for heart in life_counter.size():
		life_counter[heart].visible = value > heart	
	
func update_boost(value):
	for i in boost_counter.size():
		boost_counter[i].visible = i < value	
