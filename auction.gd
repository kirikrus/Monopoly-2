extends Panel

static var price : int = 0
static var cur : BotDNA = null
static var cur_num : int = 0
static var pl : Array[BotDNA] = []
static var cell : Cell

func _on_visibility_changed() -> void:
	price = 0
	cur = GLOBAL.link_player()
	
	if cur.get_parent().owner_ != null:
		return
	
	cell = cur.get_parent()
	pl = GLOBAL.PLAYERS.duplicate()
	cur_num = GLOBAL.CURRENT_PLAYER - 1
	
	get_node("bt/10").disabled = false
	get_node("bt/50").disabled = false
	get_node("bt/100").disabled = false
	
	update()
	get_node("log").clear()
	
	is_bot()
	
	pass # Replace with function body.

func is_bot():
	if cur.is_bot == true:
		var what = await cur.is_need_auction(cell, price)
		match what:
			-1:
				_on_pass_pressed()
			1:
				_on_up_pressed(10)
			2:
				_on_up_pressed(50)
			3:
				_on_up_pressed(100)

func update():
	get_node("price").text = str(price) + "$"
	change_color()
	
	if cur.money < 10 + price:
		get_node("bt/10").disabled = true
		get_node("bt/50").disabled = true
		get_node("bt/100").disabled = true
		pass
	elif cur.money < 50 + price:
		get_node("bt/50").disabled = true
		get_node("bt/100").disabled = true
		pass
	elif cur.money < 100 + price:
		get_node("bt/100").disabled = true
		pass

func next_player():
	cur_num += 1
	if cur_num > pl.size() - 1:
		cur_num = 0
	cur = pl[cur_num]
	
	if pl.size() == 1:
		cell.owner_ = cur
		cur.money -= price
		cur.capital -= price - cell.cost 
		cell.owner_.update()
		cell.owner_mesh.material.albedo_color = cur.color
		cell.owner_sign.show()
		UI.money_log(cur, -price, "auc")
		visible = false
		SOUND.buy.play()
		UI._false_.visible = false
		return
	
	get_node("bt/10").disabled = false
	get_node("bt/50").disabled = false
	get_node("bt/100").disabled = false
	
	is_bot()

func change_color():
	var style = get_node("price").get_theme_stylebox("normal")
	var new_style := style.duplicate() as StyleBoxFlat
	new_style.bg_color = cur.color
	new_style.bg_color.a = 0.5
	get_node("price").add_theme_stylebox_override("normal", new_style)

func _on_up_pressed(extra_arg_0: int) -> void:
	price += extra_arg_0
	get_node("log").append_text("[color=" + str(cur.color.to_html()) + "]" + 
								cur.name_ + "[/color]" + " поднимает ставку на " + str(extra_arg_0) + "$\n")
	next_player()
	update()
	pass # Replace with function body.

func _on_pass_pressed() -> void:
	pl.erase(cur)
	cur_num -= 1
	get_node("log").append_text("[color=" + str(cur.color.to_html()) + "]" + 
								cur.name_ + "[/color]" + " выходит из сделки :(\n")
	next_player()
	update()
	pass # Replace with function body.
