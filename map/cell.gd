extends StaticBody3D

class_name Cell

@export var id : int # id с учетом только клеток монополии (цветных клеток)
@export var corner: bool
@export var center: bool
@export var player_center: Vector3
@export var color: Color
@export var monopoly_id: int
@export var name_: String
@export var special_cell_id: int
@export var special_cell_name: String
@export var cost: int = -1
@export var one_house_cost: int
@export var rent: int

var monopoly : Array[Cell]
var owner_ : BotDNA = null
var house_count: int = 0
var house_meshes: Array[MeshInstance3D] = [MeshInstance3D.new(), MeshInstance3D.new(),MeshInstance3D.new(),MeshInstance3D.new(),MeshInstance3D.new()]
var house_rent: Array
var zalog : bool = false

var owner_sign : MeshInstance3D 		#карта владельца
var owner_mesh : PlaneMesh 				#меш карты владельца

var neighbors: Array[Cell]
var cell_size: Vector3
var min_cell_size = 1

func _ready():
	player_center.y = 0
	
	var mesh : MeshInstance3D = get_child(0)
	cell_size = mesh.scale
	
	add_to_group("board")
	await get_tree().process_frame
	
	find_neighbors()
	monopoly = BRAIN.get_monopoly(monopoly_id)
	set_rent()
	
	if(monopoly_id != 0):
		owner_mesh = PlaneMesh.new()
		owner_mesh.size = Vector2(1,1)
		
		var material = StandardMaterial3D.new()
		owner_mesh.material = material
		
		owner_sign = MeshInstance3D.new()
		owner_sign.mesh = owner_mesh
		owner_sign.position = Vector3(-0.5,-0.2,-2.2)
		add_child(owner_sign)
		owner_sign.hide()

func set_rent():
	house_rent = DB.rent[id]

func move_to_y(target_y: float, count: int, duration: float = 1):
	if count != 0:
		for n in neighbors:
			if n == self:
				continue
			n.move_to_y(target_y/2, count-1)
	
	var collision = get_child(1)
	collision.disabled = true
	
	var start_y = position.y
	var time_passed = 0.0
	
	while time_passed < duration/2:
		var t = time_passed / duration
		position.y = lerp(start_y, target_y, t)
		await get_tree().process_frame
		time_passed += get_process_delta_time()
	position.y = target_y
	while time_passed < duration:
		var t = time_passed / duration
		position.y = lerp(target_y, 0.0, t)
		await get_tree().process_frame
		time_passed += get_process_delta_time()
	position.y = 0
	
	collision.disabled = false

func find_neighbors():
	for other : Cell in get_tree().get_nodes_in_group("board"):
		if other == self:
			continue
		var dx = other.get_child(1).global_position.x - get_child(1).global_position.x
		var dz = other.get_child(1).global_position.z - get_child(1).global_position.z
		if other.cell_size != cell_size: #так как клетки разного скейла, то для одинаковости малых и больших так
			dx /= 2
			dz /= 2
		if abs(dx) <= min_cell_size and abs(dz) <= min_cell_size:
			neighbors.append(other)

func show_inf():
	if monopoly_id == 0 && !center:
		return
	
	UI.card_inf.show()
	var card = UI.card_inf.get_child(1).get_child(0)
	
	if center:
		card.get_child(0).text = name_
		card.get_child(1).text = ""
		card.get_child(2).get_child(0).text = "1 карта: "
		card.get_child(2).get_child(1).text = str(house_rent[0]) + "$"
		card.get_child(3).get_child(0).text = "2 карты: "
		card.get_child(3).get_child(1).text = str(house_rent[1]) + "$"
		card.get_child(4).get_child(0).text = "3 карты: "
		card.get_child(4).get_child(1).text = str(house_rent[2]) + "$"
		card.get_child(5).get_child(0).text = "4 карты: "
		card.get_child(5).get_child(1).text = str(house_rent[3]) + "$"
		card.get_child(6).get_child(0).text = ""
		card.get_child(6).get_child(1).text = ""
		card.get_child(7).text = ""
		card.get_child(8).text = str(cost) + "$"
	else:
		card.get_child(0).text = name_
		card.get_child(1).text = "Рента: " + str(rent) + "$"
		card.get_child(2).get_child(0).text = "🟩"
		card.get_child(2).get_child(1).text = str(house_rent[0]) + "$"
		card.get_child(3).get_child(0).text = "🟩🟩"
		card.get_child(3).get_child(1).text = str(house_rent[1]) + "$"
		card.get_child(4).get_child(0).text = "🟩🟩🟩"
		card.get_child(4).get_child(1).text = str(house_rent[2]) + "$"
		card.get_child(5).get_child(0).text = "🟩🟩🟩🟩"
		card.get_child(5).get_child(1).text = str(house_rent[3]) + "$"
		card.get_child(6).get_child(0).text = "🟥"
		card.get_child(6).get_child(1).text = str(house_rent[4]) + "$"
		card.get_child(7).text = "Цена дома: " + str(one_house_cost) + "$"
		card.get_child(8).text = str(cost) + "$"
	
	var old_style = UI.card_inf.get_child(1).get_theme_stylebox("panel") as StyleBoxFlat
	var styleBox = old_style.duplicate()
	styleBox.border_color = color
	UI.card_inf.get_child(1).add_theme_stylebox_override("panel", styleBox)
	
	old_style = card.get_child(0).get_theme_stylebox("normal") as StyleBoxFlat
	styleBox = old_style.duplicate()
	styleBox.bg_color = color
	card.get_child(0).add_theme_stylebox_override("normal", styleBox)

func buy():
	owner_ = GLOBAL.link_player()
	owner_.money -= cost * owner_.pl_buy_koef
	if owner_.pl_buy_koef == 0:
		owner_.capital += cost
	UI.money_log(null, -cost * owner_.pl_buy_koef, "buy")
	
	owner_.update()
	
	owner_mesh.material.albedo_color = GLOBAL.link_player().color
	owner_sign.show()
	
	UI.card_buy_panel.hide()
	
	SOUND.buy.play()
	
	owner_.pl_buy_koef = 1

func monopoly_check() -> bool:
	for cell : Cell in monopoly:
		if cell.owner_ != owner_:
			return false
		if cell.zalog:
			return false
	return true

func monopoly_count() -> int:
	var i = 0
	for cell : Cell in monopoly:
		if cell.owner_ == owner_:
			i+=1
	return  i

func zalog_check( re : int = 1) -> bool:
	var flag : bool = true
	for cell : Cell in monopoly:
		if cell.house_count != 0:
			flag = false
	return flag

func house_check( re : int = 1) -> bool:
	var flag : bool = true
	for cell : Cell in monopoly:
		if cell.house_count == house_count - 1 * re:
			flag = false
	return flag

func house_count_in_monopoly() -> int:
	var i = 0
	for cell : Cell in monopoly:
		if cell.owner_ == owner_:
			i += cell.house_count
	return  i

func is_houses_in_monopoly() -> bool:
	var flag : bool = false
	for cell : Cell in monopoly:
		if cell.house_count != 0:
			flag = true
	return flag

func build(special : bool = false):
	if house_count == 5: return
	
	if !special:
		if !house_check() || !monopoly_check() || owner_.money < one_house_cost: return
		
		owner_.money -= one_house_cost
		owner_.capital -= one_house_cost * GLOBAL.sell_koef
		UI.money_log(null, -one_house_cost, "house")
	else:
		owner_.capital += one_house_cost * GLOBAL.sell_koef
	
	house_count += 1
	var mesh = owner_.house_style
	var cur_house = house_meshes[house_count-1]
	
	cur_house.scale = Vector3(0.33,0.33,0.33)
	cur_house.mesh = mesh
	
	match house_count:
		1: 
			add_child(cur_house)
			cur_house.position = Vector3(-0.25,0,-0.25)
		2: 
			add_child(cur_house)
			cur_house.position = Vector3(-0.75,0,-0.25)
		3: 
			add_child(cur_house)
			cur_house.position = Vector3(-0.25,0,-0.75)
		4: 
			add_child(cur_house)
			cur_house.position = Vector3(-0.75,0,-0.75)
		5: 
			house_meshes[0].hide()
			house_meshes[1].hide()
			house_meshes[2].hide()
			house_meshes[3].hide()
			
			mesh = owner_.hotel_style
			cur_house.scale = Vector3(0.9,0.9,0.9)
			cur_house.mesh = mesh
			add_child(cur_house)
			cur_house.position = Vector3(-0.5,0,-0.5)
	SOUND.build.play()

func debuild(special : bool = false):
	if !special:
		if !house_check(-1) && monopoly_check(): return
		owner_.money += one_house_cost * GLOBAL.sell_koef
		owner_.capital += one_house_cost * GLOBAL.sell_koef
		UI.money_log(null, one_house_cost * GLOBAL.sell_koef, "house")
	else:
		owner_.capital -= one_house_cost * GLOBAL.sell_koef
	
	if house_count == 0: return
	
	if house_count == 5:
		house_meshes[0].show()
		house_meshes[1].show()
		house_meshes[2].show()
		house_meshes[3].show()
	
	house_count -= 1
	
	var cur_house = house_meshes[house_count]
	remove_child(cur_house)
	SOUND.debuild.play()

func set_zalog(special : bool = false):
	if !zalog_check():
		return
	
	if zalog && owner_.money < GLOBAL.sell_koef * cost:
		return false
	
	if !zalog:
		if !special: 
			owner_.money += GLOBAL.sell_koef * cost
			UI.money_log(null, GLOBAL.sell_koef * cost, "zalog")
		owner_mesh.material.albedo_texture = GLOBAL.noise
	elif !special: 
		owner_.money -= GLOBAL.sell_koef * cost
		owner_mesh.material.albedo_texture = null
		UI.money_log(null, -GLOBAL.sell_koef * cost, "zalog")
	zalog = !zalog
	SOUND.debuild.play()

func pay_rent():
	var pl = GLOBAL.link_player()
	if owner_ != pl && owner_ != null:
		
		if owner_.jail != 0 && zalog:
			return
		
		if center:
			var r = monopoly_count() * 50
			pl.money -= r * pl.pl_rent_koef
			pl.capital -= r * pl.pl_rent_koef
			owner_.money += r * pl.pl_rent_koef
			owner_.capital += r * pl.pl_rent_koef
			UI.money_log(owner_, -r * pl.pl_rent_koef, "rent")
			pl.pl_rent_koef = 1
			return
		
		if house_count > 0:
			pl.money -= house_rent[house_count - 1] * pl.pl_rent_koef
			pl.capital -= house_rent[house_count - 1] * pl.pl_rent_koef
			owner_.money += house_rent[house_count - 1] * pl.pl_rent_koef
			owner_.capital += house_rent[house_count - 1] * pl.pl_rent_koef
			UI.money_log(owner_, -house_rent[house_count - 1] * pl.pl_rent_koef, "rent")
			pl.pl_rent_koef = 1
			return
		
		if monopoly_check():
			pl.money -= rent * 2 * pl.pl_rent_koef
			pl.capital -= rent * 2 * pl.pl_rent_koef
			owner_.money += rent * 2 * pl.pl_rent_koef
			owner_.capital += rent * 2 * pl.pl_rent_koef
			UI.money_log(owner_, -rent * 2 * pl.pl_rent_koef, "rent")
		else:
			pl.money -= rent * pl.pl_rent_koef
			pl.capital -= rent * pl.pl_rent_koef
			owner_.money += rent * pl.pl_rent_koef
			owner_.capital += rent * pl.pl_rent_koef
			UI.money_log(owner_, -rent * pl.pl_rent_koef, "rent")
		
		pl.pl_rent_koef = 1

func owns_group_except(to : BotDNA = null):  ## почти монополия
	var missing_count = 0
	for c in monopoly:
		if c.owner_ != owner_ && c.owner_ != to:
			missing_count += 1
	return missing_count == 1

func is_part_of_monopoly(to : BotDNA = null):  ## уже монополия
	var missing_count = 0
	for c in monopoly:
		if c.owner_ != owner_ && c.owner_ != to:
			missing_count += 1
	return missing_count == 0

func is_useless(): ## 1 клетка
	var missing_count = 0
	for c in monopoly:
		if c.owner_ != owner_:
			missing_count += 1
	return missing_count > 1

func get_missing_cell() -> Cell:
	for c in monopoly:
		if c.owner_ != owner_:
			return c
	return null
