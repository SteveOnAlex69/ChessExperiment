using Godot;
using System;
using System.Text;
using System.Collections.Generic;


public partial class CsharpTest : Node
{
	public static CsharpTest new_object(string starting){
		CsharpTest cur = new CsharpTest();
		return cur;
	}
	
	public ChessMove next_move(ChessBoardWrapper chessboard){
		List<ChessMove> move_list = new List<ChessMove>(chessboard.generate_move());
		Random rng = new Random();
		return move_list[rng.Next(0, move_list.Count)];
	}
	
	public int count_move(ChessBoardWrapper chessboard, int depth){
		if (depth == 0) return 1;
		if (chessboard.stupid_draw_check() != "None") return 1;
		int ans = 0;
		List<ChessMove> move_list = new List<ChessMove>(chessboard.generate_move());
		if (depth == 1) return move_list.Count;
		foreach (ChessMove i in move_list){
			chessboard.do_move(i);
			ans += count_move(chessboard, depth - 1);
			chessboard.roll_back();
		}
		return ans;
	}
		
	public static void sigma(Vector2 ass){
		GD.Print("Hello\n");
	}
}
