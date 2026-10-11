extends Interactable

@export var orb_texture: Texture2D
@export var bob_rate: float = 2.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$OrbBody/OrbSprite.texture = orb_texture
	$OrbBody.animation_rate = bob_rate
	#ready()

func _interact(event: InputEvent, _source):
	if event.is_action_released("select_object"):
		Globals.inventory_popup_requested.emit($InventoryPassHandler)

func _on_button_set_source_pressed() -> void:
	$InventoryTransferAgent.connecting_source = true
	Globals.inventory_hide_requested.emit()
	
func _on_button_set_destination_pressed() -> void:
	$InventoryTransferAgent.connecting_dest = true
	Globals.inventory_hide_requested.emit()

func _on_inventory_transfer_agent_connection_complete() -> void:
	Globals.inventory_popup_requested.emit($InventoryPassHandler)
