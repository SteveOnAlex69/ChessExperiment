extends Node


class_name ChessBoard;

enum MOVE {Invalid, Normal, Castle};

var chessboard: Array = "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr".split("");
var white_castle: Array;
var black_castle: Array;

var most_recent_move;

func _init():
	white_castle.append(1); white_castle.append(1);
	black_castle.append(1); black_castle.append(1);

func get_cell(cell:int):
	return chessboard[cell];

func set_cell(cell:int, val:String):
	chessboard[cell] = val;
	
func normal_move(cell1: int, cell2: int):
	var pos = Utility.int_to_cell_vector(cell1);
	if chessboard[cell1].to_lower() == 'r':
		if pos.x == 0:
			if pos.y == 0:
				white_castle[0] = 0;
			if pos.y == 7:
				white_castle[1] = 0;
		if pos.x == 7:
			if pos.y == 0:
				black_castle[0] = 0;
			if pos.y == 7:
				black_castle[1] = 0;
	if chessboard[cell1].to_lower() == 'k':
		if chessboard[cell1] == 'K':
			white_castle[0] = 0;
			white_castle[1] = 0;
		else:
			black_castle[0] = 0;
			black_castle[1] = 0;
			
	chessboard[cell2] = chessboard[cell1];
	chessboard[cell1] = ".";
	

func castle(cell1: int, cell2: int):
	normal_move(cell1, cell2);
	var coord1 = Utility.int_to_cell_vector(cell1);
	var coord2 = Utility.int_to_cell_vector(cell2);
	if coord1.y > coord2.y:
		var rook_coord = Vector2(coord2.x, 0);
		var desired_coord = Vector2(coord2.x, coord2.y + 1);
		var cell3 = Utility.vector_to_cell_index(rook_coord);
		var cell4 = Utility.vector_to_cell_index(desired_coord);
		normal_move(cell3, cell4);
	else:
		var rook_coord = Vector2(coord2.x, 7);
		var desired_coord = Vector2(coord2.x, coord2.y - 1);
		var cell3 = Utility.vector_to_cell_index(rook_coord);
		var cell4 = Utility.vector_to_cell_index(desired_coord);
		normal_move(cell3, cell4);
	
# <-------- Move Validator Start -------->

func check_king_move(coord1: Vector2, coord2: Vector2): 
	if Utility.is_king_distance(coord1, coord2): # normal move
		return MOVE.Normal;
	# castling
	if (coord1.x == coord2.x) && (Utility.chebyshev_distance(coord1, coord2) == 2):
		var is_white = Utility.is_upper_case(chessboard[Utility.vector_to_cell_index(coord1)]);
		if coord1.y > coord2.y: #castle to the 1st file
			if is_white:
				if (white_castle[0] == 1) && check_rook_move(coord1, Vector2(coord1.x, 0)):
					return MOVE.Castle;
			else:
				if (black_castle[0] == 1) && check_rook_move(coord1, Vector2(coord1.x, 0)):
					return MOVE.Castle;
		else: #castle to the 8th file
			if is_white:
				if (white_castle[1] == 1) && check_rook_move(coord1, Vector2(coord1.x, 7)):
					return MOVE.Castle;
			else:
				if (black_castle[1] == 1) && check_rook_move(coord1, Vector2(coord1.x, 7)):
					return MOVE.Castle;
	return MOVE.Invalid;
	

func check_knight_move(coord1: Vector2, coord2: Vector2):
	if Utility.is_knight_distance(coord1, coord2):
		return MOVE.Normal;
	return MOVE.Invalid;
	
	
func check_bishop_move(coord1: Vector2, coord2: Vector2):
	if Utility.is_bishop_distance(coord1, coord2):
		if (coord1.x - coord1.y) == (coord2.x - coord2.y): # main diagonal
			var offset = coord1.y - coord1.x;
			var l = min(coord1.x, coord2.x);
			var r = max(coord1.x, coord2.x);
			
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(i, i + offset));
				if chessboard[cur_cell] != ".":
					return MOVE.Invalid;
		else:
			var offset = coord1.x + coord1.y;
			var l = min(coord1.x, coord2.x);
			var r = max(coord1.x, coord2.x);
			
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(i, offset - i));
				if chessboard[cur_cell] != ".":
					return MOVE.Invalid;
		return MOVE.Normal;
	return MOVE.Invalid;
		

func check_rook_move(coord1: Vector2, coord2: Vector2):
	if Utility.is_rook_distance(coord1, coord2):
		if coord1.x == coord2.x:
			var l = min(coord1.y, coord2.y);
			var r = max(coord1.y, coord2.y);
			
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(coord1.x, i));
				if chessboard[cur_cell] != ".":
					return MOVE.Invalid;
		else:
			var l = min(coord1.x, coord2.x);
			var r = max(coord1.x, coord2.x);
			for i in range(l+1, r):
				var cur_cell = Utility.vector_to_cell_index(Vector2(i, coord1.y));
				if chessboard[cur_cell] != ".":
					return MOVE.Invalid;
		return MOVE.Normal;
	return MOVE.Invalid;
	
func check_queen_move(coord1: Vector2, coord2: Vector2):
	# queen move rule is the same as queen capture rule, so nothing to edit
	if check_bishop_move(coord1, coord2) || check_rook_move(coord1, coord2):
		return MOVE.Normal;
	return MOVE.Invalid;
		
func check_pawn_move(coord1: Vector2, coord2: Vector2):
	var cell1:int = Utility.vector_to_cell_index(coord1);
	var cell2:int = Utility.vector_to_cell_index(coord2);
	var is_white = Utility.is_upper_case(chessboard[cell1]);
	if chessboard[cell2] == "." && Utility.is_pawn_distance(coord1, coord2) && check_rook_move(coord1, coord2): 
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
	if chessboard[cell2] != "." && check_bishop_move(coord1, coord2) && (Utility.chebyshev_distance(coord1, coord2) <= 1): 
		#capture, not move
		if ((coord1.x < coord2.x) != is_white):
			return MOVE.Invalid;
		return MOVE.Normal;
	
	return MOVE.Invalid;
	

func validate_move(cell1: int, cell2: int):
	var cur = chessboard[cell1].to_lower();
	var coord1 = Utility.int_to_cell_vector(cell1);
	var coord2 = Utility.int_to_cell_vector(cell2);
	
	if (chessboard[cell2] != ".") && (Utility.is_upper_case(chessboard[cell1]) == Utility.is_upper_case(chessboard[cell2])):
		return MOVE.Invalid;
	
	match cur:
		"k":
			return check_king_move(coord1, coord2);
		"q":
			return check_queen_move(coord1, coord2);
		"b":
			return check_bishop_move(coord1, coord2);
		"n":
			return check_knight_move(coord1, coord2);
		"r":
			return check_rook_move(coord1, coord2);
		"p":
			return check_pawn_move(coord1, coord2);
			
	return MOVE.Normal;
	

func generate_move_from_cell(cell1: int):
	var move_list: Array;
	for i in range(0, 8):
		for j in range(0, 8):
			if (validate_move(cell1, Utility.vector_to_cell_index(Vector2(i, j))) != MOVE.Invalid):
				move_list.append(Vector2(i, j));
	return move_list;

# <-------- Move Validator End -------->

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
