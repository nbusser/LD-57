class_name Enemy extends Node3D

signal player_caught_cheating

@export var alien_intelligence: int = 2

var type: Enums.EnemyType = Enums.EnemyType.SPROINK:
	set(value):
		type = value
		_update_sprite()
var state: Enums.EnemyState = Enums.EnemyState.IDLE:
	set(value):
		state = value
		_update_sprite()

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var card_scene = preload("res://src/Card/Card.tscn")
@onready var drop_zone_enemy: Node3D = $"../EnemySnapper/CardsInBattleField"
@onready var mouth: Node3D = $"../Enemy/Mouth"
@onready var card_game: CardGame = $"../cardgame"


func _update_sprite():
	if (
		state == Enums.EnemyState.DISTRACTED
		or state == Enums.EnemyState.ASLEEP
		or state == Enums.EnemyState.WEAK
		or state == Enums.EnemyState.THINKING
		or state == Enums.EnemyState.POKED_LEFT
		or state == Enums.EnemyState.POKED_RIGHT
	):
		Globals.enemy_state = Globals.BaseEnemyState.DISTRACTED
	elif state == Enums.EnemyState.ANGRY:
		Globals.enemy_state = Globals.BaseEnemyState.ANGRY
	else:
		Globals.enemy_state = Globals.BaseEnemyState.IDLE

	animated_sprite_3d.flip_h = false
	match [type, state]:
		# sproink
		[Enums.EnemyType.SPROINK, Enums.EnemyState.IDLE]:
			animated_sprite_3d.play("sproink_idle")
		[Enums.EnemyType.SPROINK, Enums.EnemyState.WEAK]:
			animated_sprite_3d.play("sproink_weak")
		[Enums.EnemyType.SPROINK, Enums.EnemyState.THINKING]:
			animated_sprite_3d.play("sproink_thinking")
		[Enums.EnemyType.SPROINK, Enums.EnemyState.ANGRY]:
			animated_sprite_3d.play("sproink_angry")
		[Enums.EnemyType.SPROINK, Enums.EnemyState.DISTRACTED]:
			animated_sprite_3d.play("sproink_distracted")
		[Enums.EnemyType.SPROINK, Enums.EnemyState.POKED_LEFT]:
			animated_sprite_3d.play("sproink_poked")
			animated_sprite_3d.flip_h = true
		[Enums.EnemyType.SPROINK, Enums.EnemyState.POKED_RIGHT]:
			animated_sprite_3d.play("sproink_poked")
		[Enums.EnemyType.SPROINK, _]:
			animated_sprite_3d.play("sproink_idle")
		# pig
		[Enums.EnemyType.PIG, Enums.EnemyState.IDLE]:
			animated_sprite_3d.play("pig_idle")
		[Enums.EnemyType.PIG, Enums.EnemyState.WEAK]:
			animated_sprite_3d.play("pig_weak")
		[Enums.EnemyType.PIG, Enums.EnemyState.THINKING]:
			animated_sprite_3d.play("pig_thinking")
		[Enums.EnemyType.PIG, Enums.EnemyState.ANGRY]:
			animated_sprite_3d.play("pig_angry")
		[Enums.EnemyType.PIG, Enums.EnemyState.DISTRACTED]:
			animated_sprite_3d.play("pig_distracted")
		[Enums.EnemyType.PIG, Enums.EnemyState.SHOCKED]:
			animated_sprite_3d.play("pig_shocked")
		[Enums.EnemyType.PIG, Enums.EnemyState.ASLEEP]:
			animated_sprite_3d.play("pig_asleep")
		[Enums.EnemyType.PIG, Enums.EnemyState.POKED_LEFT]:
			animated_sprite_3d.play("pig_poked")
			animated_sprite_3d.flip_h = true
		[Enums.EnemyType.PIG, Enums.EnemyState.POKED_RIGHT]:
			animated_sprite_3d.play("pig_poked")
		[Enums.EnemyType.PIG, _]:
			animated_sprite_3d.play("pig_idle")


func _ready() -> void:
	_update_sprite()
	Globals.tutorial_mode_changed.connect(_on_tutorial_mode_changed)


func _on_tutorial_mode_changed(is_tutorial: bool) -> void:
	if is_tutorial:
		($DistractionTimer as Timer).stop()
	else:
		$DistractionTimer.wait_time = randf() * 13.0 + 3.0
		$DistractionTimer.start()


func _on_distraction_timer_timeout() -> void:
	# Alien gets distracted only if he is idling
	if state == Enums.EnemyState.IDLE:
		var states = [
			{state = Enums.EnemyState.DISTRACTED, distraction_time = 1.0},
			# Uncomment when we have a sleeping enemy
			# {state = Enums.EnemyState.ASLEEP, distraction_time = 3.0}
		]
		var new_state = states[randi() % len(states)]

		state = new_state.state
		await get_tree().create_timer(new_state.distraction_time).timeout
		state = Enums.EnemyState.IDLE

	$DistractionTimer.wait_time = randf() * 13.0 + 3.0
	$DistractionTimer.start()


# gdlint:disable = class-definitions-order
const NB_FRAMES_TO_GET_CAUGHT = 140
const NB_FRAMES_TO_LOSE = 280
var en_instance_de_se_faire_chopper = 0
# gdlint:enable = class-definitions-order


func _process(_delta: float) -> void:
	if (
		(state == Enums.EnemyState.IDLE or state == Enums.EnemyState.ANGRY)
		&& Globals.action_state == Globals.ActionState.ILLEGAL
	):
		en_instance_de_se_faire_chopper += 1
		if en_instance_de_se_faire_chopper >= NB_FRAMES_TO_GET_CAUGHT:
			state = Enums.EnemyState.ANGRY
		elif en_instance_de_se_faire_chopper >= NB_FRAMES_TO_LOSE:
			emit_signal("player_caught_cheating")
	else:
		en_instance_de_se_faire_chopper = max(0, en_instance_de_se_faire_chopper - 1)

	if state == Enums.EnemyState.ANGRY and en_instance_de_se_faire_chopper == 0:
		state = Enums.EnemyState.IDLE


func alien_draw_card(card_instance: Node3D) -> void:
	await get_tree().create_timer(1.0).timeout
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(card_instance, "global_position", mouth.global_position, 1.0)
	tween.parallel().tween_property(
		card_instance, "rotation_degrees", card_instance.rotation_degrees + Vector3(90, 0, 0), 1.0
	)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	var card_value = card_instance.get("card_value")
	var initial_state = state
	state = Enums.EnemyState.THINKING
	await get_tree().create_timer(1.5).timeout
	if initial_state != Enums.EnemyState.THINKING:
		state = initial_state
	card_instance.queue_free()


func get_list_avoid_card(initial_list: Array, avoid: int) -> Array:
	var filtre: Array = []
	for c in initial_list:
		if c != avoid:
			filtre.append(c)

	if filtre.size() != 0:
		return filtre
	return initial_list


func alien_think_about_card(hand, battle_field: Array) -> int:
	if Globals.tutorial_mode:
		return 3
	#Fonction appelée par le cardgame pour trigger une carte de l'alien
	#Pour l'instant on va juste prendre la première carte de la main de l'alien
	#On récupère le premier joueur pour savoir si on joue une carte en contre ou pas
	#Y REFLECHI
	await get_tree().create_timer(1.0).timeout
	battle_field = battle_field
	var choosen_card: int = 1

	match alien_intelligence:
		0:
			if hand.size() > 0:
				return hand[0]
		1:
			if hand.size() > 0:
				var random_choice = randi() % 2
				if random_choice == 0:
					choosen_card = hand[0]
				else:
					choosen_card = hand.min()
		2:
			#Jouer optimal càd
			if battle_field.size() == 0:
				#ON JOUE EN PREMIER
				if hand.size() > 0:
					return hand.min()
			else:  #On joue en deuxième
				var player_card = -99
				var new_hand: Array = []
				choosen_card = hand.min()
				for card in battle_field:
					if card["player"] == "player":
						player_card = card["card"]
						break
				if player_card == -2:
					new_hand = get_list_avoid_card(hand, 5)
					choosen_card = new_hand.min()
				elif player_card == 0:
					new_hand = get_list_avoid_card(hand, 0)
					choosen_card = new_hand.min()

				return choosen_card
		_:
			return 1
	return choosen_card


#Fonction appelée par le cardgame pour trigger une carte de l'alien
func alien_play_card(value: int) -> void:
	#On instancie une carte
	var card_inst = card_scene.instantiate()
	card_inst.init(value)
	#On la place à un endroit la tavu
	var previous_cards = drop_zone_enemy.get_children()
	drop_zone_enemy.add_child(card_inst)
	card_inst.global_position = mouth.global_position

	var tween = get_tree().create_tween()
	tween.parallel().tween_property(
		card_inst, "global_position", Vector3(drop_zone_enemy.global_position), .8
	)
	tween.parallel().tween_property(card_inst, "rotation", Vector3(5 * PI / 2, 0, 0), .7)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)

	card_game.round_manager.play_card("alien", value)


func poke_left():
	_poke(true)


func poke_right():
	_poke(false)


func _poke(left: bool):
	if not $PokedTimer.is_stopped():
		return

	if left:
		state = Enums.EnemyState.POKED_LEFT
	else:
		state = Enums.EnemyState.POKED_RIGHT

	$PokedTimer.start()
	await $PokedTimer.timeout

	state = Enums.EnemyState.ANGRY
	en_instance_de_se_faire_chopper = NB_FRAMES_TO_LOSE - 60
