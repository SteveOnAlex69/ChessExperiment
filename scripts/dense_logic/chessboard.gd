extends Resource


class_name ChessBoard;

enum MOVE {Invalid, Normal, Castle, EnPassant, Promote};

var init_state: String;
var chessboard: PackedStringArray;
var can_castle: Array[Array];
var white_move: bool;
var game_continuing: bool = false;
var board_history_hash: Array[int];
var fifty_move_counter: int;

var most_recent_move: Array[int];
var available_move: Array;
var updated: bool = false;
var castled: Array[int] = [0, 0];

# <-------- Simple stuff starts ---------->

func _init(starting: String):
	init_state = starting;
	reset_board();
	
func is_white_move() -> bool:
	return white_move;

func is_continuing() -> bool:
	return game_continuing;
	
func start_game() -> void:
	game_continuing = true;
	
func end_game() -> void:
	game_continuing = false;
	
func reset_board() -> void:
	chessboard = init_state.split("");
	white_move = true;
	most_recent_move.clear();
	fifty_move_counter = 100;
	board_history_hash.clear();
	castled = [0, 0];
	
	can_castle = [[1, 1], [1, 1]];
	updated = false;
	
	if chessboard[Utility.cell_notation_to_int("a5")] != 'K':
		can_castle[1] = [0, 0];
	if chessboard[Utility.cell_notation_to_int("h5")] != 'k':
		can_castle[0] = [0, 0];
	if chessboard[Utility.cell_notation_to_int("a1")] != 'R':
		can_castle[1][0] = 0;
	if chessboard[Utility.cell_notation_to_int("a8")] != 'R':
		can_castle[1][1] = 0;
	if chessboard[Utility.cell_notation_to_int("h1")] != 'r':
		can_castle[0][0] = 0;
	if chessboard[Utility.cell_notation_to_int("h8")] != 'r':
		can_castle[0][1] = 0;

func get_cell(cell:int) -> String:
	return chessboard[cell];

func set_cell(cell:int, val:String) -> void:
	chessboard[cell] = val;
	
func update_history(fifty_move_reset: bool = false) -> void:
	white_move = !white_move;
	if fifty_move_reset:
		fifty_move_counter = 100;
		board_history_hash.clear();
	else:
		fifty_move_counter -= 1;
		board_history_hash.append(hash(chessboard));
	
func disable_castling_rook(cell: int) -> void:
	var pos = Utility.int_to_cell_vector(cell);
	if (chessboard[cell].to_lower() == 'r') && ((pos.y == 0) || (pos.y == 7)):
		var is_8th_file: int = (pos.y == 7);
		if pos.x == 0:
			can_castle[1][is_8th_file] = 0;
		if pos.x == 7:
			can_castle[0][is_8th_file] = 0;
			
func deep_copy() -> ChessBoard:
	var tmp = ChessBoard.new(init_state);
	tmp.white_move = white_move;
	tmp.game_continuing = game_continuing;
	tmp.fifty_move_counter = fifty_move_counter;
	tmp.updated = false;
	
	tmp.chessboard = chessboard.duplicate();
	tmp.can_castle = can_castle.duplicate(true);
	tmp.castled = castled.duplicate(true);
	tmp.board_history_hash = board_history_hash.duplicate(true);
	tmp.most_recent_move = most_recent_move.duplicate(true);
	
	return tmp;

# <-------- Simple stuff ends ---------->

# <-------- Handling move starts ---------->
	
func normal_move(cell1: int, cell2: int, is_actual_move: bool = true) -> void:
	if is_actual_move:
		update_history((chessboard[cell1].to_lower() == 'p') || (chessboard[cell2] != '.'));
	disable_castling_rook(cell1); 
	disable_castling_rook(cell2);
	
	if chessboard[cell1] == 'K':
		can_castle[1] = [0, 0];
		castled[1] = 1;
	if chessboard[cell1] == 'k':
		can_castle[0] = [0, 0];
		castled[0] = 1;
	chessboard[cell2] = chessboard[cell1];
	chessboard[cell1] = ".";
	most_recent_move = [cell1, cell2];
	
	if is_actual_move: 
		updated = false;
	
func castle(cell1: int, cell2: int) -> void:
	update_history();
	normal_move(cell1, cell2, false);
	var coord1 = Utility.int_to_cell_vector(cell1);
	var coord2 = Utility.int_to_cell_vector(cell2);
	if coord1.y > coord2.y:
		var cell3 = Utility.vector_to_cell_index(Vector2(coord2.x, 0));
		var cell4 = Utility.vector_to_cell_index(Vector2(coord2.x, coord2.y + 1));
		normal_move(cell3, cell4, false);
	else:
		var cell3 = Utility.vector_to_cell_index(Vector2(coord2.x, 7));
		var cell4 = Utility.vector_to_cell_index(Vector2(coord2.x, coord2.y - 1));
		normal_move(cell3, cell4, false);
	updated = false;
		
func en_passant(cell1: int, cell2: int) -> void:
	update_history(true);
	normal_move(cell1, cell2, false);
	var coord1 = Utility.int_to_cell_vector(cell1);
	var coord2 = Utility.int_to_cell_vector(cell2);
	var coord3 = Vector2(coord1.x, coord2.y);
	
	var cell3 = Utility.vector_to_cell_index(coord3);
	normal_move(cell3, cell3, false);
	updated = false;
	
func promote(cell: int, s: String) -> void:
	s = s.to_lower();
	if (white_move):
		s = s.to_upper();
	chessboard[cell] = s;
	
	white_move = !white_move;
	updated = false;
	
	
# <-------- Handling move ends ---------->

# <-------- Move Validator Start -------->

func check_tile_attacked(cell: int, opponent_side: bool) -> bool:
	var cur_coord = Utility.int_to_cell_vector(cell);
	var d_coord: Array[Vector2];
	var d_int: Array[int];
	
	# check rook, bishop and queen
	d_coord = [Vector2(1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1)];
	d_int = [8, 1, -1, -8, 9, -9, 7, -7];
	
	for i in range(0, 8):
		var antagonist = ["q", "r"];
		if (i >= 4):
			antagonist[1] = "b";
		var coord = cur_coord+ d_coord[i];
		var _cell = cell + d_int[i];
		while(min(coord.x, coord.y) >= 0 && max(coord.x, coord.y) < 8):
			if (chessboard[_cell] != ".") :
				if (Utility.is_upper_case(chessboard[_cell]) != opponent_side):
					break;
				var cur = chessboard[_cell].to_lower();
				if (antagonist.find(cur) != -1):
					return true;
				break;
			coord += d_coord[i];
			_cell += d_int[i];
	
	# check knight
	d_coord = [Vector2(1, 2), Vector2(2, 1), Vector2(1, -2), Vector2(2, -1), Vector2(-1, 2), Vector2(-2, 1), Vector2(-1, -2), Vector2(-2, -1)];
	d_int = [10, 17, 6, 15, -6, -15, -10, -17];
	for i in range(0, d_coord.size()):
		var coord = cur_coord + d_coord[i];
		var _cell = cell + d_int[i];
		if (min(coord.x, coord.y) >= 0 && max(coord.x, coord.y) < 8):
			if (chessboard[_cell].to_lower() == "n") && (Utility.is_upper_case(chessboard[_cell]) == opponent_side):
				return true;
	
	#check king
	d_coord = [Vector2(-1, -1), Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -1), Vector2(0, 1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1)];
	d_int = [-9, -8, -7,  -1, 1, 7, 8, 9];
	for i in range(0, d_coord.size()):
		var coord = cur_coord + d_coord[i];
		var _cell = cell + d_int[i];
		if (min(coord.x, coord.y) >= 0 && max(coord.x, coord.y) < 8):
			if (chessboard[_cell].to_lower() == "k") && (Utility.is_upper_case(chessboard[_cell]) == opponent_side):
				return true;
	
	#check pawn
	if opponent_side == false:
		d_coord = [Vector2(1, -1), Vector2(1, 1)];
		d_int = [7, 9];
	else:
		d_coord = [Vector2(-1, 1), Vector2(-1, -1)];
		d_int = [-7, -9];
		
	for i in range(0, d_coord.size()):
		var coord = cur_coord + d_coord[i];
		var _cell = cell + d_int[i];
		if (min(coord.x, coord.y) >= 0 && max(coord.x, coord.y) < 8):
			if (chessboard[_cell].to_lower() == "p") && (Utility.is_upper_case(chessboard[_cell]) == opponent_side):
				return true;
	
	return false;
	
func in_check(current_side: bool) -> bool:
	var cur = "K";
	if (current_side == false):
		cur = "k";
	return check_tile_attacked(chessboard.find(cur), !current_side);

func generate_move_type_from_cell(cell1: int) -> Array:
	var move_list: Array;
	var cur = chessboard[cell1].to_lower();
	if (chessboard[cell1] == "."):
		return move_list;
	# Normal Move
	if (cur == "b" || cur == "r" || cur == "q"):
		var d_coord: Array[Vector2];
		var d_int: Array[int];
		if (cur == "r"):
			d_coord = [Vector2(1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(-1, 0)];
			d_int = [8, 1, -1, -8];
		if (cur == "b"):
			d_coord = [Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1)];
			d_int = [9, -9, 7, -7];
		if (cur == "q"):
			d_coord = [Vector2(1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1)];
			d_int = [8, 1, -1, -8, 9, -9, 7, -7];
			
		for i in range(0, d_coord.size()):
			var coord = Utility.int_to_cell_vector(cell1) + d_coord[i];
			var cell2 = cell1 + d_int[i];
			while(min(coord.x, coord.y) >= 0 && max(coord.x, coord.y) < 8):
				if (chessboard[cell2] != ".") && (Utility.is_upper_case(chessboard[cell2]) == Utility.is_upper_case(chessboard[cell1])):
					break;
				move_list.append([cell2, MOVE.Normal]);
				if (chessboard[cell2] != "."):
					break;
				coord += d_coord[i];
				cell2 += d_int[i];
				
	if (cur == "k" || cur == "n"):
		var d_coord: Array[Vector2];
		var d_int: Array[int];
		if (cur == "n"):
			d_coord = [Vector2(1, 2), Vector2(2, 1), Vector2(1, -2), Vector2(2, -1), Vector2(-1, 2), Vector2(-2, 1), Vector2(-1, -2), Vector2(-2, -1)];
			d_int = [10, 17, 6, 15, -6, -15, -10, -17];
		if (cur == "k"):
			d_coord = [Vector2(-1, -1), Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -1), Vector2(0, 1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1)];
			d_int = [-9, -8, -7, -1, 1, 7, 8, 9];
			
		for i in range(0, d_coord.size()):
			var coord = Utility.int_to_cell_vector(cell1) + d_coord[i];
			var cell2 = cell1 + d_int[i];
			if (min(coord.x, coord.y) >= 0 && max(coord.x, coord.y) < 8):
				if (chessboard[cell2] == ".") || (Utility.is_upper_case(chessboard[cell2]) != Utility.is_upper_case(chessboard[cell1])):
					move_list.append([cell2, MOVE.Normal]);
					
	if (cur == "p"):
		var d_coord: Array[Vector2];
		var d_int: Array[int];
		if (chessboard[cell1] == "P"):
			d_coord = [Vector2(1, -1), Vector2(1, 1), Vector2(1, 0)];
			d_int = [7, 9, 8];
			if (cell1 / 8 == 1):
				d_coord.append(Vector2(2, 0));
				d_int.append(16);
		else:
			d_coord = [Vector2(-1, 1), Vector2(-1, -1), Vector2(-1, 0)];
			d_int = [-7, -9, -8];
			if (cell1 / 8 == 6):
				d_coord.append(Vector2(-2, 0));
				d_int.append(-16);
		for i in range(0, d_coord.size()):
			var coord = Utility.int_to_cell_vector(cell1) + d_coord[i];
			var cell2 = cell1 + d_int[i];
			if (min(coord.x, coord.y) >= 0 && max(coord.x, coord.y) < 8):
				if (i < 2):
					if (chessboard[cell2] != ".") && (Utility.is_upper_case(chessboard[cell2]) != Utility.is_upper_case(chessboard[cell1])):
						if (coord.x == 0 || coord.x == 7):
							move_list.append([cell2, MOVE.Promote]);
						else:
							move_list.append([cell2, MOVE.Normal]);
					
					#En passant:
					if (chessboard[cell2] == "."):
						if (most_recent_move.size() == 2) && (chessboard[most_recent_move[1]].to_lower() == "p") && (chessboard[most_recent_move[1]] != chessboard[cell1]):
							var coord1 = Utility.int_to_cell_vector(cell1);
							var coord2 = Utility.int_to_cell_vector(cell2);
							var coord3 = Utility.int_to_cell_vector(most_recent_move[0]);
							var coord4 = Utility.int_to_cell_vector(most_recent_move[1]);
							if (Utility.chebyshev_distance(coord3, coord4) == 2):
								if (Utility.manhattan_distance(coord1, coord4) == 1) && (coord1.x == coord4.x) && coord2 == Vector2((coord4.x + coord3.x) / 2, coord4.y):
									move_list.append([cell2, MOVE.EnPassant]);
				if (i >= 2):
					if (chessboard[cell2] == "."):
						if (coord.x == 0 || coord.x == 7):
							move_list.append([cell2, MOVE.Promote]);
						else:
							move_list.append([cell2, MOVE.Normal]);
					else:
						break;
							
	if (cur == "k"):
		var cell_is_white = Utility.is_upper_case(chessboard[cell1]);
		var posX = 7;
		if (cell_is_white):
			posX = 0;
		
		if (can_castle[int(cell_is_white)][0] == 1): #castle to the left
			var blocked:bool = false;
			for i in range(1, 4):
				if (chessboard[Utility.vector_to_cell_index(Vector2(posX, i))] != "."):
					blocked = true;
					break;
			if (!blocked):
				var attacked:bool = false;
				for i in range(2, 5):
					if (check_tile_attacked(Utility.vector_to_cell_index(Vector2(posX, i)), !cell_is_white)):
						attacked = true;
						break;
				if (!attacked):
					move_list.append([cell1 - 2, MOVE.Castle]);
		if (can_castle[int(cell_is_white)][1] == 1): #castle to the right
			var blocked:bool = false;
			for i in range(5, 7):
				if (chessboard[Utility.vector_to_cell_index(Vector2(posX, i))] != "."):
					blocked = true;
			if (!blocked):
				var attacked:bool = false;
				for i in range(4, 7):
					if (check_tile_attacked(Utility.vector_to_cell_index(Vector2(posX, i)), !cell_is_white)):
						attacked = true;
						break;
				if (!attacked):
					move_list.append([cell1 + 2, MOVE.Castle]);
	return move_list;
	
func generate_move() -> void:
	if updated:
		return;
	updated = true;
	available_move.clear();
	for i in range(0, 64):
		if (chessboard[i] != ".") && (Utility.is_upper_case(chessboard[i]) == white_move):
			var current_list: Array = generate_move_type_from_cell(i);
			for k in current_list:
				var tmp_board = deep_copy();
				if (k[1] == MOVE.Normal || k[1] == MOVE.Promote):
					tmp_board.normal_move(i, k[0]);
				if (k[1] == MOVE.Castle):
					tmp_board.castle(i, k[0]);
				if (k[1] == MOVE.EnPassant):
					tmp_board.en_passant(i, k[0]);
				if (tmp_board.in_check(white_move)):
					continue;
				if (k[1] != MOVE.Promote):
					available_move.append([i, k[0], k[1]]);
				else:
					for j in range(0, 4):
						available_move.append([i, k[0], k[1], j]);
						

func has_available_move() -> bool:
	generate_move();
	return available_move.size() > 0;

# <-------- Move Validator End -------->

# <-------- Game State Messing Start -------->

func checkmated(current_side: int) -> bool:
	if in_check(current_side):
		if (has_available_move()):
			return false;
		return true;
	return false;
	
func stalemated(current_side: int) -> bool:
	if !in_check(current_side):
		if (has_available_move()):
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
	var cnt= 0; var cur_hash = hash(chessboard.duplicate());
	for i in board_history_hash:
		if (i == cur_hash):
			cnt += 1;
			
	if (cnt >= 2):
		return three_repetition_rule;
	return none;

# <-------- Game State Messing End -------->
