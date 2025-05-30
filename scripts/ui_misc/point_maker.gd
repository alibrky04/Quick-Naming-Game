extends Area2D

@export var sprite_texture: Texture2D:
	set(value):
		sprite_texture = value
		$Sprite2D.texture = value
	get:
		return $Sprite2D.texture
