extends StaticBody2D

var textures = [ 
	"res://assets/obstacles/Dead surfer_v1.png",
	"res://assets/obstacles/Dead surfer_v2.png",
	"res://assets/obstacles/Dead surfer_v3.png",
]
	


func _ready():
	randomize() #Randomize the seed for randomness
	var random_index = randi() %textures.size() #get a random index from the array
	var texture_path = textures[random_index]  # Get the texture path from the array
	$Sprite2D.texture = load(texture_path)  # Load the texture and assign it to the Sprite
