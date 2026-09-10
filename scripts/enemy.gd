extends CharacterBody2D

signal defeated
var hp := 2
var direction := -1
var home_x := 0.0
var hurt_time := 0.0

func _ready() -> void:
	var collider := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 16.0
	capsule.height = 48.0
	collider.shape = capsule
	collider.position = Vector2(0, -2)
	add_child(collider)
	add_to_group("enemies")
	home_x = position.x
	z_index = 3
	queue_redraw()

func _physics_process(delta: float) -> void:
	velocity.x = direction * 42.0
	if abs(position.x - home_x) > 95: direction *= -1
	if not is_on_floor(): velocity.y += 1100.0 * delta
	move_and_slide()
	if hurt_time > 0: hurt_time -= delta
	queue_redraw()

func take_hit(damage: int) -> void:
	if hurt_time > 0: return
	hp -= damage
	hurt_time = 0.2
	velocity.x = 180.0 if global_position.x > get_parent().player.global_position.x else -180.0
	if hp <= 0:
		defeated.emit()
		queue_free()

func _draw() -> void:
	var tint := Color("d68a72") if hurt_time <= 0 else Color("fff0b1")
	draw_circle(Vector2(0, -25), 18, Color("19152f"))
	draw_colored_polygon(PackedVector2Array([Vector2(-22, -8), Vector2(22, -8), Vector2(16, 27), Vector2(-16, 27)]), tint)
	draw_circle(Vector2(-7, -27), 3, Color("ffdc86"))
	draw_circle(Vector2(7, -27), 3, Color("ffdc86"))
	draw_line(Vector2(-15, 11), Vector2(15, 11), Color("3a2348"), 4)
