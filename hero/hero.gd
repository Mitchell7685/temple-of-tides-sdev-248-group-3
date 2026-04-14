extends CharacterBody2D
signal died
signal attacked
signal hurt
signal health_changed(new_health)

@export var speed: int = 75
@onready var _sprite = $AnimatedSprite2D
@export var max_health := 3
enum {IDLE, WALK, HURT, DEAD}
var state = IDLE
enum {UP, DOWN, LEFT, RIGHT}
var face_dir = DOWN
var current_interactable = null
var is_invincible := false
var health := max_health 

func _ready() -> void:
	add_to_group("player")
	change_state(IDLE)
	health = max_health
	change_state(IDLE)
	$hitbox.monitoring = false

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
		start_attack()
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


func start_attack():
	if $hitbox.monitoring:
		return # prevents double attack spam

	$hitbox.monitoring = true  

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

	# safety timer (backup in case animation breaks)
	await get_tree().create_timer(0.4).timeout

	$hitbox.monitoring = false

#Interaction handler
func _process(delta):
	if current_interactable != null and Input.is_action_just_pressed("interact"):
		if current_interactable.has_method("interact"):
			current_interactable.interact()

func die():
	change_state(DEAD)
	get_tree().change_scene_to_file("res://Scenes/die.tscn")

func interact():
	print("Interacting")

#Show Interact Prompt
func _on_interaction_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		$Label.show()
		current_interactable = area.get_parent()

#Hide interact prompt
func _on_interaction_zone_area_exited(area: Area2D) -> void:
	if area.get_parent() == current_interactable:
		$Label.hide()
		current_interactable = null


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		take_damage()

func take_damage(amount := 1):
	if is_invincible:
		return
	
	health -= amount
	print("Health:", health)
	health_changed.emit(health)
	
	change_state(HURT)
	hurt.emit()
	
	if health <= 0:
		die()
		return
	
	await get_tree().create_timer(0.5).timeout
	is_invincible = false
	change_state(IDLE)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(1)
