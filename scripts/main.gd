extends Node2D

const PlayerScene = preload("res://scripts/player.gd")
const EnemyScene = preload("res://scripts/enemy.gd")

var player: CharacterBody2D
var enemies: Array[CharacterBody2D] = []
var soul := 0
var total_enemies := 2
var message := ""
var message_time := 0.0
var camera_offset := 0.0
var victory := false
var altar_used := false
var time := 0.0

func _ready() -> void:
	_add_platform(Vector2(576, 584), Vector2(1152, 128))
	_add_platform(Vector2(505, 438), Vector2(150, 16))
	_add_platform(Vector2(872, 368), Vector2(125, 16))
	player = PlayerScene.new()
	player.position = Vector2(170, 470)
	player.attack_landed.connect(_on_attack_landed)
	player.damaged.connect(_on_player_damaged)
	add_child(player)
	for point in [Vector2(650, 478), Vector2(930, 478)]:
		var enemy := EnemyScene.new()
		enemy.position = point
		enemy.defeated.connect(_on_enemy_defeated)
		enemy.player_contact.connect(_on_enemy_contact)
		enemies.append(enemy)
		add_child(enemy)
	message = "穿過遺跡，收集靈魂火花，讓篝火重新甦醒。"
	message_time = 4.0
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
	time += delta
	if message_time > 0.0:
		message_time -= delta
		if message_time <= 0.0:
			message = ""
	if player == null:
		return
	camera_offset = lerp(camera_offset, clamp(player.position.x - 360.0, 0.0, 420.0), delta * 3.5)
	if Input.is_action_just_pressed("interact") and player.position.distance_to(Vector2(1040, 465)) < 110.0 and not victory:
		if soul >= total_enemies:
			victory = true
			message = "篝火點亮了沉眠的深淵。你完成了第一段遠征。"
			message_time = 999.0
		else:
			message = "篝火仍在等待靈魂火花……（%d / %d）" % [soul, total_enemies]
			message_time = 2.5
			if altar_used:
				player.hp = player.max_hp
			else:
				altar_used = true
				player.hp = player.max_hp
				message = "篝火溫暖了你的披風，生命已恢復。"
				message_time = 2.5
	if Input.is_action_just_pressed("ui_cancel") and victory:
		get_tree().reload_current_scene()
	queue_redraw()

func _on_attack_landed(enemy: Node) -> void:
	if is_instance_valid(enemy) and enemy.has_method("take_hit"):
		enemy.take_hit(1)

func _on_enemy_defeated() -> void:
	soul += 1
	message = "靈魂火花被收集了。返回右側篝火。"
	message_time = 2.0

func _on_enemy_contact() -> void:
	if is_instance_valid(player) and player.has_method("take_damage"):
		player.take_damage(1)

func _on_player_damaged() -> void:
	message = "暗影撕裂了你的靈魂。"
	message_time = 1.0

func _draw() -> void:
	# Deep dusk sky and moon
	draw_rect(Rect2(0, 0, 1152, 648), Color("080719"))
	draw_circle(Vector2(940 - camera_offset * 0.12, 128), 94, Color("241b45"))
	draw_circle(Vector2(940 - camera_offset * 0.12, 128), 67, Color("d6a6bd"))
	draw_circle(Vector2(922 - camera_offset * 0.12, 113), 67, Color("3a2858"))
	# Distant mountain silhouettes
	for i in range(12):
		var x := float(i * 130) - fmod(camera_offset * 0.18, 130.0)
		draw_colored_polygon(PackedVector2Array([Vector2(x, 430), Vector2(x + 70, 222 + (i % 3) * 34), Vector2(x + 155, 430)]), Color("151331"))
	# Ruined pillars with parallax
	for x in [68.0, 350.0, 760.0, 1080.0]:
		var px := x - camera_offset * 0.42
		draw_rect(Rect2(px - 18, 270, 38, 250), Color("201b3c"))
		draw_rect(Rect2(px - 31, 255, 64, 18), Color("302655"))
		draw_rect(Rect2(px - 12, 300, 9, 220), Color("2c244a"))
	# drifting motes
	for i in range(10):
		var mote_x := fmod(float(i * 137) + time * (8.0 + i), 1120.0) + 16.0
		var mote_y := 170.0 + fmod(float(i * 61), 270.0)
		draw_circle(Vector2(mote_x, mote_y), 2.0 + (i % 2), Color(1.0, 0.75, 0.48, 0.35))
	# Ground and platforms; these match the collision bodies exactly
	draw_rect(Rect2(0, 520, 1152, 128), Color("151126"))
	draw_rect(Rect2(0, 520, 1152, 7), Color("8c5277"))
	draw_line(Vector2(0, 545), Vector2(1152, 545), Color("251d3d"), 2)
	draw_rect(Rect2(430, 430, 150, 16), Color("714769"))
	draw_rect(Rect2(430, 430, 150, 4), Color("b36b80"))
	draw_rect(Rect2(810, 360, 125, 16), Color("714769"))
	draw_rect(Rect2(810, 360, 125, 4), Color("b36b80"))
	# Altar / soul brazier
	var altar_x := 1040.0
	draw_rect(Rect2(altar_x - 34, 475, 68, 45), Color("4a2d59"))
	draw_rect(Rect2(altar_x - 45, 465, 90, 12), Color("9b5b7d"))
	draw_line(Vector2(altar_x - 25, 493), Vector2(altar_x + 25, 493), Color("bd6f86"), 3)
	var flame := 18.0 + sin(time * 5.0) * 2.0
	draw_circle(Vector2(altar_x, 450), flame, Color(1.0, 0.48, 0.27, 0.18))
	draw_circle(Vector2(altar_x, 450), 11, Color("f3a45f"))
	draw_circle(Vector2(altar_x, 446), 5, Color("fff0a6"))
	# HUD panels
	draw_rect(Rect2(24, 20, 336, 94), Color(0.035, 0.025, 0.10, 0.94))
	draw_rect(Rect2(24, 20, 5, 94), Color("e09a72"))
	draw_string(ThemeDB.fallback_font, Vector2(45, 50), "ASHENLIGHT", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("f0c18a"))
	draw_string(ThemeDB.fallback_font, Vector2(45, 78), "生命  %d / %d" % [player.hp, player.max_hp], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("d9c7e9"))
	draw_string(ThemeDB.fallback_font, Vector2(195, 78), "靈魂  %d / %d" % [soul, total_enemies], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ffd18a"))
	draw_string(ThemeDB.fallback_font, Vector2(36, 616), "A / D 移動   SPACE 跳躍   J 或左鍵攻擊   E 互動", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("bca9d3"))
	if message != "":
		draw_rect(Rect2(350, 22, 770, 48), Color(0.035, 0.025, 0.10, 0.86))
		draw_string(ThemeDB.fallback_font, Vector2(370, 53), message, HORIZONTAL_ALIGNMENT_LEFT, 730, 17, Color("ffdba0"))
	if victory:
		draw_rect(Rect2(290, 205, 570, 170), Color(0.05, 0.025, 0.13, 0.96))
		draw_rect(Rect2(290, 205, 570, 5), Color("f0a06e"))
		draw_string(ThemeDB.fallback_font, Vector2(0, 255), "篝火已甦醒", HORIZONTAL_ALIGNMENT_CENTER, 1152, 32, Color("ffe0a5"))
		draw_string(ThemeDB.fallback_font, Vector2(0, 294), "ASHENLIGHT  ·  第一段遠征完成", HORIZONTAL_ALIGNMENT_CENTER, 1152, 18, Color("d9c7e9"))
		draw_string(ThemeDB.fallback_font, Vector2(0, 340), "按 ESC 重新開始", HORIZONTAL_ALIGNMENT_CENTER, 1152, 16, Color("bca9d3"))
