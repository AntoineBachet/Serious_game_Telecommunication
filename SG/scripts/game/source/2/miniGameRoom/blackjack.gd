extends Control

const cardsRef = ["hA","h2","h3","h4","h5","h6","h7","h8","h9","h10","hJ","hQ","hK", 
"sA","s2","s3","s4","s5","s6","s7","s8","s9","s10","sJ","sQ","sK",
"dA","d2","d3","d4","d5","d6","d7","d8","d9","d10","dJ","dQ","dK",
"cA","c2","c3","c4","c5","c6","c7","c8","c9","c10","cJ","cQ","cK"]
var cards = []

var hearts = preload("res://assets/game/source/2/casino/coeur.png")
var spades = preload("res://assets/game/source/2/casino/pique.png")
var diamonds = preload("res://assets/game/source/2/casino/carreau.png")
var clubs = preload("res://assets/game/source/2/casino/trefle.png")
var suitsImages = {"s": spades, "h": hearts, "d": diamonds, "c": clubs}

var dealerScore
var dealerVisibleScore
var dealerCards
var playerScore
var playerCards

var roundCounter

var t

var dealerMoney
var playerMoney
const bet = 10

######## Initialisation ########
func _ready():
	global.set_details({"area":"source", "level":"2", "scene":"miniGameRoom"})

	#### Affichage et traduction des textes ####
	get_node("dealerCards/Label").set_text(global.get_game_text("blackjackDealer"))
	get_node("playerCards/Label").set_text(global.get_game_text("blackjackPlayer"))
	get_node("card").set_text(global.get_game_text("blackjackHit"))
	get_node("stop").set_text(global.get_game_text("blackjackStand"))
	get_node("new").set_text(global.get_game_text("blackjackNewRound"))
	get_node("newGame").set_text(global.get_game_text("blackjackNewGame"))
	get_node("rulesButton").set_text(global.get_game_text("blackjackRulesTitle"))
	get_node("rulesDialog").set_title(global.get_game_text("blackjackRulesTitle"))
	get_node("rulesDialog").set_text(global.get_game_text("blackjackRules"))
	get_node("money/labelBox/playerLabel").set_text(global.get_game_text("blackjackPlayer"))
	get_node("money/labelBox/dealerLabel").set_text(global.get_game_text("blackjackDealer"))
	get_node("money/moneyLabel").set_text(global.get_game_text("blackjackMoney"))
	get_node("roundCounter/roundCounterLabel").set_text(global.get_game_text("blackjackRound"))

	#### Préparation ####
	get_node("gameInfo").set_use_bbcode(true)
	t = Timer.new()
	t.set_wait_time(1)	
	t.set_one_shot(true)
	self.add_child(t)
	get_node("rulesDialog").get_children()[1].set_autowrap(true)

	#### Lancement du jeu ####
	randomize()

#	new_game()

	get_node("new").set_disabled(true)
	get_node("new").set_default_cursor_shape(0)
	get_node("newGame").set_disabled(false)
	get_node("newGame").set_default_cursor_shape(2)
	get_node("card").set_disabled(true)
	get_node("card").set_default_cursor_shape(0)
	get_node("stop").set_disabled(true)
	get_node("stop").set_default_cursor_shape(0)

	set_process(true)
####################

func _process(delta):
	if global.get_used_item() != "":
		global.set_used_item("")

######## Gagner/perdre une manche ########
func win():
	dealerMoney -= bet
	playerMoney += bet
	update_money_display()
	if dealerMoney > 0:
		get_node("card").set_disabled(true)
		get_node("card").set_default_cursor_shape(0)
		get_node("stop").set_disabled(true)
		get_node("stop").set_default_cursor_shape(0)
		get_node("new").set_disabled(false)
		get_node("new").set_default_cursor_shape(2)
	else:
		get_node("new").set_disabled(true)
		get_node("new").set_default_cursor_shape(0)
		t.start()
		yield(t, "timeout")
		t.start()
		yield(t, "timeout")
		display_info(global.get_game_text("blackjackWinGame"))
		riddle_solved()

func lose():
	playerMoney -= bet
	dealerMoney += bet
	update_money_display()
	if playerMoney > 0:
		get_node("card").set_disabled(true)
		get_node("card").set_default_cursor_shape(0)
		get_node("stop").set_disabled(true)
		get_node("stop").set_default_cursor_shape(0)
		get_node("new").set_disabled(false)
		get_node("new").set_default_cursor_shape(2)
	else:
		get_node("new").set_disabled(true)
		get_node("new").set_default_cursor_shape(0)
		player.play_sound("wrong")
		t.start()
		yield(t, "timeout")
		t.start()
		yield(t, "timeout")
		display_info(global.get_game_text("blackjackLoseGame"))
		get_node("newGame").set_disabled(false)
		get_node("newGame").set_default_cursor_shape(2)
####################

func update_money_display():
	get_node("money/moneyBox/playerMoney").set_text(str(playerMoney))
	get_node("money/moneyBox/dealerMoney").set_text(str(dealerMoney))

######## Donner une carde à who, face visible ou non, as ou non, et l'afficher ########
func add_card(who, hidden = false, notAce = false):
	var card = draw_card()
	
	var cardName = card.substr(1, card.length()-1)
	var cardValue

	# Empêcher la distribution de deux as au départ par flemme de rajouter le split et le choix de la valeur de l'as ?
	if notAce:
		while cardName == "A":
			cards.append(card)
			card = draw_card()
			cardName = card.substr(1, card.length()-1)

	if cardName == "A":
		cardValue = 11
	elif cardName in ["K", "Q", "J"]:
		cardValue = 10
	else:
		cardValue = int(cardName)
	
	if who == "player":
		playerScore += cardValue
		playerCards.append(card)
		get_node("playerCards/score").set_text(str(playerScore))
	elif who == "dealer":
		dealerScore += cardValue
		dealerCards.append(card)
		if !hidden:
			dealerVisibleScore += cardValue
		get_node("dealerCards/score").set_text(str(dealerVisibleScore))

	display_card(card, who, hidden)
####################

######## Boutons Carte, Rester, Nouvelle manche, Nouvelle partie ########
func _on_card_pressed():
	get_node("card").set_disabled(true)
	get_node("card").set_default_cursor_shape(0)
	get_node("stop").set_disabled(true)
	get_node("stop").set_default_cursor_shape(0)
	t.start()
	yield(t, "timeout")
	add_card("player")
	if playerScore > 21:
		lose()
		display_info(global.get_game_text("blackjackBustPlayer"))
		show_dealer_cards()
	elif playerScore == 21:
		_on_stop_pressed()
	else:
		get_node("card").set_disabled(false)
		get_node("card").set_default_cursor_shape(2)
		get_node("stop").set_disabled(false)
		get_node("stop").set_default_cursor_shape(2)

func _on_stop_pressed():
	get_node("card").set_disabled(true)
	get_node("card").set_default_cursor_shape(0)
	get_node("stop").set_disabled(true)
	get_node("stop").set_default_cursor_shape(0)
	while dealerScore < 17:
		t.start()
		yield(t, "timeout")
		add_card("dealer", true)
	t.start()
	yield(t, "timeout")
	show_dealer_cards()
	
	if dealerScore > 21:
		display_info(global.get_game_text("blackjackBustDealer"))
		win()
	else:
		compare_scores()
####################

######## Comparaison des scores quand la défaite n'est pas immédiatement visible ########
func compare_scores():
	if playerScore > dealerScore:
		win()
		if playerScore == 21 and playerCards.size() == 2:
			win()
			display_info(global.get_game_text("blackjackBlackjackPlayer"))
		else:
			display_info(global.get_game_text("blackjackWinPlayer"))
	elif playerScore < dealerScore:
		lose()
		if dealerScore == 21 and dealerCards.size() == 2:
			lose()
			display_info(global.get_game_text("blackjackBlackjackDealer"))
		else:
			display_info(global.get_game_text("blackjackWinDealer"))
	else:
		if playerScore == 21:
			if playerCards.size() == 2 and dealerCards.size() == 2:
				display_info(global.get_game_text("blackjackDoubleBlackjack"))
				win()
				lose()
			elif playerCards.size() == 2 and dealerCards.size() > 2:
				display_info(global.get_game_text("blackjackBlackjackPlayer"))
				win()
				win()
			elif dealerCards.size() == 2 and playerCards.size() > 2:
				display_info(global.get_game_text("blackjackBlackjackDealer"))
				lose()
				lose()
			else:
				display_info(global.get_game_text("blackjackDraw"))
				win()
				lose()
		else:
			display_info(global.get_game_text("blackjackDraw"))
			win()
			lose()
####################

func _on_new_pressed():
	new_round()

func _on_newGame_pressed():
	new_game()

######## Nouvelle manche ########
func new_round():
	get_node("new").set_disabled(true)
	get_node("new").set_default_cursor_shape(0)
	get_node("card").set_disabled(true)
	get_node("card").set_default_cursor_shape(0)
	get_node("stop").set_disabled(true)
	get_node("stop").set_default_cursor_shape(0)

	display_info("")

	dealerScore = 0
	dealerVisibleScore = 0
	dealerCards = []

	playerScore = 0
	playerCards = []

	roundCounter += 1

	get_node("roundCounter/roundCounter").set_text(str(roundCounter))
	get_node("dealerCards/score").set_text("0")
	get_node("playerCards/score").set_text("0")

	remove_cards("player")
	remove_cards("dealer")

	# Deux cartes pour le joueur, une carte visible et une carte masquée pour le croupier
	t.start()
	yield(t, "timeout")
	add_card("player")
	t.start()
	yield(t, "timeout")
	add_card("dealer")
	t.start()
	yield(t, "timeout")
	add_card("player", false, true)
	t.start()
	yield(t, "timeout")
	add_card("dealer", true, true)

	get_node("card").set_disabled(false)
	get_node("card").set_default_cursor_shape(2)
	get_node("stop").set_disabled(false)
	get_node("stop").set_default_cursor_shape(2)

	if playerScore == 21:
		_on_stop_pressed()
####################

######## Afficher une carte, face visible ou non, devant who ########
func display_card(card, who, hidden = false):
	var cardSuit = card.substr(0, 1)
	var cardSuitImage = suitsImages[cardSuit]
	var cardName = card.substr(1, card.length()-1)

	var cardBox = VBoxContainer.new()

	var cardImage = TextureFrame.new()
	cardImage.set_texture(cardSuitImage)

	var cardLabel = Label.new()
	cardLabel.set_text(cardName)
	cardLabel.set_align(1)

	cardBox.add_child(cardImage)
	cardBox.add_child(cardLabel)

	if who == "player":
		get_node("playerCards").add_child(cardBox)
	elif who == "dealer":
		if hidden:
			cardImage.set_texture(null)
			cardLabel.set_text("?")
		get_node("dealerCards").add_child(cardBox)
####################

######## Affichage de texte décrivant le déroulement de la partie ########
func display_info(text):
	get_node("gameInfo").set_bbcode(text)
#	get_node("riddleOverlay").set_text(text)
#	print(text)
####################

######## Nouvelle partie ########
func new_game():
	get_node("newGame").set_disabled(true)
	get_node("newGame").set_default_cursor_shape(0)

	dealerMoney = 50
	playerMoney = 50

	roundCounter = 0
	
	update_money_display()
	new_round()
####################

######## Enlever toutes les cartes de devant un des deux joueurs ########
func remove_cards(who):
	var cardsList
	if who == "player":
		cardsList = get_node("playerCards")
	elif who == "dealer":
		cardsList = get_node("dealerCards")

	for i in range(2, cardsList.get_children().size()):
		cardsList.remove_child(cardsList.get_children()[2])
####################

######## Retourner les cartes du croupier et afficher son score ########
func show_dealer_cards():
	remove_cards("dealer")
	for card in dealerCards:
		display_card(card, "dealer")
	get_node("dealerCards/score").set_text(str(dealerScore))
####################

######## Tirage d'une carte ########
func draw_card():
	if cards.size() < 17: # Pour qu'on ne risque pas, par terrible malchance, de se retrouver coincé avec 16 as
		cards = cardsRef + cardsRef + cardsRef + cardsRef # Paquet de cartes tout neuf

	var rand = randi()%cards.size()
	var card = cards[rand]
	cards.remove(rand)
	return card
####################

######## Bouton de triche ########
func cheat():
	riddle_solved()
####################

######## Partie gagnée ########
func riddle_solved():
	global.give_item("source_2_miniGameRoom_sparePart")
	get_node("riddleOverlay").riddle_solved(3)
####################

######## Affichage des règles ########
func _on_rules_pressed():
	get_node("rulesDialog").popup_centered_ratio(0.6)
####################