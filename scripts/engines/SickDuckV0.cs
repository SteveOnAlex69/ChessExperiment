using Godot;
using System;
using System.Text;
using System.Collections.Generic;
using System.Diagnostics;


public partial class SickDuckV0 : Node
{
	public static SickDuckV0 new_object(){
		SickDuckV0 cur = new SickDuckV0();
		return cur;
	}
	
	public ChessMoveClass next_move(ChessBoardWrapper chessboard){
		List<ChessMove> move_list = new List<ChessMove>(chessboard.generate_move());
		Random rng = new Random();
		return new ChessMoveClass(move_list[rng.Next(0, move_list.Count)]);
	}
	
	public int count_move(ChessBoardWrapper chessboard, int depth){
		if (depth == 0) return 1;
		if (chessboard.stupid_draw_check() != "None") 
			return 1;
		if (depth == 1) return chessboard.count_possible_move();
		
		int ans = 0;
		List<ChessMove> move_list = chessboard.generate_move();
		foreach (ChessMove i in move_list){
			chessboard.do_move(i);
			ans += count_move(chessboard, depth - 1);
			chessboard.roll_back();
		}
		move_list.Clear();
		return ans;
	}
}
