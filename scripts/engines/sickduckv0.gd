extends Resource

class_name SickDuckV0;

func _init():
	pass;
	#I'm lost for words
	
func next_move(chessboard: ChessBoardWrapper) -> Array:
	var move_list: Array = chessboard.generate_move().duplicate(true);
	var rng = RandomNumberGenerator.new()
	rng.randomize();
	return move_list[rng.randi_range(0, move_list.size() - 1)];

func count_move(chessboard: ChessBoardWrapper, depth: int) -> int:
	if (depth == 0):
		return 1;
	if (chessboard.stupid_draw_check() != "None"):
		return 0;
	var ans: int = 0;
	var move_list: Array = chessboard.generate_move().duplicate(true);
	if (depth == 1):
		return move_list.size();
	
	for i in move_list:
		chessboard.do_move(i);
		ans += count_move(chessboard, depth - 1);
		chessboard.roll_back();
			
	return ans;
