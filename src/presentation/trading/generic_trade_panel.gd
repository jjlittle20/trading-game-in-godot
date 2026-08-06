extends Control
signal closed
signal purchase_requested(shop_id: String, item_id: String, quantity: int)

const TRADE_ITEM_ROW_SCENE := preload("res://src/presentation/trading/trade_item_row.tscn")

@onready var panel: PanelContainer = ($CenterContainer/GenericTradePanel)

@onready var title_label: Label = (
	$CenterContainer/GenericTradePanel/MarginContainer/VBoxContainer/Header/TitleLabel
)

@onready var close_button: Button = (
	$CenterContainer/GenericTradePanel/MarginContainer/VBoxContainer/Header/CloseButton
)

@onready var shop_info_label: Label = (
	$CenterContainer/GenericTradePanel/MarginContainer/VBoxContainer/ShopInfoLabel
)

@onready var stock_container: VBoxContainer = (
	$CenterContainer/GenericTradePanel/MarginContainer/VBoxContainer/StockScroll/StockContainer
)

@onready var empty_stock_label: Label = (
	$CenterContainer/GenericTradePanel/MarginContainer/VBoxContainer/EmptyStockLabel
)

var shop_id: String = ""
var shop_level: String = "BASIC"
var include_lower_levels: bool = true

var _is_configured: bool = false


func setup(
	new_shop_id: String,
	new_shop_level: String = "BASIC",
	new_include_lower_levels: bool = true,
) -> void:
	shop_id = new_shop_id.to_upper()
	shop_level = new_shop_level.to_upper()
	include_lower_levels = new_include_lower_levels
	_is_configured = true

	# setup() may be called before or after the node enters the tree.
	if is_node_ready():
		refresh_shop()


func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)

	if not _is_configured:
		push_warning("GenericTradePanel opened without setup() being called")
		return

	refresh_shop()


func refresh_shop() -> void:
	if not is_node_ready():
		return

	_clear_stock_rows()

	if shop_id.is_empty():
		_show_error("No shop ID was provided")
		return

	if Game.shops == null:
		_show_error("The shop service is not available")
		return

	if not Game.shops.has_shop(shop_id):
		_show_error("Unknown shop: %s" % shop_id)
		return

	title_label.text = _create_shop_title()

	shop_info_label.text = "Shop level: %s" % (shop_level.capitalize())

	var stock: Array[Dictionary] = (Game.shops.get_stock_items(
			shop_id,
			shop_level,
			include_lower_levels,
		))

	empty_stock_label.visible = stock.is_empty()

	for item in stock:
		_add_stock_row(item)


func _add_stock_row(item: Dictionary) -> void:
	var row = TRADE_ITEM_ROW_SCENE.instantiate()

	row.setup(item)

	row.purchase_requested.connect(_on_row_purchase_requested)

	stock_container.add_child(row)


func _clear_stock_rows() -> void:
	for child in stock_container.get_children():
		child.queue_free()


func _create_shop_title() -> String:
	return shop_id.replace("_", " ").capitalize()


func _show_error(message: String) -> void:
	title_label.text = "Shop unavailable"
	shop_info_label.text = message
	empty_stock_label.visible = true


func _on_row_purchase_requested(item_id: String, quantity: int) -> void:
	purchase_requested.emit(shop_id, item_id, quantity)


func _on_close_button_pressed() -> void:
	closed.emit()
	queue_free()
