extends Node2D

var answer = ""
var current = "aaaa"
var nul_char = 'a'
var current_z = 1

var riddle
var first_seen = false

func _ready():
	global.set_details({"area":"source", "level":"3", "scene":"shop"})

	set_process(true)
	#set_process_input(true)

	if global.get_used_item() == "source_3_shop_tiles":
		get_node("riddleOverlay").set_tip_list( [global.get_game_text("tile_riddle2Tip1"), global.get_game_text("tile_riddle2Tip2")] )
	else:
		_hide_tiles()
		get_node("riddleOverlay").set_tip( global.get_game_text("tile_riddle2Tip_noTiles") )
		

	global.set_state("source_3_shop_tileMoving", false)

	riddle = global.get_riddle("tile2")
	var index_answer
	
	if !global.get_state("source_3_shop_tileRiddle2RandomNumber"):
		first_seen = true
		randomize()
		index_answer = randi()%(riddle["possibilities"].size())
		global.set_state("source_3_shop_tileRiddle2RandomNumber", str(index_answer))
	else:
		index_answer = int( global.get_state("source_3_shop_tileRiddle2RandomNumber") )
	
	answer = riddle["possibilities"][index_answer]
	get_node("riddle").set_text(riddle["riddle"])
	
	get_node("validateButton").set_text( global.get_gui_text("validateButton") )
	get_node("validateButton").connect("pressed", self, "_on_validate_pressed")
	get_node("validateButton").set_default_cursor_shape(2)
	
	for i in range(5):
		for t in get_tree().get_nodes_in_group("type"+str(i)):
			t.set_type(i)
			t.connect("release", self, "_on_tile_release", [t, i])

func _process(delta):
	if global.get_used_item() != "":
		if global.get_used_item() == "source_3_shop_tiles":
			_show_tiles()
		global.set_used_item("")

func _on_validate_pressed():
	if current == answer:
		if !first_seen:
			win()
			set_process(false)
		else: ### On force le joueur à se tromper la première fois
			first_seen = false
			get_node("riddleOverlay").set_text( global.get_game_text("tile_riddle2Wrong") )
			var index_answer = randi()%(riddle["possibilities"].size())
			while str(index_answer) == global.get_state("source_3_shop_tileRiddle2RandomNumber"):
				index_answer = randi()%(riddle["possibilities"].size())
			answer = riddle["possibilities"][index_answer]
			print(answer)
			global.set_state("source_3_shop_tileRiddle2RandomNumber", str(index_answer))
	else:
		if first_seen:
			get_node("riddleOverlay").set_text( global.get_game_text("tile_riddle2Wrong") )
			first_seen = false
		player.play_sound("wrong")
		get_node("riddleOverlay").set_text( global.get_game_text("tile_riddle2Lose") )

func win():
	global.set_state("source_3_shop_tileRiddle2Solved", true)
	get_node("riddleOverlay").set_text( global.get_game_text("tile_riddle2Win") )
	global.give_item("source_3_shop_chocolate")
	get_node("riddleOverlay").riddle_solved(2)

func cheat():
	first_seen = false
	current = answer
	### Rangement
	for i in range(5):
		for t in get_tree().get_nodes_in_group("type"+str(i)):
			_move_tile(t, get_node("heap"+str(i)))
	
	var taken_tiles = [0,0,0,0,0]
	for i in range(4):
		var type = int( answer[i] )
		var tile_to_move = get_node("tiles"+str(type)+"/tile"+str(type)+"_"+str(taken_tiles[type]))
		taken_tiles[type] += 1
		_move_tile( tile_to_move, get_node("answer/answer"+str(i)))
		tile_to_move.connect("taken", self, "_on_tile_taken", [tile_to_move, i])



func _on_tile_release(tile, type):
	### On remet la tuile dans le tas
	if tile.get_node("hitbox").overlaps_area( get_node("heap"+str(type)) ):
		_move_tile(tile, get_node("heap"+str(type)))
	
	### On met la tuile dans une zone de réponse
	else:
		for ans in get_tree().get_nodes_in_group("answer"):
			if tile.get_node("hitbox").overlaps_area(ans):
				var index = int( ans.get_name()[-1] )
				if current[index] == nul_char: ## On place la tuile s'il n'y a pas déjà une tuile en place
					_move_tile(tile, ans)
					current[index] = str(type)
					
					tile.connect("taken", self, "_on_tile_taken", [tile, index])

### Mise à jour de la réponse quand on enlève une tuile qui était dans une zone de réponse
func _on_tile_taken(tile, index):
	tile.disconnect("taken", self, "_on_tile_taken")
	current[index] = nul_char

### Placement des tuiles bien au centre
func _move_tile(tile, destination):
	var tween = get_node("Tween")
	var animationDuration = 0.15
	var startPos = tile.get_pos()
	var endPos = destination.get_pos()

	tween.interpolate_property(tile, "transform/pos", startPos, endPos, animationDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _hide_tiles():
	for i in range(5):
		get_node("heap"+str(i)).hide()
		get_node("tiles"+str(i)).hide()

func _show_tiles():
	get_node("riddleOverlay").set_tip_list( [global.get_game_text("tile_riddle2Tip1"), global.get_game_text("tile_riddle2Tip2")] )
	for i in range(5):
		get_node("heap"+str(i)).show()
		get_node("tiles"+str(i)).show()