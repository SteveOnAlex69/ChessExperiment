using Godot;
using System;
using System.Text;
using System.Collections.Generic;


public partial class ChessBoard : Node
{
	enum MOVE {Invalid, Normal, Castle, EnPassant, Promote};

	string init_state;
	char[] chessboard = new char[64];
	public bool[,] can_castle = new bool[2, 2];
	public bool[] castled = new bool[2];
	public bool white_move = true;
	bool game_continuing = false;
	int fifty_move_counter;
	
	List<int> board_history_hash = new List<int>();
	int[] most_recent_move = new int[2];
	bool updated = false;
	public List<ChessMove> available_move = new List<ChessMove>();
	
// <------------------------ Simple stuff starts ------------------------>
	public static ChessBoard new_object(string starting){
		ChessBoard cur = new ChessBoard();
		cur.init_state = starting;
		cur.available_move.Capacity = 336;
		cur.reset_board();
		return cur;
	}
	
	public bool is_white_move(){
		return white_move;
	}
	
	public bool is_continuing(){
		return game_continuing;
	}
	
	public int get_most_recent_move(int i){
		return most_recent_move[i];
	}
	
	public void start_game(){
		game_continuing = true;
	}
	
	public void end_game(){
		game_continuing = false;
	}
	
	public void reset_board(){
		for(int i = 0; i < 64; ++i) chessboard[i] = init_state[i];
		white_move = true;
		fifty_move_counter = 100;
		board_history_hash.Clear();
		updated = false;
		for(int x=  0; x <= 1; ++x){
			for(int y = 0; y <= 1; ++y){
				can_castle[x,y] = true;
			}
			most_recent_move[x] = -1;
			castled[x] = false;
		}
		
		if (chessboard[Utility.cell_notation_to_int("a5")] != 'K')
			can_castle[1,0] = can_castle[1,1] = false;
		if (chessboard[Utility.cell_notation_to_int("h5")] != 'k')
			can_castle[0,0] = can_castle[0,1] = false;
		if (chessboard[Utility.cell_notation_to_int("a1")] != 'R')
			can_castle[1,0] = false;
		if (chessboard[Utility.cell_notation_to_int("a8")] != 'R')
			can_castle[1,1] = false;
		if (chessboard[Utility.cell_notation_to_int("h1")] != 'r')
			can_castle[0,0] = false;
		if (chessboard[Utility.cell_notation_to_int("h8")] != 'r')
			can_castle[0,1] = false;
	}
	
	public char get_cell(int cell){
		return chessboard[cell];
	}
	
	public void set_cell(int cell, char val){
		chessboard[cell] = val;
	}
	
	private int hash_chessboard(){
		const int MOD = (int)(1e9 + 7), BASE = 307;
		long ans = 0;
		long cur = 1;
		for(int i = 0; i < 64; ++i){
			ans = (ans + cur * chessboard[i]) % MOD;
			cur = (cur * BASE) % MOD;
		}
		return (int)ans;
	}
	
	private void update_history(bool fifty_move_reset = false){
		white_move = !white_move;
		if (fifty_move_reset){
			fifty_move_counter = 100;
		}
		else{
			fifty_move_counter -= 1;
		}
	}
	
	private char to_lower_char(char c){
		if (c >= 'A' && c <= 'Z') 
			return (char)((int)c - ((int)'A' - (int)'a'));
		return c;
	}
	
	private void disable_castling_rook(int cell){
		var pos = Utility.int_to_cell_vector(cell);
		if (to_lower_char(chessboard[cell]) == 'r' && (pos.Y == 0 || pos.Y == 7)){
			int x = (pos.X == 0) ? 1 : 0, y = (pos.Y == 7) ? 1 : 0;
			can_castle[x,y] = false;
		}
	}
	
	public ChessBoard deep_copy(){
		ChessBoard tmp = new_object(init_state);
		
		tmp.white_move = white_move;
		tmp.game_continuing = game_continuing;
		tmp.fifty_move_counter = fifty_move_counter;
		tmp.updated = false;
		
		for(int i = 0; i < 64; ++i) tmp.chessboard[i] = chessboard[i];
		for(int i = 0; i < 2; ++i){
			tmp.castled[i] = castled[i];
			tmp.most_recent_move[i] = most_recent_move[i];
			for(int j = 0; j < 2; ++j){
				tmp.can_castle[i,j] = can_castle[i, j];
			}
		}
		tmp.board_history_hash = new List<int>(board_history_hash);
		return tmp;
	}
	
	
// <------------------------ Simple stuff ends ------------------------>

// <------------------------ Handling move starts ------------------------>
	
	public void normal_move(int cell1, int cell2, bool is_actual_move = true){
		if (is_actual_move){
			update_history((to_lower_char(chessboard[cell1]) == 'p') || (chessboard[cell2] != '.'));
		}
		board_history_hash.Add(hash_chessboard());
		updated = false;
		disable_castling_rook(cell1);
		disable_castling_rook(cell2);
		
		if (chessboard[cell1] == 'K'){
			can_castle[1,0] = can_castle[1,1] = false;
			castled[1] = true;
		}
		if (chessboard[cell1] == 'k'){
			can_castle[0,0] = can_castle[0,1] = false;
			castled[0] = true;
		}
		chessboard[cell2] = chessboard[cell1];
		chessboard[cell1] = '.';
		most_recent_move[0] = cell1; most_recent_move[1] = cell2;
	}
	
	public void castle(int cell1, int cell2){
		board_history_hash.Add(hash_chessboard());
		update_history(false);
		normal_move(cell1, cell2, false);
		Vector2 coord1 = Utility.int_to_cell_vector(cell1);
		Vector2 coord2 = Utility.int_to_cell_vector(cell2);
		if (coord1.Y > coord2.Y){
			int cell3 = Utility.vector_to_cell_index(new Vector2(coord2.X, 0));
			int cell4 = Utility.vector_to_cell_index(new Vector2(coord2.X, coord2.Y + 1));
			normal_move(cell3, cell4, false);
		}
		else{
			int cell3 = Utility.vector_to_cell_index(new Vector2(coord2.X, 7));
			int cell4 = Utility.vector_to_cell_index(new Vector2(coord2.X, coord2.Y - 1));
			normal_move(cell3, cell4, false);
		}
		updated = false;
	}

	public void en_passant(int cell1, int cell2){
		board_history_hash.Add(hash_chessboard());
		update_history(true);
		normal_move(cell1, cell2, false);
		
		int cell3 = (cell1 - cell1 % 8) + cell2 % 8;
		normal_move(cell3, cell3, false);
		updated = false;
	}
	
	public void promote(int cell, string s){
		s = s.ToLower();
		if (white_move)
			s = s.ToUpper();
		chessboard[cell] = s[0];
		white_move = !white_move;
		updated = false;
	}
	
	
// <------------------------ Handling move ends ------------------------>
//
// <------------------------ Move Validator Start ------------------------>

	public bool check_tile_attacked(int cell, bool opponent_side){
		Vector2 cur_coord = Utility.int_to_cell_vector(cell);
		List<Vector2> d_coord;
		List<int> d_int;
		// check rook, bishop and queen
		d_coord = new List<Vector2>{new Vector2(1, 0), new Vector2(0, 1), new Vector2(0, -1), new Vector2(-1, 0), 
			new Vector2(1, 1), new Vector2(-1, -1), new Vector2(1, -1), new Vector2(-1, 1)};
		d_int = new List<int>{8, 1, -1, -8, 9, -9, 7, -7};
		
		for(int i = 0; i < d_coord.Count; ++i){
			char[] antagonist = new char[2];
			antagonist[0] = 'q';
			if (i >= 4) antagonist[1] = 'b';
			else antagonist[1] = 'r';
			Vector2 coord = cur_coord+ d_coord[i];
			int _cell = cell + d_int[i];
			
			while(Math.Min(coord.X, coord.Y) >= 0 && Math.Max(coord.X, coord.Y) < 8){
				if (chessboard[_cell] != '.') {
					if (char.IsUpper(chessboard[_cell]) != opponent_side)
						break;
					var cur = to_lower_char(chessboard[_cell]);
					if (antagonist[0] == cur || antagonist[1] == cur)
						return true;
					break;
				}
				coord += d_coord[i];
				_cell += d_int[i];
			}
		}
	
		
		// check knight
		d_coord = new List<Vector2>{new Vector2(1, 2), new Vector2(2, 1), new Vector2(1, -2), new Vector2(2, -1), 
				new Vector2(-1, 2), new Vector2(-2, 1), new Vector2(-1, -2), new Vector2(-2, -1)};
		d_int = new List<int>{10, 17, 6, 15, -6, -15, -10, -17};
		for (int i = 0; i < d_coord.Count; ++i){
			Vector2 coord = cur_coord + d_coord[i];
			int _cell = cell + d_int[i];
			if (Math.Min(coord.X, coord.Y) >= 0 && Math.Max(coord.X, coord.Y) < 8){
				if ((to_lower_char(chessboard[_cell]) == 'n') && (char.IsUpper(chessboard[_cell]) == opponent_side))
					return true;
			}
		}
		
		
		//check king
		d_coord = new List<Vector2>{new Vector2(-1, -1), new Vector2(-1, 0), new Vector2(-1, 1), new Vector2(0, -1), 
			new Vector2(0, 1), new Vector2(1, -1), new Vector2(1, 0), new Vector2(1, 1)};
		d_int = new List<int>{-9, -8, -7,  -1, 1, 7, 8, 9};
		for(int i = 0; i < d_coord.Count; ++i){
			Vector2 coord = cur_coord + d_coord[i];
			int _cell = cell + d_int[i];
			if (Math.Min(coord.X, coord.Y) >= 0 && Math.Max(coord.X, coord.Y) < 8){
				if ((to_lower_char(chessboard[_cell]) == 'k') && (char.IsUpper(chessboard[_cell]) == opponent_side))
					return true;
			}
		}
		
		//check pawn
		if (opponent_side == false){
			d_coord = new List<Vector2>{new Vector2(1, -1), new Vector2(1, 1)};
			d_int = new List<int>{7, 9};
		}
		else{
			d_coord = new List<Vector2>{new Vector2(-1, -1), new Vector2(-1, 1)};
			d_int = new List<int>{-9, -7};
		}
		for(int i = 0; i < d_coord.Count; ++i){
			Vector2 coord = cur_coord + d_coord[i];
			int _cell = cell + d_int[i];
			if (Math.Min(coord.X, coord.Y) >= 0 && Math.Max(coord.X, coord.Y) < 8){
				if ((to_lower_char(chessboard[_cell]) == 'p') && (char.IsUpper(chessboard[_cell]) == opponent_side))
					return true;
			}
		}
		
		return false;
	}
	
	public bool in_check(bool current_side){
		char cur = (current_side) ? 'K' : 'k';
		for(int i = 0; i < 64; ++i) {
			if (chessboard[i] == cur) {
				bool ans = check_tile_attacked(i, !current_side);
				return ans;
			}
		}
		return false;
	}
	
	private List<ChessMove> generate_move_type_from_cell(int cell1){
		List<ChessMove> move_list = new List<ChessMove>();
		char cur = to_lower_char(chessboard[cell1]);
		if (chessboard[cell1] == '.')
			return move_list;
		move_list.Capacity = 30;
		// Normal Move
		if (cur == 'b' || cur == 'r' || cur == 'q'){
			List<Vector2> d_coord = new List<Vector2>{new Vector2(1, 0), new Vector2(0, 1), new Vector2(0, -1), new Vector2(-1, 0), 
				new Vector2(1, 1), new Vector2(-1, -1), new Vector2(1, -1), new Vector2(-1, 1)};
			List<int> d_int = new List<int>{8, 1, -1, -8, 9, -9, 7, -7};
			
			int l = 0, r = 8;
			if (cur == 'r') r = 4;
			if (cur == 'b') l = 4;
				
			for(int i = l; i < r; ++i){
				Vector2 coord = Utility.int_to_cell_vector(cell1) + d_coord[i];
				int cell2 = cell1 + d_int[i];
				while(Math.Min(coord.X, coord.Y) >= 0 && Math.Max(coord.X, coord.Y) < 8){
					if ((chessboard[cell2] != '.') && (char.IsUpper(chessboard[cell2]) == char.IsUpper(chessboard[cell1])))
						break;
					move_list.Add(new ChessMove(cell1, cell2, (int)MOVE.Normal));
					if (chessboard[cell2] != '.')
						break;
					coord += d_coord[i];
					cell2 += d_int[i];
				}
			}
		}
		
		if (cur == 'k' || cur == 'n'){
			List<Vector2> d_coord;
			List<int> d_int;
			if (cur == 'n'){
				d_coord = new List<Vector2>{new Vector2(1, 2), new Vector2(2, 1), new Vector2(1, -2), new Vector2(2, -1), 
					new Vector2(-1, 2), new Vector2(-2, 1), new Vector2(-1, -2), new Vector2(-2, -1)};
				d_int = new List<int>{10, 17, 6, 15, -6, -15, -10, -17};
			}
			else{
				d_coord = new List<Vector2>{new Vector2(-1, -1), new Vector2(-1, 0), new Vector2(-1, 1), new Vector2(0, -1), 
					new Vector2(0, 1), new Vector2(1, -1), new Vector2(1, 0), new Vector2(1, 1)};
				d_int = new List<int>{-9, -8, -7,  -1, 1, 7, 8, 9};
			}
				
			for(int i = 0; i < d_coord.Count; ++i){
				Vector2 coord = Utility.int_to_cell_vector(cell1) + d_coord[i];
				int cell2 = cell1 + d_int[i];
				if (Math.Min(coord.X, coord.Y) >= 0 && Math.Max(coord.X, coord.Y) < 8){
					if ((chessboard[cell2] == '.') || (char.IsUpper(chessboard[cell2]) != char.IsUpper(chessboard[cell1])))
						move_list.Add(new ChessMove(cell1, cell2, (int)MOVE.Normal));
				}
			}
		}
		
		// pawn
		if (cur == 'p'){
			List<Vector2> d_coord;
			List<int> d_int;
			if (chessboard[cell1] == 'P'){
				d_coord = new List<Vector2> {new Vector2(1, -1), new Vector2(1, 1), new Vector2(1, 0)};
				d_int = new List<int>{7, 9, 8};
				if (cell1 / 8 == 1){
					d_coord.Add(new Vector2(2, 0));
					d_int.Add(16);
				}
			}
			else{
				d_coord = new List<Vector2> {new Vector2(-1, -1), new Vector2(-1, 1), new Vector2(-1, 0)};
				d_int = new List<int>{-9, -7, -8};
				if (cell1 / 8 == 6){
					d_coord.Add(new Vector2(-2, 0));
					d_int.Add(-16);
				}
			}
			for(int i = 0; i < d_coord.Count; ++i){
				Vector2 coord = Utility.int_to_cell_vector(cell1) + d_coord[i];
				int cell2 = cell1 + d_int[i];
				if (Math.Min(coord.X, coord.Y) >= 0 && Math.Max(coord.X, coord.Y) < 8){
					if (i < 2){ // capture move
						if ((chessboard[cell2] != '.') && (char.IsUpper(chessboard[cell2]) != char.IsUpper(chessboard[cell1]))){
							if (coord.X == 0 || coord.X == 7) 
								move_list.Add(new ChessMove(cell1, cell2, (int)MOVE.Promote));
							else move_list.Add(new ChessMove(cell1, cell2, (int)MOVE.Normal));
						}
						
						//En passant:
						if (chessboard[cell2] == '.'){
							if ((most_recent_move[0] != -1) && (to_lower_char(chessboard[most_recent_move[1]]) == 'p') 
								&& (chessboard[most_recent_move[1]] != chessboard[cell1])){
								Vector2 coord1 = Utility.int_to_cell_vector(cell1);
								Vector2 coord2 = Utility.int_to_cell_vector(cell2);
								Vector2 coord3 = Utility.int_to_cell_vector(most_recent_move[0]);
								Vector2 coord4 = Utility.int_to_cell_vector(most_recent_move[1]);
								if (Utility.chebyshev_distance(coord3, coord4) == 2)
									if ((Utility.manhattan_distance(coord1, coord4) == 1) && (coord1.X == coord4.X) 
										&& coord2 == new Vector2((coord4.X + coord3.X) / 2, coord4.Y))
										move_list.Add(new ChessMove(cell1, cell2, (int)MOVE.EnPassant));
							}
						}
					}
					else{ // non-capture move
						if (chessboard[cell2] == '.'){
							if (coord.X == 0 || coord.X == 7)
								move_list.Add(new ChessMove(cell1, cell2, (int)MOVE.Promote));
							else
								move_list.Add(new ChessMove(cell1, cell2, (int)MOVE.Normal));
						}
						else break;
					}
				}
			}
		}
								
		
		// Castle
		if (cur == 'k'){
			int cell_is_white = (char.IsUpper(chessboard[cell1])) ? 1: 0;
			bool cell_is_white_b = char.IsUpper(chessboard[cell1]);
			int posX = 7;
			if (cell_is_white == 1)
				posX = 0;
			if (can_castle[cell_is_white,0]){ //castle to the left
				bool blocked=  false;
				for(int i = 1; i <= 3; ++i)
					if (chessboard[Utility.vector_to_cell_index(new Vector2(posX, i))] != '.'){
						blocked = true;
						break;
					}
				if (!blocked){
					bool attacked = false;
					for(int i = 2; i <= 4; ++i){
						if (check_tile_attacked(Utility.vector_to_cell_index(new Vector2(posX, i)), !cell_is_white_b)){
							attacked = true;
							break;
						}
					}
					if (!attacked)
						move_list.Add(new ChessMove(cell1, cell1 - 2, (int)MOVE.Castle));
				}
			}
			if (can_castle[cell_is_white,1]){ //castle to the right
				bool blocked = false;
				for(int i = 5; i <= 6; ++i)
					if (chessboard[Utility.vector_to_cell_index(new Vector2(posX, i))] != '.'){
						blocked = true;
						break;
					}
				if (!blocked){
					bool attacked = false;
					for(int i = 4; i <= 6; ++i){
						if (check_tile_attacked(Utility.vector_to_cell_index(new Vector2(posX, i)), !cell_is_white_b)){
							attacked = true;
							break;
						}
					}
					if (!attacked)
						move_list.Add(new ChessMove(cell1, cell1 + 2, (int)MOVE.Castle));
				}
			}
		}
		return move_list;
	}
		
	public void turn_off_update(){updated= false;}
	public void pop_back_history(){
		if (board_history_hash.Count == 0) return;
		board_history_hash.RemoveAt(board_history_hash.Count - 1);
	}
	
	public void generate_move(){
		if (updated) return;
		updated = true;
		available_move.Clear();
		
		
		//ulong starting = Time.GetTicksUsec();
		//ulong ending = Time.GetTicksUsec();
		//
		//GD.Print("Time elapsed by engine: ", ending - starting, " micro seconds");
		for(int i = 0; i < 64; ++i){
			if ((chessboard[i] != '.') && (char.IsUpper(chessboard[i]) == white_move)){
				List<ChessMove> current_list = generate_move_type_from_cell(i);
				foreach (var k in current_list){
					//var tmp_board = deep_copy();
					//if (k.get_move_type() == (int)MOVE.Normal || k.get_move_type() == (int)MOVE.Promote)
						//tmp_board.normal_move(i, k.get_move_des());
					//if (k.get_move_type() == (int)MOVE.Castle)
						//tmp_board.castle(i, k.get_move_des());
					//if (k.get_move_type() == (int)MOVE.EnPassant)
						//tmp_board.en_passant(i, k.get_move_des());
					//if (tmp_board.in_check(white_move))
						//continue;
					if (k.get_move_type() != (int)MOVE.Promote){
						available_move.Add(k);
					}
					else{
						for(int j = 0; j < 4; ++j)
							available_move.Add(new ChessMove(k.get_move_start(), k.get_move_des(), k.get_move_type(), j));
					}
				}
			}
		}
	}
							

	public bool has_available_move(){
		generate_move();
		return available_move.Count > 0;
	}
	
	
// <------------------------ Move Validator End ------------------------>
//
// <------------------------ Game State Messing Start ------------------------>
	public bool checkmated(int current_side){
		if (in_check(current_side == 1)){
			if (has_available_move()){
				return false;
			}
			return true;
		}
		return false;
	}
	public bool stalemated(int current_side){
		if (!in_check(current_side == 1)){
			if (has_available_move()){
				return false;
			}
			return true;
		}
		return false;
	}
		
	public string stupid_draw_check(){
		string none = "None";
		string insufficient_material = "Draw by insufficient material!";
		string fifty_move_rule = "Draw by Fifty-Move rule!";
		string three_repetition_rule = "Draw by 3-Repetition rule!";
		
		// Fifty move rule: if no capture and pawn move happen in 50 move, draw
		if (fifty_move_counter <= 0)
			return fifty_move_rule;
		
		// draw by insufficient material: happen if one side only have a king left
		// and the other also have nothing, or a knight or a bishop
		List<char> remaining_pieces = new List<char>();
		for(int i = 0; i < 64; ++i){
			if ((chessboard[i] != '.') && (to_lower_char(chessboard[i]) != 'k'))
				remaining_pieces.Add(to_lower_char(chessboard[i]));
			if (remaining_pieces.Count > 1)
				break;
		}
		if (remaining_pieces.Count <= 1){
			if (remaining_pieces.Count == 0) return insufficient_material;
			if (remaining_pieces[0] == 'b' || remaining_pieces[0] == 'n')
				return insufficient_material;
		}
		
		// If a board state is repeated 3 times, draw
		int cnt= 0; int cur_hash = hash_chessboard();
		foreach (var i in board_history_hash){
			if (i == cur_hash)
				cnt += 1;
		}
				
		if (cnt >= 2)
			return three_repetition_rule;
		return none;
	}
	
// <------------------------ Game State Messing End ------------------------>

}
