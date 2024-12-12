extends Resource

class_name SickDuckV0;

func _init():
	pass;
	#I'm lost for words

func count_move(chessboard: ChessBoardWrapper, depth: int) -> int:
	if (depth == 0):
		return 1;
	var ans = 0;
	var move_list = chessboard.generate_move().duplicate(true);
	if (depth == 1):
		return move_list.size();
	
	var cnt = 2;
	for i in move_list:
		match i[2]:
			1:
				chessboard.normal_move(i[0], i[1]);
			2:
				chessboard.castle(i[0], i[1]);
			3:
				chessboard.en_passant(i[0], i[1]);
			4:
				chessboard.normal_move(i[0], i[1], 0);
				chessboard.promote(i[1], ["q", "r", "b", "k"][i[3]]);
		ans += count_move(chessboard, depth - 1);
		chessboard.roll_back();
			
	return ans;
