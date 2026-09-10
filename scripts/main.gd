extends Node2D

const PlayerScene = preload("res://scripts/player.gd")
const EnemyScene = preload("res://scripts/enemy.gd")

var player: CharacterBody2D
var enemies: Array[CharacterBody2D] = []
var soul := 0
var message := ""
var message_time := 0.0
var altar_active := false
var camera_offset := 0.0

func _ready() -> void:
	_add_platform(Vector2(576, 584), Vector2(1152, 128))
	_add_platform(Vector2(505, 438), Vector2(150, 16))
	_add_platform(Vector2(872, 368), Vector2(125, 16))
	player = PlayerScene.new()
	player.position = Vector2(250, 480)
	player.attack_landed.connect(_on_attack_landed)
	add_child(player)
	for point in [Vector2(650, 478), Vector2(930, 478)]:
		var enemy := EnemyScene.new()
		enemy.position = point
		enemy.defeated.connect(_on_enemy_defeated)
		enemies.append(enemy)
		add_child(enemy)
	queue_redraw()

func _add_platform(center: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = center
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	body.add_child(shape)
	add_child(body)

func _physics_process(delta: float) -> void:
	if message_time > 0.0:
		message_time -= delta
		if message_time <= 0.0:
			message = ""
	var target_offset := clamp(player.position.x - 360.0, 0.0, 420.0)
	camera_offset = lerp(camera_offset, target_offset, delta * 4.0)
	queue_redraw()
	if Input.is_action_just_pressed("interact") and player.position.distance_to(Vector2(1040, 470)) < 100.0:
		altar_active = true
		soul = 0
		message = "篝火回應了你的靈魂。生命與能量已恢復。"
		message_time = 3.0
		player.hp = player.max_hp

func _on_attack_landed(enemy: Node) -> void:
	if is_instance_valid(enemy) and enemy.has_method("take_hit"):
		enemy.take_hit(1)

func _on_enemy_defeated() -> void:
	soul += 1
	message = "靈魂火花被收集了。"
	message_time = 1.5

func _draw() -> void:
	# layered dusk background
	draw_rect(Rect2(0, 0, 1152, 648), Color("0b0920"))
	draw_circle(Vector2(940 - camera_offset * 0.12, 130), 82, Color("3b285e"))
	draw_circle(Vector2(940 - camera_offset * 0.12, 130), 66, Color("d5a8c7"))
	for i in range(12):
		var x := float(i * 130) - fmod(camera_offset * 0.22, 130.0)
		draw_colored_polygon(PackedVector2Array([Vector2(x, 420), Vector2(x + 70, 220 + (i % 3) * 35), Vector2(x + 150, 420)]), Color("171636"))
	# distant ruins
	for x in [70.0, 360.0, 760.0, 1080.0]:
		draw_rect(Rect2(x - camera_offset * 0.45, 270, 38, 170), Color("221e46"))
		draw_rect(Rect2(x - camera_offset * 0.45 - 12, 255, 62, 18), Color("302957"))
	# ground and platforms
	draw_rect(Rect2(0, 520, 1152, 128), Color("17132e"))
	draw_rect(Rect2(0, 520, 1152, 7), Color("8a4f74"))
	draw_rect(Rect2(430 - camera_offset, 430, 150, 16), Color("7d496e"))
	draw_rect(Rect2(810 - camera_offset, 360, 125, 16), Color("7d496e"))
	# altar
	var altar_x := 1040.0 - camera_offset
	draw_rect(Rect2(altar_x - 30, 475, 60, 45), Color("5a3562"))
	draw_rect(Rect2(altar_x - 42, 465, 84, 12), Color("9d5d81"))
	draw_circle(Vector2(altar_x, 450), 18, Color("f3a45f"))
	draw_circle(Vector2(altar_x, 450), 9, Color("fff0a6"))
	# HUD
	draw_rect(Rect2(24, 20, 300, 82), Color(0.04, 0.03, 0.11, 0.92))
	draw_string(ThemeDB.fallback_font, Vector2(42, 48), "ASHENLIGHT", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("f0c18a"))
	draw_string(ThemeDB.fallback_font, Vector2(42, 75), "生命  %d / %d     靈魂  %d" % [player.hp, player.max_hp, soul], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("d9c7e9"))
	draw_string(ThemeDB.fallback_font, Vector2(25, 620), "A/D 移動   SPACE 跳躍   J / 滑鼠左鍵 攻擊   E 與篝火互動", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("bca9d3"))
	if message != "":
		draw_string(ThemeDB.fallback_font, Vector2(350, 92), message, HORIZONTAL_ALIGNMENT_LEFT, 500, 18, Color("ffdba0"))
