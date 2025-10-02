extends CanvasLayer

static var is_ready = false

static var card_buy_panel : Panel
static var house_panel
static var card_inf : Panel
static var rall_dice_bt : Button
static var user_inf_container
static var end_turn
static var capital
static var _false_
static var log : RichTextLabel
static var auction
static var rich
static var lotery
static var market
static var dice1
static var dice2

static var my
static var his
static var my_money
static var his_money
static var send
static var trade_target_name
static var trade_next
static var trade_yes
static var trade_no
static var chance
static var chance_img
static var gen

func _process(delta: float) -> void:
	var cap = 0
	for p in GLOBAL.PLAYERS:
		cap += p.capital
	GLOBAL.capital = cap
	if(capital):
		capital.text = "Общий капитал: " + str(cap) + "$"
	if(gen):
		gen.text = "№" + str(GLOBAL.num_of_generation)

func _ready():
	card_buy_panel = get_node("card_buy_panel")
	house_panel = get_node("house_panel")
	card_inf = get_node("card_inf")
	user_inf_container = get_node("players")
	rall_dice_bt = %rall_dice_bt
	end_turn = %end_turn
	capital = get_node("capital")
	_false_ = get_node("false")
	log = get_node("log")
	auction = get_node("auction")
	rich = get_node("rich")
	lotery = get_node("Lotery")
	market = get_node("market")
	dice1 = get_node("footer/HBoxContainer/dice1")
	dice2 = get_node("footer/HBoxContainer/dice2")
	chance = get_node("chance")
	chance_img = get_node("chance/Container/img")
	
	my  = get_node("market/my")
	his  = get_node("market/his")
	my_money  = get_node("market/my_money")
	his_money  = get_node("market/his_money")
	send  = get_node("market/send")
	trade_target_name = get_node("market/name2")
	trade_next = get_node("market/next")
	trade_yes = get_node("market/yes")
	trade_no = get_node("market/no")
	gen = get_node("gen")
	
	is_ready = true
	#%nalog.text = str(GLOBAL.nalog_koef) + "%"

func new_inf_panel() -> Panel: #об игроке
	var panel = user_inf_container.get_child(0).duplicate(DUPLICATE_USE_INSTANTIATION)
#	panel.get_child(1).label_settings = panel.get_child(1).label_settings.duplicate(DUPLICATE_USE_INSTANTIATION)
	user_inf_container.add_child(panel)
	panel.visible = true
	return panel

func reset():
	card_inf.hide()
	house_panel.get_child(0).hide()
	house_panel.get_child(1).hide()
	house_panel.get_child(2).hide()

func money_log(from, money:int, type):
	var cur = "[color=" + str(GLOBAL.link_player().color.to_html()) + "]" + GLOBAL.link_player().name_ + "[/color]"
	match type:
		"rent":
			log.append_text(cur + " заплатил " + "[color=" + str(from.color.to_html()) + "]" + 
			from.name_ + "[/color]" + " " + str(-money) + "$\n")
		"bank":
			if money>0:
				log.append_text(cur + " получил от банка " + str(money) + "$\n")
			else:
				log.append_text(cur + " заплатил банку " + str(-money) + "$\n")
		"house":
			if money<0:
				log.append_text(cur + " построил дом за " + str(-money) + "$\n")
			else:
				log.append_text(cur + " снес дом и выручил " + str(money) + "$\n")
		"buy":
			log.append_text(cur + " купил поле за " + str(-money) + "$\n")
		"zalog":
			if money<0:
				log.append_text(cur + " разложил поле за " + str(-money) + "$\n")
			else:
				log.append_text(cur + " заложил поле и получил " + str(money) + "$\n")
		"auc":
			log.append_text("[color=" + str(from.color.to_html()) + "]" + 
			from.name_ + "[/color]" + " купил поле на аукционе за " + str(-money) + "$\n")
		"deal":
			log.append_text(cur + " совершил сделку с " + "[color=" + str(from.color.to_html()) + "]" + from.name_ + "[/color]"+ "\n")
	pass


func _on_fix_pressed() -> void:
	_false_.visible = !_false_.visible
	pass # Replace with function body.
