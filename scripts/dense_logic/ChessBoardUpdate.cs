using Godot;
using System;
using System.Text;
using System.Collections.Generic;

public partial class ChessBoardUpdate : Node
{
	public List<int> modified_cell = new List<int>();
	public bool[,] can_castle = new bool[2, 2];
	public bool[] castled = new bool[2];
	public ChessBoardUpdate(ChessBoard board){
		for(int i = 0; i < 2; ++i) {
			for(int j = 0; j < 2; ++j) can_castle[i, j] = board.can_castle[i, j];
			castled[i] = board.castled[i];
		}
	}
	
	public void add_cell(int i, char c){
		modified_cell.Add(i + 64 * (int) c);
	}
	
	public int size(){
		return modified_cell.Count;
	}
	
	public int get_cell_index(int i){return modified_cell[i] % 64;}
	public char get_cell_content(int i){return (char)(modified_cell[i] / 64);}
}
