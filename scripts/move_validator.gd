extends Node

class_name Validator;

enum MOVE {Invalid, Normal};

static func check_king_move(chessboard, coord1: Vector2, coord2: Vector2): 
	# king move rule is the same as king capture rule, so nothing to edit
	if Utility.is_king_distance(coord1, coord2):
		return MOVE.Normal;
	return MOVE.Invalid;
	

static func check_knight_move(chessboard, coord1: Vector2, coord2: Vector2):
	# knight move rule is the same as knight capture rule, so nothing to edit
	if Utility.is_knight_distance(coord1, coord2):
		return MOVE.Normal;
	return MOVE.Invalid;
	
	
static func check_bishop_move(chessboard, coord1: Vector2, coord2: Vector2):
	# bishop move rule is the same as bishop capture rule, so nothing to edit
	if Utility.is_bishop_distance(coord1, coord2):
		if (coord1.x - coord1.y) == (coord2.x - coord2.y): # main diagonal
			var offset = coord1.y - coord1.x;
			var l = min(coord1.x, coord2.x);
			var r = max(coord1.x, coord2.x);
			
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(i, i + offset));
				if chessboard.get_cell(cur_cell) != ".":
					return MOVE.Invalid;
		else:
			var offset = coord1.x + coord1.y;
			var l = min(coord1.x, coord2.x);
			var r = max(coord1.x, coord2.x);
			
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(i, offset - i));
				if chessboard.get_cell(cur_cell) != ".":
					return MOVE.Invalid;
		return MOVE.Normal;
	return MOVE.Invalid;
		

static func check_rook_move(chessboard, coord1: Vector2, coord2: Vector2):
	# rook move rule is the same as rook capture rule, so nothing to edit
	if Utility.is_rook_distance(coord1, coord2):
		if coord1.x == coord2.x:
			var l = min(coord1.y, coord2.y);
			var r = max(coord1.y, coord2.y);
			
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(coord1.x, i));
				if chessboard.get_cell(cur_cell) != ".":
					return MOVE.Invalid;
		else:
			var l = min(coord1.x, coord2.x);
			var r = max(coord1.x, coord2.x);
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(i, coord1.y));
				if chessboard.get_cell(cur_cell) != ".":
					return MOVE.Invalid;
		return MOVE.Normal;
	return MOVE.Invalid;
	
static func check_queen_move(chessboard, coord1: Vector2, coord2: Vector2):
	# queen move rule is the same as queen capture rule, so nothing to edit
	if check_bishop_move(chessboard, coord1, coord2) || check_rook_move(chessboard, coord1, coord2):
		return MOVE.Normal;
	return MOVE.Invalid;
		
static func check_pawn_move(chessboard, coord1: Vector2, coord2: Vector2):
	# pawn move rule is different from pawn capture rule, so I shall edit
	var cell1:int = Utility.vector_to_cell_index(coord1);
	var cell2:int = Utility.vector_to_cell_index(coord2);
	var is_white = Utility.is_upper_case(chessboard.get_cell(cell1));
	if chessboard.get_cell(cell2) == "." && Utility.is_pawn_distance(coord1, coord2) && check_rook_move(chessboard, coord1, coord2): 
		# move, not capture
		if ((coord1.x < coord2.x) != is_white):
			return MOVE.Invalid;
		if is_white:
			if (coord1.x != 1) && (Utility.manhattan_distance(coord1, coord2) == 2):
				return MOVE.Invalid;
		else:
			if (coord1.x != 6) && (Utility.manhattan_distance(coord1, coord2) == 2):
				return MOVE.Invalid;
		return MOVE.Normal;
	if chessboard.get_cell(cell2) != "." && check_bishop_move(chessboard, coord1, coord2) && (Utility.chebyshev_distance(coord1, coord2) <= 1): 
		#capture, not move
		if ((coord1.x < coord2.x) != is_white):
			return MOVE.Invalid;
		return MOVE.Normal;
	
	return MOVE.Invalid;

static func validate_move(chessboard, cell1: int, cell2: int):
	var cur = chessboard.get_cell(cell1).to_lower();
	var coord1 = Utility.int_to_cell_vector(cell1);
	var coord2 = Utility.int_to_cell_vector(cell2);
	
	if (chessboard.get_cell(cell2) != ".") && (Utility.is_upper_case(chessboard.get_cell(cell1)) == Utility.is_upper_case(chessboard.get_cell(cell2))):
		return MOVE.Invalid;
	
	match cur:
		"k":
			return check_king_move(chessboard, coord1, coord2);
		"q":
			return check_queen_move(chessboard, coord1, coord2);
		"b":
			return check_bishop_move(chessboard, coord1, coord2);
		"n":
			return check_knight_move(chessboard, coord1, coord2);
		"r":
			return check_rook_move(chessboard, coord1, coord2);
		"p":
			return check_pawn_move(chessboard, coord1, coord2);
			
	return MOVE.Normal;
	

static func generate_move_from_cell(chessboard, cell1: int):
	var move_list: Array;
	for i in range(0, 8):
		for j in range(0, 8):
			if validate_move(chessboard, cell1, Utility.vector_to_cell_index(Vector2(i, j))) != MOVE.Invalid:
				move_list.append(Vector2(i, j));
	return move_list;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
