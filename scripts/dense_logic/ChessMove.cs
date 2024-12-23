using Godot;
using System;

public partial class ChessMove : Node
{
	public int start, des, move_type, promote_into;
	public ChessMove(int _start, int _des, int _move_type, int _promote_into = -1){
		start = _start; des = _des; move_type = _move_type; promote_into = _promote_into;
	}
}
