extends Node

@export var button: Button

var shop_id: String = ""
var shop_level: String = "BASIC"

const TRADE_MODAL_SCENE = preload("res://src/presentation/trading/generic_trade_modal.tscn")


func setup(interaction_data: Dictionary) -> void:
	shop_id = str(interaction_data.get("id", ""))

	shop_level = str(interaction_data.get("level", "BASIC")).to_upper()

	var display_name: String = str(interaction_data.get("name", shop_id))

	if button != null:
		button.text = display_name


func _ready() -> void:
	if button != null and not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	if shop_id.is_empty():
		push_error("Shop interaction has no shop id")
		return

	if not Game.shops.has_shop(shop_id):
		push_error("Unknown shop referenced by POI: %s" % shop_id)
		return

	open_shop()


func open_shop() -> void:
	var trade_panel = TRADE_MODAL_SCENE.instantiate()

	trade_panel.setup(shop_id, shop_level, true)

	trade_panel.purchase_requested.connect(_on_purchase_requested)

	var ui_layer := (get_tree().current_scene.get_node_or_null("UI"))

	if ui_layer == null:
		push_error("Current scene has no UI CanvasLayer")
		trade_panel.queue_free()
		return

	ui_layer.add_child(trade_panel)


func _on_purchase_requested(requested_shop_id: String, item_id: String, quantity: int) -> void:
	print("Purchase requested: %d x %s from %s" % [quantity, item_id, requested_shop_id])
