extends Node2D

var chessboard = ChessBoard.new();
var chess_piece = preload("res://scene/pieces.tscn");
var selected_overlay_scene = preload("res://scene/selected_overlay.tscn");
var hint_overlay_scene = preload("res://scene/hint_overlay.tscn");
var selected_overlay;
var hint_overlay_list: Array;
var starting_point = Vector2(376, 96);
var spacing:float = 75.5;
var chess_piece_instance_list = [];
var selected_cell = "";

var flipped_board = false;

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
	selected_overlay = selected_overlay_scene.instantiate();
	add_child(selected_overlay);
	
	selected_overlay.set_sprite_scale(Vector2(spacing, spacing));
	selected_overlay.set_sprite_opacity(0.5);
	
			
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
		hint_instance.update_display(true);
		hint_instance.set_sprite_opacity(0.5);
		hint_instance.set_sprite_scale(Vector2(0.6, 0.6));

func update_selected_cell(cur_cell: String):
	clear_hint_list();
	selected_cell = cur_cell;
	if (cur_cell == ""):
		relocateOverlay(Vector2(-1, -1));
	else:
		relocateOverlay(Utility.cell_notation_to_vector(selected_cell));
		var move_list = chessboard.generate_move_from_cell(Utility.cell_notation_to_int(selected_cell));
		update_hint_list(move_list);

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position();
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
							if (chess_piece_instance_list[cell2].current_piece != ".") :
								play_sound("Capture");
							else: 
								play_sound("Move");
								
							chessboard.normal_move(cell1, cell2);
							
							renderBoard(chessboard);
							update_selected_cell("");
						2:
							play_sound("Castle");
							
							chessboard.castle(cell1, cell2);
							
							renderBoard(chessboard);
							update_selected_cell("");
						_:
							pass;
		else: #cancel selected cell if clicked outside the chessboard
			selected_cell = "";
			relocateOverlay(Vector2(-1, -1));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_flip_board_button_down():
	flipped_board = !flipped_board;
	initialRender();
	renderBoard(chessboard);
	
