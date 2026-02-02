extends Control

# Constants
const RADIUS := 450.0
const CENTER := Vector2(50, 450)
const LINE_WIDTH := 3.0
const LABEL_FONT_SIZE := 21
const ARC_POINTS := 32
const DASH_LENGTH := 10.0
const GAP_LENGTH := 5.0

# State
var fire_action: GUIDEAction:
	set(value):
		fire_action = value
		if fire_action:
			fire_action.triggered.connect(_on_triggered)
			fire_action.completed.connect(_on_completed)

var hair_trigger: GUIDETriggerHair
var current_value := 0.0
var is_triggered := false


func _process(_delta: float) -> void:
	if fire_action:
		current_value = fire_action.value_axis_1d
	queue_redraw()


func _draw() -> void:
	# Background changes color based on trigger state
	var bg_color := Color.DARK_GREEN if is_triggered else Color.DARK_RED
	_draw_quarter_circle(bg_color)
	_draw_quarter_circle_outline(Color.WHITE)

	# Draw markers and labels
	if hair_trigger:
		_draw_edge_marker()
		_draw_threshold_marker()

	_draw_current_value_marker()
	_draw_status_label()


func _draw_edge_marker() -> void:
	var angle := hair_trigger._edge_value * 90.0
	_draw_radial_line(angle, Color.CYAN, LINE_WIDTH * 2)
	_draw_radial_label(angle, "Edge: %.2f" % hair_trigger._edge_value, Color.CYAN, 50)


func _draw_threshold_marker() -> void:
	# Calculate dynamic threshold target
	var offset := -hair_trigger.actuation_threshold if is_triggered else hair_trigger.actuation_threshold
	var target := clampf(hair_trigger._edge_value + offset, 0.0, 1.0)
	var angle := target * 90.0

	_draw_dashed_radial_line(angle, Color.YELLOW)
	_draw_radial_label(angle, "Threshold: %.2f" % target, Color.YELLOW, 50)


func _draw_current_value_marker() -> void:
	var angle := current_value * 90.0
	_draw_radial_line(angle, Color.WHITE, LINE_WIDTH * 3)
	_draw_radial_label(angle, "Value: %.2f" % current_value, Color.WHITE, 80)


func _draw_status_label() -> void:
	var text := "TRIGGERED" if is_triggered else "NOT TRIGGERED"
	var color := Color.GREEN if is_triggered else Color.RED
	var font := ThemeDB.fallback_font
	draw_string(font, CENTER + Vector2(80, -30), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 24, color)


func _draw_quarter_circle(color: Color) -> void:
	var points := PackedVector2Array([CENTER])
	for i in range(ARC_POINTS + 1):
		var angle := deg_to_rad(i * 90.0 / ARC_POINTS - 90)
		points.append(CENTER + Vector2(cos(angle), sin(angle)) * RADIUS)
	draw_colored_polygon(points, color)


func _draw_quarter_circle_outline(color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(ARC_POINTS + 1):
		var angle := deg_to_rad(i * 90.0 / ARC_POINTS - 90)
		points.append(CENTER + Vector2(cos(angle), sin(angle)) * RADIUS)

	draw_polyline(points, color, LINE_WIDTH)
	draw_line(CENTER, points[0], color, LINE_WIDTH)
	draw_line(CENTER, points[-1], color, LINE_WIDTH)


func _draw_radial_line(angle: float, color: Color, width: float) -> void:
	var rad := deg_to_rad(angle - 90)
	var end := CENTER + Vector2(cos(rad), sin(rad)) * RADIUS
	draw_line(CENTER, end, color, width)


func _draw_dashed_radial_line(angle: float, color: Color) -> void:
	var rad := deg_to_rad(angle - 90)
	var direction := Vector2(cos(rad), sin(rad))
	var dist := 0.0

	while dist < RADIUS:
		var start := CENTER + direction * dist
		var end := CENTER + direction * minf(dist + DASH_LENGTH, RADIUS)
		draw_line(start, end, color, LINE_WIDTH)
		dist += DASH_LENGTH + GAP_LENGTH


func _draw_radial_label(angle: float, text: String, color: Color, offset: float) -> void:
	var rad := deg_to_rad(angle - 90)
	var pos := CENTER + Vector2(cos(rad), sin(rad)) * (RADIUS + offset)
	var font := ThemeDB.fallback_font
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, LABEL_FONT_SIZE, color)


func _on_triggered() -> void:
	is_triggered = true


func _on_completed() -> void:
	is_triggered = false
