extends CharacterBody2D
signal died
signal attacked
signal hurt

@export var speed: int = 75
@onready var _sprite = $AnimatedSprite2D
enum {IDLE, WALK, HURT, DEAD}
var state = IDLE
enum {UP, DOWN, LEFT, RIGHT}
var face_dir = DOWN

func _ready() -> void:
	change_state(IDLE)

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	position.x = clamp(position.x, 0, 560)
	position.y = clamp(position.y, 0, 432)

func change_state(new_state) -> void:
	state = new_state
	match state:
		IDLE:
			match face_dir:
				UP:
					_sprite.play("idle_forward")
				DOWN:
					_sprite.play("idle_backward")
				LEFT:
					_sprite.play("idle_left")
				RIGHT:
					_sprite.play("idle_right")
		WALK:
			match face_dir:
				UP:
					_sprite.play("walk_forward")
				DOWN:
					_sprite.play("walk_backward")
				LEFT:
					_sprite.play("walk_left")
				RIGHT:
					_sprite.play("walk_right")
		HURT:
			pass
		DEAD:
			died.emit()
			hide()

func get_input() -> void:
	var attack: bool = Input.is_action_just_pressed("attack")
	var up: bool = Input.is_action_pressed("up")
	var down: bool = Input.is_action_pressed("down")
	var left: bool = Input.is_action_pressed("left")
	var right: bool = Input.is_action_pressed("right")
	velocity.x = 0
	velocity.y = 0
	
	if attack:
		match face_dir:
			UP:
				_sprite.play("attack_forward")
			DOWN:
				_sprite.play("attack_backward")
			LEFT:
				_sprite.play("attack_left")
			RIGHT:
				_sprite.play("attack_right")
		attacked.emit(face_dir)
	if up:
		face_dir = UP
		velocity.y -= speed
	if down:
		face_dir = DOWN
		velocity.y += speed
	if left:
		face_dir = LEFT
		velocity.x -= speed
	if right:
		face_dir = RIGHT
		velocity.x += speed
	
	if state == IDLE and (velocity.x != 0 or velocity.y != 0):
		change_state(WALK)
	if state == WALK and velocity.x == 0 and velocity.y == 0:
		change_state(IDLE)
	
	
