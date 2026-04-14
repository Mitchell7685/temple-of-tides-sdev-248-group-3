extends StaticBody2D

signal talking(message)

var message: String = "text"

func talk(viewport: Node, event: Input, _shape_id: int):
	if event.is_action_just_pressed("interact"):
		talking.emit(message)

#When interacted, show text
func interact():
	print("monk interacted")
	$Label.show()
	await get_tree().create_timer(4.0).timeout
	$Label.hide()
	print("interact ended")
