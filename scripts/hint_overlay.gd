extends Node2D

func update_display(showing: bool):
	if showing:
		show();
	else:
		hide();
		
func set_sprite_scale(s: Vector2):
	$Sprite2D.scale = s;

func set_sprite_opacity(f: float):
	$Sprite2D.modulate = Color(1, 1, 1, f);

# Called when the node enters the scene tree for the first time.
func _ready():
	update_display(false);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
