extends Resource

class_name SickDuckV0;

func _init():
	pass;
	#I'm lost for words

func count_move(chessboard: ChessBoardWrapper, depth: int) -> int:
	if (depth == 0):
		return 1;
	var ans = 0;
	var move_list = chessboard.generate_move();
	for i in move_list:
		if (i.size() == 3):
			match i[2]:
				1:
					chessboard.normal_move(i[0], i[1]);
				2:
					chessboard.castle(i[0], i[1]);
				3:
					chessboard.en_passant(i[0], i[1]);
		else:
			pass
		ans += count_move(chessboard, depth - 1);
		chessboard.roll_back();
	return ans;
