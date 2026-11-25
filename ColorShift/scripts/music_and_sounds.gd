extends Node

## Standalone audio autoload for ColorShift.
##
## It does not modify the gameplay scripts: it listens to SceneManager scene
## changes to choose the background music and watches the player's
## AnimatedSprite2D to fire the jump, death and walk sounds.
##
## Registered in project.godot as the "MusicAndSounds" autoload.

const MENU_MUSIC := preload("res://bso_colorshift/backgrounds/Underwater/Cleyton RX - Underwater.mp3")
const LEVEL_MUSIC := preload("res://bso_colorshift/backgrounds/Enchanted Tiki 86/enchanted tiki 86.mp3")
const JUMP_SOUND := preload("res://bso_colorshift/larry/jump/saltop2/freesound_community-17-salto-p2-100872.mp3")
const DEATH_SOUND := preload("res://bso_colorshift/larry/death/human-impact-on-ground-6982/freesound_community-human-impact-on-ground-6982.mp3")
const WALK_SOUND := preload("res://bso_colorshift/larry/walk/wooland run step/freesound_community-180904-woodland04-run-steps-skip-jump-clip-47486.mp3")
const MENU_SELECT_SOUND := preload("res://bso_colorshift/menu select/Menu Selection Click.wav")
const AMULET_SOUND := preload("res://bso_colorshift/menu select/amulet/133008__cosmicd__annulet-of-absorption.wav")
const COLOR_CHANGE_SOUND := preload("res://bso_colorshift/change colors/light switch/Light Switch Click On Sfx.wav")
const DOOR_OPEN_SOUND := preload("res://bso_colorshift/extra SFX/dragon-studio-door-opening-397990.mp3")
const COLLECTABLE_SOUND := preload("res://bso_colorshift/extra SFX/liecio-diamond-found-190255.mp3")
const KEY_COLLECT_SOUND := preload("res://bso_colorshift/extra SFX/litupsubway-key-collect-sfx-522219.mp3")

## Scenes that use the level theme. Everything else uses the menu theme.
const LEVEL_SCENES := ["demo_level", "level_1", "level_2", "level_3", "level_4", "level_5"]
## Intro del logo: no suena música de fondo mientras se ve.
const INTRO_SCENE := "title_scene"

const MUSIC_FADE_TIME := 0.6
const MUSIC_FADE_FROM_DB := -30.0

## Volumen de la musica de fondo en dB (0 = original, negativo = mas flojo).
## Se pueden ajustar aqui los dos temas de forma independiente.
const MENU_MUSIC_VOLUME_DB := -10.0
const LEVEL_MUSIC_VOLUME_DB := -10.0

## Avoids playing the menu sound twice when a click triggers hover + focus.
const MENU_SELECT_COOLDOWN_MS := 60

## Quick sound tuning.
## The jump sound starts with ~40 ms of silence. Starting at 0.05 s skips it,
## so the hit is heard as soon as the button is pressed (0.0 keeps the silence).
const JUMP_START_OFFSET := 0.05
## Per-sound volume offsets in dB (0 = original volume).
const JUMP_VOLUME_DB := 0.0
const DEATH_VOLUME_DB := 0.0
const WALK_VOLUME_DB := -15.0
const MENU_SELECT_VOLUME_DB := 0.0
const AMULET_VOLUME_DB := -3.0
const COLOR_CHANGE_VOLUME_DB := 0.0
const DOOR_OPEN_VOLUME_DB := 0.0
const COLLECTABLE_VOLUME_DB := 0.0
const KEY_COLLECT_VOLUME_DB := 0.0

## Amulet intro: only the first seconds are heard, then it fades out.
const AMULET_PLAY_TIME := 2.0
const AMULET_FADE_TIME := 0.5
const SILENT_DB := -40.0

## El sonido de coleccionable dura mas de 5 s; solo se escucha el inicio.
const COLLECTABLE_PLAY_TIME := 1.0
const COLLECTABLE_FADE_TIME := 0.12

var _music: AudioStreamPlayer
var _jump: AudioStreamPlayer
var _death: AudioStreamPlayer
var _walk: AudioStreamPlayer
var _menu_select: AudioStreamPlayer
var _amulet: AudioStreamPlayer
var _color_change: AudioStreamPlayer
var _door_open: AudioStreamPlayer
var _collectable: AudioStreamPlayer
var _key_collect: AudioStreamPlayer

var _music_tween: Tween
var _amulet_tween: Tween
var _collectable_tween: Tween
var _current_music: AudioStream = null
var _pending_music_scene: String = ""
var _player: Node = null
var _sprite: AnimatedSprite2D = null
var _walking := false
var _last_menu_select_ms: int = -1000


func _ready() -> void:
	# Music has to keep playing while the pause menu pauses the tree.
	process_mode = Node.PROCESS_MODE_ALWAYS

	_music = _make_player("MusicPlayer", "Music")
	_jump = _make_player("JumpPlayer", "SFX")
	_death = _make_player("DeathPlayer", "SFX")
	_walk = _make_player("WalkPlayer", "SFX")
	_menu_select = _make_player("MenuSelectPlayer", "SFX")
	_amulet = _make_player("AmuletPlayer", "SFX")
	_color_change = _make_player("ColorChangePlayer", "SFX")
	_door_open = _make_player("DoorOpenPlayer", "SFX")
	_collectable = _make_player("CollectablePlayer", "SFX")
	_key_collect = _make_player("KeyCollectPlayer", "SFX")

	_make_looping(MENU_MUSIC)
	_make_looping(LEVEL_MUSIC)
	_make_looping(WALK_SOUND)

	_music.stream = MENU_MUSIC
	_jump.stream = JUMP_SOUND
	_death.stream = DEATH_SOUND
	_walk.stream = WALK_SOUND
	_menu_select.stream = MENU_SELECT_SOUND
	_amulet.stream = AMULET_SOUND
	_color_change.stream = COLOR_CHANGE_SOUND
	_door_open.stream = DOOR_OPEN_SOUND
	_collectable.stream = COLLECTABLE_SOUND
	_key_collect.stream = KEY_COLLECT_SOUND

	_jump.volume_db = JUMP_VOLUME_DB
	_death.volume_db = DEATH_VOLUME_DB
	_walk.volume_db = WALK_VOLUME_DB
	_menu_select.volume_db = MENU_SELECT_VOLUME_DB
	_amulet.volume_db = AMULET_VOLUME_DB
	_color_change.volume_db = COLOR_CHANGE_VOLUME_DB
	_door_open.volume_db = DOOR_OPEN_VOLUME_DB
	_collectable.volume_db = COLLECTABLE_VOLUME_DB
	_key_collect.volume_db = KEY_COLLECT_VOLUME_DB

	SceneManager.scene_changed.connect(_on_scene_changed)
	SceneManager.scene_change_started.connect(_on_scene_change_started)
	get_tree().node_added.connect(_on_node_added)

	# Autoloads are ready before the initial scene is loaded, so wait one frame.
	await get_tree().process_frame
	_hook_existing_buttons()
	_sync_music(_current_scene_name())


func _process(_delta: float) -> void:
	if get_tree().paused:
		_stop_walking()
		return

	_refresh_player()
	if _sprite == null:
		return

	# The walk sound is a loop: keep it in sync with the current animation.
	if _sprite.animation == &"run":
		_start_walking()
	else:
		_stop_walking()


# Fired on the exact frame the animation changes, so the jump sound starts
# as soon as the player presses the jump button instead of on the next frame.
func _on_animation_changed() -> void:
	if _sprite == null:
		return

	var animation_name := String(_sprite.animation).to_lower()
	if animation_name == "jump":
		_play(_jump, JUMP_START_OFFSET)
	elif animation_name == "death":
		_play(_death)


func _on_scene_changed(scene_name: String) -> void:
	_sync_music(scene_name)


func _on_scene_change_started(scene_name: String) -> void:
	# Only when a level is selected/loaded, never for menus or level reloads.
	if _is_level(scene_name):
		_start_amulet_intro()
	else:
		_cancel_amulet()
		_pending_music_scene = ""


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_hook_button(node)


func _hook_existing_buttons() -> void:
	for node in get_tree().root.find_children("*", "", true, false):
		if node is BaseButton:
			_hook_button(node)


func _hook_button(button: BaseButton) -> void:
	if not button.mouse_entered.is_connected(_on_menu_option_changed):
		button.mouse_entered.connect(_on_menu_option_changed)
	if not button.focus_entered.is_connected(_on_menu_option_changed):
		button.focus_entered.connect(_on_menu_option_changed)


func _on_menu_option_changed() -> void:
	if SceneManager.is_transitioning:
		return

	# A click can hover and focus at the same time: play the sound only once.
	var now := Time.get_ticks_msec()
	if now - _last_menu_select_ms < MENU_SELECT_COOLDOWN_MS:
		return

	_last_menu_select_ms = now
	_play(_menu_select)


func _sync_music(scene_name: String) -> void:
	# La intro del estudio va sin música: la del menú entra al llegar a main_menu.
	if scene_name.to_lower() == INTRO_SCENE:
		return

	var next_stream: AudioStream = LEVEL_MUSIC if _is_level(scene_name) else MENU_MUSIC

	# Do not overlap the level music with the amulet intro.
	if next_stream == LEVEL_MUSIC and _amulet.playing:
		_pending_music_scene = scene_name
		return

	_pending_music_scene = ""
	_play_music(next_stream)


func _music_volume_for(stream: AudioStream) -> float:
	return LEVEL_MUSIC_VOLUME_DB if stream == LEVEL_MUSIC else MENU_MUSIC_VOLUME_DB


func _play_music(next_stream: AudioStream) -> void:
	if next_stream == null:
		return

	var target_db := _music_volume_for(next_stream)
	if next_stream == _current_music and _music.playing:
		# The track may have been faded out by the amulet intro: bring it back.
		if _music.volume_db < target_db - 0.01:
			_fade_music_to(target_db, MUSIC_FADE_TIME)
		return

	_current_music = next_stream
	_music.stream = next_stream
	_music.volume_db = MUSIC_FADE_FROM_DB
	_music.play()
	_fade_music_to(target_db, MUSIC_FADE_TIME)


func _fade_music_to(target_db: float, duration: float) -> void:
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_music, "volume_db", target_db, duration)


func _start_amulet_intro() -> void:
	_cancel_amulet()
	_pending_music_scene = ""

	# Let the amulet be heard on its own, without the current music.
	_fade_music_to(SILENT_DB, 0.3)

	_amulet.volume_db = AMULET_VOLUME_DB
	_amulet.play()

	# Play only the beginning of the sound and fade it out at the end.
	var fade := minf(AMULET_FADE_TIME, AMULET_PLAY_TIME * 0.5)
	var wait := maxf(AMULET_PLAY_TIME - fade, 0.0)
	_amulet_tween = create_tween()
	_amulet_tween.tween_interval(wait)
	_amulet_tween.tween_property(_amulet, "volume_db", SILENT_DB, fade)
	_amulet_tween.tween_callback(_amulet.stop)
	_amulet_tween.finished.connect(_on_amulet_finished)


func _on_amulet_finished() -> void:
	_amulet_tween = null
	_amulet.volume_db = AMULET_VOLUME_DB

	# The level scene may already be loaded, waiting for the intro to end.
	if _pending_music_scene != "":
		_pending_music_scene = ""
		_play_music(LEVEL_MUSIC)
	else:
		# The transition was cancelled: bring the previous track back.
		_play_music(_current_music)


func _cancel_amulet() -> void:
	if _amulet_tween and _amulet_tween.is_valid():
		_amulet_tween.kill()
	_amulet_tween = null

	if _amulet != null:
		_amulet.stop()
		_amulet.volume_db = AMULET_VOLUME_DB


func _current_scene_name() -> String:
	if SceneManager.current_scene_name != "":
		return SceneManager.current_scene_name

	var scene := get_tree().current_scene
	if scene == null:
		return ""
	return scene.scene_file_path.get_file().get_basename()


func _is_level(scene_name: String) -> bool:
	var key := scene_name.to_lower()
	if key == "level_select":
		return false
	return key in LEVEL_SCENES or key.begins_with("level_")


func _refresh_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if is_instance_valid(_player) and player == _player and _has_valid_sprite():
		return
	_attach_player(player)


func _attach_player(player: Node) -> void:
	_player = player
	_sprite = null
	_stop_walking()

	if _player == null:
		return

	_sprite = _player.get_node_or_null("%PlayerSkin") as AnimatedSprite2D
	if _sprite == null:
		_sprite = _player.find_child("PlayerSkin", true, false) as AnimatedSprite2D

	if _sprite != null:
		if not _sprite.animation_changed.is_connected(_on_animation_changed):
			_sprite.animation_changed.connect(_on_animation_changed)


func _has_valid_sprite() -> bool:
	return _sprite != null and is_instance_valid(_sprite) and _sprite.is_inside_tree()


func _make_player(node_name: String, bus: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.bus = bus
	add_child(player)
	return player


func _make_looping(stream: AudioStream) -> void:
	if stream != null and "loop" in stream:
		stream.set("loop", true)


func _play(player: AudioStreamPlayer, from_position: float = 0.0) -> void:
	if player == null or player.stream == null:
		return
	player.stop()
	player.play(from_position)


# Gameplay effects. Called from the scripts that trigger each action.
func play_color_change() -> void:
	_play(_color_change)


func play_door_open() -> void:
	_play(_door_open)


func play_collectable() -> void:
	if _collectable == null or _collectable.stream == null:
		return

	# El archivo completo dura ~5.7 s; se corta tras el tañido inicial.
	if _collectable_tween and _collectable_tween.is_valid():
		_collectable_tween.kill()
	_collectable.volume_db = COLLECTABLE_VOLUME_DB
	_play(_collectable)

	var fade := minf(COLLECTABLE_FADE_TIME, COLLECTABLE_PLAY_TIME * 0.5)
	_collectable_tween = create_tween()
	_collectable_tween.tween_interval(COLLECTABLE_PLAY_TIME - fade)
	_collectable_tween.tween_property(_collectable, "volume_db", SILENT_DB, fade)
	_collectable_tween.tween_callback(_collectable.stop)
	_collectable_tween.finished.connect(_on_collectable_finished)


func _on_collectable_finished() -> void:
	_collectable_tween = null
	_collectable.volume_db = COLLECTABLE_VOLUME_DB


func play_key_collect() -> void:
	_play(_key_collect)


func _start_walking() -> void:
	if _walking or _walk == null:
		return
	_walking = true
	_walk.play()


func _stop_walking() -> void:
	_walking = false
	if _walk != null and _walk.playing:
		_walk.stop()
