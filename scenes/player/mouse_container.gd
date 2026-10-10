extends PanelContainer

const pointer_offset = Vector2(20, 50)

var shown_items: int = 0
var supressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	%ProgressBar.hide()
	%TextureRect.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position() + pointer_offset
	if shown_items == 0 or supressed:
		hide()
	else:
		show()
	
func _input(event: InputEvent) -> void:
	if visible:
		Input.use_accumulated_input = false
		
		if event is InputEventMouseMotion:
			global_position = event.global_position + pointer_offset
	else:
		Input.use_accumulated_input = true

func hide_progress():
	%ProgressBar.hide()
	shown_items &= 0b1111_1111_1111_1110
	reset_size()

func show_progress(percent: float):
	## Shows the progress bar at the mouse position at the given percentage (0-100).
	%ProgressBar.value = percent
	if percent >= 100:
		%ProgressBar.hide()
		shown_items &= 0b1111_1111_1111_1110
	else:
		%ProgressBar.show()
		shown_items |= 0b0001
		reset_size()

func show_item_texture(item: Types.Item, qty: int = 1):
	%TextureRect.show()
	%TextureRect.texture = Globals.ItemTextures[item]
	if qty != 1:
		%TextureQtyLabel.text = str(qty)
	else:
		%TextureQtyLabel.text = ""
	shown_items |= 0b0010
	reset_size()

func hide_item_texture():
	%TextureRect.hide()
	shown_items &= 0b1111_1111_1111_1101
	reset_size()

func hide_all():
	%TextureRect.hide()
	%ProgressBar.hide()
	hide()
	shown_items = 0
