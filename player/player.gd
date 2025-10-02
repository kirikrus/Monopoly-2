extends StaticBody3D

class_name Player
var id = 1 #werwerwerwerwer
@export var color: Color = Color.BLACK
var name_ : String = ""
var money : int = 25000
var capital : int = 2500
var inf_panel : Panel
var house_style : ArrayMesh = load("res://models/стили домов/япония/дом.tres")
var hotel_style : ArrayMesh = load("res://models/стили домов/япония/отель.tres") 
var mesh : CapsuleMesh = CapsuleMesh.new()
var doubles_count : int = 0
var jail: int = 0
var is_die : bool = false
var is_bot : bool = false

var pl_rent_koef : float = 1.
var pl_buy_koef : float = 1.

#region хождения
var velocity = GLOBAL.player_velocity
var is_moving = false
var cell_counter = -1
var direction = Vector3(0,0,1)
var just_changed_dir = false
var old_cell_tmp : Cell = null
var is_in_center = false

func __process(delta: float) -> void:
	if is_die:
		return
	if inf_panel:
		update()
	
	if self == GLOBAL.link_player():
		money_check()
	
	if is_moving:
		var cur_cell : Cell = near_cell()
		
		if (cur_cell):
			if (cur_cell != old_cell_tmp):
				cell_counter += 1
				old_cell_tmp = cur_cell
				just_changed_dir = false
				if cur_cell.special_cell_name == "start":
					money += GLOBAL.start_get_money
					capital += GLOBAL.start_get_money
					UI.money_log(null, GLOBAL.start_get_money, "bank")
			
			if (!just_changed_dir && get_parent().center == true && cur_cell.center == true) || \
			   (!just_changed_dir && is_in_center && cur_cell.center == true):
				set_parent(cur_cell)
				match direction:
					Vector3(-1,0,0):
						direction = Vector3(0,0,-1)
					Vector3(0,0,-1):
						direction = Vector3(1,0,0)
					Vector3(1,0,0):
						direction = Vector3(0,0,1)
					Vector3(0,0,1):
						direction = Vector3(-1,0,0)
				just_changed_dir = true
				is_in_center = !is_in_center
			
			global_position += direction * velocity
			
			if (!just_changed_dir && cur_cell.corner == true && global_position.distance_to(cur_cell.global_position) <= 1.3):
				match direction:
					Vector3(-1,0,0):
						direction = Vector3(0,0,-1)
					Vector3(0,0,-1):
						direction = Vector3(1,0,0)
					Vector3(1,0,0):
						direction = Vector3(0,0,1)
					Vector3(0,0,1):
						direction = Vector3(-1,0,0)
				just_changed_dir = true
			
			if(cell_counter == GLOBAL.dice):
				is_moving = false
				cell_counter = -1
				move_end()
#endregion

func money_check():
	if money < 0:
		UI.rall_dice_bt.hide()
		UI.end_turn.hide()
	else:
		UI.rall_dice_bt.show()
		UI.end_turn.show()

func set_ready() -> void:
	#GLOBAL.PLAYERS.append(self)
	position = Vector3(16.5,0.5,12.5)
	call_deferred("set_parent", near_cell())
	
	inf_panel = UI.new_inf_panel()
	var sh : ShaderMaterial
	
	update()
	
	sh = inf_panel.get_node("blur").material.duplicate()
	sh.set_shader_parameter("color_over", color) 
	inf_panel.get_node("blur").material = sh
	
	sh = UI.rall_dice_bt.get_child(0).material.duplicate() #кто ходит цвет
	sh.set_shader_parameter("color_over", Color(GLOBAL.link_player().color)) 
	UI.rall_dice_bt.get_child(0).material = sh

func update():
	inf_panel.get_node("name").text = name_
	#inf_panel.get_node("name").add_theme_color_override("font_color", color)
	inf_panel.get_node("money").text = str(money) + "$"
	inf_panel.get_node("capital").text = "Капитал: " + str(capital) + "$"
	
	var status
	var koef : float = capital as float / GLOBAL.capital as float
	if koef <= 0.3: status = "бедняк"
	elif koef <= 0.5: status = "состоятельный"
	elif koef <= 0.7: status = "богатый"
	elif koef <= 2: status = "невероятно богатый"
	inf_panel.get_node("status").text = "Статус: " + status
	

func update_positions():
	var players : Array[Player]
	
	var player_count = 0
	for p in get_parent().get_children():
		if p.has_method("move"):
			player_count += 1
			players.append(p)
	
	var radius : float = 0.3
	if player_count <= 1:
		position = get_parent().player_center
		return
	
	for i in range(player_count):
		var player = players[i]
		var angle = TAU * i / player_count  # TAU = 2π
		var offset = get_parent().player_center + Vector3(cos(angle), 0, sin(angle)) * radius
		player.position = offset

func set_parent(tile: Cell):
	get_parent().remove_child(self)
	tile.add_child(self)
	update_positions()

func move():
	if BRAIN.dice1 == BRAIN.dice2 && jail != 0:
		jail = 0
	
	if jail != 0:
		jail -= 1
		if jail == 0:
			money -= GLOBAL.jail_exit
			capital -= GLOBAL.jail_exit
			UI.money_log(null, -GLOBAL.jail_exit, "bank")
		else:
			UI.end_turn.disabled = false
			return
	
	position = get_parent().player_center
	is_moving = true
	return

func move_end():
	set_parent(near_cell())
	var cell : Cell = get_parent()
	cell.show_inf()
	
	if cell.owner_ == null && (cell.monopoly_id != 0):
		UI.card_buy_panel.show()
		UI._false_.visible = true
		
		if cell.cost > money: UI.card_buy_panel.get_child(0).disabled = true
		else: UI.card_buy_panel.get_child(0).disabled = false
	else:
		pass
	
	cell.pay_rent()
	special()
	
	if BRAIN.dice1 != BRAIN.dice2:
		UI.end_turn.disabled = false
	
	return

func special():
	var cell : Cell = get_parent()
	
	match cell.special_cell_name:
		"start":
			money += GLOBAL.start_get_money
			capital += GLOBAL.start_get_money
			UI.money_log(null, GLOBAL.start_get_money, "bank")
		"big_rent":
			money -= capital * GLOBAL.nalog_koef
			capital -= capital * GLOBAL.nalog_koef
			UI.money_log(null, -capital * GLOBAL.nalog_koef, "bank")
		"diamond":
			money -= 200
			capital -= 200
			UI.money_log(null, -200, "bank")
		"jail":
			jail = 3
			global_position = Vector3(0.5,0,12.5)
			direction = Vector3(0,0,-1)
			move_end()
		"rich_rent":
			UI.rich.visible = true
		"lotery":
			UI.lotery.visible = true
		"chance":
			UI.chance.visible = true
		"pirat":
			UI.chance.visible = true
		"treasure":
			UI.chance.visible = true

func near_cell():
	return BRAIN.near_cell_find(self)

func get_cells():
	var cells : Array[Cell] = []
	for cell : Cell in get_tree().get_nodes_in_group("board"):#добавить рандомный вызов
		if cell.owner_ == self:
			cells.append(cell)
	return cells

func die():
	hide()
	is_die = true
	
	inf_panel.get_node("name").add_theme_color_override("font_color", Color.FIREBRICK)
	
	for c : Cell in get_cells():
		c.owner_ = null
		c.owner_sign.hide()
		c.zalog = false
		for i : int in range(c.house_count):
			var cur_house = c.house_meshes[i]
			c.remove_child(cur_house)
		c.house_count = 0
	
	GLOBAL.LOOSE_PLAYERS.append(self)
	GLOBAL.PLAYERS.erase(self)
	GLOBAL.CURRENT_PLAYER -= 1
	BRAIN.next_player()
	
	UI.rall_dice_bt.disabled = false
	UI.end_turn.disabled = true
	
	if GLOBAL.PLAYERS.size() != 0:
		var sh = UI.rall_dice_bt.get_child(0).material.duplicate() #кто ходит цвет
		sh.set_shader_parameter("color_over", Color(GLOBAL.link_player().color)) 
		UI.rall_dice_bt.get_child(0).material = sh
