@tool
class_name SinusoidNode
extends GaeaNodeResource

enum FuncTypes { SIN, COS, SIN_DECAY, COS_DECAY}
var defaults = {&"z_offset": 1, &"frequency_constant": 1, &"decay_exponent": 0.5}

func _get_enums_count() -> int:
	return 1

func _get_enum_title(enum_idx: int) -> String:
	return "Enum #" + str(enum_idx + 1)
	
func _get_enum_description(enum_idx: int) -> String:
	return "Description for enum #" + str(enum_idx + 1)

func _get_enum_options(enum_idx: int) -> Dictionary:
	if enum_idx == 0:
		return FuncTypes
	return {"": 0}

func _on_enum_value_changed(enum_idx: int, option_value: int) -> void:
	super(enum_idx, option_value)
	notify_argument_list_changed()


func _get_title() -> String:
	return "SinusoidNode"

func _get_arguments_list() -> Array[StringName]:
	var requirements : Array[StringName] = [&"z_offset", &"frequency_constant"]
	if get_enum_selection(0) in [FuncTypes.SIN_DECAY, FuncTypes.COS_DECAY]:
		requirements.append(&"decay_exponent")
	return requirements

func _get_argument_type(_arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.FLOAT

func _get_argument_default_value(arg_name: StringName) -> Variant:
	return defaults[arg_name]

func _get_output_ports_list() -> Array[StringName]:
	return [&"output_function"]

func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.SAMPLE

func _get_data(output_port: StringName, pouch: GaeaGenerationPouch) -> Variant:
	assert(output_port == &"output_function", "Invalid output_port")
	var data_zoff: float = _get_arg(&"z_offset", pouch)
	var data_frq: float = _get_arg(&"frequency_constant", pouch)
	var data_decay: float = _get_arg(&"decay_exponent", pouch)
	var result = GaeaValue.Sample.new()
	var operation = get_enum_selection(0)
	for x in _get_axis_range(Vector3i.AXIS_X, pouch.area):
		for y in _get_axis_range(Vector3i.AXIS_Y, pouch.area):
			for z in _get_axis_range(Vector3i.AXIS_Z, pouch.area):
				if operation == FuncTypes.SIN:
					result.set_xyz(x, y, z, compute_sin(x, y, data_frq, data_zoff))
				elif operation == FuncTypes.COS:
					result.set_xyz(x, y, z, compute_cos(x, y, data_frq, data_zoff))
				elif operation == FuncTypes.SIN_DECAY:
					result.set_xyz(x, y, z, compute_sin_decay(x, y, data_frq, data_zoff, data_decay))
				elif operation == FuncTypes.COS_DECAY:
					result.set_xyz(x, y, z, compute_cos_decay(x, y, data_frq, data_zoff, data_decay))
	return result

func compute_sin(x, y, fc, zo):
	return (sin(fc * sqrt((x**2) + (y**2))) + zo) / (1 + zo)

func compute_cos(x, y, fc, zo):
	return (cos(fc * sqrt((x**2) + (y**2))) + zo) / (1 + zo)

func compute_sin_decay(x, y, fc, zo, dc):
	return (sin(fc * (sqrt((x**2) + (y**2))) ** dc) + zo) / (1 + zo)

func compute_cos_decay(x, y, fc, zo, dc):
	return (cos(fc * (sqrt((x**2) + (y**2))) ** dc) + zo) / (1 + zo)
