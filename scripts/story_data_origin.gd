# =============================================================================
# 劇情資料 (story_data.gd)
# =============================================================================
# 這個檔案只負責「存劇情」，不負責顯示。main.gd 會來這裡查資料。
#
# 零基礎概念：
# - extends RefCounted：輕量型物件，不掛在場景節點上也可以存在。
# - class_name StoryData：給這個腳本取一個類別名，別的腳本可以用 StoryData.xxx 呼叫。
# - Dictionary：鍵值對，像 {"鍵": 值}，用 .get("鍵", 預設值) 取值。
# - Array：有序列表 [項目1, 項目2, ...]，用 [0]、[1] 或 [i] 取第幾個。
# - static func：靜態函式，不用先「做出一個 StoryData 實例」也能呼叫，直接 StoryData.get_node(...) 即可。
# =============================================================================

extends RefCounted

# -----------------------------------------------------------------------------
# STORY — 整個劇情的「地圖」
# -----------------------------------------------------------------------------
# 每個「節點」用一個 ID 當鍵，例如 "start"、"dog-route-1"。
# 節點有兩大類：
#   1. 一般節點：有 background、dialogues、options
#   2. 結局節點：有 type: "ending"、ending_type: "good"/"bad"、title、text、image
#
# dialogues：陣列，每一句有 speaker（誰說的）、text（內容）、character（立繪檔名）。
#   - speaker / text 這兩個欄位「可以是字串」，也可以是 {"zh": "...", "en": "..."} 這種雙語字典
# options：陣列，每個選項有 text（按鈕文字）、next（按下後要跳的節點 ID）。
#   - text 也可以是 {"zh": "...", "en": "..."} 這種雙語字典
# background：背景圖檔名（不含 .png），對應 assets/backgrounds/ 裡的圖。
# =============================================================================

const STORY := {
	# ---- 起點 ----
	"start": {
		"background": "a-park",
		"dialogues": [
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "哈囉～好久不見！你也來公園散步嗎？", "en": "Hi! Long time no see. Are you taking a walk in the park too?"},
				"character": "girl-a-happy"
			},
			{
				"narration": true,
				"text": {"zh": "對面來了一個人...", "en": "A person is coming from the opposite direction..."},
				"color": "#888888"
			},
			{
				"speaker": {"zh": "你", "en": "You"},
				"text": {"zh": "嗨，好久不見⋯⋯", "en": "Hey... long time no see."},
				"character": "boy-a-normal"
			}
		],
		# "options": [
		# 	{"text": {"zh": "我來溜狗啦", "en": "I'm walking my dog."}, "next": "dog-route-1"},
		# 	{"text": {"zh": "對啊，最近心情不好，來散散心", "en": "Yeah. I've been feeling down, so I came out for a walk."}, "next": "feeling-route-1"},
		# 	{"text": {"zh": "對啊，我想說可能會遇見你", "en": "Yeah. I thought I might run into you."}, "next": "stalker-route-1"}
		# ]
	"next": "dog-route-1",
	},
	# ---- 遛狗路線 ----
	"dog-route-1": {
		"background": "a-park",
		"dialogues": [
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "哇！好可愛的狗狗！你養多久了啊？", "en": "Wow! Your dog is so cute! How long have you had them?"},
				"character": "girl-a-happy"
			},
			{
				"speaker": {"zh": "你", "en": "You"},
				"text": {"zh": "其實才養了兩個月而已。", "en": "Actually, only about two months."},
				"character": "boy-a-normal"
			},
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "可以讓我摸摸牠嗎？", "en": "Can I pet them?"},
				"character": "girl-a-happy"
			}
		],
		"options": [
			{"text": {"zh": "當然可以！牠很親人的", "en": "Sure! They're really friendly."}, "next": "dog-route-2a"},
			{"text": {"zh": "抱歉，牠有點怕生...", "en": "Sorry, they're a bit shy..."}, "next": "dog-route-2b"}
		]
	},
	"dog-route-2a": {
		"background": "a-park",
		"dialogues": [
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "真的好可愛！而且好乖喔～", "en": "So cute! And so well-behaved~"},
				"character": "girl-a-happy"
			},
			{
				"speaker": {"zh": "你", "en": "You"},
				"text": {"zh": "對啊，牠很喜歡你呢！", "en": "Yeah, they really like you!"},
				"character": "boy-a-happy"
			},
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "我也很喜歡狗狗！我們要不要一起散步？", "en": "I love dogs too! Want to take a walk together?"},
				"character": "girl-a-happy"
			}
		],
		"options": [
			{"text": {"zh": "好啊，一起走吧！", "en": "Sure, let's go!"}, "next": "dog-happy-end"}
		]
	},
	"dog-route-2b": {
		"background": "a-park",
		"dialogues": [
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "這樣啊...", "en": "Oh... I see."},
				"character": "girl-a-sad"
			}
		],
		"options": [
			{"text": {"zh": "騙你的啦，牠很喜歡你喔！你來摸摸他吧～", "en": "Just kidding—he likes you! Go ahead and pet him~"}, "next": "dog-route-2a"},
			{"text": {"zh": "其實他原本很親人，但最近發生了一些事⋯⋯", "en": "He used to be really friendly, but something happened recently..."}, "next": "feeling-route-3"}
		]
	},
	# ---- 心情 / 傾訴路線 ----
	"feeling-route-1": {
		"background": "a-park",
		"dialogues": [
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "你最近怎麼了？還好嗎？", "en": "Have you been okay lately?"},
				"character": "girl-a-normal"
			},
			{
				"speaker": {"zh": "你", "en": "You"},
				"text": {"zh": "喔，沒什麼啦...", "en": "Oh, it's nothing..."},
				"character": "boy-a-sad"
			}
		],
		"options": [
			{"text": {"zh": "只是工作有點累...", "en": "Just tired from work..."}, "next": "feeling-route-2"},
			{"text": {"zh": "其實是感情問題...", "en": "Actually, it's relationship stuff..."}, "next": "feeling-route-3"}
		]
	},
	"feeling-route-2": {
		"background": "a-park",
		"dialogues": [
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "工作太忙了嗎？要不要去喝杯咖啡？", "en": "Work's been that busy? Want to grab a coffee?"},
				"character": "girl-a-normal"
			},
			{
				"speaker": {"zh": "你", "en": "You"},
				"text": {"zh": "好啊，正好附近有間不錯的咖啡廳。", "en": "Sure. There's a nice café nearby."},
				"character": "boy-a-normal"
			}
		],
		"options": [
			{"text": {"zh": "一起去吧！", "en": "Let's go together!"}, "next": "feeling-happy-end"}
		]
	},
	"feeling-route-3": {
		"background": "a-park",
		"dialogues": [
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "欸？是發生什麼事了嗎？", "en": "Huh? What happened?"},
				"character": "girl-a-surprise"
			},
			{
				"speaker": {"zh": "你", "en": "You"},
				"text": {"zh": "其實...", "en": "Well..."},
				"character": "boy-a-sad"
			}
		],
		"options": [
			{"text": {"zh": "我想多聊聊...", "en": "I want to talk a bit more..."}, "next": "feeling-happy-end"},
			{"text": {"zh": "我很想見到你，所以才在這裡等你", "en": "I really wanted to see you, so I waited here."}, "next": "stalker-route-2"}
		]
	},
	# ---- 跟蹤狂路線（壞結局） ----
	"stalker-route-1": {
		"background": "a-park",
		"dialogues": [
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "咦？你怎麼知道我會在這裡？", "en": "Huh? How did you know I'd be here?"},
				"character": "girl-a-surprise"
			},
			{
				"speaker": {"zh": "你", "en": "You"},
				"text": {"zh": "這個嘛...", "en": "Well..."},
				"character": "boy-a-normal"
			}
		],
		"options": [
			{"text": {"zh": "我常常看到你在這裡散步", "en": "I often see you walking here."}, "next": "stalker-route-2"},
			{"text": {"zh": "只是碰巧啦！", "en": "It was just a coincidence!"}, "next": "stalker-route-3"}
		]
	},
	"stalker-route-2": {
		"background": "a-park",
		"dialogues": [
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "你該不會一直在觀察我吧？", "en": "Have you been watching me?"},
				"character": "girl-a-angry"
			}
		],
		"options": [
			{"text": {"zh": "...", "en": "..."}, "next": "stalker-bad-end"}
		]
	},
	"stalker-route-3": {
		"background": "a-park",
		"dialogues": [
			{
				"speaker": {"zh": "莉莉", "en": "Lily"},
				"text": {"zh": "真的嗎？怎麼感覺怪怪的...", "en": "Really? It still feels kind of weird..."},
				"character": "girl-a-normal"
			}
		],
		"options": [
			{"text": {"zh": "其實我喜歡你很久了...", "en": "I've liked you for a long time..."}, "next": "stalker-route-2"},
			{"text": {"zh": "你想太多了啦～我才沒那麼閒，最近可是很忙的！", "en": "You're overthinking it~ I've been really busy lately!"}, "next": "feeling-route-1"}
		]
	},
	# ---- 結局 ----
	"dog-happy-end": {
		"type": "ending",
		"ending_type": "good",
		"title": {"zh": "狗狗結局", "en": "Dog Ending"},
		"text": {"zh": "你們一起散步，成為了好朋友。", "en": "You take a walk together and become good friends."},
		"image": "ending-dog",
		"background": "a-park"
	},
	"feeling-happy-end": {
		"type": "ending",
		"ending_type": "good",
		"title": {"zh": "傾訴結局", "en": "Heart-to-Heart Ending"},
		"text": {"zh": "你們聊了很久，心情好多了。", "en": "You talk for a long time, and you feel much better."},
		"image": "ending-sunshine",
		"background": "a-drink-shop"
	},
	"stalker-bad-end": {
		"type": "ending",
		"ending_type": "bad",
		"title": {"zh": "壞結局", "en": "Bad Ending"},
		"text": {"zh": "你被當成了跟蹤狂⋯⋯", "en": "You get mistaken for a stalker..."},
		"image": "ending-fail",
		"background": "a-park"
	}
}

# 遊戲從哪一個節點開始（main.gd 會用這個當起點）
const START_NODE := "start"

# 依 ID 取得節點資料；找不到就回傳空 Dictionary {}
static func get_node(id: String) -> Dictionary:
	return STORY.get(id, {})

# 這個節點是不是結局？（有 type == "ending" 的就是）
static func is_ending(node: Dictionary) -> bool:
	return node.get("type", "") == "ending"

# 結局是不是好結局？（ending_type == "good"）
static func is_good_ending(node: Dictionary) -> bool:
	return node.get("ending_type", "") == "good"
