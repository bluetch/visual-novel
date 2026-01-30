# =============================================================================
# 主場景腳本 (main.gd)
# =============================================================================
# 這個腳本控制整個文字冒險遊戲的流程。
# 在 Godot 裡，腳本要「掛」在某個節點上才會執行；
# 這個腳本掛在 main 場景的根節點（Control）上。
#
# 零基礎概念：
# - extends Control：代表這個腳本「繼承」Control 節點，所以可以放按鈕、標籤等 UI。
# - func：函式（function），就是把一堆指令包成一個名字，之後可以重複呼叫。
# - var / const：變數（會變）和常數（不會變），用來存資料。
# =============================================================================

extends Control

# -----------------------------------------------------------------------------
# 載入劇情資料
# -----------------------------------------------------------------------------
# preload 會在遊戲一開始就載入檔案，之後直接用 Story 就能取用。
# "res://" 是 Godot 的專案根目錄，寫路徑時都從這裡開始。
#
# 小提醒：story_data.gd 也有 class_name StoryData（全域類別名），
# 為了避免「名稱衝突」警告，我們這裡用 Story 當變數名。
const Story = preload("res://scripts/story_data.gd")

# 取得 Autoload 的單例物件（位在 /root/GlobalState）
# 這樣寫的好處是：就算編輯器的靜態檢查不認得 Autoload 名稱，程式也仍然正確且好維護。
const GameStateDataScript = preload("res://scripts/game_state.gd")
@onready var game_state = get_node("/root/GlobalState") as GameStateDataScript

# -----------------------------------------------------------------------------
# 變數：記錄「現在玩到哪裡」
# -----------------------------------------------------------------------------
var _current_node_id: String = ""   # 當前劇情節點 ID，例如 "start"、"dog-route-1"
var _current_node: Dictionary = {}  # 當前節點的全部內容（對話、選項等）
var _current_dialogue_index: int = 0  # 現在顯示到第幾句對話（從 0 開始數）
var _narration_pending: bool = false
var _default_dialog_text_modulate: Color = Color(1,1,1,1)

# -----------------------------------------------------------------------------
# 常數：圖片路徑的「模板」
# -----------------------------------------------------------------------------
# %s 是佔位符，之後用字串替換。例如 _BG_PATH % "a-park" 會變成
# "res://assets/backgrounds/a-park.png"
const _BG_PATH := "res://assets/backgrounds/%s.png"
const _CHAR_PATH := "res://assets/characters/%s.png"
const _END_PATH := "res://assets/endings/%s.png"


# =============================================================================
# _ready() — 遊戲一開始會自動執行一次
# =============================================================================
# Godot 有很多「內建函式」，名字固定，引擎會在特定時機呼叫。
# _ready 就是：場景載入完成、節點都準備好之後，執行一次。
func _ready() -> void:
	# 連接「下一句」按鈕的按下事件
	# 按鈕有 pressed 信號（signal），按下時會發出；connect 表示「當按下時，請呼叫 _on_next_pressed」
	$DialogBg/NextBtn.pressed.connect(_on_next_pressed)

	# 連接「重新開始」按鈕的按下事件
	# $ 是取得子節點的快寫，例如 $DialogBg 就是「名為 DialogBg 的子節點」
	$EndingOverlay/CenterContainer/VBoxContainer/RestartBtn.pressed.connect(_restart)

	# 讓對話框可以接收滑鼠點擊（否則點擊會穿過去）
	# MOUSE_FILTER_STOP = 停在這裡，不傳給後面的節點
	$DialogBg.mouse_filter = Control.MOUSE_FILTER_STOP

	# 遊戲中也可切換語言（中文 / 英文）
	$LangBtn.pressed.connect(_toggle_language)
	game_state.language_changed.connect(_on_language_changed)
	_refresh_static_ui()

	# 先隱藏結局畫面，再從劇情起點開始
	_hide_ending_overlay()
	_goto_node(Story.START_NODE)

	# 儲存對話文字預設顏色（之後可還原）
	_default_dialog_text_modulate = $DialogBg/DialogText.modulate


# =============================================================================
# 語言切換：更新 UI / 重畫當前內容
# =============================================================================

func _refresh_static_ui() -> void:
	# 這裡放「不是劇情內容」但需要翻譯的 UI 字
	$LangBtn.text = game_state.ui("lang_btn")
	$EndingOverlay/CenterContainer/VBoxContainer/RestartBtn.text = game_state.ui("restart")


func _toggle_language() -> void:
	# 在 zh/en 之間切換
	if game_state.language == "zh":
		game_state.set_language("en")
	else:
		game_state.set_language("zh")


func _on_language_changed(_lang: String) -> void:
	# 語言切換後：更新 UI，並把「目前畫面」重新渲染成新語言
	_refresh_static_ui()

	# 結局畫面顯示中：用當前 node 重畫結局文字
	if $EndingOverlay/CenterContainer.visible:
		if not _current_node.is_empty():
			_show_ending(_current_node)
		return

	# 一般對話中：重畫「目前那一句」與「選項」
	if _current_node.is_empty():
		return
	_render_current_dialogue_line()
	if $DialogBg/OptionsContainer.visible:
		_show_options(_current_node.get("options", []))


func _render_current_dialogue_line() -> void:
	# 注意：_current_dialogue_index 指向「下一句要顯示的 index」
	# 所以目前畫面上那一句其實是 index-1
	var dialogues: Array = _current_node.get("dialogues", [])
	if dialogues.is_empty():
		return
	var idx: int = clampi(_current_dialogue_index - 1, 0, dialogues.size() - 1)
	var d: Dictionary = dialogues[idx]
	# 隱藏或顯示說話者名稱（旁白應隱藏 speaker）
	var speaker_val = d.get("speaker", "")
	var speaker_text = game_state.pick(speaker_val)
	if d.get("narration", false) or speaker_text == "":
		$DialogBg/CharacterName.visible = false
	else:
		$DialogBg/CharacterName.visible = true
		$DialogBg/CharacterName.text = speaker_text

	_set_character(d.get("character", ""))

	# 文字與可選顏色覆寫（支援 hex，如 "#RRGGBB"）
	$DialogBg/DialogText.text = game_state.pick(d.get("text", ""))
	var color_hex: String = d.get("color", "")
	if color_hex != "":
		$DialogBg/DialogText.modulate = _color_from_hex(color_hex)
	else:
		$DialogBg/DialogText.modulate = _default_dialog_text_modulate


# =============================================================================
# _input(event) — 每當玩家有輸入（鍵盤、滑鼠）時，Godot 會呼叫
# =============================================================================
# event 是輸入事件，我們檢查是不是「滑鼠左鍵按下」。
# 這樣玩家點畫面任意處就可以下一句，不用一定要按按鈕。
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# 轉成滑鼠事件型別，才能用 .button_index、.pressed 等
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			# 如果滑鼠是在「按鈕」上點擊（例如語言按鈕、選項按鈕、重新開始…），
			# 就不要用「點畫面下一句」去干擾（避免點一次按鈕卻推進對話）。
			var hovered := get_viewport().gui_get_hovered_control()
			if hovered != null and hovered is BaseButton:
				return

			# 只有「對話進行中」才觸發：對話框顯示、下一句按鈕顯示、選項沒顯示
			if $DialogBg.visible and $DialogBg/NextBtn.visible and not $DialogBg/OptionsContainer.visible:
				_advance_dialogue()
				# 告訴引擎「這個輸入我吃掉了」，避免再觸發其他東西
				get_viewport().set_input_as_handled()


# -----------------------------------------------------------------------------
# 隱藏結局畫面，改顯示一般遊戲畫面（對話框、立繪）
# -----------------------------------------------------------------------------
func _hide_ending_overlay() -> void:
	$EndingOverlay/ColorRect.visible = false
	$EndingOverlay/CenterContainer.visible = false
	$DialogBg.visible = true
	$CharacterSprite.visible = true


# -----------------------------------------------------------------------------
# 顯示結局畫面，隱藏對話框和立繪
# -----------------------------------------------------------------------------
func _show_ending_overlay() -> void:
	$DialogBg.visible = false
	$CharacterSprite.visible = false
	$EndingOverlay/ColorRect.visible = true
	$EndingOverlay/CenterContainer.visible = true


# -----------------------------------------------------------------------------
# 重新開始：隱藏結局 → 跳回起點
# -----------------------------------------------------------------------------
func _restart() -> void:
	_hide_ending_overlay()
	_goto_node(Story.START_NODE)


# =============================================================================
# _goto_node(id) — 跳到某個劇情節點
# =============================================================================
# id 是節點名稱，例如 "start"、"dog-route-1"、"stalker-bad-end"。
# 從 StoryData 拿該節點的資料，如果是結局就顯示結局；否則顯示對話與選項。
func _goto_node(id: String) -> void:
	var node: Dictionary = Story.get_node(id)
	if node.is_empty():
		return  # 找不到就提早離開，不做事

	_current_node_id = id
	_current_node = node

	# 結局節點：顯示結局畫面後直接 return，不再跑下面的對話邏輯
	if Story.is_ending(node):
		_show_ending(node)
		return

	# 一般對話節點：換背景、清選項、顯示下一句按鈕，然後跑第一句對話
	_set_background(node.get("background", "a-park"))
	_current_dialogue_index = 0
	_clear_options()
	$DialogBg/OptionsContainer.visible = false
	$DialogBg/NextBtn.visible = true

	# 若節點有 node-level narration，先顯示旁白（隱藏 speaker），下一次按 Next 再開始 dialogues
	if _current_node.has("narration"):
		_narration_pending = true
		$DialogBg/CharacterName.visible = false
		$DialogBg/DialogText.text = game_state.pick(_current_node.get("narration", ""))
		var narr_color: String = _current_node.get("narration_color", "")
		if narr_color != "":
			$DialogBg/DialogText.modulate = _color_from_hex(narr_color)
		else:
			$DialogBg/DialogText.modulate = _default_dialog_text_modulate
		return

	_advance_dialogue()


# =============================================================================
# _advance_dialogue() — 推進對話：下一句，或顯示選項
# =============================================================================
# 若還有未顯示的對話，就顯示一句，並把「當前句數」+1。
# 若對話都顯示完了，就改成顯示選項按鈕，並隱藏「下一句」按鈕。
func _advance_dialogue() -> void:
	var dialogues: Array = _current_node.get("dialogues", [])

	# 如果剛剛顯示過 node-level narration，下一次按 Next 要開始 dialogues
	if _narration_pending:
		_narration_pending = false
		# 還原對話文字顏色（若旁白改過顏色）
		$DialogBg/DialogText.modulate = _default_dialog_text_modulate

	# 已經沒有下一句了：若節點沒有定義 options 欄位，嘗試自動跳到 next
	if _current_dialogue_index >= dialogues.size():
		if not _current_node.has("options"):
			var next_id: String = _current_node.get("next", "")
			if next_id != "":
				_goto_node(next_id)
				return
		_show_options(_current_node.get("options", []))
		return

	# 取當前這一句的資料（speaker=誰說的, text=內容, character=立繪檔名）
	var d: Dictionary = dialogues[_current_dialogue_index]
	# 隱藏或顯示說話者名稱（旁白應隱藏 speaker）
	var speaker_val = d.get("speaker", "")
	var speaker_text = game_state.pick(speaker_val)
	if d.get("narration", false) or speaker_text == "":
		$DialogBg/CharacterName.visible = false
	else:
		$DialogBg/CharacterName.visible = true
		$DialogBg/CharacterName.text = speaker_text

	_set_character(d.get("character", ""))
	var msg: String = game_state.pick(d.get("text", ""))
	$DialogBg/DialogText.text = msg
	var color_hex: String = d.get("color", "")
	if color_hex != "":
		$DialogBg/DialogText.modulate = _color_from_hex(color_hex)
	else:
		$DialogBg/DialogText.modulate = _default_dialog_text_modulate

	_current_dialogue_index += 1  # 下一句
	$DialogBg/NextBtn.visible = true


# 當玩家按下「下一句」按鈕時，Godot 會呼叫這個函式
func _on_next_pressed() -> void:
	_advance_dialogue()


# -----------------------------------------------------------------------------
# 清空所有選項按鈕（每個節點都會重建，所以要先把舊的刪掉）
# -----------------------------------------------------------------------------
# get_children() 會回傳該節點底下所有子節點；queue_free() 是「請在稍後刪除這個節點」。
func _clear_options() -> void:
	for c in $DialogBg/OptionsContainer.get_children():
		c.queue_free()


# -----------------------------------------------------------------------------
# 顯示選項按鈕
# -----------------------------------------------------------------------------
# opts 是選項陣列，每項有 "text"（按鈕文字）和 "next"（按下後要跳的節點 ID）。
# 我們用迴圈建立按鈕、設文字、連接到 _on_option_pressed，並加進 OptionsContainer。
func _show_options(opts: Array) -> void:
	$DialogBg/NextBtn.visible = false
	_clear_options()
	if opts.is_empty():
		# 還原對話文字顏色
		$DialogBg/DialogText.modulate = _default_dialog_text_modulate
		return

	$DialogBg/OptionsContainer.visible = true
	for opt in opts:
		var next_id: String = opt.get("next", "")
		var btn := Button.new()  # 建立新按鈕
		btn.text = game_state.pick(opt.get("text", ""))
		btn.add_theme_font_size_override("font_size", 28)
		# pressed.connect(...) 表示按下時呼叫 _on_option_pressed，並把 next_id 傳進去
		btn.pressed.connect(_on_option_pressed.bind(next_id))
		$DialogBg/OptionsContainer.add_child(btn)  # 把按鈕加到選項容器裡


# 玩家按下某個選項時，我們就跳到該選項對應的節點
func _on_option_pressed(next_id: String) -> void:
	_goto_node(next_id)


# -----------------------------------------------------------------------------
# 顯示結局畫面
# -----------------------------------------------------------------------------
# 結局節點有 title、text、image、ending_type（好/壞）等。
# 我們依照好壞結局改背景色與標題顏色，並顯示結局圖、標題、說明。
func _show_ending(node: Dictionary) -> void:
	_show_ending_overlay()
	var bg: String = node.get("background", "a-park")
	_set_background(bg)

	var img_key: String = node.get("image", "")
	if img_key:
		var tex: Texture2D = load(_END_PATH % img_key) as Texture2D
		$EndingOverlay/CenterContainer/VBoxContainer/EndingImage.texture = tex
		$EndingOverlay/CenterContainer/VBoxContainer/EndingImage.visible = true
	else:
		$EndingOverlay/CenterContainer/VBoxContainer/EndingImage.visible = false

	$EndingOverlay/CenterContainer/VBoxContainer/EndingTitle.text = game_state.pick(node.get("title", ""))
	$EndingOverlay/CenterContainer/VBoxContainer/EndingText.text = game_state.pick(node.get("text", ""))

	var is_good: bool = Story.is_good_ending(node)
	if is_good:
		$EndingOverlay/ColorRect.color = Color(0.08, 0.15, 0.12, 0.94)
		$EndingOverlay/CenterContainer/VBoxContainer/EndingTitle.add_theme_color_override("font_color", Color(0.6, 0.95, 0.75))
	else:
		$EndingOverlay/ColorRect.color = Color(0.18, 0.08, 0.08, 0.94)
		$EndingOverlay/CenterContainer/VBoxContainer/EndingTitle.add_theme_color_override("font_color", Color(0.95, 0.5, 0.5))

	# 還原對話文字顏色，避免結局畫面後文字顏色異常
	$DialogBg/DialogText.modulate = _default_dialog_text_modulate


# -----------------------------------------------------------------------------
# 更換背景圖
# -----------------------------------------------------------------------------
# key 是檔名不含副檔名，例如 "a-park"、"a-drink-shop"。
func _set_background(key: String) -> void:
	var path: String = _BG_PATH % key
	var tex: Texture2D = load(path) as Texture2D
	if tex:
		$Background.texture = tex


# -----------------------------------------------------------------------------
# 更換立繪（角色圖）
# -----------------------------------------------------------------------------
# key 是檔名不含副檔名，例如 "girl-a-happy"、"boy-a-normal"。
# 若 key 是空的，就隱藏立繪（例如某些只有旁白的場合）。
func _set_character(key: String) -> void:
	if key.is_empty():
		$CharacterSprite.visible = false
		return
	var path: String = _CHAR_PATH % key
	var tex: Texture2D = load(path) as Texture2D
	if tex:
		$CharacterSprite.texture = tex
		$CharacterSprite.visible = true


func _color_from_hex(hex:String) -> Color:
	if hex == "":
		return _default_dialog_text_modulate
	var s := hex.strip_edges()
	if s.begins_with("#"):
		s = s.substr(1, s.length() - 1)
	if s.length() == 6:
		var r = int("0x" + s.substr(0,2))
		var g = int("0x" + s.substr(2,2))
		var b = int("0x" + s.substr(4,2))
		return Color8(r, g, b)
	# fallback
	return _default_dialog_text_modulate
