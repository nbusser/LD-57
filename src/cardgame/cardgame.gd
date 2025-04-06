class_name CardGame
extends Node


class RoundManager:
	const DECK_SIZE: int = 21
	const HAND_SIZE: int = 3
	const DEFAULT_DECK: Array = [1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 0, 0, 0, -2, -2, -2]
	var my_deck: Array = []
	var alien_deck: Array = []
	#Sur le batteField c'est : {"player": "player", "card": 1}
	var battle_field: Array = []
	var first_player: bool = false
	var alien_hand: Array = []
	var alien_life: int = 20
	var player_life: int = 20

	#On setup le deck du joueur et de l'alien
	func setup_decks(player_deck_arg: Array = [], alien_deck_arg: Array = []) -> void:
		#On setup le deck du joueur
		if player_deck_arg.size() == 0:
			my_deck = DEFAULT_DECK.duplicate()
		else:
			my_deck = player_deck_arg.duplicate()
		#On setup le deck de l'alien
		if alien_deck_arg.size() == 0:
			alien_deck_arg = DEFAULT_DECK.duplicate()
		else:
			alien_deck_arg = alien_deck_arg.duplicate()
		#On mélange les decks
		my_deck.shuffle()
		alien_deck_arg.shuffle()

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
		battle_field.append({"player": player, "card": card})

	# Fonction pour faire piocher l'alien à partir de la fonction draw_cards et de alien_hand
	func alien_draw_cards(count: int) -> void:
		alien_hand = draw_cards(alien_deck, count)

	# Fonction pour faire jouer l'alien
	func alien_play_card() -> void:
		var card_to_play: int = alien_hand.pop_back()
		play_card("alien", card_to_play)

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
