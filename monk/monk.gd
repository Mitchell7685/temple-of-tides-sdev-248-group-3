extends StaticBody2D

signal talking(message)

var message: String = "text"

func talk(viewport: Node, event: Input, _shape_id: int):
	if event.is_action_just_pressed("interact"):
		talking.emit(message)
