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
