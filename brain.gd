extends Node

var GLOBAL = preload("res://GLOBAL.gd")

#@onready var cells: Array[Node] = get_tree().get_nodes_in_group("board")
static var dice1 = -2
static var dice2 = -1

static func near_cell_find(player: Player):
	var ray_origin = player.global_transform.origin + Vector3.UP * 0.5 
	var ray_end = ray_origin + Vector3.DOWN * 2.0
	var space_state = player.get_world_3d().direct_space_state

	var params = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	params.exclude = [player]

	var result = space_state.intersect_ray(params)

	if result:
		var position = result.position
		var cell = Vector3i(floor(position.x), floor(position.y), floor(position.z))  
		return result.collider
	return null

func get_monopoly(num:int) -> Array[Cell]:
	var monopoly : Array[Cell]
	for cell : Cell in get_tree().get_nodes_in_group("board"):
		if cell.monopoly_id == num:
			monopoly.append(cell)
	return monopoly

func _on_rall_dice_bt_pressed() -> void:
	UI.rall_dice_bt.disabled = true
	
	dice1 = randi_range(1,6)
	dice2 = randi_range(1,6)
	
	UI.dice1.text = str(dice1)
	UI.dice2.text = str(dice2)
	
	GLOBAL.dice = dice1 + dice2
	GLOBAL.link_player().move()
	
	if dice1 == dice2:
		UI.rall_dice_bt.disabled = false
		UI.end_turn.disabled = true

func next_player():
	GLOBAL.CURRENT_PLAYER += 1
	if GLOBAL.CURRENT_PLAYER > GLOBAL.PLAYERS.size():
		GLOBAL.CURRENT_PLAYER = 1

func _on_buy_pressed() -> void:
	GLOBAL.link_player().get_parent().buy()
	UI.card_buy_panel.hide()
	UI._false_.visible = false

func _on_add_h_pressed() -> void:
	GLOBAL.CURRENT_CELL.build()
	pass

func _on_del_h_pressed() -> void:
	GLOBAL.CURRENT_CELL.debuild()
	pass 

func _on_zalog_pressed() -> void:
	GLOBAL.CURRENT_CELL.set_zalog()
	pass 

func _on_end_turn_pressed() -> void:
	BRAIN.next_player()
	UI.rall_dice_bt.disabled = false
	UI.end_turn.disabled = true
	var sh : ShaderMaterial = UI.rall_dice_bt.get_child(0).material.duplicate()
	sh.set_shader_parameter("color_over", Color(GLOBAL.link_player().color)) 
	UI.rall_dice_bt.get_child(0).material = sh
	pass # Replace with function body.

func _on_auction_pressed() -> void:
	UI.auction.visible = true
	UI.card_buy_panel.visible = false
	pass

func _on_market_pressed() -> void:
	UI.market.visible = true
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	GLOBAL.link_player().die()
	pass # Replace with function body.


func regame():
	GLOBAL.num_of_generation += 1
	
	GLOBAL.LOOSE_PLAYERS[5].win_count += 1
	
	if GLOBAL.num_of_generation % GLOBAL.GENERATION_INTERVAL == 0:
		var bots_tmp : Array[BotDNA] = GLOBAL.LOOSE_PLAYERS
		GLOBAL.LOOSE_PLAYERS.sort_custom(func(a, b): return a.win_count < b.win_count)
		
		set_winner()
		set_prizewinner()
		
		save_generation()
		
		for bot : BotDNA in GLOBAL.LOOSE_PLAYERS:
			bot.win_count = 0
		
		var child_1: Array = crossover(GLOBAL.winner_dna, GLOBAL.prizewinner_dna)
		var child_2: Array = crossover(GLOBAL.winner_dna, GLOBAL.prizewinner_dna)
		copy_DNA(GLOBAL.LOOSE_PLAYERS[4], child_1)
		copy_DNA(GLOBAL.LOOSE_PLAYERS[3], child_2)
		var mutate_1 : Array = mutate(GLOBAL.winner_dna)
		var mutate_2 : Array = mutate(GLOBAL.prizewinner_dna)
		copy_DNA(GLOBAL.LOOSE_PLAYERS[2], mutate_1)
		copy_DNA(GLOBAL.LOOSE_PLAYERS[1], mutate_2)
		GLOBAL.LOOSE_PLAYERS[0].randomize_DNA()
		
		
	for i in range(GLOBAL.LOOSE_PLAYERS.size()):
		var new : BotDNA = BotDNA.new()
		new.copy_data_from(GLOBAL.LOOSE_PLAYERS[i])
		GLOBAL.PLAYERS.append(new)
	GLOBAL.LOOSE_PLAYERS.clear()
	
	GLOBAL.CURRENT_PLAYER = 1
	get_tree().reload_current_scene()
	pass

func set_winner():
	GLOBAL.winner_dna.clear()
	var winner : BotDNA = GLOBAL.LOOSE_PLAYERS[5]
	GLOBAL.winner_dna.append(winner.risk_tolerance)
	GLOBAL.winner_dna.append(winner.auction_aggressiveness)
	GLOBAL.winner_dna.append(winner.cash_reserve_ratio)
	GLOBAL.winner_dna.append(winner.build_priority)
	GLOBAL.winner_dna.append(winner.mortgaging_threshold)
	GLOBAL.winner_dna.append(winner.deal_value_sensitivity)
	GLOBAL.winner_dna.append(winner.trading_propensity)
	GLOBAL.winner_dna.append(winner.greed)
	GLOBAL.winner_dna.append(winner.purposefulness)
	GLOBAL.winner_dna.append(winner.desire_to_cooperate)
	GLOBAL.winner_dna.append(winner.thrift)
	GLOBAL.winner_dna.append(winner.objectivity_of_transaction)
	GLOBAL.winner_dna.append(winner.win_count)
	pass

func set_prizewinner():
	GLOBAL.prizewinner_dna.clear()
	var winner : BotDNA = GLOBAL.LOOSE_PLAYERS[4]
	GLOBAL.prizewinner_dna.append(winner.risk_tolerance)
	GLOBAL.prizewinner_dna.append(winner.auction_aggressiveness)
	GLOBAL.prizewinner_dna.append(winner.cash_reserve_ratio)
	GLOBAL.prizewinner_dna.append(winner.build_priority)
	GLOBAL.prizewinner_dna.append(winner.mortgaging_threshold)
	GLOBAL.prizewinner_dna.append(winner.deal_value_sensitivity)
	GLOBAL.prizewinner_dna.append(winner.trading_propensity)
	GLOBAL.prizewinner_dna.append(winner.greed)
	GLOBAL.prizewinner_dna.append(winner.purposefulness)
	GLOBAL.prizewinner_dna.append(winner.desire_to_cooperate)
	GLOBAL.prizewinner_dna.append(winner.thrift)
	GLOBAL.prizewinner_dna.append(winner.objectivity_of_transaction)
	GLOBAL.prizewinner_dna.append(winner.win_count)
	pass

func crossover(parent1: Array, parent2: Array) -> Array: ##2 потомка через скрещивание робедителя и призера
	var child: Array = []
	for i in parent1.size():
		if randf() < 0.5:
			child.append(parent1[i])
		else:
			child.append(parent2[i])
	return child

func copy_DNA(to : BotDNA, other: Array):
	to.risk_tolerance = other[0]
	to.auction_aggressiveness = other[1]
	to.cash_reserve_ratio = other[2]
	to.build_priority = other[3]
	to.mortgaging_threshold = other[4]
	to.deal_value_sensitivity = other[5]
	to.trading_propensity = other[6]
	to.greed = other[7]
	to.purposefulness = other[8]
	to.desire_to_cooperate = other[9]
	to.thrift = other[10]
	to.objectivity_of_transaction = other[11]

func mutate(dna: Array, mutation_rate: float = 0.1, mutation_strength: float = 0.2) -> Array: ## мутация ДНК
	for i in dna.size():
		if randf() < mutation_rate:
			dna[i] += randf_range(-mutation_strength, mutation_strength)
			dna[i] = clamp(dna[i], 0, 1)  # Все значения от 0 до 1
	return dna

func save_generation():
	var data := {
		"generation": GLOBAL.num_of_generation,
		"winner_dna": GLOBAL.winner_dna,
		"bots": []
	}

	for bot in GLOBAL.LOOSE_PLAYERS:
		data["bots"].append(bot.get_dna_array())

	var file := FileAccess.open("user://genetics/gen_%03d.json" % GLOBAL.num_of_generation, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))  # красиво отформатированный JSON
	file.close()
