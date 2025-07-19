extends Area3D

var detected_enemies: Array[NPC] = []

func _on_body_entered(body: Node3D):
	if not body is CharacterBody3D:
		return

	if not body is NPC:
		return

	var npc = body as NPC
	
	# detect enemies inclui tambem aliados
	if npc.type == NPC.NPCType.ENEMY and not detected_enemies.has(npc):
		detected_enemies.append(npc)
		if !npc.is_running_away:
			SignalBus.hit_battery.emit(true)
		#print("Bateria atingida por inimigo!")

	if npc.type == NPC.NPCType.GOOD_BOT and not detected_enemies.has(npc):
		detected_enemies.append(npc)
		SignalBus.hit_battery.emit(false)
		#print("Bateria atingida por aliado!")

func _on_body_exited(body: Node3D):
	if body is NPC:
		var npc = body as NPC
		if detected_enemies.has(npc):
			detected_enemies.erase(npc)
