extends Node
# SoundManager is autoloaded globally - no class_name needed

## Global sound manager for playing game SFX.
## Preloads all sounds and provides simple playback methods.

const SOUND_HIT = preload("res://assets/WinXp/Sounds/Windows XP Error.wav")
const SOUND_REFACTOR = preload("res://assets/sounds/JDSherbert - Pixel UI SFX Pack (FREE)/Stereo/wav (HD)/JDSherbert - Pixel UI SFX Pack - Select 1 (Sine).wav")
const SOUND_COLLECT = preload("res://assets/sounds/JDSherbert - Pixel UI SFX Pack (FREE)/Stereo/wav (HD)/JDSherbert - Pixel UI SFX Pack - Select 2 (Sine).wav")
const SOUND_CRITICAL = preload("res://assets/WinXp/Sounds/Windows XP Critical Stop.wav")
const SOUND_GAME_OVER = preload("res://assets/WinXp/Sounds/Windows XP Shutdown.wav")

# JDSherbert Pixel UI SFX
const SOUND_MENU_HOVER = preload("res://assets/sounds/JDSherbert - Pixel UI SFX Pack (FREE)/Stereo/wav (HD)/JDSherbert - Pixel UI SFX Pack - Cursor 1 (Sine).wav")
const SOUND_MENU_SELECT = preload("res://assets/sounds/JDSherbert - Pixel UI SFX Pack (FREE)/Stereo/wav (HD)/JDSherbert - Pixel UI SFX Pack - Select 1 (Sine).wav")
const SOUND_MENU_CANCEL = preload("res://assets/sounds/JDSherbert - Pixel UI SFX Pack (FREE)/Stereo/wav (HD)/JDSherbert - Pixel UI SFX Pack - Cancel 1 (Sine).wav")

# Music - same track for menu and game
const MUSIC_MAIN = preload("res://assets/sounds/Music/Cartoon, Jéja - On & On (feat. Daniel Levi) Electronic Pop NCS - Copyright Free Music - NoCopyrightSounds (128k).ogg")

# Music player
var _music_player: AudioStreamPlayer

func _ready() -> void:
	if GameEvents:
		GameEvents.collectible_picked_up.connect(_on_collectible_picked_up)

## Plays a specific sound stream.
func play_sound(stream: AudioStream, pitch: float = 1.0) -> void:
	if not stream:
		return
	
	# Create a fresh player to avoid cancellation
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.pitch_scale = pitch
	player.bus = "Master"
	player.volume_db = 0.0
	add_child(player)
	player.play()
	
	# Auto-cleanup after playing
	await player.finished
	player.queue_free()

## Plays the music (loops) - same for menu and game.
func play_music() -> void:
	if _music_player and is_instance_valid(_music_player):
		return  # Already playing
	
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = MUSIC_MAIN
	_music_player.bus = "Master"
	_music_player.volume_db = -10.0
	_music_player.pitch_scale = 0.8
	_music_player.autoplay = true
	_music_player.finished.connect(_on_music_finished)
	add_child(_music_player)

func _on_music_finished() -> void:
	if _music_player and is_instance_valid(_music_player):
		_music_player.play()  # Loop

## Stops the music.
func stop_music() -> void:
	if _music_player and is_instance_valid(_music_player):
		_music_player.stop()
		_music_player.queue_free()
		_music_player = null

## Plays the enemy hit sound.
func play_hit() -> void:
	play_sound(SOUND_HIT)

## Plays the refactor/tier drop sound.
func play_refactor() -> void:
	play_sound(SOUND_REFACTOR, 0.9)

## Plays the collectible pickup sound.
func play_collect() -> void:
	play_sound(SOUND_COLLECT, 1.0)

## Plays the critical RAM warning sound.
func play_critical() -> void:
	play_sound(SOUND_CRITICAL)

## Plays the game over sound.
func play_game_over() -> void:
	play_sound(SOUND_GAME_OVER)

## Plays the menu hover sound.
func play_menu_hover() -> void:
	play_sound(SOUND_MENU_HOVER)

## Plays the menu select/click sound.
func play_menu_select() -> void:
	play_sound(SOUND_MENU_SELECT)

## Plays the menu cancel sound.
func play_menu_cancel() -> void:
	play_sound(SOUND_MENU_CANCEL)

func _on_collectible_picked_up(_collectible: Node2D) -> void:
	play_collect()
