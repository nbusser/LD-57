extends Node3D

enum EnemyType { SPROINK, PIG }
enum EnemyState { IDLE, WEAK, DISTRACTED }

var type: EnemyType = EnemyType.SPROINK:
	set(value):
		type = value
		_update_sprite()
var state: EnemyState = EnemyState.IDLE:
	set(value):
		state = value
		_update_sprite()

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var card_scene = preload("res://src/Card/Card.tscn")
@onready var batte_field_zone = $"../CardsInBattleField"
@onready var card_game: Node = $"../cardgame"


func _update_sprite():
	match [type, state]:
		# sproink
		[EnemyType.SPROINK, EnemyState.IDLE]:
			animated_sprite_3d.play("sproink_idle")
		[EnemyType.SPROINK, EnemyState.WEAK]:
			animated_sprite_3d.play("sproink_weak")
		[EnemyType.SPROINK, ..]:
			animated_sprite_3d.play("sproink_idle")
		# pig
		[EnemyType.PIG, EnemyState.DISTRACTED]:
			animated_sprite_3d.play("pig_distracted")
		[EnemyType.PIG, ..]:
			animated_sprite_3d.play("pig_distracted")


func _ready() -> void:
	_update_sprite()


func _alien_draw_card(card_instance: Node3D) -> void:
	await get_tree().create_timer(1.0).timeout
	#TODO PLACEHOLDER DE L ALIEN QUI FAIT GENRE QU IL PREND UNE CARTE
	#PEUT ETRE QU IL FAUDRA FAIRE BOUGER SON BRAS OU QU IL FASSE LA GUEULE
	var card_value = card_instance.get("card_value")
	animated_sprite_3d.play("pig_distracted")
	await get_tree().create_timer(3.0).timeout
	_update_sprite()
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
