extends CharacterBody2D



@export var current_speed: = 60000 # Speed of the enemy
var speed_decrease_rate = 50
var minimum_speed = 5000

var player: CharacterBody2D  # Reference to the player node

func _ready():
	# Get reference to the player node
	player = get_parent().get_node("Player")

func _process(delta):
	if get_parent().playerSpeed < 1000:
		current_speed = 30000
	var direction = global_position.direction_to(player.global_position)
	# Move the enemy towards the player
	velocity = direction * current_speed * delta
	decrease_speed(delta)
	move_and_slide()

func decrease_speed(delta):
	#Decrease the speed gradually
	if current_speed > minimum_speed:
		current_speed -= speed_decrease_rate * delta
	if current_speed < minimum_speed:
		current_speed = minimum_speed

func bash():
	current_speed = 0
	$AnimationPlayer.play("yeti_bash")
	get_parent().get_node("Player/Camera2D").shake()
	
