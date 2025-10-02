extends Node2D

var pl_count : int = 0
var bot_count : int = 0
var start_money : int = 0

var cur_player : int = 0
var players : Array[BotDNA] = []
var bots : Array[BotDNA] = []
var players_icons : Array[Button] = [Button.new(),Button.new(),Button.new(),Button.new()]

var _available_colors := [
	Color8(255, 0, 0),      # Красный
	Color8(0, 255, 0),      # Зелёный
	Color8(0, 0, 255),      # Синий
	Color8(255, 255, 0),    # Жёлтый
	Color8(255, 0, 255),    # Пурпурный
	Color8(0, 255, 255),    # Голубой
	Color8(255, 128, 0),    # Оранжевый
	Color8(128, 0, 255),    # Фиолетовый
	Color.SADDLE_BROWN,
	Color.WEB_GRAY
]

var _available_names := [
	"Олег",
	"Инга",
	"Софи",
	"Магамед",
	"Николай",
	"Инесса",
	"Артур",
	"Крис",
	"Силиция",
	"Князь",
	"Зарина",
	"Княжна",
	"Круэлла",
	"Ольга",
	"Яна",
	"Арнольд",
	"Генадий",
]
var _available_style := [
	"база",
	"модерн",
	"япония",
	"киберпанк",
]

func get_random_unique_color() -> Color:
	if _available_colors.is_empty():
		push_warning("Цвета закончились!")
		return Color.WHITE  # или другой дефолт
	var index := randi() % _available_colors.size()
	return _available_colors.pop_at(index)

func get_random_unique_name() -> String:
	var index := randi() % _available_names.size()
	return _available_names.pop_at(index)

func get_random_style() -> String:
	var index := randi() % _available_style.size()
	return _available_style[index]

func _ready():
	var container = %icon_container
	for child in container.get_children():
		if child is Button:
			child.pressed.connect(_on_icon_pressed.bind(child))
	
	var children = %names.get_children()
	for c : LineEdit in children:
		var color : Color = get_random_unique_color()
		c.add_theme_color_override("clear_button_color_pressed", color)
		c.add_theme_color_override("clear_button_color", color)
		c.add_theme_color_override("selection_color", color)
		c.add_theme_color_override("caret_color", color)
		c.add_theme_color_override("font_placeholder_color", color)
		c.add_theme_color_override("font_selected_color", color)
		c.add_theme_color_override("font_uneditable_color", color)
		c.add_theme_color_override("font_color", color)

func _on_icon_pressed(button: Button) -> void:
	%click.play()
	for bt in players_icons:
		if bt == button:
			return
	
	var color = %names.get_children()[cur_player].get_theme_color("font_color")
	
	var states = ["normal", "hover", "pressed", "disabled", "focus"]
	for state in states:
		var style = players_icons[cur_player].get_theme_stylebox(state)
		if style is StyleBoxFlat:
			var new_style := style.duplicate() as StyleBoxFlat
			new_style.bg_color = Color(0,0,0,0)
			players_icons[cur_player].add_theme_stylebox_override(state, new_style)
	
	players_icons[cur_player] = button
	
	
	for state in states:
		var style = button.get_theme_stylebox(state)
		if style is StyleBoxFlat:
			var new_style := style.duplicate() as StyleBoxFlat
			new_style.bg_color = color
			button.add_theme_stylebox_override(state, new_style)
	pass

func _on_players_value_changed(value: float) -> void:
	pl_count = int(value)
	%pl_count.text = str(pl_count)
	
	var i = 0
	players.clear()
	while(i != pl_count):
		players.append(BotDNA.new())
		i += 1
	
	var children = %names.get_children()
	
	for c in children:
		c.show()
		
	i = pl_count
	while(i != 4):
		children[i].hide()
		i += 1
	pass # Replace with function body.

func _on_players_2_value_changed(value: float) -> void:
	bot_count = int(value)
	%bot_count.text = str(bot_count)
	
	var i = 0
	bots.clear()
	while(i != bot_count):
		bots.append(BotDNA.new())
		bots[i].randomize_DNA()
		bots[i].is_bot = true
		i += 1
	pass # Replace with function body.

func _on_players_3_value_changed(value: float) -> void:
	start_money = int(value)
	%money.text = str(start_money)
	pass # Replace with function body.

func _on_player(new_text: String, extra_arg_0: int) -> void:
	%click.play()
	cur_player = extra_arg_0
	var children = %names.get_children()
	for c : LineEdit in children:
		c.add_theme_font_size_override("font_size", 40)
	children[cur_player].add_theme_font_size_override("font_size", 60)
	pass # Replace with function body.


func _on_style_pressed(extra_arg_0: String) -> void:
	%click.play()
	
	var panel = %prev.get_theme_stylebox("panel")
	var styleBox : StyleBoxTexture = panel.duplicate()
	var texture : Texture2D
	
	match extra_arg_0:
		'"base"':
			texture = load("res://иконки/ep--house.png")
			players[cur_player].house_style = load("res://models/стили домов/база/дом.tres")
			players[cur_player].hotel_style = load("res://models/стили домов/база/отель.tres")
		'"eco"':
			texture = load("res://иконки/game-icons--greenhouse.png")
		'"japan"':
			texture = load("res://иконки/emojione-monotone--japanese-castle.png")
			players[cur_player].house_style = load("res://models/стили домов/япония/дом.tres")
			players[cur_player].hotel_style = load("res://models/стили домов/япония/отель.tres")
		'"modern"':
			texture = load("res://иконки/heroicons--home-modern.png")
			players[cur_player].house_style = load("res://models/стили домов/модерн/дом.tres")
			players[cur_player].hotel_style = load("res://models/стили домов/модерн/отель.tres")
		'"cuberpunk"':
			texture = load("res://иконки/tabler--building-skyscraper.png")
			players[cur_player].house_style = load("res://models/стили домов/киберпанк/дом.tres")
			players[cur_player].hotel_style = load("res://models/стили домов/киберпанк/отель.tres")
	
	styleBox.texture = texture
	%prev.add_theme_stylebox_override("panel", styleBox)


func _on_start_pressed() -> void:
	%click.play()
	
	var i = 0
	for p in players:
		p.color = %names.get_children()[i].get_theme_color("font_color")
		p.name_ = %names.get_children()[i].text
		i += 1
	
	i=0
	for p in bots:
		p.color = get_random_unique_color()
		p.name_ = get_random_unique_name()
		var style : String = get_random_style()
		p.house_style = load("res://models/стили домов/"+ style +"/дом.tres")
		p.hotel_style = load("res://models/стили домов/"+ style +"/отель.tres")
		i += 1
	
	if !load_generation_DNA():
		for p in bots:
			p.randomize_DNA()
	
	var p1 = players.pop_back()
	var pl_bot : Array[BotDNA] = players + bots
	pl_bot.shuffle()
	if p1 != null:
		pl_bot.push_front(p1)
	
	i=0
	for p in pl_bot:
		p.money = %money.get_parent().value - GLOBAL.start_get_money
		p.capital = %money.get_parent().value - GLOBAL.start_get_money
		p.add_child(MeshInstance3D.new())
		p.get_child(0).mesh = p.mesh
		p.get_child(0).mesh.material = StandardMaterial3D.new()
		p.get_child(0).mesh.material.albedo_color = p.color
		p.scale = Vector3(0.25,0.25,0.25)
		i += 1
	
	GLOBAL.PLAYERS = pl_bot
	GLOBAL.START_MONEY = %money.get_parent().value
	get_tree().change_scene_to_file("res://node_3d.tscn")
	pass # Replace with function body.

func load_generation_DNA():
	if bots.size() == 0:
		return
	
	GLOBAL.num_of_generation = 420
	#var file := FileAccess.open("user://genetics/gen_%03d.json" % GLOBAL.num_of_generation, FileAccess.READ) #для обучения
	var file := FileAccess.open("res://genetics/gen_%03d.json" % GLOBAL.num_of_generation, FileAccess.READ) #для экспорта
	if not file: 
		return false
	var content = file.get_as_text()
	file.close()
	var data = JSON.parse_string(content)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Invalid save file.")
		return false
	
	var arr : Array = data["bots"]
	arr.sort_custom(func(a, b): return a[12] > b[12])
	
	var i = 0
	for dna in arr:
		BRAIN.copy_DNA(bots[i],dna)
		i += 1
		if i >= bots.size():
			break
	
	return true
