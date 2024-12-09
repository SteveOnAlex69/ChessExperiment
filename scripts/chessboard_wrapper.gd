extends Resource

class_name ChessBoardWrapper;

var init_state;
var chessboard: ChessBoard;
var board_history: Array;

func get_cell(cell:int):
	return chessboard.get_cell(cell);

func set_cell(cell:int, val:String):
	chessboard.set_cell(cell, val);

func _init(starting:String):
	init_state = starting;
	chessboard = ChessBoard.new(starting);
	
func reset_board():
	chessboard.reset_board();
	board_history.clear();
	
func is_continuing() -> bool:
	return chessboard.is_continuing();
	
func is_white_move() -> bool:
	return chessboard.is_white_move;
	
func start_game():
	chessboard.start_game();
	board_history.append(chessboard.deep_copy());
	
func end_game():
	chessboard.end_game();
	
func most_recent_move(i: int):
	return chessboard.most_recent_move[i];
	
func normal_move(cell1: int, cell2: int, is_actual_move: bool = true):
	chessboard.normal_move(cell1, cell2, is_actual_move);
	board_history.append(chessboard.deep_copy());
	
func castle(cell1: int, cell2: int):
	chessboard.castle(cell1, cell2);
	board_history.append(chessboard.deep_copy());
	
func en_passant(cell1: int, cell2: int):
	chessboard.castle(cell1, cell2);
	board_history.append(chessboard.deep_copy());
	
func promote(cell: int, s: String):
	board_history.pop_back();
	chessboard.promote(cell, s);
	board_history.append(chessboard.deep_copy());
	
func in_check(current_side: bool):
	return chessboard.in_check(current_side);

func validate_move(cell1: int, cell2: int): #validate_move, but perform check check
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
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
