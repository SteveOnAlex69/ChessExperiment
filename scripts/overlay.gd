extends Node2D

func update_display(showing: bool) -> void:
	if showing:
		show();
	else:
		hide();
		
func set_sprite_scale(s: Vector2) -> void:
	var sprite = $Sprite2D;
	if sprite && sprite is Sprite2D:
		sprite.scale = s;

func set_sprite_opacity(f: float) -> void:
	var sprite = $Sprite2D;
	if sprite && sprite is Sprite2D:
		sprite.modulate = Color(1, 1, 1, f);

func set_sprite_layer(i: int) -> void:
	var sprite = $Sprite2D;
	if sprite && sprite is Sprite2D:
		sprite.z_index = i;
		
	
func all_in_one(showing: bool = false, scale: Vector2 = Vector2(1, 1), opacity: float = 1, layer: int = 0) -> void:
	update_display(showing);
	set_sprite_scale(scale);
	set_sprite_opacity(opacity);
	set_sprite_layer(layer);
