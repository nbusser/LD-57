
class_name CardGame
extends Node

class RoundManager:
	const DECK_SIZE: int = 21
	const HAND_SIZE: int = 3
	const DEFAULT_DECK: Array = [1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,0,0,0,-2,-2,-2]
	var myDeck: Array = []
	var alienDeck: Array = []
	#Sur le batteField c'est : {"player": "player", "card": 1}
	var battleField: Array = []
	var firstPlayer: bool = false
	var alienHand: Array = []
	var alienLife: int = 20
	var playerLife: int = 20

	#On setup le deck du joueur et de l'alien
	func setup_decks(playerDeckArg: Array = [], alienDeckArg: Array = []) -> void:
		#On setup le deck du joueur
		if playerDeckArg.size() == 0:
			myDeck = DEFAULT_DECK.duplicate()
		else:
			myDeck = playerDeckArg.duplicate()
		#On setup le deck de l'alien
		if alienDeckArg.size() == 0:
			alienDeckArg = DEFAULT_DECK.duplicate()
		else:
			alienDeckArg = alienDeckArg.duplicate()
		#On mélange les decks
		myDeck.shuffle()
		alienDeckArg.shuffle()

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
		battleField.append({"player": player, "card": card})

	# Fonction pour faire piocher l'alien à partir de la fonction draw_cards et de alienHand
	func alien_draw_cards(count : int) -> void:
		alienHand = draw_cards(alienDeck, count)

	# Fonction pour faire jouer l'alien
	func alien_play_card() -> void:
		var card_to_play: int = alienHand.pop_back()
		play_card("alien", card_to_play)

	#Résolution du combat
	func battle()-> bool:
		var wasFirst = firstPlayer
		var player_score = battleField[0]["card"] if battleField[0]["player"] == "player" else 0
		var alien_score = battleField[0]["card"] if battleField[0]["player"] == "alien" else 0

		#CAS SPECIAL ETOILE ET -2
		if alien_score == 0 or player_score == 0:
			#2 étoiles
			if alien_score == 0 and player_score == 0:
				if wasFirst:
					playerLife -= 5
				else:
					alienLife -= 5
				#Les roles s'inversent
				firstPlayer = not wasFirst
			elif alien_score == 0:
				#L'alien a joué une étoile
				firstPlayer = true
				if player_score == -2:
					alienLife -= 2
			elif player_score == 0:
				#Le joueur a joué une étoile
				firstPlayer = false
				if alien_score == -2:
					playerLife -= 2

		#CAS SPECIAL -2 ET 5
		elif (alien_score == -2 and player_score == 5) or (player_score == -2 and alien_score == 5):
			if alien_score == -2:
				playerLife -= 5  # Alien perd 7 points de vie
				firstPlayer = false
			else:
				alienLife -= 5  # Joueur perd 7 points de vie
				firstPlayer = true
				
		#CAS NORMAL
		else:
			#On retire les points de vie
			firstPlayer = false if player_score > alien_score else true
			if player_score > alien_score:
				#Le joueur perd
				playerLife -= player_score - alien_score
			elif alien_score > player_score:
				#L'alien perd
				alienLife -= alien_score - player_score
			else:
				#Egalité
				#Ouai dark sasukesouke
				pass
			
		return firstPlayer

	#Trouver un moyen de detecter la fin de partie.
	#Toutes les données sont accessible depuis la classe la
