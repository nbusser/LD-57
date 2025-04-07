extends Node3D

signal player_caught_cheating

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
		or state == Enums.EnemyState.POKED
	):
		Globals.enemy_state = Globals.BaseEnemyState.DISTRACTED
	elif state == Enums.EnemyState.ANGRY:
		Globals.enemy_state = Globals.BaseEnemyState.ANGRY
	else:
		Globals.enemy_state = Globals.BaseEnemyState.IDLE

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
		[Enums.EnemyType.SPROINK, Enums.EnemyState.POKED]:
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
		[Enums.EnemyType.PIG, Enums.EnemyState.POKED]:
			animated_sprite_3d.play("pig_poked")
		[Enums.EnemyType.PIG, _]:
			animated_sprite_3d.play("pig_idle")


func _ready() -> void:
	_update_sprite()
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
var en_instance_de_se_faire_chopper = 0

const NB_FRAMES_TO_LOSE = 140
var en_instance_de_se_faire_virer = 0
# gdlint:enable = class-definitions-order


func _process(_delta: float) -> void:
	if (
		(state == Enums.EnemyState.IDLE or state == Enums.EnemyState.ANGRY)
		&& Globals.action_state == Globals.ActionState.ILLEGAL
	):
		if state == Enums.EnemyState.IDLE:
			en_instance_de_se_faire_chopper += 1
			if en_instance_de_se_faire_chopper >= NB_FRAMES_TO_GET_CAUGHT:
				en_instance_de_se_faire_chopper = 0
				state = Enums.EnemyState.ANGRY
		elif state == Enums.EnemyState.ANGRY:
			en_instance_de_se_faire_virer += 1
			if en_instance_de_se_faire_virer >= NB_FRAMES_TO_LOSE:
				en_instance_de_se_faire_virer = 0
				state = Enums.EnemyState.ANGRY
				emit_signal("player_caught_cheating")
		else:
			assert(false, "Invalid state, bourricot")
	else:
		en_instance_de_se_faire_chopper = max(0, en_instance_de_se_faire_chopper - 1)
		en_instance_de_se_faire_virer = max(0, en_instance_de_se_faire_virer - 1)


func alien_draw_card(card_instance: Node3D) -> void:
	await get_tree().create_timer(1.0).timeout
	#TODO PLACEHOLDER DE L ALIEN QUI FAIT GENRE QU IL PREND UNE CARTE
	#PEUT ETRE QU IL FAUDRA FAIRE BOUGER SON BRAS OU QU IL FASSE LA GUEULE
	var card_value = card_instance.get("card_value")
	var initial_state = state
	state = Enums.EnemyState.THINKING
	await get_tree().create_timer(3.0).timeout
	if initial_state != Enums.EnemyState.THINKING:
		state = initial_state
	card_instance.queue_free()


func alien_think_about_card(hand, battle_field: Array) -> int:
	#Fonction appelée par le cardgame pour trigger une carte de l'alien
	#TODO : faire un algo de choix de carte
	#Pour l'instant on va juste prendre la première carte de la main de l'alien
	#On récupère le premier joueur pour savoir si on joue une carte en contre ou pas
	#Y REFLECHI
	await get_tree().create_timer(1.0).timeout
	battle_field = battle_field
	if hand.size() > 0:
		return hand[0]
	return -1


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
		card_inst, "global_position", Vector3(drop_zone_enemy.global_position), 1
	)
	tween.parallel().tween_property(card_inst, "rotation", Vector3(5 * PI / 2, 0, 0), .7)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_callback(
		func():
			for node in previous_cards:
				node.call_deferred("queue_free")
	)

	card_game.round_manager.play_card("alien", value)
	#TODO REGLER L INSTANCE DE LA CARTE


func poke_left():
	print("poke left")


func poke_right():
	print("poke right")
