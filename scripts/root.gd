extends Node2D

var chessboard = ChessBoard.new();

var chess_piece = preload("res://scene/pieces.tscn");
var hint_overlay_scene = preload("res://scene/hint_overlay.tscn");
var selected_overlay_scene = preload("res://scene/selected_overlay.tscn");
var promotion_gui_scene = preload("res://scene/promotion_gui.tscn");

var hint_overlay_list: Array;
var starting_point = Vector2(376, 96);
var spacing:float = 75.5;
var chess_piece_instance_list = [];
var selected_cell = "";

var flipped_board = false;
var selected_overlay = selected_overlay_scene.instantiate();
var promotion_overlay = selected_overlay_scene.instantiate();
var promotion_gui = promotion_gui_scene.instantiate();
var promotion_pieces: Array;

# <------------------------- Utility function start ------------------------->

func vector_to_pos(p: Vector2):
	if (flipped_board) :
		p.x = 7 - p.x;
		p.y = 7 - p.y;
	return Vector2(starting_point.x + p.y * spacing, starting_point.y + (7 - p.x) * spacing);
	
func get_cell(mouse_pos: Vector2):
	for i in chess_piece_instance_list:
		if (Utility.chebyshev_distance(i.position, mouse_pos) < 32):
			return i.current_cell;
	return "None";
	

func get_viewport_size() -> Vector2:
	return get_viewport().size;
	
# <------------------------- Utility function end ------------------------->

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

func renderBoard(board_state):
	for i in range(0, 8):
		for j in range(0, 8):
			var current_cell = Utility.vector_to_cell_index(Vector2(i, j));
			chess_piece_instance_list[current_cell].set_type(chessboard.get_cell(current_cell));
			

func initializeOverlay():
	var v = get_viewport_size();
	
	add_child(selected_overlay); 
	selected_overlay.all_in_one(false, Vector2(spacing, spacing), 0.5, 0);
	
	add_child(promotion_overlay);
	promotion_overlay.all_in_one(false, v, 0.3, 2);
	promotion_overlay.position = Vector2(v.x / 2, v.y / 2);
	
	add_child(promotion_gui);
	promotion_gui.all_in_one(false, Vector2(spacing, spacing * 4), 1, 3);
	
	
			
func relocateOverlay(v: Vector2):
	if v.x == -1:
		selected_overlay.update_display(false);
	else:
		selected_overlay.update_display(true);
		selected_overlay.position = vector_to_pos(v);

# <------------------------- Rendering chessboard end  ------------------------->

# Called when the node enters the scene tree for the first time.
func _ready():
	initialRender();
	renderBoard(chessboard);
	initializeOverlay();

func play_sound(arg:String):
	match arg:
		"Move":
			$PieceMoveSound.play();
		"Capture":
			$PieceCaptureSound.play();
		"Castle":
			$CastlingSound.play();
		"Promote":
			$PromoteSound.play();
		_:
			print("What?");
			
func clear_hint_list():
	if (hint_overlay_list.size() == 0):
		return;
	for i in hint_overlay_list:
		remove_child(i);
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
	selected_cell = cur_cell;
	if (cur_cell == ""):
		relocateOverlay(Vector2(-1, -1));
	else:
		relocateOverlay(Utility.cell_notation_to_vector(selected_cell));
		var move_list = chessboard.generate_move_from_cell(Utility.cell_notation_to_int(selected_cell));
		update_hint_list(move_list);
		
	
func handle_normal_move(cell1: int, cell2: int):
	if (chess_piece_instance_list[cell2].current_piece != ".") :
		play_sound("Capture");
	else: 
		play_sound("Move");
		
	chessboard.normal_move(cell1, cell2);
	renderBoard(chessboard);
	update_selected_cell("");
	
func handle_castle(cell1: int, cell2: int):
	play_sound("Castle");
	chessboard.castle(cell1, cell2);
	renderBoard(chessboard);
	update_selected_cell("");
	
func handle_enpassant(cell1: int, cell2: int):
	play_sound("Capture");
	chessboard.en_passant(cell1, cell2);
	
	renderBoard(chessboard);
	update_selected_cell("");
	
func handle_promotion(cell1: int, cell2: int):
	var is_white = Utility.is_upper_case(chessboard.get_cell(cell1));
	chessboard.normal_move(cell1, cell2);
	renderBoard(chessboard);
	update_selected_cell("");
	
	create_promotion_pop_up(is_white, Utility.int_to_cell_vector(cell2));
	

func create_promotion_pop_up(is_white: bool, v: Vector2):
	clear_hint_list();
	promotion_overlay.update_display(true);
	promotion_gui.update_display(true);
	
	v = vector_to_pos(v);
	var _v = v;
	if (is_white != flipped_board): 
		_v.y += spacing * 1.5;
	else:
		_v.y -= spacing * 1.5;
	promotion_gui.position = _v;
		
	
	var arr: Array = ["q", "r", "b", "n"];
	for i in range(0, 4): 
		if is_white:
			arr[i] = arr[i].to_upper();
		var piece_instance = chess_piece.instantiate();
		
		promotion_pieces.append(piece_instance);
		add_child(piece_instance);
		
		piece_instance.set_type(arr[i]);
		var v1 = v;
		if (is_white != flipped_board) :
			v1.y += spacing * i;
		else:
			v1.y -= spacing * i;
		piece_instance.set_sprite_layer(4);
		piece_instance.position = v1;
		
func promotion_call(cell: int, s: String):
	if s == "None":
		chessboard.rollback();
	else:
		play_sound("Promote");
		var coord = Utility.int_to_cell_vector(cell);
		chessboard.promote(cell, s);
	renderBoard(chessboard);
	update_selected_cell("");
	
	promotion_overlay.update_display(false);
	promotion_gui.update_display(false);
	for i in promotion_pieces:
		remove_child(i);
	promotion_pieces.clear();
	
	
func handling_mouse_press(mouse_pos: Vector2):
	var cur_cell = get_cell(mouse_pos);
	if (cur_cell != "None"):  # if clicked inside the chessboard
		if (selected_cell == ""): # if not selecting any cell, select the cell
			var cell = Utility.cell_notation_to_int(cur_cell);
			if chessboard.get_cell(cell) != ".":
				update_selected_cell(cur_cell);
		else:
			var cell1 = Utility.cell_notation_to_int(selected_cell);
			var cell2 = Utility.cell_notation_to_int(cur_cell);
			
			var val1 = chessboard.get_cell(cell1);
			var val2 = chessboard.get_cell(cell2);
			if val2 != "." && (Utility.is_upper_case(val1) == Utility.is_upper_case(val2)): # if clicked on the same cell, cancel
				update_selected_cell(cur_cell);
			else:
				match chessboard.validate_move(cell1, cell2):
					1:
						handle_normal_move(cell1, cell2);
					2: 
						handle_castle(cell1, cell2);
					3:
						handle_enpassant(cell1, cell2);
					4:
						handle_promotion(cell1, cell2);
					_:
						pass;
	else: #cancel selected cell if clicked outside the chessboard
		update_selected_cell("");

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position();
		if promotion_pieces.size() == 4: # are opening promotion box
			var chosen_piece = "None";
			for i in promotion_pieces:
				if (Utility.chebyshev_distance(i.position, mouse_pos) < 32):
					chosen_piece = i.current_piece;
			promotion_call(chessboard.most_recent_move[1], chosen_piece);
		else:
			handling_mouse_press(mouse_pos);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_flip_board_button_down():
	flipped_board = !flipped_board;
	initialRender();
	renderBoard(chessboard);
	
