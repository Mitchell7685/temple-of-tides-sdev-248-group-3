extends CharacterBody2D
signal dead
signal attacking
signal interaction

@export var speed: int = 150
enum {IDLE, RUN, HURT, DEAD}
var state = IDLE
enum {UP, DOWN, LEFT, RIGHT, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT}
var face_dir = RIGHT

func _ready() -> void:
	change_state(IDLE)

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

func change_state(new_state) -> void:
	state = new_state
	match state:
		IDLE:
			pass
		RUN:
			pass
		HURT:
			pass
		DEAD:
			dead.emit()
			hide()

func get_input() -> void:
	var attack: bool = Input.is_action_just_pressed("attack")
	var interact: bool = Input.is_action_just_pressed("interact")
	var up: bool = Input.is_action_pressed("up")
	var down: bool = Input.is_action_pressed("down")
	var left: bool = Input.is_action_pressed("left")
	var right: bool = Input.is_action_pressed("right")
	
	if attack:
		attacking.emit(face_dir)
	if interact:
		var click_pos: Vector2 = get_global_mouse_position()
		interaction.emit(click_pos)
	if up:
		if not left and not right:
			face_dir = UP
		velocity.y += speed
	if down:
		if not left and not right:
			face_dir = DOWN
		velocity.y -= speed
	if left:
		if not up and not down:
			face_dir = LEFT
		velocity.x -= speed
	if right:
		if not up and not down:
			face_dir = RIGHT
		velocity.x += speed
	
	if up:
		if left:
			face_dir = UP_LEFT
		elif right:
			face_dir = UP_RIGHT
	elif down:
		if left:
			face_dir = DOWN_LEFT
		elif right:
			face_dir = DOWN_RIGHT
	
	if state == IDLE and (velocity.x != 0 or velocity.y != 0):
		change_state(RUN)
	elif state == RUN and velocity.x == 0 and velocity.y == 0:
		change_state(IDLE)
	
	
