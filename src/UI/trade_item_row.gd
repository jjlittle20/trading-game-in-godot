extends PanelContainer

signal purchase_requested(item_id: String, quantity: int)

@onready var name_label: Label = ($MarginContainer/HBoxContainer/ItemDetails/NameLabel)

@onready var description_label: Label = (
	$MarginContainer/HBoxContainer/ItemDetails/DescriptionLabel
)

@onready var price_label: Label = ($MarginContainer/HBoxContainer/PriceLabel)

@onready var quantity_spin_box: SpinBox = ($MarginContainer/HBoxContainer/QuantitySpinBox)

@onready var buy_button: Button = ($MarginContainer/HBoxContainer/BuyButton)

var item_data: Dictionary = { }
var item_id: String = ""
var unit_price: int = 0

var _is_configured: bool = false


func setup(new_item_data: Dictionary) -> void:
	item_data = new_item_data.duplicate(true)

	item_id = str(item_data.get("id", ""))

	unit_price = int(item_data.get("cost", item_data.get("base_price", item_data.get("price", 0))))

	_is_configured = true

	if is_node_ready():
		_refresh_display()


func _ready() -> void:
	print("TradeItemRow ready for item: ", item_id)

	if not buy_button.pressed.is_connected(_on_buy_button_pressed):
		buy_button.pressed.connect(_on_buy_button_pressed)

	if not quantity_spin_box.value_changed.is_connected(_on_quantity_changed):
		quantity_spin_box.value_changed.connect(_on_quantity_changed)

	if not _is_configured:
		push_warning("TradeItemRow opened without item data")
		return

	_refresh_display()


func _refresh_display() -> void:
	var display_name: String = str(item_data.get("name", item_id))

	var description: String = str(item_data.get("description", ""))

	name_label.text = display_name
	description_label.text = description

	buy_button.disabled = item_id.is_empty()

	_update_price_text()


func _update_price_text() -> void:
	var quantity: int = int(quantity_spin_box.value)

	var total_price: int = unit_price * quantity

	price_label.text = "%d each\n%d total" % [unit_price, total_price]


func _on_quantity_changed(_new_value: float) -> void:
	_update_price_text()


func _on_buy_button_pressed() -> void:
	print("Buy pressed for: ", item_id)

	if item_id.is_empty():
		push_error("Cannot purchase an item without an ID")
		return

	var quantity: int = int(quantity_spin_box.value)

	if quantity <= 0:
		push_error("Purchase quantity must be above zero")
		return

	print("Emitting purchase request: ", item_id, " quantity ", quantity)

	purchase_requested.emit(item_id, quantity)
