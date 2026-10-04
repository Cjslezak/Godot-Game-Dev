extends Interactable

func _interact(event: InputEvent, source):
	source = source as Player
	if event.is_action_released("select_object"):
		source.open_object_inventory($InventoryPassHandler)
