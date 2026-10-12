extends Interactable

@export var item: ItemStackResource
@export var sprite_size: Vector2 = Vector2(50, 50)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite.texture = item.texture
	var scale_vect = sprite_size / $Sprite.get_rect().size
	$Sprite.set_scale(scale_vect)
	$DetectionArea/CollisionShape2D.shape.set_size(sprite_size)

func _interact(event: InputEvent, interact_from: Variant):
	var player = interact_from as Player
	if event.is_action_pressed("select_object"):
		player.on_gather_resource(item.type, item.qty)
		queue_free()
