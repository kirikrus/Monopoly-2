extends Node

static var CURRENT_PLAYER: int = 1
static var CURRENT_CELL: Cell = null
static var PLAYERS: Array[BotDNA] = []
static var LOOSE_PLAYERS: Array[BotDNA] = []
static var dice: int = 0
static var sell_koef: float = 0.5
static var start_get_money : int = 200
static var jail_exit : int = 200
static var nalog_koef : float = 0.10 #от капитала
static var capital : int 
static var START_MONEY : int = 2500

static var noise: Texture2D = load("res://models/new_noise_texture_2d.res")

static var player_velocity : = 0.5 ## по-умолчанию 0.1, для обучения 0.5
static var bot_speed : float = 1 ## по-умолчанию = 1, для обучения 0.0
static var bot_card_speed : float = 5 ## по-умолчанию = 5, для обучения 0.0

static var GENERATION_INTERVAL : int = 10 ## периодичность мутаций
static var num_of_generation : int = 0
static var winner_dna: Array[float] = [] ## победитель
static var prizewinner_dna: Array[float] = [] ##почти победитель

static func link_player() -> BotDNA:
	return PLAYERS[CURRENT_PLAYER-1]
