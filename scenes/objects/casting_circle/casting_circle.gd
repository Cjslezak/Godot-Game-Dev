extends Interactable

func _interact(event: InputEvent, source):
	source = source as Player
	if event.is_action_released("select_object"):
		source.open_object_inventory($InventoryPassHandler)

func destroy(by_player: bool, source: Variant):
	if by_player:
		source = source as Player
		for drop in properties.drops:
			source.on_gather_resource(drop, properties.drops[drop])
	queue_free()
