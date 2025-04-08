class_name CardGame
extends Node

signal card_spawned_on_the_deck(card: Card)
signal player_lost
signal player_won
signal alien_played_card(card: int)

enum GameState {
	NOT_STARTED,
	INIT,
	DRAW,
	WAITING_FOR_RECUP,
	WHOS_FIRST,
	PLAYER_TURN,
	ALIEN_TURN,
	BATTLE,
	GAME_OVER,
	WIN,
	SHOP,
	IS_GAME_END
}

enum Side { PLAYER, ALIEN }

const HP_TO_SHOP: int = 8

var current_state: GameState = GameState.NOT_STARTED
var precedent_state: GameState = current_state
var round_manager: RoundManager = null
var timer_in_progress: bool = false

@onready var player_deck_node = get_node("../deckManager/deckObjectPlayer")
@onready var alien_deck_node = get_node("../deckManager/deckObjectAlien")
@onready var card_scene = preload("res://src/Card/Card.tscn")
@onready var the_alien = get_node("../Enemy")
@onready var cards_manager = $"../CardsManager"
@onready var player_snapper = $"../Snapper"
@onready var snapper = $"../Snapper/CardsInBattleField"
@onready var enemy_snapper = $"../EnemySnapper/CardsInBattleField"
@onready var timer = $"StepTimer"
@onready var _cards_sfx: AudioBankPlayer = $"../SFX/Card"


func game_state_to_string(gs: GameState):
	match gs:
		GameState.NOT_STARTED:
			return "NOT_STARTED"
		GameState.INIT:
			return "INIT"
		GameState.DRAW:
			return "DRAW"
		GameState.WAITING_FOR_RECUP:
			return "WAITING_FOR_RECUP"
		GameState.WHOS_FIRST:
			return "WHOS_FIRST"
		GameState.PLAYER_TURN:
			return "PLAYER_TURN"
		GameState.ALIEN_TURN:
			return "ALIEN_TURN"
		GameState.BATTLE:
			return "BATTLE"
		GameState.GAME_OVER:
			return "GAME_OVER"
		GameState.WIN:
			return "WIN"


func setup_and_start_timer(duration: float) -> bool:
	if timer_in_progress:
		#print(timer.time_left)
		if timer.is_stopped():
			timer_in_progress = false
			return true
		return false

	timer.start(duration)
	timer_in_progress = true
	return false


class RoundManager:
	signal life_changed(side: Side, value: int)

	const DECK_SIZE: int = 21
	const HAND_SIZE: int = 3
	const DEFAULT_DECK: Array = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 0, 0, 0, -2, -2, -2]
	var my_custom_deck: Array = []
	var my_deck: Array = []
	var alien_deck: Array = []
	#Sur le battle_field c'est : {"player": "player", "card": 1}
	var battle_field: Array = []
	var first_player: bool = true
	var alien_hand: Array = []
	var hp_until_shop: int = 0
	var alien_life: int = 20:
		set(value):
			alien_life = value
			life_changed.emit(Side.ALIEN, value)
	var player_life: int = 20:
		set(value):
			player_life = value
			life_changed.emit(Side.PLAYER, value)
	var alien_playing: bool = false

	#On setup le deck du joueur et de l'alien
	func setup_decks(player_deck_arg: Array = [], alien_deck_arg: Array = []) -> void:
		#On setup le deck du joueur
		if player_deck_arg.size() == 0:
			my_deck = DEFAULT_DECK.duplicate()
		else:
			my_deck = player_deck_arg.duplicate()
		#On setup le deck de l'alien
		if alien_deck_arg.size() == 0:
			alien_deck = DEFAULT_DECK.duplicate()
		else:
			alien_deck = alien_deck_arg.duplicate()
		#On mélange les decks
		my_deck.shuffle()
		alien_deck.shuffle()

	#Fonciton pour piocher X cartes
	func draw_cards(deck: Array, count: int) -> Array:
		var drawn_cards: Array = []
		for i in range(count):
			if deck.size() > 0:
				var card: int = deck[0]
				deck.remove_at(0)
				drawn_cards.append(card)
			else:
				break
		return drawn_cards

	# Fonction pour jouer une carte sur le champ de bataille
	func play_card(player: String, card: int) -> void:
		battle_field.append({"player": player, "card": card})

	#Résolution du combat
	func battle() -> bool:
		var explanation = ""
		var was_first = first_player
		var player_score = -99
		var alien_score = -99
		var before_hp_player = player_life
		var before_hp_alien = alien_life
		for card in battle_field:
			if card["player"] == "player":
				player_score = card["card"]
			elif card["player"] == "alien":
				alien_score = card["card"]
		#CAS SPECIAL ETOILE ET -2
		if alien_score == 0 or player_score == 0:
			#2 étoiles
			if alien_score == 0 and player_score == 0:
				if was_first:
					explanation += ("I countered your star. You lose 5 points.")
					player_life -= 5
				else:
					explanation += ("You countered my star. I lose 5 points.")
					alien_life -= 5
				#Les roles s'inversent
				first_player = not was_first
				explanation += (" We swap playing order.")
			elif alien_score == 0:
				#L'alien a joué une étoile
				first_player = true
				if player_score == -2:
					explanation += ("I lose 2 points and you get to go first.")
					alien_life -= 2
			elif player_score == 0:
				#Le joueur a joué une étoile
				first_player = false
				if alien_score == -2:
					player_life -= 2
					explanation += ("You lose 2 points and I get to go first.")

		#CAS SPECIAL -2 ET 5
		elif (alien_score == -2 and player_score == 5) or (player_score == -2 and alien_score == 5):
			if alien_score == -2:
				player_life -= 5  # Alien perd 7 points de vie
				first_player = false
				explanation += ("Oh no, you countered my -2 with a 5! I lose 7 points. I will go first.")
			else:
				alien_life -= 5  # Joueur perd 7 points de vie
				first_player = true
				explanation += ("Ha! I countered your -2 with a 5! You lose 7 points. You will go first.")

		elif player_score == alien_score:
			#Les deux joueurs ont joué -2
			#On ne fait rien, on ne change pas de joueur
			first_player = was_first
			explanation += ("Well, that's a draw.")
			if first_player:
				explanation += (" You still go first!")
			else:
				explanation += (" I still go first!")
			print("Egalité")
		#CAS NORMAL
		else:
			#On retire les points de vie
			first_player = false if player_score > alien_score else true
			if player_score > alien_score:
				explanation += (
					str(player_score)
					+ " > "
					+ str(alien_score)
					+ ": I'm losing "
					+ str(player_score - alien_score)
					+ " points on this one! Loser goes first."
				)
				#Le joueur perd
				player_life -= player_score - alien_score
			elif alien_score > player_score:
				explanation += (
					str(alien_score)
					+ " > "
					+ str(player_score)
					+ ": you're losing "
					+ str(alien_score - player_score)
					+ " points on this one! Loser goes first."
				)
				#L'alien perd
				alien_life -= alien_score - player_score
			else:
				#Egalité
				explanation += ("Well, that's a draw. You go first.")
				#Ouai dark sasukesouke

		await (Globals.show_messages([explanation]))

		#On remet les cartes joués dans les decks
		#TODO Il faudrait faire un système propre, la on remet à la fin du coup on cycle sur les 21 cartes, une fois arrivé à la fin on va repiocher dans le même ordre
		#En vrai on s'en fout parce que généralement ça sera fini avant mais bon on peut changer dans le futur
		my_deck.append(player_score)
		alien_deck.append(alien_score)

		hp_until_shop += before_hp_alien - alien_life
		hp_until_shop += before_hp_player - player_life
		print("hp until shop: ", hp_until_shop)
		return first_player

	#Trouver un moyen de detecter la fin de partie.
	#Toutes les données sont accessible depuis la classe la


func _instantiate_card(is_player_card: bool, value: int) -> Node3D:
	var pos_reference_node: Node3D = player_deck_node if is_player_card else alien_deck_node

	var card_inst: Card = card_scene.instantiate()
	card_inst.rotation = Vector3(0, 0, PI)
	card_inst.init(value)

	if is_player_card:
		card_inst.add_to_group("grabbable_cards")
		cards_manager.cards_on_top_of_deck.add_child(card_inst)
	else:
		the_alien.alien_draw_card(card_inst)
		add_child(card_inst)

	card_inst.global_position = pos_reference_node.global_position + Vector3(0, .001, 0)

	return card_inst


func create_round_manager() -> RoundManager:
	round_manager = RoundManager.new()
	current_state = GameState.INIT
	return round_manager


func _process(delta: float) -> void:
	delta = delta
	if current_state != precedent_state:
		#print(game_state_to_string(current_state))
		precedent_state = current_state

	match current_state:
		GameState.NOT_STARTED:
			#On ne fait rien
			return

		GameState.INIT:
			round_manager.setup_decks(round_manager.my_custom_deck)
			for i in range(RoundManager.HAND_SIZE - 1):
				var card = round_manager.draw_cards(round_manager.my_deck, 1)
				_instantiate_card(true, card[0])

			for i in range(RoundManager.HAND_SIZE - 1):
				var card = round_manager.draw_cards(round_manager.alien_deck, 1)
				_instantiate_card(false, card[0])
				round_manager.alien_hand.append(card[0])

			#La distrubution des cartes est faite, on passe en DRAW
			current_state = GameState.DRAW

		GameState.DRAW:
			var card = TYPE_NIL
			card = round_manager.draw_cards(round_manager.my_deck, 1)
			_instantiate_card(true, card[0])
			card = round_manager.draw_cards(round_manager.alien_deck, 1)
			_instantiate_card(false, card[0])
			round_manager.alien_hand.append(card[0])

			current_state = GameState.WAITING_FOR_RECUP

		GameState.WAITING_FOR_RECUP:
			current_state = GameState.WHOS_FIRST

		GameState.WHOS_FIRST:
			if round_manager.first_player:
				current_state = GameState.PLAYER_TURN
			else:
				current_state = GameState.ALIEN_TURN
		GameState.PLAYER_TURN:
			player_snapper.is_playing = true
			for card in round_manager.battle_field:
				#On vérifie qu'on a bien posé la carte
				if card["player"] == "player":
					if round_manager.first_player:
						current_state = GameState.ALIEN_TURN
						cards_manager._is_card_close_to_battlefield = false
						player_snapper.is_playing = false
					else:
						current_state = GameState.BATTLE
						cards_manager._is_card_close_to_battlefield = false
						player_snapper.is_playing = false

		GameState.ALIEN_TURN:
			if !timer_in_progress:  # Start animation
				if not round_manager.alien_playing:
					round_manager.alien_playing = true
					var the_alien_choosen_card = await the_alien.alien_think_about_card(
						round_manager.alien_hand, round_manager.battle_field
					)
					round_manager.alien_hand.erase(the_alien_choosen_card)
					the_alien.alien_play_card(the_alien_choosen_card)
					alien_played_card.emit(the_alien_choosen_card)

			var timer_over = setup_and_start_timer(2.0)
			if !timer_over:
				return

			for card in round_manager.battle_field:
				#On vérifie qu'on a bien posé la carte
				if card["player"] == "alien":
					round_manager.alien_playing = false
					if not round_manager.first_player:
						current_state = GameState.PLAYER_TURN
					else:
						current_state = GameState.BATTLE

		GameState.BATTLE:
			#On fait la bataille
			if !timer_in_progress:  # Start animation
				var tween = get_tree().create_tween()
				tween.set_trans(Tween.TRANS_CUBIC)
				tween.set_ease(Tween.EASE_IN)
				for card in enemy_snapper.get_children():
					tween.parallel().tween_property(
						card, "global_position", card.global_position + Vector3(.07, 0, 0), 1
					)
				for card in snapper.get_children():
					tween.parallel().tween_property(
						card, "global_position", card.global_position + Vector3(-.07, 0, 0), 1
					)
				tween.tween_callback(
					func():
						for node in snapper.get_children():
							node.call_deferred("queue_free")
						for node in enemy_snapper.get_children():
							node.call_deferred("queue_free")
				)

			var timer_over = setup_and_start_timer(3.0)
			if !timer_over:
				return
			round_manager.battle()
			round_manager.battle_field.clear()

			#Soit on va au shop, soit on fait un test de fin de partie
			if round_manager.player_life <= 0:
				player_lost.emit()
			elif round_manager.alien_life <= 0:
				player_won.emit()

			if round_manager.hp_until_shop >= HP_TO_SHOP:
				current_state = GameState.SHOP
			else:
				current_state = GameState.IS_GAME_END

		GameState.SHOP:
			#TODO FAIRE UN SHOP
			#C EST JUSTE GENRE 2 3 CARTES SUR LESQUELLES ONT PEUT CLIQUER CA EN PREND UNE ET CA LA MET DANS NOTRE MANCHE
			#SI ON A LE TEMPS CA SERAIT BIEN QUE L ALIEN PUISSE COMPTER COMBIEN DE CARTES ON A ET DEVIENNE DOUTEUX MAIS BON
			#IL FAUT RELIER CA AU NODE SHOP DEJA PRESENT ET MASQUE
			print("C'est l'heure du shopping")
			round_manager.hp_until_shop = 0
			#await get_tree().create_timer(3).timeout
			current_state = GameState.IS_GAME_END

		GameState.IS_GAME_END:
			if round_manager.player_life <= 0:
				current_state = GameState.GAME_OVER
			elif round_manager.alien_life <= 0:
				current_state = GameState.WIN
			else:
				current_state = GameState.DRAW
		_:
			return


func _on_cards_manager_card_added_in_sleeve(nb_cards_in_hand: int, nb_other_cards: int) -> void:
	if nb_cards_in_hand < round_manager.HAND_SIZE and nb_cards_in_hand + nb_other_cards < 6:
		var card = round_manager.draw_cards(round_manager.my_deck, 1)[0]
		_instantiate_card(true, card)
