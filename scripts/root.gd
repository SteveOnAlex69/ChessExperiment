extends Node2D

var Validator = preload("res:///scripts/move_validator.gd");
var Utility = preload("res:///scripts/utility_functions.gd")
var chessboard = "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr".split("");
var chess_piece = preload("res://scene/pieces.tscn");
var selected_overlay_scene = preload("res://scene/selected_overlay.tscn");
var selected_overlay;
var starting_point = Vector2(376, 96);
var spacing:float = 75.5;
var chess_piece_instance_list = [];
var selected_cell = "";

# <------------------------- Utility function start ------------------------->

func vector_to_pos(p: Vector2):
	return Vector2(starting_point.x + p.y * spacing, starting_point.y + (7 - p.x) * spacing);
	
func get_cell(mouse_pos: Vector2):
	for i in chess_piece_instance_list:
		if (Utility.chebyshev_distance(i.position, mouse_pos) < 32):
			return i.current_cell;
	return "None";
	
# <------------------------- Utility function end ------------------------->

# <------------------------- Rendering chessboard here  ------------------------->
func renderBoard(board_state):
	chess_piece_instance_list.clear();
	for i in range(0, 8):
		for j in range(0, 8):
			var current_cell = Utility.vector_to_cell_index(Vector2(i, j));
			var cell_str = Utility.vector_to_cell_notation(Vector2(i, j));
			
			var chess_piece_instance = chess_piece.instantiate();
			chess_piece_instance_list.append(chess_piece_instance);
			add_child(chess_piece_instance);
			
			chess_piece_instance.position = vector_to_pos(Vector2(i, j));
			chess_piece_instance.set_type(chessboard[current_cell]);
			chess_piece_instance.set_current_cell(cell_str);

func reRenderBoard(board_state):
	for i in range(0, 8):
		for j in range(0, 8):
			var current_cell = Utility.vector_to_cell_index(Vector2(i, j));
			chess_piece_instance_list[current_cell].set_type(chessboard[current_cell]);
			
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
	print(Utility.chebyshev_distance(Vector2(0, 0), Vector2(1, 1)));
	renderBoard(chessboard);
	initializeOverlay();

func play_sound(arg:String):
	match arg:
		"Move":
			$PieceMoveSound.play();
		"Capture":
			$PieceCaptureSound.play();
		_:
			print("What?");

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		print(selected_cell);
		var mouse_pos = get_viewport().get_mouse_position();
		var cur_cell = get_cell(mouse_pos);
		if (cur_cell != "None"):  # if clicked inside the chessboard
			if (selected_cell == ""): # if not selecting any cell, select the cell
				var cell = Utility.cell_notation_to_int(cur_cell);
				if chessboard[cell] != ".":
					selected_cell = cur_cell;
					relocateOverlay(Utility.cell_notation_to_vector(selected_cell));
			else:
				var cell1 = Utility.cell_notation_to_int(selected_cell);
				var cell2 = Utility.cell_notation_to_int(cur_cell);
				
				if chessboard[cell2] != "." && (Utility.is_upper_case(chessboard[cell1]) == Utility.is_upper_case(chessboard[cell2])): # if clicked on the same cell, cancel
					selected_cell = cur_cell;
					relocateOverlay(Utility.cell_notation_to_vector(selected_cell));
				else:
					if Validator.validate_move(chessboard, cell1, cell2): # swap the two cell
						if (chess_piece_instance_list[cell2].current_piece != ".") :
							play_sound("Capture");
						else: 
							play_sound("Move");
							
						chessboard[cell2] = chessboard[cell1];
						chessboard[cell1] = ".";
						
						reRenderBoard(chessboard);
						selected_cell = "";
						relocateOverlay(Vector2(-1, -1));
		else: #cancel selected cell if clicked outside the chessboard
			selected_cell = "";
			relocateOverlay(Vector2(-1, -1));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
