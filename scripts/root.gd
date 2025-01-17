extends Node2D

var chessboard = ChessBoardWrapper.new_object(Utility.fein("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"));
const ALLOWED_DISTANCE = 35;

var chess_piece = preload("res://scene/pieces.tscn");
var hint_overlay_scene = preload("res://scene/hint_overlay.tscn");
var selected_overlay_scene = preload("res://scene/selected_overlay.tscn");
var promotion_gui_scene = preload("res://scene/promotion_gui.tscn");

var hint_overlay_list: Array;
var starting_point = Vector2(376, 116);
var spacing:float = 75.5;
var chess_piece_instance_list = [];
var can_manual:Array[int] = [1, 1];

var flipped_board = false;
var selected_overlay = selected_overlay_scene.instantiate();
var selected_promotion_overlay = selected_overlay_scene.instantiate();
var dark_overlay = selected_overlay_scene.instantiate();
var promotion_gui = promotion_gui_scene.instantiate();
var promotion_pieces: Array;

var chess_engine_white: SickDuckV0 = SickDuckV0.new_object();
var chess_engine_black: SickDuckV0 = SickDuckV0.new_object();

# <------------------------- Utility function start ------------------------->

func vector_to_pos(p: Vector2):
	if (flipped_board) :
		p.x = 7 - p.x;
		p.y = 7 - p.y;
	return Vector2(starting_point.x + p.y * spacing, starting_point.y + (7 - p.x) * spacing);
	
func get_cell(mouse_pos: Vector2):
	for i in chess_piece_instance_list:
		if (Utility.chebyshev_distance(i.position, mouse_pos) < ALLOWED_DISTANCE):
			return i.current_cell;
	return "None";
	
func get_viewport_size() -> Vector2:
	return get_viewport().size;
	
# <------------------------- Utility function end ------------------------->


	
# <------------------------- Misc (Idk how to categorize them) here ------------------------->
func update_label(is_white_move:bool):
	if is_white_move:
		$Infos/GameState.text = "White Turn";
	else:
		$Infos/GameState.text = "Black Turn";
# <------------------------- Misc ends  ------------------------->

# <------------------------- Rendering chessboard here  ------------------------->
func initialRender():
	for i in chess_piece_instance_list: 
		remove_child(i);
	chess_piece_instance_list.clear();
	for i in range(0, 8):
		for j in range(0, 8):
			var current_cell = Utility.vector_to_cell_index(Vector2(i, j));
			var cell_str = Utility.vector_to_cell_notation(Vector2(i, j));
			
			var chess_piece_instance = chess_piece.instantiate();
			chess_piece_instance_list.append(chess_piece_instance);
			add_child(chess_piece_instance);
			
			chess_piece_instance.position = vector_to_pos(Vector2(i, j));
			chess_piece_instance.set_current_cell(cell_str);

func renderBoard(chessboard):
	for i in range(0, 8):
		for j in range(0, 8):
			var current_cell = Utility.vector_to_cell_index(Vector2(i, j));
			chess_piece_instance_list[current_cell].set_type(chessboard.get_cell(current_cell));
			
# <------------------------- Rendering chessboard end  ------------------------->


# <------------------------- Rendering overlay here  ------------------------->


func initializeOverlay():
	var v = get_viewport_size();
	
	add_child(selected_overlay); 
	selected_overlay.all_in_one(false, Vector2(spacing, spacing), 0.5, 0);
	
	add_child(selected_promotion_overlay); 
	selected_promotion_overlay.all_in_one(false, Vector2(spacing, spacing), 0.2, 10);
	
	add_child(dark_overlay);
	dark_overlay.all_in_one(false, v, 0.3, 2);
	dark_overlay.position = Vector2(v.x / 2, v.y / 2);
	
	add_child(promotion_gui);
	promotion_gui.all_in_one(false, Vector2(spacing, spacing * 4), 1, 3);
	
	
			
func relocateOverlay(v: Vector2):
	if v.x == -1:
		selected_overlay.update_display(false);
	else:
		selected_overlay.update_display(true);
		selected_overlay.position = vector_to_pos(v);


func clear_hint_list():
	if (hint_overlay_list.size() == 0):
		return;
	for i in hint_overlay_list:
		remove_child(i);
		i.queue_free();
	hint_overlay_list.clear();
	
func update_hint_list(move_list):
	for i in move_list:
		var hint_instance = hint_overlay_scene.instantiate();
		
		hint_overlay_list.append(hint_instance);
		add_child(hint_instance);
		
		hint_instance.position = vector_to_pos(i);
		hint_instance.all_in_one(true, Vector2(0.6, 0.6), 0.5, 2);
		
		
func update_selected_cell(cur_cell: String):
	clear_hint_list();
	chessboard.selected_cell = cur_cell;
	if (cur_cell == ""):
		relocateOverlay(Vector2(-1, -1));
	else:
		relocateOverlay(Utility.cell_notation_to_vector(chessboard.selected_cell));
		var move_list = chessboard.generate_move_from_cell(Utility.cell_notation_to_int(chessboard.selected_cell));
		update_hint_list(move_list);
# <------------------------- Rendering overlay end  ------------------------->

# <------------------------- Sound stuff here  ------------------------->
func play_sound(arg:String):
	match arg:
		"Move":
			$SoundPack/PieceMoveSound.play();
		"Capture":
			$SoundPack/PieceCaptureSound.play();
		"Castle":
			$SoundPack/CastlingSound.play();
		"Promote":
			$SoundPack/PromoteSound.play();
		"NewGame":
			$SoundPack/NewGameSound.play();
		"EndGame":
			$SoundPack/EndGameSound.play();
		"Check":
			$SoundPack/CheckSound.play();
		_:
			print("Invalid Sound");
			
# <------------------------- Sound stuff ends  ------------------------->
			

# <------------------------- Handle Game Events Here  ------------------------->
		
func handle_check() -> bool:
	var cur = chessboard.is_white_move();
	if (chessboard.in_check(cur)):
		play_sound("Check");
		return true;
	return false;
	
func handle_normal_move(cell1: int, cell2: int):
	var is_capture = chess_piece_instance_list[cell2].current_piece != ".";
	
	chessboard.normal_move(cell1, cell2, true);
	renderBoard(chessboard);
	update_selected_cell("");
	
	if !handle_check():
		if is_capture :
			play_sound("Capture");
		else: 
			play_sound("Move");
	
func handle_castle(cell1: int, cell2: int):
	chessboard.castle(cell1, cell2);
	renderBoard(chessboard);
	update_selected_cell("");
	
	if !handle_check():
		play_sound("Castle");
	
func handle_enpassant(cell1: int, cell2: int):
	chessboard.en_passant(cell1, cell2);
	
	renderBoard(chessboard);
	update_selected_cell("");
	
	if !handle_check():
		play_sound("Capture");
	
func handle_promotion(cell1: int, cell2: int):
	var is_white = Utility.is_upper_case(chessboard.get_cell(cell1));
	chessboard.normal_move(cell1, cell2, false);
	renderBoard(chessboard);
	update_selected_cell("");
	
	create_promotion_pop_up(is_white, Utility.int_to_cell_vector(cell2));
	
func create_promotion_pop_up(is_white: bool, v: Vector2):
	clear_hint_list();
	dark_overlay.update_display(true);
	promotion_gui.update_display(true);
	
	v = vector_to_pos(v);
	var _v = Vector2(v.x, v.y - spacing * 1.5);
	if (is_white != flipped_board): 
		_v.y += spacing * 3;
	promotion_gui.position = _v;
	
	var arr: Array = ["q", "r", "b", "n"];
	for i in range(0, 4): 
		if is_white:
			arr[i] = arr[i].to_upper();
		var piece_instance = chess_piece.instantiate();
		promotion_pieces.append(piece_instance);
		add_child(piece_instance);
		
		piece_instance.set_type(arr[i]);
		var v1 = Vector2(v.x, v.y - spacing * i);
		if (is_white != flipped_board) :
			v1.y += 2 * spacing * i;
		piece_instance.set_sprite_layer(4);
		piece_instance.position = v1;
		
func promotion_call(cell: int, s: String):
	if s == "None":
		chessboard.roll_back();
	else:
		chessboard.promote(cell, s);
		if !handle_check():
			play_sound("Promote");
	renderBoard(chessboard);
	update_selected_cell("");
	
	dark_overlay.update_display(false);
	promotion_gui.update_display(false);
	for i in promotion_pieces:
		remove_child(i);
		i.queue_free();
	promotion_pieces.clear();
	
	check_game_ended();
	if (chessboard.is_continuing()):
		update_label(chessboard.is_white_move());
		
# <------------------------- Handle Game Events End  ------------------------->
	
	
# <------------------------- Handle Input  ------------------------->
func handling_mouse_press(mouse_pos: Vector2):
	var cur_cell = get_cell(mouse_pos);
	if (cur_cell != "None"):  # if clicked inside the chessboard
		var cur_signal = chessboard.press_on_cell(cur_cell);
		if (cur_signal.size() > 0):
			var cell1 = cur_signal[1]; var cell2 = cur_signal[2];
			match cur_signal[0]:
				0:
					handle_normal_move(cell1, cell2);
				1: 
					handle_castle(cell1, cell2);
				2:
					handle_enpassant(cell1, cell2);
				3:
					handle_promotion(cell1, cell2);
		update_selected_cell(chessboard.selected_cell);
	else: #cancel selected cell if clicked outside the chessboard
		update_selected_cell("");
		
	if (promotion_pieces.size() == 0) && (chessboard.selected_cell == ""):
		check_game_ended();
	if (chessboard.is_continuing()):
		update_label(chessboard.is_white_move());
		

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if chessboard.is_continuing() == false:
			return;
		if can_manual[int(chessboard.is_white_move())] == 0:
			return;
		var mouse_pos = get_viewport().get_mouse_position();
		if promotion_pieces.size() == 4: # are opening promotion box
			var chosen_piece = "None";
			for i in promotion_pieces:
				if (Utility.chebyshev_distance(i.position, mouse_pos) < ALLOWED_DISTANCE):
					chosen_piece = i.current_piece;
			promotion_call(chessboard.most_recent_move(1), chosen_piece);
		else:
			handling_mouse_press(mouse_pos);
			
		if (chessboard.is_continuing()):
			update_label(chessboard.is_white_move());

# <------------------------- Handle Input  ------------------------->

#var brah = ChessBoardWrapper.new(CsharpTest.fein("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"));
# Called when the node enters the scene tree for the first time.
func _ready():
	CsharpTest.sigma(Vector2(1, -1));
	
	initialRender();
	renderBoard(chessboard);
	initializeOverlay();
	
	dark_overlay.update_display(true);
	
	$OperationButton/FlipBoard.z_index = 10;
	$OperationButton/NewGame.z_index = 10;
	$OperationButton/UndoMove.z_index = 10;
	
	$GamemodeSwitcher/PvP.z_index = 10;
	$GamemodeSwitcher/PvE.z_index = 10;
	$GamemodeSwitcher/EvP.z_index = 10;
	$GamemodeSwitcher/EvE.z_index = 10;
	
	$Infos/GameState.z_index = 10;
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
var engine_check_timer = 0;
const DELAY = 0.01
var calculating:bool = false;
func _process(delta):
	engine_check_timer += delta;
	if (engine_check_timer >= DELAY):
		engine_check_timer = 0;
		if !calculating && chessboard.is_continuing() && can_manual[int(chessboard.is_white_move())] == 0:
			var start_time = Time.get_ticks_msec();
			var cur;
			calculating = true;
			if (chessboard.is_white_move()):
				cur = chess_engine_white.next_move(chessboard);
			else:
				cur = chess_engine_black.next_move(chessboard);
			calculating = false;
			var end_time = Time.get_ticks_msec();
			print("Time elapsed: ", end_time - start_time, "ms!");
			
			var what_to_play = "None";
			match cur.get_move_type():
				0:
					if (chessboard.get_cell(cur.get_move_des()) == "."):
						what_to_play = "Move";
					else:
						what_to_play = "Capture";
				1: 
					what_to_play = "Castle";
				2: 
					what_to_play = "Capture";
				3:
					what_to_play = "Promote";
			chessboard.do_move(cur);
			if handle_check():
				what_to_play = "Check";
			play_sound(what_to_play);
			renderBoard(chessboard);
			check_game_ended();
			
			
	if promotion_pieces.size() == 4:
		var mouse_pos = get_viewport().get_mouse_position();
		var found: bool = false;
		for i in promotion_pieces:
			if Utility.chebyshev_distance(i.position, mouse_pos) < ALLOWED_DISTANCE:
				selected_promotion_overlay.update_display(true);
				selected_promotion_overlay.position = i.position;
				found = true;
				break;
				
		if (!found):
			selected_promotion_overlay.update_display(false);
	else:
		selected_promotion_overlay.update_display(false);
	
func check_game_ended():
	var current_side: int = chessboard.is_white_move();
	if chessboard.checkmated(current_side):
		if (current_side == 1):
			handle_end_game("Black Win!");
		else:
			handle_end_game("White Win!");
		return;
		
	if chessboard.stalemated(current_side):	
		handle_end_game("Draw by stalemate!");
		return;
		
	var msg = chessboard.stupid_draw_check();
	if (msg != "None"):
		handle_end_game(msg);
		return;

func handle_start_game():
	chessboard.reset_board();
	chessboard.start_game();

	for i in range(1, 5):
		var start_time = Time.get_ticks_msec();
		var ans = chess_engine_white.count_move(chessboard, i);
		var end_time = Time.get_ticks_msec();
		print("Test ", i, ": ", ans, ". Time elapsed: ", end_time - start_time, " ms!");

	initialRender();
	renderBoard(chessboard);
	play_sound("NewGame");
	$Infos/GameState.text = "White Turn";
	dark_overlay.update_display(false);

func handle_end_game(msg: String, should_play_sound: bool = true):
	if should_play_sound:
		play_sound("EndGame");
	chessboard.end_game();
	$Infos/GameState.text = msg;
	dark_overlay.update_display(true);

func _on_flip_board_button_down():
	flipped_board = !flipped_board;
	initialRender();
	renderBoard(chessboard);

func _on_new_game_button_down():
	handle_start_game();


func _on_undo_move_button_down():
	if chessboard.is_continuing():
		chessboard.roll_back();
		renderBoard(chessboard);
		play_sound("Move");



func _on_pvp_button_down():
	if (can_manual == [1, 1]):
		return;
	can_manual = [1, 1];
	handle_end_game("Press New Game to Start", chessboard.is_continuing());
	chessboard.reset_board();


func _on_pve_button_down():
	if (can_manual == [0, 1]):
		return;
	can_manual = [0, 1];
	handle_end_game("Press New Game to Start", chessboard.is_continuing());
	chessboard.reset_board();


func _on_evp_button_down():
	if (can_manual == [1, 0]):
		return;
	can_manual = [1, 0];
	handle_end_game("Press New Game to Start", chessboard.is_continuing());
	chessboard.reset_board();


func _on_eve_button_down():
	if (can_manual == [0, 0]):
		return;
	can_manual = [0, 0];
	handle_end_game("Press New Game to Start", chessboard.is_continuing());
	chessboard.reset_board();
