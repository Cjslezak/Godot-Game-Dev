extends Node

const TextureSize = 64

const HighlightColor: Color = Color(1.353, 1.353, 1.353, 1.0)
const GhostColor: Color = Color(1.0, 1.0, 1.0, 0.502)
const ItemTextures: Dictionary[Types.Item, Resource] = {
	Types.Item.WOOD: preload("res://pixel_art/Wood Texture.png"),
	Types.Item.CRYSTAL: preload("res://pixel_art/Crystal Texture.png"),
	Types.Item.CASTING_CIRCLE: preload("res://pixel_art/Pentagram Inventory.png"),
	Types.Item.PYLON: preload("res://pixel_art/Pixel Orb.png")
}
const PlacementTextures: Dictionary[Types.Item, Resource] = {
	Types.Item.CASTING_CIRCLE: preload("res://pixel_art/Pixel Pentagram.png")
}
const StructureFiles: Dictionary[Types.Item, PackedScene] = {
	Types.Item.CASTING_CIRCLE: preload("res://scenes/objects/casting_circle/casting_circle.tscn")
}

func current_hotbar_action(event: InputEvent) -> Variant:
	var hotbar_button = null
	if event.is_action_released("hotbar_1"):
		hotbar_button = 1
	elif event.is_action_released("hotbar_2"):
		hotbar_button = 2
	elif event.is_action_released("hotbar_3"):
		hotbar_button = 3
	elif event.is_action_released("hotbar_4"):
		hotbar_button = 4
	elif event.is_action_released("hotbar_5"):
		hotbar_button = 5
	elif event.is_action_released("hotbar_6"):
		hotbar_button = 6
	elif event.is_action_released("hotbar_7"):
		hotbar_button = 7
	elif event.is_action_released("hotbar_8"):
		hotbar_button = 8
	elif event.is_action_released("hotbar_9"):
		hotbar_button = 9
	elif event.is_action_released("hotbar_0"):
		hotbar_button = 0
	return hotbar_button
