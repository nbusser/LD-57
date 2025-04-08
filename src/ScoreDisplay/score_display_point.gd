extends Node3D

var color = Color.BLACK:
	set(value):
		color = value
		light.material.emission = color

@onready var light: CSGShape3D = $Light
