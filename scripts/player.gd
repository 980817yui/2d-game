extends CharacterBody2D

signal attack_landed(enemy)

const SPEED := 250.0
const ACCEL := 1500.0
const FRICTION := 1800.0
const GRAVITY := 1250.0
const JUMP_FORCE := -500.0
var hp := 5
var max_hp := 5
var facing := 1
var attacking := false
var attack_time := 0.0
var attack_hit := false

func _ready() -> void:
	var collider := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 16.0
	capsule.height = 54.0
	collider.shape = capsule
	collider.position = Vector2(0, -3)
	add_child(collider)
	z_index = 4
	queue_redraw()

func _physics_process(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right")
	if axis != 0:
		velocity.x = move_toward(velocity.x, axis * SPEED, ACCEL * delta)
		facing = 1 if axis > 0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	if not is_on_floor(): velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y = JUMP_FORCE
	if Input.is_action_just_pressed("attack") and not attacking:
		attacking = true
		attack_time = 0.26
		attack_hit = false
	if attacking:
		attack_time -= delta
		if attack_time < 0.14 and not attack_hit:
			attack_hit = true
			for node in get_tree().get_nodes_in_group("enemies"):
				if node.global_position.distance_to(global_position + Vector2(facing * 46, -8)) < 58:
					attack_landed.emit(node)
		if attack_time <= 0: attacking = false
		queue_redraw()
	move_and_slide()
	global_position.x = clamp(global_position.x, 30.0, 1110.0)

func _draw() -> void:
	# cloak/body silhouette
	draw_circle(Vector2(0, -30), 15, Color("e5a071"))
	draw_colored_polygon(PackedVector2Array([Vector2(-18, -16), Vector2(19, -16), Vector2(25, 25), Vector2(-25, 25)]), Color("48356e"))
	draw_colored_polygon(PackedVector2Array([Vector2(-18, 8), Vector2(-35, 27), Vector2(-19, 25), Vector2(0, 9), Vector2(19, 25), Vector2(34, 27), Vector2(18, 8)]), Color("2a234d"))
	draw_circle(Vector2(facing * 6, -33), 3, Color("ffd777"))
	if attacking:
		var start := Vector2(facing * 18, -18)
		var end := Vector2(facing * 70, -48)
		draw_line(start, end, Color("ffd18a"), 7)
		draw_arc(Vector2(facing * 18, -25), 48, -1.1 if facing > 0 else 2.0, 1.0 if facing > 0 else 4.1, 14, Color("f7a067"), 3)
