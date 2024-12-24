using Godot;
using System;
using System.Text;
using System.Collections.Generic;


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
		ChessBoardUpdate cur = new ChessBoardUpdate(chessboard);
		cur.add_cell(cell1, chessboard.get_cell(cell1));
		cur.add_cell(cell2, chessboard.get_cell(cell2));
		board_history.Add(cur);
		
		chessboard.normal_move(cell1, cell2, is_actual_move);
	}
	public void castle(int cell1, int cell2){
		ChessBoardUpdate cur = new ChessBoardUpdate(chessboard);
		int l = 0, r = 4;
		if (cell1 < cell2) {
			l = 4; r = 7;
		}
		int poo = cell1 - cell1 % 8;
		for(int i = l; i <= r; ++i){
			cur.add_cell(poo + i, chessboard.get_cell(poo + i));
		}
		board_history.Add(cur);
		
		chessboard.castle(cell1, cell2);
	}
	public void en_passant(int cell1, int cell2){
		ChessBoardUpdate cur = new ChessBoardUpdate(chessboard);
		int cell3 = (cell1 - cell1 % 8) + (cell2 % 8);
		cur.add_cell(cell1, chessboard.get_cell(cell1));
		cur.add_cell(cell2, chessboard.get_cell(cell2));
		cur.add_cell(cell3, chessboard.get_cell(cell3));
		board_history.Add(cur);
		
		chessboard.en_passant(cell1, cell2);
	}
	public void promote(int cell, string s){
		chessboard.promote(cell, s);
	}
	public void do_move(ChessMove i){
		switch (i.get_move_type()){
			case 1:
				normal_move(i.get_move_start(), i.get_move_des());
				break;
			case 2:
				castle(i.get_move_start(), i.get_move_des());
				break;
			case 3:
				en_passant(i.get_move_start(), i.get_move_des());
				break;
			case 4:
				string[] gang = new string[]{"q", "r", "b", "n"};
				normal_move(i.get_move_start(), i.get_move_des(), false);
				promote(i.get_move_des(), gang[i.get_promote_type()]);
				break;
		}
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
		foreach (ChessMove i in chessboard.available_move)
			if (i.get_move_start() == cell1 && i.get_move_des() == cell2)
				return i.get_move_type();
		return 0;
	}
		
	public Godot.Collections.Array generate_move_from_cell(int cell1){
		chessboard.generate_move();
		Godot.Collections.Array ans = new Godot.Collections.Array();
		foreach (ChessMove i in chessboard.available_move)
			if (i.get_move_start() == cell1)
				if ((i.get_move_type() != 4) || (i.get_promote_type() == 0))
					ans.Add(Utility.int_to_cell_vector(i.get_move_des()));
		return ans;
	}
		
	public List<ChessMove> generate_move(){
		chessboard.generate_move();
		return chessboard.available_move;
	}
		
	public bool roll_back(){
		if (chessboard.is_continuing() == false || board_history.Count == 0)
			return false;
		ChessBoardUpdate cur = board_history[board_history.Count - 1];
		for(int i = 0; i < 2; ++i) {
			for(int j = 0; j < 2; ++j) chessboard.can_castle[i, j] = cur.can_castle[i, j];
			chessboard.castled[i] = cur.castled[i];
		}
		for(int i = 0; i < cur.size(); ++i){
			chessboard.set_cell(cur.get_cell_index(i), cur.get_cell_content(i));
		}
		board_history.RemoveAt(board_history.Count - 1);
		
		chessboard.white_move = !chessboard.white_move;
		chessboard.turn_off_update();
		chessboard.pop_back_history();
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
		
	public static void sigma(Vector2 ass){
		GD.Print("Hello\n");
	}
}
