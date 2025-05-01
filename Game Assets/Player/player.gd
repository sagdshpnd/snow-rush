extends CharacterBody2D

var turn
var turn_angle = 0
# Declare Signals
signal dead
signal lives_changed
signal double_tap

var lives = 3: set = set_lives

#State Machine
enum {INIT, ALIVE, HURT, DEAD}
var state

func _ready():
	change_state(INIT)
	
func change_state(new_state):
	state = new_state
	match state:
		INIT: 
			$Sprite2D.modulate.a = 1
			print("Init")
		ALIVE:
			$Sprite2D.modulate.a = 1
			print("ALIVE")
		HURT:
			position.y -= 50
			get_parent().playerSpeed = 0
			print("Playerspeed is ", get_parent().playerSpeed)
			lives -= 1
			if lives > 0:
				await $AnimationPlayer.animation_finished
				change_state(ALIVE)
				print("PLayerspeed is ", get_parent().playerSpeed)
			else:
				change_state(DEAD)
			$AnimationPlayer.play("hurt")
			
		DEAD:
			dead.emit()
			$Sprite2D.modulate.a = 1
			$AnimationPlayer.play("dead")
			get_parent().playerSpeed = 0
			print("DEAD")
			

func _physics_process(_delta):
	if state == HURT or state == DEAD:
		return
	if get_parent().gameRunning == true and Input.is_action_just_pressed("left"):
		turn_angle = -1
	
	if  get_parent().gameRunning == true and Input.is_action_just_pressed("right"):
		turn_angle = 1
		
	if get_parent().gameRunning == true and Input.is_action_just_pressed("down"):
		turn_angle = 0
		get_parent().playerSpeed = 1000
		
	if turn_angle < -1:
		turn_angle = -1
	if turn_angle > 1:
		turn_angle = 1
	
	turn_player(turn_angle)     
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("obstacles"):
			hurt()
		if collision.get_collider().is_in_group("enemy"):
			get_parent().get_node("Yeti").bash()
			die()
			
	

func set_lives(value):
	lives = value
	lives_changed.emit(value)
	if lives <= 0:
		change_state(DEAD)

func turn_player(key_pressed):
	match key_pressed:
		-1:
			$AnimationPlayer.play("turn_left")
		0:
			$AnimationPlayer.play("Straight")
		1:
			$AnimationPlayer.play("turn_right")

func reset():
	#print("Resetting Lives")
	lives = 3
	change_state(ALIVE)
			
func hurt():
	if state != HURT:
		change_state(HURT)
		#print("Lives =", lives)

func die():
	if state!= DEAD:
		change_state(DEAD)
		lives = 0
