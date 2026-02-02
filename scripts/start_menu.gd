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
	# 在全域根節點上加一個高層級的黑幕，先遮住畫面再載入 main，避免短暫露出預設 UI
	var mask_layer := CanvasLayer.new()
	mask_layer.layer = 1000
	var mask := ColorRect.new()
	mask.color = Color(0,0,0,1)
	mask.anchor_left = 0.0
	mask.anchor_top = 0.0
	mask.anchor_right = 1.0
	mask.anchor_bottom = 1.0
	mask.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mask.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mask_layer.add_child(mask)
	var root := get_tree().get_root()
	

	# Replace current scene by instantiating main.tscn manually.
	var packed := load("res://scenes/main.tscn") as PackedScene
	if not packed:
		push_error("Failed to load main.tscn")
		mask_layer.queue_free()
		return
	var inst := packed.instantiate()
	# 設定 main 的初始過場時長（秒），可改成你想要的數值
	if inst.has_method("set"):
		# 如果 main.gd 有 export 變數 initial_fade_duration，這裡會設置成功
		inst.set("initial_fade_duration", 0.6)
	root.add_child(inst)
	get_tree().set_current_scene(inst)

	# 等待 main 場景發出初始化完成訊號後再移除黑幕與 StartMenu
	if inst.has_signal("game_ready"):
		await inst.game_ready
	else:
		# 若不支援 signal，備用短延遲
		var timer = get_tree().create_timer(0.12)
		await timer.timeout

	if is_instance_valid(mask_layer):
		mask_layer.queue_free()
	call_deferred("_deferred_remove_self")

func _deferred_remove_self() -> void:
	var root := get_tree().get_root()
	if root.has_node(self.get_path()):
		root.remove_child(self)
	queue_free()


func _refresh_text(_lang: String) -> void:
	$Center/VBox/Title.text = game_state.ui("game_title")
	$Center/VBox/LangLabel.text = game_state.ui("language")
	$Center/VBox/LangRow/ZhBtn.text = game_state.ui("chinese")
	$Center/VBox/LangRow/EnBtn.text = game_state.ui("english")
	$Center/VBox/StartBtn.text = game_state.ui("start")

	# 小 UX：目前語言的按鈕禁用，避免一直重複點
	$Center/VBox/LangRow/ZhBtn.disabled = game_state.language == "zh"
	$Center/VBox/LangRow/EnBtn.disabled = game_state.language == "en"
