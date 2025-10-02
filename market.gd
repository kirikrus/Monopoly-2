extends Panel
var me : BotDNA
var him : BotDNA

var him_num = 0
var players : Array[BotDNA] = []

var my_deal_cells : Array[Cell] = []	## предлагаемые клетки
var my_deal_sum : int = 0				## предлагаемая сумма
var my_sum : int = 0					
var his_deal_cells : Array[Cell] = []	## желаемые клетки
var his_deal_sum : int = 0				## желаемая сумма 
var his_sum : int = 0					

func _on_visibility_changed() -> void:
	UI._false_.visible = !UI._false_.visible
	$yes.hide()
	$no.hide()
	$send.show()
	$fals.hide()
	$exit.show()
	load_()
	pass # Replace with function body.

func load_():
	his_deal_sum = 0
	his_sum = 0
	my_deal_sum = 0
	my_sum = 0
	his_deal_cells = []
	my_deal_cells = []
	
	for c in $my.get_children():
		$my.remove_child(c)
	for c in $my_deal.get_children():
		$my_deal.remove_child(c)
	for c in $his.get_children():
		$his.remove_child(c)
	for c in $his_deal.get_children():
		$his_deal.remove_child(c)
	
	$my_sum.text = "Итог: 0$"
	$his_sum.text = "Итог: 0$"
	
	$my_money.text = "0"
	$his_money.text = "0"
	
	if visible == true:
		me = GLOBAL.link_player()
		
		players.clear()
		for p in GLOBAL.PLAYERS:
			if p == me: continue
			players.append(p)
		
		if him_num >= players.size():
			him_num = 0
		
		him = players[him_num]
		
		$name1.add_theme_color_override("font_color", me.color)
		$name2.add_theme_color_override("font_color", him.color)
		
		$name1.text = me.name_
		$name2.text = him.name_
		
		for c : Cell in me.get_cells():
			if !c.is_houses_in_monopoly():
				$my.add_child(get_panel(c))
		
		for c : Cell in him.get_cells():
			if !c.is_houses_in_monopoly():
				$his.add_child(get_panel(c))
	pass # Replace with function body.

func get_panel(c : Cell):
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(50, 50)
	
	var style := StyleBoxFlat.new()
	style.bg_color = c.color
	style.bg_color.a = 0.75
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)
	
	panel.set_meta("st", c.name_)
	
	panel.gui_input.connect(_on_rect_pressed.bind(c, panel))  # Ловим ПКМ и ЛКМ
	return panel

func _on_rect_pressed(event: InputEvent, cell : Cell, card : Panel):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if card.get_parent() == $my_deal || card.get_parent() == $his_deal:
				card.get_parent().remove_child(card)
				if cell.owner_ == me:
					$my.add_child(card)
					my_sum -= cell.cost
					my_deal_cells.erase(cell)
				else:
					$his.add_child(card)
					his_sum -= cell.cost
					his_deal_cells.erase(cell)
			elif card.get_parent() == $my || card.get_parent() == $his:
				card.get_parent().remove_child(card)
				if cell.owner_ == me:
					$my_deal.add_child(card)
					my_sum += cell.cost
					my_deal_cells.append(cell)
				else:
					$his_deal.add_child(card)
					his_sum += cell.cost
					his_deal_cells.append(cell)
			update()
			
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cell.show_inf()
	pass

func _on_yes_pressed() -> void:
	for c in my_deal_cells:
		c.owner_ = him
		c.owner_mesh.material.albedo_color = him.color
		c.zalog = false
		c.owner_mesh.material.albedo_texture = null
	for c in his_deal_cells:
		c.owner_ = me
		c.owner_mesh.material.albedo_color = me.color
		c.zalog = false
		c.owner_mesh.material.albedo_texture = null
	
	me.money -= my_deal_sum
	me.money += his_deal_sum
	him.money -= his_deal_sum
	him.money += my_deal_sum
	
	me.capital += his_sum + his_deal_sum - my_sum - my_deal_sum
	him.capital -= his_sum + his_deal_sum - my_sum - my_deal_sum
	
	UI.money_log(him,0, "deal")
	visible = false
	pass # Replace with function body.

func _on_send_pressed() -> void:
	$yes.show()
	$no.show()
	$send.hide()
	$fals.show()
	$exit.hide()
	if !me.is_bot:
		him.inp_offer = [his_deal_cells, his_deal_sum, my_deal_cells, my_deal_sum, me]
	if him.is_bot:
		him.on_trade_offer_received()
	pass # Replace with function body.

func _on_no_pressed() -> void:
	visible = false
	pass # Replace with function body.

func _on_next_pressed() -> void:
	him_num += 1
	if him_num >= players.size():
		him_num = 0
	load_()
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	visible = false
	pass # Replace with function body.

func _on_my_money_text_changed(new_text: String) -> void:
	my_deal_sum = new_text.to_int()
	update()
	pass # Replace with function body.

func _on_his_money_text_changed(new_text: String) -> void:
	his_deal_sum = new_text.to_int()
	update()
	pass # Replace with function body.

func update():
	$my_sum.text = "Итог: " + str(my_deal_sum + my_sum) + "$"
	$his_sum.text = "Итог: " + str(his_deal_sum + his_sum) + "$"
	pass
