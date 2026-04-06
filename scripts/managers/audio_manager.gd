extends Node
class_name AudioManager

@onready var _menu_music_player: AudioStreamPlayer = AudioStreamPlayer.new()

var _sfx_players: Dictionary = {}
var _menu_music_enabled: bool = false

func _ready() -> void:
	_create_audio_players()
	_connect_signals()
	_menu_music_player.finished.connect(_on_menu_music_finished)

func _create_audio_players() -> void:
	_create_audio_player("complexity_upgrade", preload("res://assets/audio/complexity_upgrade.ogg"))
	_create_audio_player("complexity_downgrade", preload("res://assets/audio/complexity_downgrade.ogg"))
	_create_audio_player("data_packet_collect", preload("res://assets/audio/data_packet_collect.ogg"))
	_create_audio_player("garbage_collector_collect", preload("res://assets/audio/garbage_collector_collect.ogg"))
	_create_audio_player("hotfix_patch_pickup", preload("res://assets/audio/hotfix_patch_pickup.ogg"))
	_create_audio_player("speed_boost", preload("res://assets/audio/speed_boost.ogg"))
	_create_audio_player("game_over_transition_cue", preload("res://assets/audio/game_over_transition_cue.ogg"))
	_create_audio_player("game_over_screen", preload("res://assets/audio/game_over_screen.ogg"))
	_create_audio_player("game_start_audio", preload("res://assets/audio/game_start_audio.ogg"))
	_create_audio_player("heisenberg_teleporting", preload("res://assets/audio/heisenberg_teleporting.ogg"))
	_create_audio_player("infinite_loop_hit", preload("res://assets/audio/infinite_loop_hit.ogg"))
	_create_audio_player("spaghetti_hit", preload("res://assets/audio/spaghetti_hit.ogg"))
	_create_audio_player("stack_overflow_hit", preload("res://assets/audio/stack_overflow_hit.ogg"))
	_create_audio_player("system_overload_warning", preload("res://assets/audio/system_overload_warning.ogg"))
	_create_audio_player("difficulty_tier1", preload("res://assets/audio/difficulty_tier1.mp3"))
	_create_audio_player("difficulty_tier2", preload("res://assets/audio/difficulty_tier2.mp3"))
	_create_audio_player("difficulty_tier3", preload("res://assets/audio/difficulty_tier3.mp3"))

	_menu_music_player.name = "MenuMusicPlayer"
	_menu_music_player.stream = preload("res://assets/audio/tense_background_music.mp3")
	_menu_music_player.bus = "Master"
	_menu_music_player.autoplay = false
	add_child(_menu_music_player)

func _create_audio_player(key: String, stream: AudioStream) -> void:
	var player = AudioStreamPlayer.new()
	player.name = "%s_player" % key
	player.stream = stream
	player.bus = "Master"
	player.autoplay = false
	add_child(player)
	_sfx_players[key] = player

func _connect_signals() -> void:
	GameEvents.game_state_requested.connect(_on_game_state_requested)
	GameEvents.game_state_changed.connect(_on_game_state_changed)
	GameEvents.game_over_transition.connect(_on_game_over_transition)
	GameEvents.game_over_screen_shown.connect(_on_game_over_screen_shown)
	GameEvents.difficulty_increased.connect(_on_difficulty_increased)
	GameEvents.complexity_upgraded.connect(Callable(self, "_play_sfx").bind("complexity_upgrade"))
	GameEvents.heisenberg_teleporting.connect(Callable(self, "_play_sfx").bind("heisenberg_teleporting"))
	GameEvents.complexity_downgraded.connect(Callable(self, "_play_sfx").bind("complexity_downgrade"))
	GameEvents.data_packet_collected.connect(Callable(self, "_play_sfx").bind("data_packet_collect"))
	GameEvents.garbage_collector_collected.connect(Callable(self, "_play_sfx").bind("garbage_collector_collect"))
	GameEvents.hotfix_patch_collected.connect(Callable(self, "_play_sfx").bind("hotfix_patch_pickup"))
	GameEvents.speed_boost_collected.connect(Callable(self, "_play_sfx").bind("speed_boost"))
	GameEvents.enemy_hit.connect(_on_enemy_hit)
	GameEvents.ram_critical_reached.connect(Callable(self, "_play_sfx").bind("system_overload_warning"))

func _on_menu_music_finished() -> void:
	if _menu_music_enabled:
		_menu_music_player.play()

func _on_game_state_requested(state: String) -> void:
	if state == "play":
		_play_sfx("game_start_audio")

func _on_game_state_changed(state: String) -> void:
	if state == "menu":
		_menu_music_enabled = true
		_menu_music_player.play()
	elif state == "play":
		_menu_music_enabled = false
		_menu_music_player.stop()
		_play_sfx("difficulty_tier1")
	else:
		_menu_music_enabled = false
		_menu_music_player.stop()

func _on_game_over_transition() -> void:
	_play_sfx("game_over_transition_cue")

func _on_game_over_screen_shown() -> void:
	_play_sfx("game_over_screen")

func _on_difficulty_increased(tier: int, _time_elapsed: float) -> void:
	_play_sfx("difficulty_tier%d" % tier)

func _on_enemy_hit(enemy_name: String) -> void:
	var lower_name = enemy_name.to_lower()
	if lower_name.find("infinite_loop") >= 0:
		_play_sfx("infinite_loop_hit")
	elif lower_name.find("spaghetti") >= 0:
		_play_sfx("spaghetti_hit")
	elif lower_name.find("stack_overflow") >= 0:
		_play_sfx("stack_overflow_hit")

func _play_sfx(key: String) -> void:
	if not _sfx_players.has(key):
		return
	var player = _sfx_players[key]
	if player:
		player.play()
