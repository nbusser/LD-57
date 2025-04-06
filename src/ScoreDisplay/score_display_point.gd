extends Node3D

@onready var csgcylinder_3d: CSGCylinder3D = $CSGCylinder3D

var color = Color.BLACK:
	set(value):
		color = value
		csgcylinder_3d.material.emission = color
