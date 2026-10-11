extends Interactable

@export var orb_texture: Texture2D
@export var bob_rate: float = 2.0

var player: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$OrbBody/OrbSprite.texture = orb_texture
	$OrbBody.animation_rate = bob_rate
	#ready()

func _interact(event: InputEvent, source):
	source = source as Player
	player = source
	if event.is_action_released("select_object"):
		source.open_object_inventory($InventoryPassHandler)

func _on_button_set_source_pressed() -> void:
	$InventoryTransferAgent.set_source_inventory(get_path())

func _on_button_set_destination_pressed() -> void:
	$InventoryTransferAgent.set_dest_inventory(player.get_path())
