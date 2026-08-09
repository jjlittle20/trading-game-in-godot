extends Node

const SaveService = preload("res://src/core/saves/save_service.gd")

const PlayerState = preload("res://src/domains/player/player_state.gd")

const PlayerService = preload("res://src/domains/player/player_service.gd")

const GameClockService = preload("res://src/domains/time/game_clock_service.gd")

const PoiRepository = preload("res://src/domains/world/poi_repository.gd")

const WorldService = preload("res://src/domains/world/world_service.gd")

const ItemRepository = preload("res://src/domains/items/item_repository.gd")

const ItemService = preload("res://src/domains/items/item_service.gd")

const ShopRepository = preload("res://src/domains/shops/shop_repository.gd")

const ShopService = preload("res://src/domains/shops/shop_service.gd")

const SceneService = preload("res://src/core/scenes/scene_service.gd")

const DEFAULT_PLAYER_DATA_PATH := ("res://data/playerData.json")

const SAVE_PLAYER_DATA_PATH := ("user://playerData.json")

const SAVE_POI_DATA_PATH := ("user://poiData.json")

const DEFAULT_POI_DATA_PATH := ("res://content/base/world/pois.json")

const BASE_ITEM_DATA_PATH := ("res://content/base/items/items.json")

const BASE_SHOP_DATA_PATH := ("res://content/base/shops/shops.json")

var player = null
var clock = null

var world = null
var items = null
var shops = null
var scenes = null

var _player_save_service = null
var _poi_save_service = null

var _poi_repository = null
var _item_repository = null
var _shop_repository = null


func _ready() -> void:
	_initialise_services()


func _initialise_services() -> void:
	_create_core_services()
	_player_save_service = SaveService.new(DEFAULT_PLAYER_DATA_PATH, SAVE_PLAYER_DATA_PATH)
	_poi_save_service = SaveService.new(DEFAULT_POI_DATA_PATH, SAVE_POI_DATA_PATH)

	var player_state = _player_save_service.load_player_state()

	if player_state == null:
		push_error("Could not load PlayerState. Using emergency defaults.")

		player_state = PlayerState.new()

	_create_runtime_services(player_state)
	_load_definition_services()

	print("Game services initialised")


func _create_runtime_services(player_state) -> void:
	player = PlayerService.new(player_state, _player_save_service)

	clock = GameClockService.new(player_state, _player_save_service)


func _create_core_services() -> void:
	scenes = SceneService.new()
	add_child(scenes)


func _load_definition_services() -> void:
	_load_world_definitions()
	_load_item_definitions()
	_load_shop_definitions()


func _load_world_definitions() -> void:
	_poi_repository = PoiRepository.new()
	var poi_data = _poi_save_service.load_poi_data()
	var loaded: bool = _poi_repository.load_from_dictionary(
		poi_data,
		_poi_save_service.get_load_path(),
	)

	if not loaded:
		push_error("Could not initialise POI definitions")

	world = WorldService.new(_poi_repository, _poi_save_service)

	print("World service initialised with %d POIs" % world.get_poi_count())


func _load_item_definitions() -> void:
	_item_repository = ItemRepository.new()

	var loaded: bool = _item_repository.load_from_file(BASE_ITEM_DATA_PATH)

	if not loaded:
		push_error("Could not initialise item definitions")

	items = ItemService.new(_item_repository)

	print("Item service initialised with %d items" % items.get_item_count())


func _load_shop_definitions() -> void:
	if items == null:
		push_error("Cannot initialise shops before items")
		return

	_shop_repository = ShopRepository.new()

	var loaded: bool = _shop_repository.load_from_file(BASE_SHOP_DATA_PATH)

	if not loaded:
		push_error("Could not initialise shop definitions")

	shops = ShopService.new(_shop_repository, items)

	var stock_valid: bool = (shops.validate_shop_stock())

	if not stock_valid:
		push_error("One or more shops contain invalid item references")

	print("Shop service initialised with %d shops" % shops.get_shop_count())


func reset_game() -> bool:
	if _player_save_service == null:
		push_error("Game has no SaveService")
		return false

	var deleted: bool = _player_save_service.delete_save()

	if not deleted:
		return false

	var player_state = _player_save_service.load_player_state()

	if player_state == null:
		player_state = PlayerState.new()

	_create_runtime_services(player_state)

	return true
