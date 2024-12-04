extends Node

static func check_king_move(Utility, chessboard, coord1: Vector2, coord2: Vector2): 
	# king move rule is the same as king capture rule, so nothing to edit
	return Utility.is_king_distance(coord1, coord2);
	

static func check_knight_move(Utility, chessboard, coord1: Vector2, coord2: Vector2):
	# knight move rule is the same as knight capture rule, so nothing to edit
	return Utility.is_knight_distance(coord1, coord2);
	
	
static func check_bishop_move(Utility, chessboard, coord1: Vector2, coord2: Vector2):
	# bishop move rule is the same as bishop capture rule, so nothing to edit
	if Utility.is_bishop_distance(coord1, coord2):
		if (coord1.x - coord1.y) == (coord2.x - coord2.y): # main diagonal
			var offset = coord1.y - coord1.x;
			var l = min(coord1.x, coord2.x);
			var r = max(coord1.x, coord2.x);
			
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(i, i + offset));
				if chessboard[cur_cell] != ".":
					return false;
		else:
			var offset = coord1.x + coord1.y;
			var l = min(coord1.x, coord2.x);
			var r = max(coord1.x, coord2.x);
			
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(i, offset - i));
				if chessboard[cur_cell] != ".":
					return false;
		return true;
	return false;
		

static func check_rook_move(Utility, chessboard, coord1: Vector2, coord2: Vector2):
	# rook move rule is the same as rook capture rule, so nothing to edit
	if Utility.is_rook_distance(coord1, coord2):
		if coord1.x == coord2.x:
			var l = min(coord1.y, coord2.y);
			var r = max(coord1.y, coord2.y);
			
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(coord1.x, i));
				if chessboard[cur_cell] != ".":
					return false;
		else:
			var l = min(coord1.x, coord2.x);
			var r = max(coord1.x, coord2.x);
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(i, coord1.y));
				if chessboard[cur_cell] != ".":
					return false;
		return true;
	return false;
	
static func check_queen_move(Utility, chessboard, coord1: Vector2, coord2: Vector2):
	# queen move rule is the same as queen capture rule, so nothing to edit
	return check_bishop_move(Utility, chessboard, coord1, coord2) || check_rook_move(Utility, chessboard, coord1, coord2);
		
static func check_pawn_move(Utility, chessboard, coord1: Vector2, coord2: Vector2):
	# pawn move rule is different from pawn capture rule, so I shall edit
	var cell1:int = Utility.vector_to_cell_index(coord1);
	var cell2:int = Utility.vector_to_cell_index(coord2);
	var is_white = Utility.is_upper_case(chessboard[cell1]);
	if chessboard[cell2] == "." && Utility.is_pawn_distance(coord1, coord2) && check_rook_move(Utility, chessboard, coord1, coord2): 
		# move, not capture
		if ((coord1.x < coord2.x) != is_white):
			return false;
		if is_white:
			if (coord1.x != 1) && (Utility.manhattan_distance(coord1, coord2) == 2):
				return false;
		else:
			if (coord1.x != 6) && (Utility.manhattan_distance(coord1, coord2) == 2):
				return false;
		return true;
	if chessboard[cell2] != "." && check_bishop_move(Utility, chessboard, coord1, coord2) && (Utility.chebyshev_distance(coord1, coord2) <= 1): 
		#capture, not move
		if ((coord1.x < coord2.x) != is_white):
			return false;
		return true;
	
	return false;
	

static func validate_move(chessboard, cell1: int, cell2: int):
	var Utility = load("res:///scripts/utility_functions.gd")
	var cur = chessboard[cell1].to_lower();
	var coord1 = Utility.int_to_cell_vector(cell1);
	var coord2 = Utility.int_to_cell_vector(cell2);
	
	match cur:
		"k":
			return check_king_move(Utility, chessboard, coord1, coord2);
		"q":
			return check_queen_move(Utility, chessboard, coord1, coord2);
		"b":
			return check_bishop_move(Utility, chessboard, coord1, coord2);
		"n":
			return check_knight_move(Utility, chessboard, coord1, coord2);
		"r":
			return check_rook_move(Utility, chessboard, coord1, coord2);
		"p":
			return check_pawn_move(Utility, chessboard, coord1, coord2);
			
	
	return true;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
