extends Resource


class_name ChessBoard;

enum MOVE {Invalid, Normal, Castle, EnPassant, Promote};

var chessboard: Array = "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr".split("");
var white_castle: Array;
var black_castle: Array;
var is_white_move: bool;
var game_continuing: bool = false;
var board_history_hash: Array;
var fifty_move_counter: int;

var most_recent_move: Array[int];

func _init():
	white_castle.append(1); white_castle.append(1);
	black_castle.append(1); black_castle.append(1);
	is_white_move = true;

func is_continuing():
	return game_continuing;
	
func start_game():
	game_continuing = true;
	
func end_game():
	game_continuing = false;
	
func reset_board():
	chessboard = "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr".split("");
	is_white_move = true;
	most_recent_move.clear();
	fifty_move_counter = 100;
	board_history_hash.clear();
	
	white_castle[0] = 1; white_castle[1] = 1;
	black_castle[0] = 1; black_castle[1] = 1;
	
	if chessboard[Utility.cell_notation_to_int("a5")] != 'K':
		white_castle[0] = 0; white_castle[1] = 0;
	if chessboard[Utility.cell_notation_to_int("h5")] != 'k':
		black_castle[0] = 0; black_castle[1] = 0;
	if chessboard[Utility.cell_notation_to_int("a1")] != 'R':
		white_castle[0] = 0;
	if chessboard[Utility.cell_notation_to_int("a8")] != 'R':
		white_castle[1] = 0;
	if chessboard[Utility.cell_notation_to_int("h1")] != 'r':
		black_castle[0] = 0;
	if chessboard[Utility.cell_notation_to_int("h8")] != 'r':
		black_castle[1] = 0;
	

func get_cell(cell:int):
	return chessboard[cell];

func set_cell(cell:int, val:String):
	chessboard[cell] = val;
	
func update_history(fifty_move_reset: bool = false):
	is_white_move = !is_white_move;
	if fifty_move_reset:
		fifty_move_counter = 100;
		board_history_hash.clear();
	else:
		fifty_move_counter -= 1;
		board_history_hash.append(hash(chessboard));
	
func disable_castling_rook(cell: int):
	var pos = Utility.int_to_cell_vector(cell);
	if (chessboard[cell].to_lower() == 'r'):
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
	
func normal_move(cell1: int, cell2: int, is_actual_move: bool = true):
	if is_actual_move:
		update_history((chessboard[cell1].to_lower() == 'p') || (chessboard[cell2] != '.'));
	disable_castling_rook(cell1); 
	disable_castling_rook(cell2);
	
	if chessboard[cell1].to_lower() == 'k':
		if chessboard[cell1] == 'K':
			white_castle[0] = 0;
			white_castle[1] = 0;
		else:
			black_castle[0] = 0;
			black_castle[1] = 0;
	chessboard[cell2] = chessboard[cell1];
	chessboard[cell1] = ".";
	most_recent_move = [cell1, cell2];
	

func castle(cell1: int, cell2: int):
	update_history();
	normal_move(cell1, cell2, false);
	var coord1 = Utility.int_to_cell_vector(cell1);
	var coord2 = Utility.int_to_cell_vector(cell2);
	if coord1.y > coord2.y:
		var rook_coord = Vector2(coord2.x, 0);
		var desired_coord = Vector2(coord2.x, coord2.y + 1);
		var cell3 = Utility.vector_to_cell_index(rook_coord);
		var cell4 = Utility.vector_to_cell_index(desired_coord);
		normal_move(cell3, cell4, false);
	else:
		var rook_coord = Vector2(coord2.x, 7);
		var desired_coord = Vector2(coord2.x, coord2.y - 1);
		var cell3 = Utility.vector_to_cell_index(rook_coord);
		var cell4 = Utility.vector_to_cell_index(desired_coord);
		normal_move(cell3, cell4, false);
		

func en_passant(cell1: int, cell2: int):
	update_history(true);
	normal_move(cell1, cell2, false);
	var coord1 = Utility.int_to_cell_vector(cell1);
	var coord2 = Utility.int_to_cell_vector(cell2);
	var coord3 = Vector2(coord1.x, coord2.y);
	
	var cell3 = Utility.vector_to_cell_index(coord3);
	normal_move(cell3, cell3, false);
	

func promote(cell: int, s: String):
	is_white_move = !is_white_move;
	chessboard[cell] = s;
	
func deep_copy() -> ChessBoard:
	var tmp = ChessBoard.new();
	
	tmp.is_white_move = is_white_move;
	tmp.game_continuing = game_continuing;
	tmp.fifty_move_counter = fifty_move_counter;
	tmp.chessboard = chessboard.duplicate(true);
	tmp.white_castle = white_castle.duplicate(true);
	tmp.black_castle = black_castle.duplicate(true);
	tmp.board_history_hash = board_history_hash.duplicate(true);
	tmp.most_recent_move = most_recent_move.duplicate(true);
	
	return tmp;
	

# <-------- Move Validator Start -------->

func check_king_move(coord1: Vector2, coord2: Vector2, allow_special: bool = true): 
	if Utility.is_king_distance(coord1, coord2): # normal move
		return MOVE.Normal;
	if (!allow_special):
		return MOVE.Invalid;
	# castling
	if (coord1.x == coord2.x) && (Utility.chebyshev_distance(coord1, coord2) == 2):
		var is_white = Utility.is_upper_case(chessboard[Utility.vector_to_cell_index(coord1)]);
		if coord1.y > coord2.y: #castle to the 1st file
			var check_castling = white_castle[0];
			if (!is_white): 
				check_castling = black_castle[0];
			if (check_castling == 1) && check_rook_move(coord1, Vector2(coord1.x, 0)):
				for i in range(coord2.y, coord1.y + 1):
					if check_tile_attacked(Utility.vector_to_cell_index(Vector2(coord2.x, i)), !is_white_move):
						return MOVE.Invalid;
				return MOVE.Castle;
		else: #castle to the 8th file
			var check_castling = white_castle[0];
			if (!is_white): 
				check_castling = black_castle[0];
			if (check_castling == 1) && check_rook_move(coord1, Vector2(coord1.x, 7)):
				for i in range(coord1.y, coord2.y + 1):
					if check_tile_attacked(Utility.vector_to_cell_index(Vector2(coord2.x, i)), !is_white_move):
						return MOVE.Invalid;
				return MOVE.Castle;
	return MOVE.Invalid;
	

func check_knight_move(coord1: Vector2, coord2: Vector2):
	if Utility.is_knight_distance(coord1, coord2):
		return MOVE.Normal;
	return MOVE.Invalid;
	
	
func check_bishop_move(coord1: Vector2, coord2: Vector2):
	if (coord1 == coord2):
		return MOVE.Normal;
	if Utility.is_bishop_distance(coord1, coord2):
		var diff = Vector2(coord2.x - coord1.x, coord2.y - coord1.y);
		var cardinality = abs(diff.x);
		diff.x /= cardinality; diff.y /= cardinality;
		var coord = coord1;
		while(coord != coord2):
			if coord != coord1:
				var cur_cell = Utility.vector_to_cell_index(coord);
				if (chessboard[cur_cell] != "."):
					return MOVE.Invalid;
			coord += diff;
		return MOVE.Normal;
	return MOVE.Invalid;
		

func check_rook_move(coord1: Vector2, coord2: Vector2):
	if (coord1 == coord2):
		return MOVE.Normal;
	if Utility.is_rook_distance(coord1, coord2):
		var diff = Vector2(coord2.x - coord1.x, coord2.y - coord1.y);
		var cardinality = abs(diff.x + diff.y);
		diff.x /= cardinality; diff.y /= cardinality;
		var coord = coord1;
		while(coord != coord2):
			if coord != coord1:
				var cur_cell = Utility.vector_to_cell_index(coord);
				if (chessboard[cur_cell] != "."):
					return MOVE.Invalid;
			coord += diff;
		return MOVE.Normal;
	return MOVE.Invalid;
	
func check_queen_move(coord1: Vector2, coord2: Vector2):
	if check_bishop_move(coord1, coord2) || check_rook_move(coord1, coord2):
		return MOVE.Normal;
	return MOVE.Invalid;
		
func check_pawn_move(coord1: Vector2, coord2: Vector2, allow_special:bool = true):
	var cell1:int = Utility.vector_to_cell_index(coord1);
	var cell2:int = Utility.vector_to_cell_index(coord2);
	var is_white = Utility.is_upper_case(chessboard[cell1]);
	# Move
	if chessboard[cell2] == "." && Utility.is_pawn_distance(coord1, coord2) && check_rook_move(coord1, coord2): 
		if ((coord1.x < coord2.x) != is_white):
			return MOVE.Invalid;
		var init_pos = 1;
		if (!is_white):
			init_pos = 6;
		if (coord1.x != init_pos) && (Utility.manhattan_distance(coord1, coord2) == 2):
			return MOVE.Invalid;
		return MOVE.Normal;
	# Capture
	if chessboard[cell2] != "." && check_bishop_move(coord1, coord2) && (Utility.chebyshev_distance(coord1, coord2) <= 1): 
		if ((coord1.x < coord2.x) != is_white):
			return MOVE.Invalid;
		return MOVE.Normal;
	# En passant
	if (!allow_special):
		return MOVE.Invalid;
	if (most_recent_move.size() == 2) && (chessboard[most_recent_move[1]].to_lower() == "p") && (chessboard[most_recent_move[1]] != chessboard[cell1]):
		var coord3 = Utility.int_to_cell_vector(most_recent_move[0]);
		var coord4 = Utility.int_to_cell_vector(most_recent_move[1]);
		if (Utility.chebyshev_distance(coord3, coord4) == 2):
			if (Utility.manhattan_distance(coord1, coord4) == 1) && (coord1.x == coord4.x) && coord2 == Vector2((coord4.x + coord3.x) / 2, coord4.y):
				return MOVE.EnPassant;
	return MOVE.Invalid;
	
func check_tile_attacked(cell: int, opponent_side: bool):
	#Safe and simple, but slow
	for i in range(0, 64):
		if (chessboard[i] != ".") && (Utility.is_upper_case(chessboard[i]) == opponent_side):
			if (validate_move_skeleton(i, cell, 0)): 
				return true;
	
	return false;
	
func in_check(current_side: bool):
	var cur = "K";
	if (current_side == false):
		cur = "k";
	return check_tile_attacked(chessboard.find(cur), !current_side);

func validate_move_skeleton(cell1: int, cell2: int, allow_special: bool = true):
	if chessboard[cell1] == ".":
		return MOVE.Invalid;
	if (chessboard[cell2] != ".") && (Utility.is_upper_case(chessboard[cell1]) == Utility.is_upper_case(chessboard[cell2])):
		return MOVE.Invalid;
	
	var cur = chessboard[cell1].to_lower();
	var coord1 = Utility.int_to_cell_vector(cell1);
	var coord2 = Utility.int_to_cell_vector(cell2);
	
	match cur:
		"k":
			return check_king_move(coord1, coord2, allow_special);
		"q":
			return check_queen_move(coord1, coord2);
		"b":
			return check_bishop_move(coord1, coord2);
		"n":
			return check_knight_move(coord1, coord2);
		"r":
			return check_rook_move(coord1, coord2);
		"p":
			var ans = check_pawn_move(coord1, coord2, allow_special);
			if (ans == MOVE.Normal) && (coord2.x == 0 || coord2.x == 7):
				ans = MOVE.Promote;
			return ans;
	return MOVE.Normal;
	

func validate_move(cell1: int, cell2: int): #validate_move, but perform check check
	var ans = validate_move_skeleton(cell1, cell2);
	if ans == MOVE.Invalid: #break early to save computation power
		return MOVE.Invalid;
	var tmp_board: ChessBoard = ChessBoard.new();
	tmp_board.is_white_move = is_white_move;
	tmp_board.fifty_move_counter = fifty_move_counter;
	tmp_board.chessboard = chessboard.duplicate(true);
	
	if (ans == MOVE.Normal) || (ans == MOVE.Promote):
		tmp_board.normal_move(cell1, cell2);
		if (tmp_board.in_check(is_white_move)):
			return MOVE.Invalid;
		return ans;
	if (ans == MOVE.EnPassant):
		tmp_board.en_passant(cell1, cell2);
		if (tmp_board.in_check(is_white_move)):
			return MOVE.Invalid;
		return MOVE.EnPassant;
	return ans;
	

func find_valid_move_from_cell(cell1: int) -> bool:
	for i in range(0, 8):
		for j in range(0, 8):
			if (validate_move(cell1, Utility.vector_to_cell_index(Vector2(i, j))) != MOVE.Invalid):
				return true;
	return false;

func generate_move_from_cell(cell1: int) -> Array:
	var move_list: Array;
	for i in range(0, 8):
		for j in range(0, 8):
			if (validate_move(cell1, Utility.vector_to_cell_index(Vector2(i, j))) != MOVE.Invalid):
				move_list.append(Vector2(i, j));
	return move_list;
	

func generate_move_type_from_cell(cell1: int) -> Array:
	var move_list: Array;
	for i in range(0, 64):
		var cur = validate_move(cell1, i);
		if (cur != MOVE.Invalid):
			move_list.append([i, cur]);
	return move_list;
	
func generate_move() -> Array:
	var move_list: Array;
	for i in range(0, 64):
		if (chessboard[i] != ".") && (Utility.is_upper_case(chessboard[i]) == is_white_move):
			var current_list: Array = generate_move_type_from_cell(i);
			for k in current_list:
				move_list.append([i, k[0], k[1]]);
	return move_list;

# <-------- Move Validator End -------->

# <-------- Game State Messing Start -------->

func checkmated(current_side: int) -> bool:
	if in_check(current_side):
		for i in range(0, 64): 
			if (chessboard[i] != ".") && (Utility.is_upper_case(chessboard[i]) == bool(current_side)) && find_valid_move_from_cell(i):
				return false;
		return true;
	return false;
	
func stalemated(current_side: int) -> bool:
	if !in_check(current_side):
		for i in range(0, 64): 
			if (chessboard[i] != ".") && (Utility.is_upper_case(chessboard[i]) == bool(current_side)) && find_valid_move_from_cell(i):
				return false;
		return true;
	return false;
	
func stupid_draw_check() -> String:
	var none = "None";
	var insufficient_material = "Draw by insufficient material!";
	var fifty_move_rule = "Draw by Fifty-Move rule!"
	var three_repetition_rule = "Draw by 3-Repetition rule!";
	# draw by insufficient material: happen if one side only have a king left
	# and the other also have nothing, or a knight or a bishop
	var remaining_pieces: Array[String];
	for i in range(0, 64):
		if (chessboard[i] != ".") && (chessboard[i].to_lower() != "k"):
			remaining_pieces.append(chessboard[i].to_lower());
		if (remaining_pieces.size() > 1):
			break;
	match remaining_pieces.size():
		0:
			return insufficient_material;
		1:
			if (remaining_pieces[0] == 'b') || (remaining_pieces[0] == 'n'):
				return insufficient_material; 
			
	# Fifty move rule: if no capture and pawn move happen in 50 move, draw
	if (fifty_move_counter <= 0):
		return fifty_move_rule;
		
	# If a board state is repeated 3 times, draw
	var cnt= 0; var cur_hash = hash(chessboard.duplicate(true));
	for i in board_history_hash:
		if (i == cur_hash):
			cnt += 1;
			
	if (cnt >= 2):
		return three_repetition_rule;
	
	return none;

# <-------- Game State Messing End -------->

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
