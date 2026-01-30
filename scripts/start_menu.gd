extends Control

# =============================================================================
# 開始頁面 (start_menu.gd)
# =============================================================================
# 這個場景提供：
# - 選擇語言（中文 / 英文）
# - 按「開始遊戲」進入 main.tscn
# =============================================================================

const GameStateDataScript = preload("res://scripts/game_state.gd")
@onready var game_state = get_node("/root/GlobalState") as GameStateDataScript


func _ready() -> void:
	# 連接按鈕事件
	$Center/VBox/LangRow/ZhBtn.pressed.connect(func(): game_state.set_language("zh"))
	$Center/VBox/LangRow/EnBtn.pressed.connect(func(): game_state.set_language("en"))
	$Center/VBox/StartBtn.pressed.connect(_start_game)

	# 語言變更時更新介面文字
	game_state.language_changed.connect(_refresh_text)

	_refresh_text(game_state.language)


func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _refresh_text(_lang: String) -> void:
	$Center/VBox/Title.text = game_state.ui("game_title")
	$Center/VBox/LangLabel.text = game_state.ui("language")
	$Center/VBox/LangRow/ZhBtn.text = game_state.ui("chinese")
	$Center/VBox/LangRow/EnBtn.text = game_state.ui("english")
	$Center/VBox/StartBtn.text = game_state.ui("start")

	# 小 UX：目前語言的按鈕禁用，避免一直重複點
	$Center/VBox/LangRow/ZhBtn.disabled = game_state.language == "zh"
	$Center/VBox/LangRow/EnBtn.disabled = game_state.language == "en"

