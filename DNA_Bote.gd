extends Player

class_name BotDNA

var risk_tolerance: float			## от 0 до 1 — склонность к риску
var auction_aggressiveness: float	## агрессия на аукционах
var cash_reserve_ratio: float		## минимальный желаемый статус от капитала
var build_priority: float			## важность постройки домов
var mortgaging_threshold: float 	## когда можно закладывать
var deal_value_sensitivity: float 	## насколько важно получить выгоду от сделки
var trading_propensity: float   	## склонность инициировать сделки
var greed : float 					## жадность
var purposefulness : float 			## целеустремленность
var desire_to_cooperate : float 	## желание сотрудничать
var thrift : float					## бережливоcть
var objectivity_of_transaction : float ## объективность принятия сделки
var win_count : int = 0 ##число побед

var score : float
var is_acting = false
var deal_count : int = 0

var inp_offer : Array

func randomize_DNA():
	risk_tolerance = randf_range(0.0, 1.0)
	auction_aggressiveness = randf_range(0.0, 1.0)
	cash_reserve_ratio = randf_range(0.0, 1.0)
	build_priority = randf_range(0.0, 1.0)
	mortgaging_threshold = randf_range(0.0, 1.0)
	deal_value_sensitivity = randf_range(0.0, 1.0)
	trading_propensity = randf_range(0.0, 1.0)
	greed = randf_range(0.0, 1.0)
	purposefulness = randf_range(0.0, 1.0)
	desire_to_cooperate = randf_range(0.0, 1.0)
	thrift = randf_range(0.0, 1.0)
	objectivity_of_transaction = randf_range(0.0, 1.0)

func delay():
	await get_tree().create_timer(GLOBAL.bot_speed).timeout

func _ready() -> void:
	await get_tree().process_frame

func _process(delta: float) -> void:
	await is_win()
	
	await __process(delta)
	
	if !UI.is_ready || is_acting:
		return
	
	if GLOBAL.link_player() == self && is_bot && !is_moving:
		is_acting = true  # блокируем повторы
		if !UI.rall_dice_bt.disabled && !UI._false_.visible:
			await delay()
			await BRAIN._on_rall_dice_bt_pressed()
		else:
			await delay()
			await what_to_do()
		is_acting = false  # разблокируем после выполнения

func choice(score : float) -> bool:
	var rand = randf_range(0,1)
	return rand <= score

func what_to_do():
	await is_need_buy()
	
	if !UI._false_.visible:
		await is_need_build()
		
		await is_need_zalog()
		await is_need_debuild()
		await is_need_spam()
		
		await is_need_deal()
		
		await delay()
		if UI.end_turn.disabled == false && UI._false_.visible == false && money >= 0:
			deal_count = 0
			BRAIN._on_end_turn_pressed()
			return
		
		await is_need_die()

func is_win():
	if GLOBAL.PLAYERS.size() == 1:
		if GLOBAL.link_player().is_bot && GLOBAL.PLAYERS[0] == self:
			print ("WINNER --> ")
			log_bot()
		GLOBAL.link_player().die()
		BRAIN.regame() #потом окошко сюда
	pass

func is_need_die():
	var monopoly = get_cells()
	while money < 0:
		await is_need_zalog()
		await is_need_debuild()
		await is_need_deal()
		
		var is_all_zalog = true
		for c in monopoly:
			if c.zalog == false:
				is_all_zalog = false
				break
		
		if money < 0 && is_all_zalog:
			log_bot()
			BRAIN._on_exit_pressed()
			return
	pass

func log_bot():
	print(
		"№" + str(GLOBAL.PLAYERS.size()) + " " +
		str(risk_tolerance) + " " +
		str(auction_aggressiveness) + " " +
		str(cash_reserve_ratio) + " " +
		str(build_priority) + " " +
		str(mortgaging_threshold) + " " +
		str(deal_value_sensitivity) + " " +
		str(trading_propensity) + " " +
		str(greed) + " " +
		str(purposefulness) + " " +
		str(desire_to_cooperate) + " " +
		str(thrift) + " " +
		str(objectivity_of_transaction) + " " +
		"\n\n"
	)
	pass

func is_need_buy():
	if UI.card_buy_panel.visible == false || get_parent().cost == -1:
		return
	var cell : Cell = get_parent()
	score = money / cell.cost * greed * purposefulness
	if choice(score) && money >= cell.cost:
		BRAIN._on_buy_pressed()
	else:
		BRAIN._on_auction_pressed()
	pass
	
func is_need_auction(cell : Cell, price : int):
	await delay()
	if price == 0:
		price = 1
	score = money / price * greed * purposefulness * cell.cost / price * auction_aggressiveness * risk_tolerance
	if choice(score) && money >= price + 100:
		if auction_aggressiveness * cell.cost / price <= 0.33:
			return 1
		elif auction_aggressiveness * cell.cost / price <= 0.66:
			return 2
		else:
			return 3
	return -1
	pass
	
func is_special_rich(role, money_1, money_2):
	await delay()
	if role == "бедняк":
		if money_1 >= money_2:
			return 1
		else:
			return 2
	else:
		score = greed * (1 - desire_to_cooperate) * money_2 / money_1 * money / money_1 #оценка первого варианта
		if choice(score) && money >= money_1:
			return 1
		return 2
	pass
	
func is_need_build():
	if money <= 50:
		return
	
	var monopoloys : Array[Cell] = []
	for c : Cell in get_cells():
		if c.monopoly_check() && c.cost != -1 && c.one_house_cost > 0 && c.center == false:
			monopoloys.append(c)
	
	if monopoloys.size() == 0:
		return
	
	var build_count = -1
	
	while build_count != 0:
		build_count = 0
		for c in monopoloys:
			if c.house_count == 5:
				continue
			if c.house_check():
				score = money / c.one_house_cost * build_priority * purposefulness * (1-thrift)
				if choice(score) && money >= c.one_house_cost:
					await c.build()
					build_count += 1
	
	pass

func benefit(cell : Cell) -> float:
	if cell.house_count == 0:
		var out : float = cell.cost as float / cell.rent as float
		return out
	else:
		var out : float = cell.cost as float / cell.house_rent[cell.house_count-1] as float
		return out

func is_need_zalog():
	var monopoloys : Array[Cell] = get_cells()
	
	if monopoloys.size() == 0:
		return
	
	var is_monopolist = false
	for c in monopoloys:
		if c.monopoly_check() && c.one_house_cost > 0:
			is_monopolist = true
			break
	
	if money <= 0 || is_monopolist && mortgaging_threshold >= 0.5:
		var bad_cell : Cell = null
		var old_profit : float = 0
		
		for c in monopoloys:
			if c.house_count_in_monopoly() != 0 || c.zalog == true:
				continue
			
			var profit = await benefit(c)
			if profit > old_profit:
				old_profit = profit
				bad_cell = c
		
		if bad_cell != null:
			await bad_cell.set_zalog()
	
	if !is_monopolist:
		for c in monopoloys:
			if c.zalog == true && money >= c.cost * GLOBAL.sell_koef:
				await c.set_zalog()
	
	for c in monopoloys:
		if c.monopoly_count() == c.monopoly.size() && c.zalog == true && money >= c.cost * GLOBAL.sell_koef:
			await c.set_zalog()
	
	#мб добавить чтобы когда много денег то расскладывали
	
	pass

func is_need_debuild():
	if money <= 0:
		var monopoloys : Array[Cell] = get_cells()
		
		var is_all_zalog = true
		for c in monopoloys:
			if c.zalog == false && !c.monopoly_check():
				is_all_zalog = false
				return
		
		var bad_cell : Cell = null
		var old_profit : float = 0
		
		for c : Cell in monopoloys:
			if c.house_count == 0 || !c.house_check(-1):
				continue
			var profit : float = await benefit(c)
			if profit > old_profit:
				old_profit = profit
				bad_cell = c
		
		if bad_cell != null:
			await bad_cell.debuild()
	return

func is_need_spam():
	pass

func is_need_deal():
	if money < 0:
		try_emergency_sell()
		return
	if choice(trading_propensity * purposefulness) && deal_count < 3:
		deal_count += 1
		var desired_cells = find_target_cells_first_priority()
		if desired_cells.size() == 0: 
			return
		var target_player = select_trade_target(desired_cells)
		
		var gain_cells : Array = [desired_cells[0]]
		var give_cells : Array = []
		if choice((1-greed)):
			give_cells = get_offer_cells(desired_cells[0])
		var give_money = get_offer_money(self.money)
		var gain_money = 0
		
		inp_offer = [0, 0, 0, 0, self]
		
		var sensitivity : float = evaluate_trade_offer(gain_cells, gain_money, give_cells, give_money)
		if sensitivity < 0:
			if abs(sensitivity) < give_money:
				give_money -=  abs(sensitivity) * thrift
			else:
				gain_money =  (abs(sensitivity) - give_money) * greed
				give_money = 0
		else:
			give_money += sensitivity * (1 - deal_value_sensitivity * greed)
		
		if give_money > money && money > 0:
			give_money = money
		
		make_trade(gain_cells,give_cells,give_money, gain_money, target_player)
		
		inp_offer = []
	pass

func make_trade(gain_cells : Array,give_cells : Array,give_money : int, gain_money : int, target : BotDNA):
	target.inp_offer = [gain_cells, gain_money, give_cells, give_money, self]
	BRAIN._on_market_pressed()
	
	while UI.trade_target_name.text != target.name_:
		UI.trade_next.emit_signal("pressed")
	
	for c : Cell in give_cells:
		for p : Panel in UI.my.get_children():
			if c.name_ == p.get_meta("st"):
				var click_event := InputEventMouseButton.new()
				click_event.button_index = MOUSE_BUTTON_LEFT
				click_event.pressed = true
				click_event.position = Vector2.ZERO  # неважно
				click_event.global_position = Vector2.ZERO
				p.emit_signal("gui_input", click_event)
				break
	for c : Cell in gain_cells:
		for p : Panel in UI.his.get_children():
			if c.name_ == p.get_meta("st"):
				var click_event := InputEventMouseButton.new()
				click_event.button_index = MOUSE_BUTTON_LEFT
				click_event.pressed = true
				click_event.position = Vector2.ZERO  # неважно
				click_event.global_position = Vector2.ZERO
				p.emit_signal("gui_input", click_event)
				break
	
	UI.my_money.text = str(abs(give_money))
	UI.my_money.emit_signal("text_changed", UI.my_money.text)

	UI.his_money.text = str(abs(gain_money))
	UI.his_money.emit_signal("text_changed", UI.his_money.text)
	
	UI.send.emit_signal("pressed")
	
	pass
	

func try_emergency_sell() -> Array:
	var urgent_cells : Array[Cell] = []
	for cell in get_cells():
		if cell.is_useless():
			urgent_cells.append(cell)
	
	if urgent_cells.size() == 0:
		return [-1,-1]
	
	for cell in urgent_cells:
		var buyer = pl_capitals_low_hight()[1]
		if buyer != null:
			var price = cell.cost * 2 * (2 - greed)
			
			var gain_cells = []
			var give_cells = cell
			var gain_money = price
			var give_money = 0
			return [give_cells, gain_money]
	
	return [-1,-1]

func pl_capitals_low_hight() -> Array:
	var cap_min = INF
	var cap_max = 0
	var min_p = null
	var max_p = null
	for p in GLOBAL.PLAYERS:
		if p == self:
			continue
		cap_min = min(cap_min, p.capital)
		cap_max = max(cap_max, p.capital)
		
		if cap_min == p.capital:
			min_p = p
		if cap_max == p.capital:
			max_p = p
	return [min_p, max_p]

func compute_value(cells: Array, money: int) -> float:
	var total = 0.0
	for cell in cells:
		var base = cell.cost
		var strategic = 0.0
		
		strategic = compute_strategic(cell)
		
		total += base * (1.0 + strategic)
	
	return total + money

func compute_strategic(cell : Cell):
	var strategic = 0.0
	
	if cell.owns_group_except(inp_offer[4]):  # почти монополия
		strategic += 1.5 * deal_value_sensitivity
	elif cell.is_part_of_monopoly(inp_offer[4]):  # уже монополия
		strategic += 3.0 * deal_value_sensitivity
	elif cell.is_useless():  # разбросанные клетки
		strategic += 0
	return strategic

func get_offer_money(max_offer: int) -> int:
	var base = max_offer * (1.0 - greed)
	base *= (1.0 - cash_reserve_ratio)
	base *= (1.0 - thrift)
	return clamp(base, 0, max_offer)

func get_offer_cells(desired_cell : Cell) -> Array:
	var count = 0
	var give = []
	for cell in get_cells():
		if cell.is_useless() && cell.monopoly_id != desired_cell.monopoly_id:
			if greed >= 0.8:
				return [cell]
			elif greed >= 0.5 && count <= 2:
				give.append(cell)
				count += 1
			elif greed < 0.5 && count <= 3:
				give.append(cell)
				count += 1
	return give

func select_trade_target(target_cells: Array) -> Player:
	for cell in target_cells:
		if cell.owner_ != null and cell.owner_ != self:
			return cell.owner_
	return null

func find_target_cells_first_priority() -> Array:
	var targets = []
	for c in get_cells():
		if c.owns_group_except():
			var cell = c.get_missing_cell()
			if cell.owner_ != null && cell.owner_ != self:
				targets.append(cell)
	return targets

func evaluate_trade_offer(gain_cells, gain_money, give_cells, give_money) -> float:
	var value_gained = compute_value(gain_cells, gain_money)
	var value_lost = compute_value(give_cells, give_money)
	
	var net_value = value_gained - value_lost
	return net_value * (0.5 + deal_value_sensitivity) * (0.5 + greed) #было по 1

func on_trade_offer_received():
	await get_tree().create_timer(GLOBAL.bot_card_speed).timeout
	var value = evaluate_trade_offer(inp_offer[2],inp_offer[3],inp_offer[0],inp_offer[1])
	if money < inp_offer[1]:
		UI.trade_no.emit_signal("pressed")
	if value > 0:
		if choice(2 * objectivity_of_transaction * greed + value / money):
			UI.trade_yes.emit_signal("pressed")
		else:
			UI.trade_no.emit_signal("pressed")
	else:
		if choice(objectivity_of_transaction * risk_tolerance * greed - abs(value) / money): 
			UI.trade_yes.emit_signal("pressed")
		else:
			UI.trade_no.emit_signal("pressed")
	
	inp_offer = []

func copy_data_from(other: BotDNA):
	self.risk_tolerance = other.risk_tolerance
	self.auction_aggressiveness = other.auction_aggressiveness
	self.cash_reserve_ratio = other.cash_reserve_ratio
	self.build_priority = other.build_priority
	self.mortgaging_threshold = other.mortgaging_threshold
	self.deal_value_sensitivity = other.deal_value_sensitivity
	self.trading_propensity = other.trading_propensity
	self.greed = other.greed
	self.purposefulness = other.purposefulness
	self.desire_to_cooperate = other.desire_to_cooperate
	self.thrift = other.thrift
	self.objectivity_of_transaction = other.objectivity_of_transaction
	
	self.win_count = other.win_count
	
	self.color = other.color
	self.name_ = other.name_
	self.add_child(MeshInstance3D.new())
	self.get_child(0).mesh = other.mesh
	self.get_child(0).mesh.material = StandardMaterial3D.new()
	self.get_child(0).mesh.material.albedo_color = other.color
	self.scale = Vector3(0.25,0.25,0.25)
	self.house_style = other.house_style
	self.hotel_style = other.hotel_style
	self.is_bot = other.is_bot

func get_dna_array() -> Array:
	return [
		risk_tolerance,
		auction_aggressiveness,
		cash_reserve_ratio,
		build_priority,
		mortgaging_threshold,
		deal_value_sensitivity,
		trading_propensity,
		greed,
		purposefulness,
		desire_to_cooperate,
		thrift,
		objectivity_of_transaction,
		win_count
	]
