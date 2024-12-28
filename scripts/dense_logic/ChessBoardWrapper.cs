using Godot;
using System;
using System.Numerics;
using System.Text;
using System.Collections.Generic;

public struct ChessMove{
	private int val;
	public ChessMove(int _start, int _des, int _move_type, int _promote_into = (int)0){
		val = _start + (_des << 6) + (_move_type << 12) + (_promote_into << 14);
	}
	public ChessMove(int _val){
		val = _val;
	}
	
	public int get_move_start(){
		return val & ((1 << 6)-1);
	}
	public int get_move_des(){
		return (val >> 6) & ((1 << 6)-1);
	}
	public int get_move_type(){
		return (val >> 12) & ((1 << 3)-1);
	}
	public int get_promote_type(){
		return (val >> 14);
	}
	public int get_val(){
		return val;
	}
}

struct ChessBoardUpdate{
	int val;
	public ChessBoardUpdate(ChessBoard board, ChessMove last, char c, bool pawn = false){
		val = 0;
		for(int i = 0; i < 2; ++i) {
			for(int j = 0; j < 2; ++j) if (board.can_castle[i, j])
				val += 1 << (i * 2 + j);
		}
		val += (last.get_val() << 4);
		val += ((int)c) << 20;
		if (pawn) val += 1 << 28;
	}
	
	public int get_can_castle(){
		return val & ((1 << 4) - 1);
	}
	public bool get_was_pawn(){
		return (val >> 28) == 1;
	}
	public ChessMove get_last_move(){
		return new ChessMove((val >> 4) & ((1 << 16) - 1));
	}
	public char get_captured_cell(){
		return (char)((val >> 20) & ((1 << 8) - 1));
	}
}

public partial class ChessBoardWrapper : Node
{
	string init_state = "";
	string selected_cell = "";
	ChessBoard chessboard;
	List<ChessBoardUpdate> board_history = new List<ChessBoardUpdate>();


// <------------------------ Literally wrapper starts ------------------------>
	public string get_cell(int cell){
		return new string(chessboard.get_cell(cell), 1);
	}
	public void set_cell(int cell, string val){
		chessboard.set_cell(cell, val[0]);
	}
	public static ChessBoardWrapper new_object(string starting){
		ChessBoardWrapper cur = new ChessBoardWrapper();
		cur.init_state = starting;
		cur.chessboard = ChessBoard.new_object(starting);
		cur.board_history = new List<ChessBoardUpdate>();
		cur.board_history.Capacity = 3000;
		
		GD.Print(System.Runtime.InteropServices.Marshal.SizeOf(typeof(ChessMove)));
		GD.Print(System.Runtime.InteropServices.Marshal.SizeOf(typeof(ChessBoardUpdate)));
		return cur;
	}
	public void reset_board(){
		chessboard.reset_board();
		board_history.Clear();
	}
	public bool is_continuing(){
		return chessboard.is_continuing();
	}
	public bool is_white_move(){
		return chessboard.is_white_move();
	}
	public void start_game(){
		chessboard.start_game();
	}
	public void end_game(){
		chessboard.end_game();
	}
	public int most_recent_move(int i){
		return chessboard.get_most_recent_move(i);
	}
	public void normal_move(int cell1, int cell2, bool is_actual_move = true){
		bool is_porn = (chessboard.get_cell(cell1) == 'p') || (chessboard.get_cell(cell1) == 'P');
		ChessBoardUpdate cur = 
			new ChessBoardUpdate(chessboard, new ChessMove(cell1, cell2, 0), 
			chessboard.get_cell(cell2), is_porn);
		board_history.Add(cur);
		
		chessboard.normal_move(cell1, cell2, is_actual_move);
	}
	public void castle(int cell1, int cell2){
		ChessBoardUpdate cur = 
			new ChessBoardUpdate(chessboard, new ChessMove(cell1, cell2, 1), '.');
		board_history.Add(cur);
		
		chessboard.castle(cell1, cell2);
	}
	public void en_passant(int cell1, int cell2){
		int cell3 = (cell1 - cell1 % 8) + (cell2 % 8);
		ChessBoardUpdate cur = 
			new ChessBoardUpdate(chessboard, 
			new ChessMove(cell1, cell2, 2), '.');
		board_history.Add(cur);
		
		chessboard.en_passant(cell1, cell2);
	}
	public void promote(int cell, string s){
		chessboard.promote(cell, s);
	}
	public void do_move(ChessMove i){
		switch (i.get_move_type()){
			case 0:
				normal_move(i.get_move_start(), i.get_move_des());
				break;
			case 1:
				castle(i.get_move_start(), i.get_move_des());
				break;
			case 2:
				en_passant(i.get_move_start(), i.get_move_des());
				break;
			case 3:
				string[] gang = new string[]{"q", "r", "b", "n"};
				normal_move(i.get_move_start(), i.get_move_des(), false);
				promote(i.get_move_des(), gang[i.get_promote_type()]);
				break;
		}
	}
	public void do_move(ChessMoveClass chessmove){
		int start = chessmove.get_move_start();
		int des = chessmove.get_move_des();
		int move_type = chessmove.get_move_type();
		int promote_into = chessmove.get_promote_type();
		ChessMove cur = 
			new ChessMove(start, des, move_type, promote_into);
		do_move(cur);
	}
	
	public bool in_check(bool current_side){
		bool cur = chessboard.in_check(current_side);
		return cur;
	}
	public bool checkmated(bool current_side){
		int tmp = (current_side) ? 1: 0;
		bool cur = chessboard.checkmated(tmp);
		return cur;
	}
	public bool stalemated(bool current_side){
		int tmp = (current_side) ? 1: 0;
		bool cur = chessboard.stalemated(tmp);
		return cur;
	}
	public string stupid_draw_check(){
		string cur = chessboard.stupid_draw_check();
		return cur;
	}
	

	public int validate_move(int cell1, int cell2){
		chessboard.generate_move();
		for(int i = 0; i < 4; ++i) {
			ulong cur = chessboard.possible_move[i,cell1];
			cur >>= cell2;
			if (cur % 2 == 1) return i;
		}
		return -1;
	}
		
	public Godot.Collections.Array generate_move_from_cell(int cell1){
		chessboard.generate_move();
		Godot.Collections.Array ans = new Godot.Collections.Array();
		for(int i = 0; i < 4; ++i){
			ulong cur = chessboard.possible_move[i, cell1];
			for(int j = 0; j < 64; ++j){
				if (cur % 2 == 1) ans.Add(Utility.int_to_cell_vector(j));
				cur >>= 1;
			}
		}
		return ans;
	}
	
	public int count_possible_move(){
		chessboard.generate_move();
		int ans = 0;
		for(int i = 0; i < 4; ++i){
			ulong ally_pieces = chessboard.ally_pieces;
			while(ally_pieces > 0) {
				int j = BitOperations.TrailingZeroCount(ally_pieces);
				ally_pieces -= ((ulong)1 << j);
				ulong cur = chessboard.possible_move[i, j];
				while(cur > 0){
					int k = BitOperations.TrailingZeroCount(cur);
					cur -= (((ulong)1) << k);
					
					if (i < 3)
						ans++;
					else ans += 4;
				}
			}
		}
		return ans;
	}
		
	public List<ChessMove> generate_move(){
		chessboard.generate_move();
		
		List<ChessMove> ans = new List<ChessMove>();
		ans.Capacity = 250;
		for(int i = 0; i < 4; ++i) {
			ulong ally_pieces = chessboard.ally_pieces;
			
			while(ally_pieces > 0) {
				int j = BitOperations.TrailingZeroCount(ally_pieces);
				ally_pieces -= ((ulong)1 << j);
				ulong cur = chessboard.possible_move[i, j];
				while(cur > 0){
					int k = BitOperations.TrailingZeroCount(cur);
					cur -= (((ulong)1) << k);
					
					if (i < 3){
						ans.Add(new ChessMove(j, k, i));
					}
					else {
						for(int t = 0; t < 4; ++t)
							ans.Add(new ChessMove(j, k, i, t));
					}
				}
			}
		}
		
		return ans;
	}
	
	private void undo_move(ChessBoardUpdate cur){
		int can_castle = cur.get_can_castle();
		for(int i = 0; i < 2; ++i) {
			for(int j = 0; j < 2; ++j){
				int cu_bit = (can_castle >> (i * 2 + j)) & 1;
				chessboard.can_castle[i, j] = (cu_bit == 1) ;
			}
		}
		ChessMove last_move = cur.get_last_move();
		int cell1 = last_move.get_move_start(), cell2 = last_move.get_move_des(), 
			type = last_move.get_move_type();
		bool was_pawn = cur.get_was_pawn();
		char captured_cell = cur.get_captured_cell();
		switch(type){
			case 0:
				chessboard.set_cell(cell1, chessboard.get_cell(cell2));
				chessboard.set_cell(cell2, captured_cell);
				if (was_pawn){
					char cell1_piece = 'P';
					if (char.IsLower(chessboard.get_cell(cell1)))
						cell1_piece = 'p';
					chessboard.set_cell(cell1, cell1_piece);
				}
				break;
			case 1:
				if (cell2 < cell1){ // castle to the left
					chessboard.set_cell(cell1 - 4, chessboard.get_cell(cell2+1));
					chessboard.set_cell(cell1, chessboard.get_cell(cell2));
					chessboard.set_cell(cell2, '.');
					chessboard.set_cell(cell2+1, '.');
				}
				else{
					chessboard.set_cell(cell1 + 3, chessboard.get_cell(cell2-1));
					chessboard.set_cell(cell1, chessboard.get_cell(cell2));
					chessboard.set_cell(cell2, '.');
					chessboard.set_cell(cell2-1, '.');
				}
				break;
			case 2:
				chessboard.set_cell(cell1, chessboard.get_cell(cell2));
				chessboard.set_cell(cell2, captured_cell);
				int cell3 = cell1 - cell1 % 8 + cell2 % 8;
				char cell3_piece = 'P';
				if (char.IsUpper(chessboard.get_cell(cell1)))
					cell3_piece = 'p';
				chessboard.set_cell(cell3, cell3_piece);
				break;
		}
	}
		
	public bool roll_back(){
		if (chessboard.is_continuing() == false || board_history.Count == 0)
			return false;
		chessboard.white_move = !chessboard.white_move;
		chessboard.turn_off_update();
		chessboard.pop_back_history();
		
		undo_move(board_history[board_history.Count - 1]);
		board_history.RemoveAt(board_history.Count - 1);
		
		return true;
	}
// <------------------------ Literally wrapper ends ------------------------>

	public Godot.Collections.Array press_on_cell(string cur_cell){
		Godot.Collections.Array ans = new Godot.Collections.Array();
		if (selected_cell == ""){ // if not selecting any cell, select the cell
			int cell = Utility.cell_notation_to_int(cur_cell);
			char val = chessboard.get_cell(cell);
			if ((val != '.') && (char.IsUpper(val) == chessboard.is_white_move()))
				selected_cell = cur_cell;
			return ans;
		}
		else{
			int cell1 = Utility.cell_notation_to_int(selected_cell);
			int cell2 = Utility.cell_notation_to_int(cur_cell);

			char val1 = chessboard.get_cell(cell1);
			char val2 = chessboard.get_cell(cell2);
			if (val2 != '.' && (char.IsUpper(val1) == char.IsUpper(val2))){ // if clicked on the same cell, cancel
				selected_cell = cur_cell;
				return ans;
			}
			else{
				int check = validate_move(cell1, cell2);
				ans = new Godot.Collections.Array(){check, cell1, cell2};
				selected_cell = "";
				return ans;
			}
		}
	}
}
