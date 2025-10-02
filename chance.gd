extends Panel

var pl_ : BotDNA
var cell_ : Cell
static var chance_ : Array

var rent : int = 0

func _on_visibility_changed() -> void:
	UI._false_.visible = !UI._false_.visible
	if visible:
		chance()
	pass # Replace with function body.

func chance():
	pl_ = GLOBAL.link_player()
	cell_ = pl_.get_parent()
	
	chance_ = DB.chance[randi_range(0,DB.chance.size()-1)]
	
	if cell_.special_cell_name == "chance":
		$Container/title.text = "Шанс"
	elif cell_.special_cell_name == "pirat":
		$Container/title.text = "Пираты"
		chance_ = [0,"Пираты взяли на абордаж вашу шлюпку!Они требуют отдать им ","pirat"]
	elif cell_.special_cell_name == "treasure":
		$Container/title.text = "КЛАД!"
		chance_ = [0,"Вы нашли пиратский клад!!! Получите 10% от ОБЩЕГО капитала карты! ","treasure"]
	
	$Container/desc.text = chance_[1]
	
	match chance_[2]:
		"pirat":
			rent = randi_range(100,1000)
			$Container/desc.text += str(rent) + "$"
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-11-53-58-1-A_pirate_ship_in_a_raging_sea-1723043825-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-d1e7f75efd3a3ea6f906f72f32ac8b0f.ctex")
			pass
		"treasure":
			$Container/desc.text += "(" + str(GLOBAL.capital * 0.1) + "$)"
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-14-45-16-1-Pirate_treasure_buried_in_the_sand_on_a_lonely_island-1212026366-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-06d7d1b8b6af6541fe0488e64fb66f88.ctex")
			pass
		"jail":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-35-13-1-police_car-604906533-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-99d308498a024c78605670b7630f2231.ctex")
			pass
		"port_free":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-03-43-1-A_huge_cruise_ship_sails_into_the_sea-1478949626-scale9.00-k_euler-deliberate_v2_ckpt.png-07f2a2640392d196dff4d697dd57e736.ctex")
			pass
		"cell_free":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-11-58-15-1-The_big_red_gift-1990904290-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-c411648415f594d3d77343496794fa81.ctex")
			pass
		"+3":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-07-12-1-one_clover_on_a_white_background-667990396-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-c97ec8480cd9fdd3929712218574e364.ctex")
			pass
		"+12":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-07-12-1-one_clover_on_a_white_background-667990396-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-c97ec8480cd9fdd3929712218574e364.ctex")
			pass
		"double":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-07-12-1-one_clover_on_a_white_background-667990396-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-c97ec8480cd9fdd3929712218574e364.ctex")
			pass
		"-rand_percent":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-11-55-16-1-A_bank_full_of_money-1252559328-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-b30ff5b547d498f638611f792d9cdb61.ctex")
			rent = randi_range(0,10)
			$Container/desc.text += str(rent) + "%" + "(" + str(rent as float / 100 * pl_.capital) + "$)"
			pass
		"+rand_percent":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-11-55-16-1-A_bank_full_of_money-1252559328-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-b30ff5b547d498f638611f792d9cdb61.ctex")
			rent = randi_range(0,10)
			$Container/desc.text += str(rent) + "%" + "(" + str(rent as float / 100 * pl_.capital) + "$)"
			pass
		"+rand_money":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-11-55-16-1-A_bank_full_of_money-1252559328-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-b30ff5b547d498f638611f792d9cdb61.ctex")
			rent = randi_range(50,1000)
			$Container/desc.text += str(rent) + "$"
			pass
		"-rand_money":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-11-55-16-1-A_bank_full_of_money-1252559328-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-b30ff5b547d498f638611f792d9cdb61.ctex")
			rent = randi_range(50,1000)
			$Container/desc.text += str(rent) + "$"
			pass
		"+777":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-06-14-1-Bright_photorealistic_casino_winnings_bright_highlights-429767394-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-59a7ad4a896f304520cf91b57b10be26.ctex")
			pass
		"repair":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-11-57-34-1-the_destroyed_bank-1626725624-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-fe8ffa17bab2a653e0ceeb8346794b08.ctex")
			pass
		"+5%":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-08-05-1-huge_courtroom_photorealism_oppressive_atmosphere-835857982-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-1e8f0de558b45952d31584a7eb8b841a.ctex")
			pass
		"0_rent":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-11-58-15-1-The_big_red_gift-1990904290-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-c411648415f594d3d77343496794fa81.ctex")
			pass
		"2_rent":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-11-55-16-1-A_bank_full_of_money-1252559328-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-b30ff5b547d498f638611f792d9cdb61.ctex")
			pass
		"+3h":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-00-07-1-A_large_house_wrapped_in_a_large_red_ribbon_gift_outside-2097494562-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-4b1a2e7eade3192d364968237152d9bd.ctex")
			pass
		"-5h_rand":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-09-29-1-Huge_earthquake_tsunami_and_tornadoes_destroy_the_city_photorealism_fear_4k_8k-817363342-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-7c153f546fbc272540860d03d1f82717.ctex")
			pass
		"-all_h_one_cell":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-09-29-1-Huge_earthquake_tsunami_and_tornadoes_destroy_the_city_photorealism_fear_4k_8k-817363342-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-7c153f546fbc272540860d03d1f82717.ctex")
			pass
		"-1h_every-10%":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-09-29-1-Huge_earthquake_tsunami_and_tornadoes_destroy_the_city_photorealism_fear_4k_8k-817363342-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-7c153f546fbc272540860d03d1f82717.ctex")
			pass
		"-3cell":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-12-10-15-1-military_mobilization-727435645-scale9.00-dpmpp_2m_sde-deliberate_v2_ckpt.png-941355c791b7d3d5e44a55e4b8633d79.ctex")
			pass
		"+cell":
			UI.chance_img.texture = load("res://.godot/imported/2025-06-17-11-58-15-1-The_big_red_gift-1990904290-scale9.00-k_dpmpp_2m_sde-deliberate_v2_ckpt.png-c411648415f594d3d77343496794fa81.ctex")
			pass
	is_bot()

func is_bot():
	if pl_.is_bot:
		await get_tree().create_timer(GLOBAL.bot_card_speed).timeout ##################################################### #########################################################################################################
		_on_ok_pressed()

func _on_ok_pressed() -> void:
	self.visible = false
	
	#print(pl_.name_ + " " + str(chance_[2]) + "\n")
	
	match chance_[2]:
		"treasure":
			var cap : int = GLOBAL.capital * 0.1
			pl_.money += cap
			UI.money_log(null,cap , "bank")
			pl_.capital += cap
			pass
		"pirat":
			pl_.money -= rent
			UI.money_log(null,-rent , "bank")
			pl_.capital -= rent
			pass
		"jail":
			pl_.jail = 3
			pl_.global_position = Vector3(0.5,0,12.5)
			pl_.direction = Vector3(0,0,-1)
			pl_.move_end()
			pass
		"port_free":#ок
			pl_.global_position = Vector3(0.5,0,6.5)
			pl_.direction = Vector3(0,0,-1)
			pl_.move_end()
			pass
		"cell_free": #говно
			return
			for c : Cell in get_tree().get_nodes_in_group("board"):
				if c.monopoly_id > 0 && c.owner_ == null:
					pl_.pl_buy_koef = 0
					pl_.set_parent(c)
					pl_.position = c.player_center
					pl_.move_end()
					break
			pass
		"+3":#ок
			UI.end_turn.disabled = true
			GLOBAL.dice = 2
			pl_.move()
			pass
		"+12":
			UI.end_turn.disabled = true
			GLOBAL.dice = 11
			pl_.move()
			pass
		"double":#ок
			UI.end_turn.disabled = true
			UI.rall_dice_bt.disabled = false
			pass
		"-rand_percent":
			if chance_[0] != 2:
				pl_.money -= rent as float / 100 * pl_.capital
				UI.money_log(null,-rent as float / 100 * pl_.capital , "bank")
				pl_.capital -= rent as float / 100 * pl_.capital
			else:
				var cap = pl_.capital * rent as float / 100 / (GLOBAL.PLAYERS.size()-1)
				for p in GLOBAL.PLAYERS:
					if p == pl_:
						continue
					p.money += cap
					UI.money_log(p, -cap , "rent")
					p.capital += cap
					
					pl_.money -= cap
					pl_.capital -= cap
			pass
		"+rand_percent":
			pl_.money += rent as float / 100 * pl_.capital
			UI.money_log(null,rent as float / 100 * pl_.capital , "bank")
			pl_.capital += rent as float / 100 * pl_.capital
			pass
		"+rand_money":
			pl_.money += rent
			UI.money_log(null,rent , "bank")
			pl_.capital += rent
			pass
		"-rand_money":#ок
			pl_.money -= rent
			UI.money_log(null,-rent , "bank")
			pl_.capital -= rent
			pass
		"+777":#ок
			pl_.money += 777
			UI.money_log(null,777 , "bank")
			pl_.capital += 777
			pass
		"repair":
			var house :int = 0
			var hotel : int = 0
			var cells : Array[Cell] = pl_.get_cells()
			
			for c : Cell in cells:
				if c.house_count > 0:
					if c.house_count != 5:
						house += 1
					else:
						hotel += 1
			
			pl_.money -= (50 * house + 200 * hotel)
			UI.money_log(null,-(50 * house + 200 * hotel) , "bank")
			pl_.capital -= (50 * house + 200 * hotel)
			pass
		"+5%":#ок
			for p in GLOBAL.PLAYERS:
				if p == pl_:
					continue
				
				var cap = p.capital * 0.05
				
				p.money -= cap
				UI.money_log(p,-cap , "rent")
				p.capital -= cap
				
				pl_.money += cap
				pl_.capital += cap
			pass
		"0_rent":#ок
			pl_.pl_rent_koef = 0
			pass
		"2_rent":#ок
			pl_.pl_rent_koef = 2
			pass
		"+3h":
			for i : int in range(3):
				var cell = get_rand("monopoly")
				if cell == null:
					return
				cell.build(true)
				pass
			pass
		"-5h_rand":
			for i : int in range(5):
				var cell = get_rand("rand")
				if cell == null:
					return
				cell.debuild(true)
				pass
			pass
		"-all_h_one_cell":#ок
			var cell = get_rand("monopoly")
			if cell == null:
				return
			while cell.house_count != 0:
				cell.debuild(true)
			pass
		"-1h_every-10%":#ок
			for c : Cell in get_tree().get_nodes_in_group("board"):
				if c.house_count > 0 && c.owner_ == pl_:
					c.debuild(true)
			
			pl_.money -= 0.1 * pl_.capital
			UI.money_log(null,-0.1 * pl_.capital, "bank")
			pl_.capital -= 0.1 * pl_.capital
			pass
		"-3cell":
			for i in range(3):
				var cell = get_rand("useless")
				if cell == null:
					return
				cell.zalog = false
				cell.owner_ = null
				cell.owner_sign.hide()
				cell.house_count = 0
				pl_.capital -= cell.cost
			pass
		"+cell":#ок
			var cell = get_rand("empty")
			if cell == null:
				return
			pl_.pl_buy_koef = 0
			cell.buy()
			pass
	pass # Replace with function body.

func get_rand(type : String):
	var pl : Player = GLOBAL.link_player()
	var cells : Array[Cell] = []
	
	for cell : Cell in get_tree().get_nodes_in_group("board"):#добавить рандомный вызов
		if cell.owner_ == pl:
			if type == "monopoly":
				if cell.monopoly_check():
					cells.append(cell)
		if type == "rand": 
			if cell.house_count > 0:
				cells.append(cell)
		elif type == "useless":
			if cell.is_useless():
				cells.append(cell)
		elif type == "empty":
			if cell.owner_ == null && cell.monopoly_id != 0:
				cells.append(cell)
	
	if cells.size() == 0:
		return null
	
	return cells[randi() % cells.size()-1]
