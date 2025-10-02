extends Node3D

@onready var camera : Camera3D = get_node("orbit/Camera3D")
@onready var cell_light = %cur_cell_light

func _init():
	if not DirAccess.dir_exists_absolute("user://genetics"):
		DirAccess.make_dir_absolute("user://genetics")

func _ready() -> void:
	await get_tree().process_frame
	
	for p : BotDNA in GLOBAL.PLAYERS:
		p.money = GLOBAL.START_MONEY - GLOBAL.start_get_money
		p.capital = GLOBAL.START_MONEY - GLOBAL.start_get_money
		p.doubles_count  = 0
		p.jail = 0
		p.is_die  = false
		p.pl_rent_koef  = 1.
		p.pl_buy_koef  = 1.
		p.is_moving = false
		p.cell_counter = -1
		p.direction = Vector3(0,0,1)
		p.just_changed_dir = false
		p.old_cell_tmp  = null
		p.is_in_center = false
	
	set_players()
	pass

func set_players():
	for p : BotDNA in GLOBAL.PLAYERS:
		%players.add_child(p)
		p.set_ready()
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if get_viewport().gui_get_hovered_control() != null:
			return
		if event.button_index == MOUSE_BUTTON_LEFT and event.position:
			var ray_origin = camera.project_ray_origin(event.position)
			var ray_dir = camera.project_ray_normal(event.position)
			var space_state = get_world_3d().direct_space_state
			var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * 1000))
			
			UI.reset()
			
			if result:
				var cell : Cell = result.collider
				
				if result and cell.has_method("move_to_y"):
					result.collider.move_to_y(-1, 1)
				
				if cell.monopoly_id != 0 && !UI.card_buy_panel.visible: #запрещаем перевыбирать поле, во время действий
					set_light(cell)
					
					result.collider.show_inf()
					
					GLOBAL.CURRENT_CELL = cell
					
					if cell.owner_ == GLOBAL.link_player():
						UI.house_panel.get_child(1).show()
						if cell.monopoly_check():
							UI.house_panel.get_child(0).show()
							UI.house_panel.get_child(2).show()
				else:
					cell_light.global_position = Vector3(15,2,15)
				
				if cell.center == true:
					set_light(cell)
					result.collider.show_inf()
			else:
				cell_light.global_position = Vector3(15,2,15)

func set_light(cell):
	cell_light.get_parent().remove_child(cell_light)
	cell.add_child(cell_light)
	cell_light.position = cell.player_center
	cell_light.position.y = 2
