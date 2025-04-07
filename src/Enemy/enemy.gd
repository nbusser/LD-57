extends Node3D

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
@onready var batte_field_zone = $"../Snapper/CardsInBattleField"
@onready var card_game: Node = $"../cardgame"


func _update_sprite():
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
		[Enums.EnemyType.PIG, _]:
			animated_sprite_3d.play("pig_idle")


func _ready() -> void:
	_update_sprite()


func _alien_draw_card(card_instance: Node3D) -> void:
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
	card_inst.rotation = Vector3(0, 0, 0)
	card_inst.init(value)
	#On la place à un endroit la tavu
	batte_field_zone.add_child(card_inst)
	card_inst.position = Vector3(0, 0, 0.1)

	card_game.round_manager.play_card("alien", value)
	#TODO REGLER L INSTANCE DE LA CARTE
