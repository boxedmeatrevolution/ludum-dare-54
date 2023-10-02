@tool
extends Node2D

const Camera := preload("res://scripts/Camera.gd")
const CameraScene := preload("res://entities/Camera.tscn")
const Car := preload("res://scripts/Car.gd")
const PlayerAI := preload("res://scripts/PlayerAI.gd")
const ParkingSpace := preload("res://scripts/ParkingSpace.gd")
const Surface := preload("res://scripts/Surface.gd")
const Curb := preload("res://scripts/Curb.gd")
const Shrub := preload("res://scripts/Shrub.gd")
const Ticket := preload("res://scripts/Ticket.gd")
const CarSpawner := preload("res://scripts/CarSpawner.gd")
const TargetSpace := preload("res://scripts/TargetSpace.gd")

const OUT_OF_BOUNDS_PADDING : float = 64.0

@export var bounds : Rect2 = Rect2(0.0, 0.0, 960.0, 600.0):
	set(value):
		bounds = value
		if Engine.is_editor_hint():
			queue_redraw()

var camera : Camera = null
var target_space : TargetSpace = null
var ticket : Ticket = null

@onready var surface_parent := $SurfaceParent
@onready var shrub_parent := $ShrubParent
@onready var marking_parent := $MarkingParent
@onready var curb_parent := $CurbParent
@onready var car_parent := $CarParent
@onready var prop_parent := $PropParent
@onready var player_car_parent := $PlayerCarParent
@onready var light_parent := $LightParent
@onready var ticket_parent := $TicketParent
@onready var target_space_parent := $TargetSpaceParent

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	global_transform = Transform2D.IDENTITY
	for child in get_children():
		if child is Car:
			var is_player := false
			for grandchild in child.get_children():
				if grandchild is PlayerAI:
					is_player = true
					break
			if is_player:
				child.reparent(player_car_parent)
			else:
				child.reparent(car_parent)
			child.bounds = bounds.grow(OUT_OF_BOUNDS_PADDING)
		elif child is ParkingSpace:
			for car in child.cars:
				car.reparent(car_parent)
				car.bounds = bounds.grow(OUT_OF_BOUNDS_PADDING)
			child.reparent(marking_parent)
		elif child is Surface:
			child.reparent(surface_parent)
		elif child is Curb:
			child.reparent(curb_parent)
		elif child is CarSpawner:
			child.car_parent = car_parent
			child.bounds = bounds.grow(OUT_OF_BOUNDS_PADDING)
		elif child is TargetSpace:
			child.reparent(target_space_parent)
			target_space = child
		elif child is Shrub:
			child.reparent(shrub_parent)
		elif child is Ticket:
			child.reparent(ticket_parent)
			ticket = child
	
	if ticket != null && target_space != null:
		ticket.ticket_collected.connect(target_space.ticket_collected)
	elif target_space != null:
		target_space.ticket_collected()
	
	camera = CameraScene.instantiate()
	if player_car_parent.get_child_count() != 0:
		camera.target_path = player_car_parent.get_child(0).get_path()
	camera.bounds = bounds
	add_child(camera)

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(bounds, Color.BLUE, false, 10.0)
		return
