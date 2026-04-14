extends CharacterBody2D
signal died
signal attacked

@export var speed: int = 60
@onready var _sprite = $AnimatedSprite2D
@export var health := 1
enum directions {UP, DOWN, LEFT, RIGHT}
var face_dir = directions.LEFT

func _ready() -> void:
	show()

func _physics_process(delta: float) -> void:
	match face_dir:
		directions.UP:
			_sprite.play("walk_forward")
			velocity.y = -speed
		directions.DOWN:
			_sprite.play("walk_backward")
			velocity.y = speed
		directions.LEFT:
			_sprite.play("walk_left")
			velocity.x = -speed
		directions.RIGHT:
			_sprite.play("walk_right")
			velocity.x = speed
	move_and_slide()
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider.name == "hero" and facing_collider(collider):
			attack()
		if collision.get_normal().x != 0 or collision.get_normal().y != 0:
			change_dir()
		if collider.is_in_group("enemies") and facing_collider(collider):
			change_dir()

func change_dir() -> void:
	var valid_states: Array = directions.values()
	valid_states.erase(face_dir)
	face_dir = valid_states.pick_random()

func facing_collider(collider: CharacterBody2D) -> bool:
	var can_attack: bool = false
	if collider.position.x > position.x and face_dir == directions.RIGHT:
		can_attack = true
	elif collider.position.x < position.x and face_dir == directions.LEFT:
		can_attack = true
	elif collider.position.y > position.y and face_dir == directions.DOWN:
		can_attack = true
	elif collider.position.y < position.y and face_dir == directions.UP:
		can_attack = true
	return can_attack


func take_damage(amount):
	health -= amount
	print("Enemy HP:", health)
	if health <= 0:
		die()
		
func die() -> void:
	queue_free()

func attack() -> void:
	match face_dir:
		directions.UP:
			_sprite.play("attack_forward")
		directions.DOWN:
			_sprite.play("attack_backward")
		directions.LEFT:
			_sprite.play("attack_left")
		directions.RIGHT:
			_sprite.play("attack_right")
	attacked.emit()
