extends Node

class_name ChessBoard;

var chessboard: Array = "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr".split("");
var can_castle_left = true;
var can_castle_right = true;
var most_recent_move;

func get_cell(cell:int):
	return chessboard[cell];

func set_cell(cell:int, val:String):
	chessboard[cell] = val;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
