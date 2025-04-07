class_name CardGame
extends Node

signal card_spawned_on_the_deck(card: Card)

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
	WIN
}

enum Side { PLAYER, ALIEN }

var current_state: GameState = GameState.NOT_STARTED
var precedent_state: GameState = current_state
var round_manager = null

@onready var player_deck_node = get_node("../deckManager/deckObjectPlayer")
@onready var alien_deck_node = get_node("../deckManager/deckObjectAlien")
@onready var card_scene = preload("res://src/Card/Card.tscn")
@onready var the_alien = get_node("../Enemy")
@onready var cards_manager = $"../CardsManager"


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
				var card: int = deck.pop_back()
				drawn_cards.append(card)
			else:
				break
		return drawn_cards

	# Fonction pour jouer une carte sur le champ de bataille
	func play_card(player: String, card: int) -> void:
		print("Player: ", player, " played card: ", card)
		battle_field.append({"player": player, "card": card})

	#Résolution du combat
	func battle() -> bool:
		var was_first = first_player
		var player_score = battle_field[0]["card"] if battle_field[0]["player"] == "player" else 0
		var alien_score = battle_field[0]["card"] if battle_field[0]["player"] == "alien" else 0

		#CAS SPECIAL ETOILE ET -2
		if alien_score == 0 or player_score == 0:
			#2 étoiles
			if alien_score == 0 and player_score == 0:
				if was_first:
					player_life -= 5
				else:
					alien_life -= 5
				#Les roles s'inversent
				first_player = not was_first
			elif alien_score == 0:
				#L'alien a joué une étoile
				first_player = true
				if player_score == -2:
					alien_life -= 2
			elif player_score == 0:
				#Le joueur a joué une étoile
				first_player = false
				if alien_score == -2:
					player_life -= 2

		#CAS SPECIAL -2 ET 5
		elif (alien_score == -2 and player_score == 5) or (player_score == -2 and alien_score == 5):
			if alien_score == -2:
				player_life -= 5  # Alien perd 7 points de vie
				first_player = false
			else:
				alien_life -= 5  # Joueur perd 7 points de vie
				first_player = true

		#CAS NORMAL
		else:
			#On retire les points de vie
			first_player = false if player_score > alien_score else true
			if player_score > alien_score:
				#Le joueur perd
				player_life -= player_score - alien_score
			elif alien_score > player_score:
				#L'alien perd
				alien_life -= alien_score - player_score
			else:
				#Egalité
				#Ouai dark sasukesouke
				pass

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
		the_alien._alien_draw_card(card_inst)
		add_child(card_inst)

	card_inst.global_position = pos_reference_node.global_position

	return card_inst


func create_round_manager() -> RoundManager:
	round_manager = RoundManager.new()
	current_state = GameState.INIT
	return round_manager


func _process(delta: float) -> void:
	delta = delta
	if current_state != precedent_state:
		print(current_state)
		precedent_state = current_state

	if current_state == GameState.NOT_STARTED:
		return

	if current_state == GameState.INIT:
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

	elif current_state == GameState.DRAW:
		var card = TYPE_NIL
		card = round_manager.draw_cards(round_manager.my_deck, 1)
		_instantiate_card(true, card[0])
		card = round_manager.draw_cards(round_manager.alien_deck, 1)
		_instantiate_card(false, card[0])
		round_manager.alien_hand.append(card)

		current_state = GameState.WAITING_FOR_RECUP

	elif current_state == GameState.WAITING_FOR_RECUP:
		#On attend que le joueur prenne les cartes, ici on met direct le bon truc
		#if blablabla

		current_state = GameState.WHOS_FIRST

	elif current_state == GameState.WHOS_FIRST:
		if round_manager.first_player:
			current_state = GameState.PLAYER_TURN
		else:
			current_state = GameState.ALIEN_TURN

	elif current_state == GameState.PLAYER_TURN:
		for card in round_manager.battle_field:
			#On vérifie qu'on a bien posé la carte
			if card["player"] == "player":
				if round_manager.first_player:
					current_state = GameState.ALIEN_TURN
				else:
					current_state = GameState.BATTLE

	elif current_state == GameState.ALIEN_TURN:
		#TODO RIGGER LE JEU DE L'ALIEN
		if not round_manager.alien_playing:
			round_manager.alien_playing = true
			var the_alien_choosen_card = await the_alien.alien_think_about_card(
				round_manager.alien_hand, round_manager.battle_field
			)
			the_alien.alien_play_card(the_alien_choosen_card)
		for card in round_manager.battle_field:
			#On vérifie qu'on a bien posé la carte
			if card["player"] == "alien":
				round_manager.alien_playing = false
				if not round_manager.first_player:
					current_state = GameState.PLAYER_TURN
				else:
					current_state = GameState.BATTLE

	elif current_state == GameState.BATTLE:
		#On fait la bataille
		round_manager.battle()
		if round_manager.player_life <= 0:
			current_state = GameState.GAME_OVER
		elif round_manager.alien_life <= 0:
			current_state = GameState.WIN
		else:
			current_state = GameState.DRAW
		print("Player life: ", round_manager.player_life)
		print("Alien life: ", round_manager.alien_life)
		round_manager.battle_field.clear()

		#TODO AJOUTER LE CLEAR DU CHAMP DE BATAILLE (INSTANCE SUR LA MAP)
		#TODO FAIRE LE WAIT FOR RECUP
		#TODO ANIMATION DE L ALIEN
		#TODO FAIRE GAFFE A LA FIN DU DECK SINON CA FAIT CRASH
		#TODO METTRE UN SWITCH
