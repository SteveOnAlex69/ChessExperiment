using Godot;
using System;

public partial class ChessMove : Node
{
	//public int start, des, move_type, promote_into;
	private int val;
	public ChessMove(int _start, int _des, int _move_type, int _promote_into = (int)0){
		val = _start + (_des << 6) + (_move_type << 12) + (_promote_into << 15);
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
		return (val >> 15);
	}
}
