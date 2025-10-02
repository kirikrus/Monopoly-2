extends Panel

static var money_1 : int = 0
static var money_2 : int = 0
static var distribution : bool = false

func role():
	var status : String
	var koef : float = GLOBAL.link_player().capital as float / GLOBAL.capital as float
	if koef <= 0.3: status = "бедняк"
	elif koef <= 0.5: status = "состоятельный"
	elif koef <= 0.7: status = "богатый"
	elif koef <= 2: status = "невероятно богатый"
	return status

func _on_visibility_changed() -> void:
	UI._false_.visible = !UI._false_.visible
	if visible:
		get_node("text").clear()
		get_node("text").append_text(
			"Добрый день! 
Вас приветствует антимонопольная служба, наша сисстема распознала Вас, 
как — [wave amp=30.0 freq=5.0 connected=1][rainbow freq=0.12 sat=0.8 val=3]"
	 + role() +
	"[/rainbow][/wave].\n\nПоэтому вы обязаны принять одно из следующих условий:"
			)
		
		var capital : int = GLOBAL.link_player().capital 
		distribution = false
		
		match role():
			"бедняк":
				get_node("bt/1").text = "Получить грант в размере 5% от Вашего капитала ("+ str(int(capital * 0.05)) +"$)"
				money_1 = -int(capital * 0.05)
				get_node("bt/2").text = "Получить грант в размере 500$"
				money_2 = -500
			"состоятельный":
				get_node("bt/1").text = "К вам нет претензий"
				get_node("bt/2").text = "Пока что нет :)"
			"богатый":
				get_node("bt/1").text = "Заплатить налог в 10% от Вашего капитала ("+ str(int(capital * 0.1)) +"$)"
				money_1 = int(capital * 0.1)
				get_node("bt/2").text = "Раздать поровну 8% Вашего капитала Вашим соперникам (по "+\
										str(int(capital * 0.08/(GLOBAL.PLAYERS.size()-1)))+"$ каждому)"
				money_2 = int(capital * 0.08)
				distribution = true
			"невероятно богатый":
				get_node("bt/1").text = "Заплатить налог в 25% от Вашего капитала ("+ str(int(capital * 0.25)) +"$)"
				money_1 = int(capital * 0.25)
				get_node("bt/2").text = "Раздать поровну 15% Вашего капитала Вашим соперникам (по "+\
										str(int(capital * 0.15/(GLOBAL.PLAYERS.size()-1)))+"$ каждому)"
				money_2 = int(capital * 0.15)
				distribution = true
		
		is_bot()
	pass # Replace with function body.

func is_bot():
	if GLOBAL.link_player().is_bot && visible:
		var what = await GLOBAL.link_player().is_special_rich(role(), abs(money_1), abs(money_2))
		if what == 1:
			bt(1)
		else:
			bt(2)
		visible = false

func bt(extra_arg_0: int) -> void:
	if money_1 == 0 || money_2 == 0:
		visible = false
		return
	if extra_arg_0 == 1:
		GLOBAL.link_player().money -= money_1
		GLOBAL.link_player().capital -= money_1
		UI.money_log(null, -money_1, "bank")
	else:
		if !distribution:
			GLOBAL.link_player().money -= money_2
			GLOBAL.link_player().capital -= money_2
			UI.money_log(null, -money_2, "bank")
		else:
			GLOBAL.link_player().money -= money_2
			GLOBAL.link_player().capital -= money_2
			var slice : int = money_2 / (GLOBAL.PLAYERS.size()-1)
			for c in GLOBAL.PLAYERS:
				if c == GLOBAL.link_player(): continue
				c.money += slice
				c.capital += slice
				UI.money_log(c, -slice, "rent")
	visible = false
