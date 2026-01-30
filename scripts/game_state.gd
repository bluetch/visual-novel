extends Node
class_name GameStateData

# =============================================================================
# GameState（全域狀態 / Singleton）
# =============================================================================
# 這個腳本會被設成「Autoload / Singleton」：
# - Autoload 的意思是：遊戲一開始就載入，且整個遊戲期間都存在
# - 你可以在任何腳本直接用 `GameState` 取得它（像全域變數一樣）
#
# 這裡我們用它來記住「目前語言」（中文 / 英文），讓你從開始頁面切到遊戲場景後，
# 語言設定不會消失。
# =============================================================================

signal language_changed(lang: String)

# 目前語言：用簡單代碼 "zh" 或 "en"
var language: String = "zh"

# UI 的固定文字（不是劇情）放這裡比較好管理
const UI := {
	"game_title": {"zh": "公園相遇", "en": "Park Encounter"},
	"start": {"zh": "開始遊戲", "en": "Start"},
	"language": {"zh": "語言", "en": "Language"},
	"chinese": {"zh": "中文", "en": "Chinese"},
	"english": {"zh": "英文", "en": "English"},
	"restart": {"zh": "重新開始", "en": "Restart"},
	"back_to_menu": {"zh": "回到開始頁", "en": "Back to Menu"},
	"lang_btn": {"zh": "中 / EN", "en": "EN / 中"},
}


func set_language(lang: String) -> void:
	# 只允許 zh/en，避免打錯造成顯示不到字
	if lang != "zh" and lang != "en":
		return
	if lang == language:
		return
	language = lang
	language_changed.emit(language)


func pick(value) -> String:
	# 小工具：把「可能是字串、也可能是 {zh:..., en:...}」的資料，轉成要顯示的文字。
	#
	# - 如果 value 是 Dictionary（例如 {"zh":"你好","en":"Hello"}）
	#   就依照目前 language 取對應語言
	# - 如果 value 是 String（例如 "你好"），就原樣回傳
	if value is Dictionary:
		var dict: Dictionary = value
		return str(dict.get(language, dict.get("zh", dict.get("en", ""))))
	return str(value)


func ui(key: String) -> String:
	# 取 UI 字典裡的固定字串
	return pick(UI.get(key, key))
