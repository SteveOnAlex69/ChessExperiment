extends Node

class_name Utility;

static func chebyshev_distance(a: Vector2, b:Vector2):
	return max(abs(a.x - b.x), abs(a.y - b.y));	
	
static func manhattan_distance(a: Vector2, b:Vector2):
	return abs(a.x - b.x) + abs(a.y - b.y);	
	
static func vector_to_cell_index(p: Vector2):
	return p.x * 8 + p.y;

static func int_to_cell_vector(i: int):
	return Vector2(i / 8, i % 8);
	
static func vector_to_cell_notation(p: Vector2):
	var x:int = round(p.x);
	var y:int = round(p.y);
	return char("a".unicode_at(0) + x) + char("1".unicode_at(0) + y);
	
static func int_to_cell_notation(i: int):
	return vector_to_cell_notation(int_to_cell_vector(i));
	
static func cell_notation_to_vector(s: String):
	return Vector2(s.unicode_at(0) - "a".unicode_at(0), s.unicode_at(1) - "1".unicode_at(0)); 
	
static func cell_notation_to_int(s: String):
	var v: Vector2 = cell_notation_to_vector(s);
	return v.x * 8 + v.y; 
	
static func is_upper_case(s: String):
	return s == s.to_upper();
	
static func is_king_distance(a: Vector2, b:Vector2):
	return chebyshev_distance(a, b) <= 1;

static func is_knight_distance(a: Vector2, b:Vector2):
	return (chebyshev_distance(a, b) == 2) && (manhattan_distance(a, b) == 3);
	
static func is_rook_distance(a: Vector2, b:Vector2):
	return chebyshev_distance(a, b) == manhattan_distance(a, b);
	
static func is_bishop_distance(a: Vector2, b:Vector2):
	return chebyshev_distance(a, b) * 2 == manhattan_distance(a, b);

static func is_pawn_distance(a: Vector2, b:Vector2):
	return (manhattan_distance(a, b) <= 2) && (a.y == b.y);
	
static func make_string_from_arr(arr: Array):
	var ans: String;
	for i in arr:
		ans = ans + i;
	return ans;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
