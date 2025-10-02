extends Node

@onready var wheel = $Lotery
@onready var button = $bt

var sectors = 8
var angle_per_sector = 360.0 / sectors

func _on_button_pressed():
	button.disabled = true
	
	var selected_sector = randi() % sectors
	if selected_sector == 2:
		selected_sector = randi() % sectors
	var extra_spins = 10
	var target_angle = (selected_sector + 0.5) * angle_per_sector
	var final_rotation = deg_to_rad(-(extra_spins * 360 + target_angle))
	wheel.rotation = 0
	
	var tween = create_tween()
	tween.tween_property(wheel, "rotation", final_rotation, GLOBAL.bot_card_speed)\
		.set_trans(Tween.TRANS_QUAD)
		#.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_callback(func ():
		prize(selected_sector)
		self.visible = false
	)

func _on_visibility_changed() -> void:
	UI._false_.visible = !UI._false_.visible
	button.disabled = false
	wheel.rotation = 0
	is_bot()
	pass # Replace with function body.

func is_bot():
	if GLOBAL.link_player().is_bot:
		_on_button_pressed()

func prize(num):
	var pl : Player = GLOBAL.link_player()
	match num:
		1: #-10%
			pl.money -= int(pl.capital * 0.1)
			UI.money_log(null,-pl.capital * 0.1 , "bank")
			pl.capital -= int(pl.capital * 0.1)
			pass
		2: #1000
			pl.money += int(1000)
			UI.money_log(null,1000 , "bank")
			pl.capital += int(1000)
			pass
		3: #-200
			pl.money += int(-200)
			UI.money_log(null,-200 , "bank")
			pl.capital += int(-200)
			pass
		4: #2+
			for i : int in range(2):
				var cell = get_rand("monopoly")
				if cell == null:
					return
				cell.build(true)
				pass
		5: #card-
			var cell = get_rand("zalog")
			if cell != null:
				cell.set_zalog(true)
			pass
		6: #+10%
			pl.money += int(pl.capital * 0.1)
			UI.money_log(null,pl.capital * 0.1 , "bank")
			pl.capital += int(pl.capital * 0.1)
			pass
		7: #2-
			for i : int in range(2):
				var cell = get_rand("monopoly")
				if cell == null:
					return
				cell.debuild(true)
				pass
			pass
		0: #+200
			pl.money += int(200)
			UI.money_log(null,200 , "bank")
			pl.capital += int(200)
			pass
	pass

func get_rand(type : String):
	var pl : Player = GLOBAL.link_player()
	var cells : Array[Cell] = []
	
	for cell : Cell in get_tree().get_nodes_in_group("board"):#добавить рандомный вызов
		if cell.owner_ == pl:
			if type == "monopoly":
				if cell.monopoly_check():
					cells.append(cell)
			elif type == "zalog": 
				if cell.zalog == false && cell.house_count_in_monopoly() == 0:
					cells.append(cell)
	
	if cells.size() == 0:
		return null
	
	return cells[randi() % cells.size()-1]
