extends Resource

class_name ChessBoardWrapper;

var init_state: String;
var selected_cell: String;
var chessboard: ChessBoard;
var board_history: Array;


# <---- Literally wrapper starts ---->
func get_cell(cell:int) -> String:
	return chessboard.get_cell(cell);

func set_cell(cell:int, val:String) -> void:
	chessboard.set_cell(cell, val);

func _init(starting:String):
	init_state = starting;
	chessboard = ChessBoard.new(starting);
	
func reset_board() -> void:
	chessboard.reset_board();
	board_history.clear();
	
func is_continuing() -> bool:
	return chessboard.is_continuing();
	
func is_white_move() -> bool:
	return chessboard.is_white_move();
	
func start_game() -> void:
	chessboard.start_game();
	board_history.append(chessboard.deep_copy());
	
func end_game() -> void:
	chessboard.end_game();
	
func most_recent_move(i: int) -> int:
	return chessboard.most_recent_move[i];
	
func normal_move(cell1: int, cell2: int, is_actual_move: bool = true) -> void:
	chessboard.normal_move(cell1, cell2, is_actual_move);
	board_history.append(chessboard.deep_copy());
	
func castle(cell1: int, cell2: int) -> void:
	chessboard.castle(cell1, cell2);
	board_history.append(chessboard.deep_copy());
	
func en_passant(cell1: int, cell2: int) -> void:
	chessboard.en_passant(cell1, cell2);
	board_history.append(chessboard.deep_copy());
	
func promote(cell: int, s: String) -> void:
	board_history.pop_back();
	chessboard.promote(cell, s);
	board_history.append(chessboard.deep_copy());
	
func in_check(current_side: bool) -> bool:
	return chessboard.in_check(current_side);

func validate_move(cell1: int, cell2: int) -> int: #validate_move, but perform check check
	return chessboard.validate_move(cell1, cell2);

func find_valid_move_from_cell(cell1: int) -> bool:
	return chessboard.find_valid_move_from_cell(cell1);

func generate_move_from_cell(cell1: int) -> Array:
	return chessboard.generate_move_from_cell(cell1);
	
func generate_move_type_from_cell(cell1: int) -> Array:
	return chessboard.generate_move_type_from_cell(cell1);
	
func generate_move() -> Array:
	return chessboard.generate_move();
	
func roll_back() -> bool:
	if (chessboard.is_continuing() == false) || (board_history.size() <= 1):
		return false;
	board_history.pop_back();
	chessboard = board_history.back().deep_copy();
	return true;
	
func checkmated(current_side: int) -> bool:
	return chessboard.checkmated(current_side);
	
func stalemated(current_side: int) -> bool:
	return chessboard.stalemated(current_side);
	
func stupid_draw_check() -> String:
	return chessboard.stupid_draw_check();

# <------- Literally wrapper ends ----->

func press_on_cell(cur_cell: String) -> Array:
	var ans: Array;
	if (selected_cell == ""): # if not selecting any cell, select the cell
		var cell = Utility.cell_notation_to_int(cur_cell);
		var val = chessboard.get_cell(cell);
		if (val != ".") && (Utility.is_upper_case(val) == chessboard.is_white_move()):
			selected_cell = cur_cell;
			return ans;
		return ans;
	else:
		var cell1 = Utility.cell_notation_to_int(selected_cell);
		var cell2 = Utility.cell_notation_to_int(cur_cell);

		var val1 = chessboard.get_cell(cell1);
		var val2 = chessboard.get_cell(cell2);
		if val2 != "." && (Utility.is_upper_case(val1) == Utility.is_upper_case(val2)): # if clicked on the same cell, cancel
			selected_cell = cur_cell;
			return ans;
		else:
			var check = chessboard.validate_move(cell1, cell2);
			ans = [check, cell1, cell2];
			selected_cell = "";
			return ans;
