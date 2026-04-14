extends Control

var player
@onready var hearts = $HBoxContainer.get_children()

func _ready():
	await get_tree().process_frame  # wait 1 frame so player exists

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("ERROR: player not found in group 'player'")
		return

	player.health_changed.connect(update_hearts)
	update_hearts(player.health)

func update_hearts(current_health):
	for i in range(hearts.size()):
		hearts[i].visible = i < current_health
