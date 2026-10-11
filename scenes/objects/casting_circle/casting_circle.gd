extends Interactable

func _interact(event: InputEvent, _source):
	if event.is_action_released("select_object"):
		Globals.inventory_popup_requested.emit($InventoryPassHandler)

func destroy():
	queue_free()
