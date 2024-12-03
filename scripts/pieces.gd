extends Node2D

enum PIECE_SET {Black_King, Black_Queen, Black_Bishop, Black_Knight, Black_Rook, Black_Pawn, White_King, White_Queen, White_Bishop, White_Knight, White_Rook, White_Pawn, Empty}

var piece_type: int;
var current_cell = "#";
var current_piece = "";

func set_type(type:String):
	current_piece = type;
	match type:
		'k':
			piece_type = 0;
		'q':
			piece_type = 1;
		'b':
			piece_type = 2;
		'n':
			piece_type = 3;
		'r':
			piece_type = 4;
		'p':
			piece_type = 5;
		'K':
			piece_type = 6;
		'Q':
			piece_type = 7;
		'B':
			piece_type = 8;
		'N':
			piece_type = 9;
		'R':
			piece_type = 10;
		'P':
			piece_type = 11;
		_: 
			piece_type = 12;
			
	update_display();
	
func set_sprite_region(sprite: Sprite2D, x: int, y:int, sprite_size:Vector2):
	sprite.region_enabled = true;
	sprite.region_rect = Rect2(Vector2(x * sprite_size.x, y * sprite_size.y), sprite_size);
	
	
func update_display():
	if (piece_type == 12):
		hide();
	else:
		show();
		var x = piece_type % 6;
		var y = piece_type / 6;
		
		set_sprite_region($Sprite2D, x, y, Vector2(64, 64));
		
func set_current_cell(cell: String):
	current_cell = cell;

# Called when the node enters the scene tree for the first time.
func _ready():
	set_type('.');
	update_display();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass