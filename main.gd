extends Node

var screensize: Vector2i
@export var playerSpeed: int = 1000
@export var rotation_angle = 500
var player_angle = 0
var score: int
var boost: int = 1
const BOOSTFACTOR: int = 20
# Game Variables
var gameRunning: bool
const SCORE_MODIFIER: int = 5500
const PLAYER_START_POS = Vector2i(520, 328)
const GROUND_START_POS = Vector2i(0,0)
# Preload Obstacles
var dead_surfer = preload("res://Game Assets/Obstacles/Dead_surfer.tscn")
var rock_2 = preload("res://Game Assets/Obstacles/Obs_1.tscn")
var rock_3 = preload("res://Game Assets/Obstacles/Obs_2.tscn")
var rock_4 = preload("res://Game Assets/Obstacles/Obs_3.tscn")
var stump = preload("res://Game Assets/Obstacles/stump.tscn")
var tree_1 = preload("res://Game Assets/Obstacles/tree_1.tscn")
var tree_2 = preload("res://Game Assets/Obstacles/tree_2.tscn")
var yeti_obj = preload("res://Game Assets/Yeti/yeti.tscn")
var boost_scene = preload("res://Game Assets/Powerups/boost_scene.tscn")

# Declare arrays to hold the obstacles
var obstacle_types = [rock_2, rock_3, rock_4, stump, tree_1, tree_2, dead_surfer]
var obstacles = []
var yeti_obstacle = []
var last_obs
# Boolean Variables
var is_yeti_present = false

#Signals
signal boost_pickup

func _ready():
	screensize = get_viewport().size
	new_game()
	
func new_game():
	score = 0 
	boost = 10
	playerSpeed = 0
	$Player.reset()
	#$HUD/MarginContainer/BoostContainer.hide() 
	#print("Obstacles before clearing: ", obstacles) 
	#print("Yeti obstacles before clearing: ", yeti_obstacle) 
	for obs in obstacles:
		obs.queue_free() 
	obstacles.clear() 
	#print("Obstacles after clearing: ", obstacles) 
	for obs in yeti_obstacle:
		obs.queue_free() 
	yeti_obstacle.clear() 
	#print("Yeti obstacles after clearing: ", yeti_obstacle) 
	$Player.position = PLAYER_START_POS 
	$Ground.position = GROUND_START_POS
	#get_tree().call_group("boost", "queue_free")


func _process(delta):
	$BGmusic.play()
	#playerSpeed = 1000
	screensize = get_viewport().size
	if Input.is_action_just_pressed("ui_accept") and not gameRunning: #Restart or Start the game
			new_game()
			hide_HUD_Messages()
			gameRunning = true
			print("Restarting...")
	if gameRunning:
		# Update Score
		score += playerSpeed
		show_score()
		# Generate Obstacles
		generate_obs()
		
		if playerSpeed < 1000:
			rotation_angle = 200
		# Move player and Camera
		player_angle = $Player.turn_angle
		match player_angle:
			-1:
				$Player.position.y += playerSpeed * delta
				# Move player to the left side of the ground
				$Player.position.x -= rotation_angle * delta

			0:
				$Player.position.y += playerSpeed * delta
			1:
				$Player.position.y += playerSpeed * delta
				# Move player to the right side of the ground
				$Player.position.x += rotation_angle * delta

		# Update Ground Position
		if $Player/Camera2D.global_position.y - $Ground.position.y > screensize.y:
			$Ground.position.y += screensize.y

		if $Player/Camera2D.global_position.x - $Ground.position.x > screensize.x * 1.5:
			$Ground.position.x += screensize.x

		if $Player/Camera2D.global_position.x - $Ground.position.x < screensize.x / 1.5:
			$Ground.position.x -= screensize.x

		# Remove Obstacles once they exit the screen
		for i in obstacles:
			if is_instance_valid(i) and i.position.y < ($Player/Camera2D.global_position.y - screensize.y):
				remove_obs(i)

		for l in yeti_obstacle:
			if is_instance_valid(l) and l.position.y < ($Player/Camera2D.global_position.y - screensize.y):
				remove_yeti_obs(l)
				#print("Yeti Removed")
	
func generate_obs():
	if obstacles.is_empty():
		for i in range(randi_range(4,7)):
			var obs_type = obstacle_types[randi() % obstacle_types.size()]
			var obs = obs_type.instantiate()
			var obs_x : int = randi_range(int($Player.position.x - screensize.x / 2 - 300), int($Player.position.x + screensize.x / 2 + 300))
			var obs_y : int = int($Player.position.y + screensize.y + randi_range(200,400))
			last_obs = obs
			add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	add_child(obs)
	obstacles.append(obs)
	#print(obstacles)

func remove_obs(obs):
	if is_instance_valid(obs):
		obs.queue_free()
	obstacles.erase(obs)

func show_score():
	$HUD.get_node("MarginContainer/ScoreContainer/Score").text = str(score / SCORE_MODIFIER) + " m"

func _on_yeti_spawner_timeout() -> void:
	spawn_yeti()
	#print("Yeti timeout")

func spawn_yeti():
	# Generate Yeti if not already present
	if gameRunning and not is_yeti_present:
		var yeti = yeti_obj.instantiate()
		var obs_x = randi_range($Player.position.x - 50, $Player.position.x + 50)
		var obs_y = $Player.position.y - 200
		yeti.position = Vector2i(obs_x, obs_y)
		add_child(yeti)
		yeti_obstacle.append(yeti)
		#print("Yeti spawned")
		is_yeti_present = true
		$YetiSpawner.start()

func remove_yeti_obs(obs):
	if is_instance_valid(obs):
		obs.queue_free()
	yeti_obstacle.erase(obs)
	is_yeti_present = false
	$YetiSpawner.start()

func _on_player_hurt() -> void:
	print("Ouch")
	playerSpeed = 0
	#rotation_angle = 0


func _on_player_dead() -> void:
	$HUD/GameOver.show()
	$HUD/RestartMsg.show()
	gameRunning = false

func hide_HUD_Messages():
	$HUD/StartSurfing.hide()
	$HUD/GameOver.hide()
	$HUD/PressKey.hide()
	$HUD/RestartMsg.hide()
	
	


func _on_obstacle_timer_timeout() -> void:
	generate_obs()


func _on_boost_timer_timeout() -> void:
	var boost = boost_scene.instantiate()
	boost.body_entered.connect(pickup_boost)
	add_child(boost)
	boost.screensize = screensize
	boost.position = Vector2(randi_range($Player.global_position.x - 200, $Player.global_position.x + 200),$Player.global_position.y + 500)
	print("Boost spawned")


func pickup_boost(body):
	if body.name == "Player":
		boost += 1
		boost_pickup.emit(boost)
		print(boost)


func _on_player_double_tap() -> void:
	if boost > 0:
		print("Double Tap Detected!")
		playerSpeed = playerSpeed * BOOSTFACTOR
		rotation_angle = 1000
		print("Player Speed boosted to ", playerSpeed)
		$SpeedTimer.start()
		boost -= 1
		boost_pickup.emit(boost)
		print(boost)


func _on_speed_timer_timeout() -> void:
	#Reset playerSpeed back to original
	playerSpeed = 1000
	print("Player back to normal speed ", playerSpeed)
