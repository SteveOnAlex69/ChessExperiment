extends Node2D

enum PIECE_SET {Black_King, Black_Queen, Black_Bishop, Black_Knight, Black_Rook, Black_Pawn, White_King, White_Queen, White_Bishop, White_Knight, White_Rook, White_Pawn, Empty}

var piece_type: int;
var current_cell = "#";
var current_piece = "";

func set_type(type:String):
	current_piece = type;
	if (Utility.is_upper_case(type)) :
		piece_type = 6;
	else :
		piece_type = 0;
	match type.to_lower():
		'k':
			piece_type += 0;
		'q':
			piece_type += 1;
		'b':
			piece_type += 2;
		'n':
			piece_type += 3;
		'r':
			piece_type += 4;
		'p':
			piece_type += 5;
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
	

func set_sprite_layer(i: int):
	var sprite = $Sprite2D;
	if sprite && sprite is Sprite2D:
		sprite.z_index = i;

# Called when the node enters the scene tree for the first time.
func _ready():
	set_type('.');
	update_display();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
