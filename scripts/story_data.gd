# =============================================================================
# 劇情資料 (story_data.gd) - 《最後一班公車》完整版
# =============================================================================

extends RefCounted
class_name StoryData

# -----------------------------------------------------------------------------
# STORY — 整個劇情的「地圖」
# -----------------------------------------------------------------------------
const STORY := {
	
	# ---- 00 起點：深夜站牌 ----
	"start": {
		"background": "bus-stop-night",
		"dialogues": [
			{
				"narration": true,
				"text": {"zh": "這座城市的深夜，安靜得能聽見路燈滋滋的電流聲。", "en": "The city at night is so quiet you can hear the hum of the streetlights."},
				"color": "#fff"
			},
			{
				"narration": true,
				"text": {"zh": "站牌上的時間停在 23:47。你低頭看手機，電力剩下 1%。", "en": "The bus sign is stuck at 23:47. You check your phone: 1% battery left."},
				"color": "#888888"
			},
			{
				"narration": true,
				"text": {"zh": "一陣老舊引擎的低鳴從街道盡頭傳來。一台沒有編號、燈光泛黃的公車緩緩靠站。", "en": "An old engine rumbles from the end of the street. A bus with no number and yellow lights pulls up."},
				"color": "#888888"
			}
		],
		"options": [
			{"text": {"zh": "別無選擇，上車吧", "en": "No choice, get on the bus"}, "next": "bus-interior-start"}
		]
	},

	# ---- 01 進入車廂 ----
	"bus-interior-start": {
		"background": "bus-interior",
		"dialogues": [
			{
				"narration": true,
				"text": {"zh": "車門在你身後發出沉重的「嗤——」聲關上了。車內有一種混合了舊報紙與雨水的潮濕氣息。", "en": "The doors hiss shut behind you. The air inside smells of damp newspapers and rain."},
				"color": "#888888"
			},
			{
				"narration": true,
				"text": {"zh": "司機戴著破舊的大盤帽，雙手動也不動地握著方向盤，彷彿與這台車融為了一體。", "en": "The driver wears a tattered cap, hands frozen on the wheel, as if merged with the bus itself."},
				"color": "#888888"
			},
			{
				"speaker": {"zh": "你", "en": "You"},
				"text": {"zh": "「那個...請問這班車往哪裡開？」", "en": "Excuse me... where is this bus heading?"},
				"character": "player-normal"
			},
			{
				"narration": true,
				"text": {"zh": "司機沒有回答。倒是後方傳來了翻動紙張的聲音。", "en": "No answer from the driver. Instead, the sound of rustling paper comes from the back."},
				"color": "#888888"
			}
		],
		"next": "station-1-student-intro"
	},

	# ---- 02 第一站：學生（遺憾） ----
	"station-1-student-intro": {
		"background": "bus-interior",
		"dialogues": [
			{
				"narration": true,
				"text": {"zh": "一個穿著校服的男學生坐在後排。他面前攤開著幾本厚重的參考書，但視線卻盯著手機螢幕發呆。", "en": "A student in uniform sits in the back. Textbooks are spread out, but he stares blankly at his phone."},
				"color": "#888888"
			},
			{
				"speaker": {"zh": "男學生", "en": "Student"},
				"text": {"zh": "「如果那時候，我沒有把鬧鐘按掉就好了。」", "en": "If only I hadn't turned off the alarm back then."},
				"character": "student-sad"
			},
			{
				"speaker": {"zh": "男學生", "en": "Student"},
				"text": {"zh": "「就差那五分鐘。那五分鐘讓我錯過了最後一次補考，也錯過了大家都在說的『未來』。」", "en": "Just five minutes. That cost me the last re-exam, and the 'future' everyone talks about."},
				"character": "student-sad"
			}
		],
		"options": [
			{"text": {"zh": "走過去坐在他旁邊", "en": "Go and sit next to him"}, "next": "student-talk-1"},
			{"text": {"zh": "保持距離，靜靜觀察", "en": "Keep your distance and watch"}, "next": "student-observe-1"}
		]
	},

	"student-talk-1": {
		"background": "bus-interior",
		"dialogues": [
			{
				"speaker": {"zh": "你", "en": "You"},
				"text": {"zh": "「人生不是只有那一場考試，雖然現在說這個像風涼話。」", "en": "Life isn't just about one exam, though that might sound hollow right now."},
				"character": "player-normal"
			},
			{
				"speaker": {"zh": "男學生", "en": "Student"},
				"text": {"zh": "「你不會懂的。我爸媽的眼神，就像我已經死在那天早上了一樣。」", "en": "You wouldn't understand. The way my parents looked at me... it's like I died that morning."},
				"character": "student-dark"
			}
		],
		"options": [
			{"text": {"zh": "「我也有過這種感覺，但世界沒崩塌。」", "en": "I've felt that way too, but the world didn't end."}, "next": "student-positive"},
			{"text": {"zh": "「也許你只是需要休息。」", "en": "Maybe you just need some rest."}, "next": "student-negative"}
		]
	},

	"student-observe-1": {
		"background": "bus-interior",
		"dialogues": [
			{
				"narration": true,
				"text": {"zh": "男孩突然開始瘋狂地用橡皮擦擦拭成績單，直到紙張被磨破了一個洞。", "en": "The boy starts frantically erasing the transcript until a hole is worn through the paper."},
				"color": "#888888"
			},
			{
				"speaker": {"zh": "男學生", "en": "Student"},
				"text": {"zh": "「消失吧...消失吧...如果這些記錄都消失就好了。」", "en": "Disappear... disappear... if only these records would all just vanish."},
				"character": "student-unstable"
			}
		],
		"options": [
			{"text": {"zh": "伸手阻止他", "en": "Reach out and stop him"}, "next": "student-positive"},
			{"text": {"zh": "移開視線，假裝沒看見", "en": "Look away, pretend not to see"}, "next": "student-negative"}
		]
	},

	"student-positive": {
		"background": "bus-interior",
		"dialogues": [
			{
				"speaker": {"zh": "男學生", "en": "Student"},
				"text": {"zh": "「你是第一個叫我停下的人。謝謝...這車上太安靜了，安靜到我覺得自己沒救了。」", "en": "You're the first person to tell me to stop. Thanks... it's so quiet here, I thought I was hopeless."},
				"character": "student-relieved"
			}
		],
		"next": "station-2-intro"
	},

	"student-negative": {
		"background": "bus-interior",
		"dialogues": [
			{
				"speaker": {"zh": "男學生", "en": "Student"},
				"text": {"zh": "（他重新縮回了座位陰影裡，整個人顯得更加透明）", "en": "(He shrinks back into the shadows of his seat, appearing more translucent.)"},
				"character": "student-dark"
			}
		],
		"next": "station-2-intro"
	},

	# ---- 03 第二站：上班族（習慣與疲憊） ----
	"station-2-intro": {
		"background": "bus-interior",
		"dialogues": [
			{
				"narration": true,
				"text": {"zh": "公車在一棟死氣沉沉的辦公大樓前停下。一個領帶歪斜、提著公事包的男人搖晃著上車。", "en": "The bus stops at a lifeless office building. A man with a crooked tie and a briefcase stumbles in."},
				"color": "#888888"
			},
			{
				"speaker": {"zh": "上班族", "en": "Salaryman"},
				"text": {"zh": "「奇怪...怎麼感應不到？遲到了...主管在等我的簡報...」", "en": "Strange... why isn't it swiping? I'm late... my boss is waiting for the presentation..."},
				"character": "worker-confused"
			}
		],
		"options": [
			{"text": {"zh": "「先生，這裡不是公司，你已經下班了。」", "en": "Sir, this isn't the office. You're off work."}, "next": "salaryman-remind"},
			{"text": {"zh": "（默默看著他，不去打擾他的幻象）", "en": "(Watch silently, don't disturb his illusion)"}, "next": "salaryman-silent"}
		]
	},

	"salaryman-remind": {
		"background": "bus-interior",
		"dialogues": [
			{
				"speaker": {"zh": "上班族", "en": "Salaryman"},
				"text": {"zh": "「下班？但我還沒做完...如果我不做，誰來做？」", "en": "Off work? But I'm not done... if I don't do it, who will?"},
				"character": "worker-anxious"
			},
			{
				"speaker": {"zh": "上班族", "en": "Salaryman"},
				"text": {"zh": "「休息...？我都快忘了這個詞怎麼寫了...」", "en": "Rest...? I've almost forgotten what that word means..."},
				"character": "worker-tired"
			}
		],
		"next": "station-3-intro"
	},

	"salaryman-silent": {
		"background": "bus-interior",
		"dialogues": [
			{
				"speaker": {"zh": "上班族", "en": "Salaryman"},
				"text": {"zh": "「原來...這班車也沒有我的位置嗎...」", "en": "So... there's no place for me on this bus either..."},
				"character": "worker-despair"
			}
		],
		"next": "station-3-intro"
	},

	# ---- 04 第三站：老人（遺忘與歸處） ----
	"station-3-intro": {
		"background": "bus-interior-fog",
		"dialogues": [
			{
				"narration": true,
				"text": {"zh": "車窗外起了大霧。一位穿著優雅碎花洋裝的老太太不知何時出現在前排。", "en": "A thick fog rolls in. An old lady in an elegant floral dress appears in the front seat."},
				"color": "#888888"
			},
			{
				"speaker": {"zh": "老太太", "en": "Elderly Lady"},
				"text": {"zh": "「少年仔，你知道『和平街 10 號』到了嗎？我老伴在那裡等我吃晚餐。」", "en": "Young man, is 'No. 10 Peace Street' here yet? My husband is waiting there for dinner."},
				"character": "grandma-normal"
			}
		],
		"options": [
			{"text": {"zh": "「那一站快到了，我陪您一起等。」", "en": "That stop is coming soon. I'll wait with you."}, "next": "grandma-kind"},
			{"text": {"zh": "「那一站已經不存在了，這台車也沒有終點。」", "en": "That stop doesn't exist anymore. This bus has no destination."}, "next": "grandma-truth"}
		]
	},

	"grandma-kind": {
		"background": "bus-interior-fog",
		"dialogues": [
			{
				"speaker": {"zh": "老太太", "en": "Elderly Lady"},
				"text": {"zh": "「是嗎？那就好...我怕他等太久。謝謝你喔。」", "en": "Is it? Good... I was afraid he'd wait too long. Thank you."},
				"character": "grandma-smile"
			}
		],
		"next": "station-4-final"
	},

	"grandma-truth": {
		"background": "bus-interior-fog",
		"dialogues": [
			{
				"speaker": {"zh": "老太太", "en": "Elderly Lady"},
				"text": {"zh": "「不存在了...？那我該去哪裡？我的家呢？」", "en": "Doesn't exist...? Then where should I go? Where is my home?"},
				"character": "grandma-confused"
			}
		],
		"next": "station-4-final"
	},

	# ---- 05 第四站：空位（自我抉擇） ----
	"station-4-final": {
		"background": "bus-interior-dark",
		"dialogues": [
			{
				"narration": true,
				"text": {"zh": "乘客們一個個消失了。司機第一次緩緩轉過頭——他戴著一張空白的面具。", "en": "Passengers vanish. The driver turns—he wears a blank mask."},
				"color": "#888888"
			},
			{
				"speaker": {"zh": "司機", "en": "Driver"},
				"text": {"zh": "「最後一站到了。這裡有個空位...你想坐下，還是下車？」", "en": "The final stop. There's an empty seat... Do you want to sit, or get off?"},
				"character": "driver-mask"
			}
		],
		"options": [
			{"text": {"zh": "（坐下）我累了，載我去任何地方。", "en": "(Sit down) I'm tired. Take me anywhere."}, "next": "ending-stay"},
			{"text": {"zh": "（下車）這不是我該留下的地方。", "en": "(Get off) This isn't where I belong."}, "next": "ending-leave"},
			{"text": {"zh": "「換你休息吧。」（接過方向盤）", "en": "Your turn to rest. (Take the wheel)"}, "next": "ending-driver"}
		]
	},

	# ---- 06 結局 ----
	"ending-stay": {
		"type": "ending",
		"ending_type": "bad",
		"title": {"zh": "結局：永恆的乘客", "en": "Ending: Eternal Passenger"},
		"text": {"zh": "你坐下了。公車駛入深淵，你成為了這台車的一部分。", "en": "You sit. The bus drives into the abyss; you become part of the vehicle."},
		"image": "end-stay",
		"background": "black-screen"
	},
	"ending-leave": {
		"type": "ending",
		"ending_type": "good",
		"title": {"zh": "結局：黎明的曙光", "en": "Ending: First Light"},
		"text": {"zh": "你跳下車。回頭時，街道已恢復成熟悉的早晨。", "en": "You jump out. When you look back, the street is back to normal morning."},
		"image": "end-leave",
		"background": "bus-stop-morning"
	},
	"ending-driver": {
		"type": "ending",
		"ending_type": "good",
		"title": {"zh": "結局：守渡人", "en": "Ending: The Ferryman"},
		"text": {"zh": "司機向你點頭示意。現在，由你來決定下一班車何時啟程。", "en": "The driver nods. Now, you decide when the next bus departs."},
		"image": "end-driver",
		"background": "bus-interior-driver"
	}
}

const START_NODE := "start"

static func get_node(id: String) -> Dictionary:
	return STORY.get(id, {})

static func is_ending(node: Dictionary) -> bool:
	return node.get("type", "") == "ending"

static func is_good_ending(node: Dictionary) -> bool:
	return node.get("ending_type", "") == "good"
