@tool
extends EditorScript

const CAMINHO_RES := "res://Jogador/mortal.res"
const CAMINHO_FBX := "res://Jogador/mortal.fbx"
const CAMINHO_ANIM_PLAYER := "ModeloVisual/Correr_modelo/AnimationPlayer"
const NOME_BIBLIOTECA := "Correr_modelo"
const NOME_ANIM_NO_PLAYER := "mortal"
const CAMINHO_CENA_ARENA := "res://arena.tscn"

func _run() -> void:
	var anim := _carregar_animacao()
	if anim == null:
		push_error("Não consegui carregar animação nem de " + CAMINHO_RES + " nem de " + CAMINHO_FBX)
		return

	anim.loop_mode = Animation.LOOP_NONE

	# 1. Atualiza a cena atualmente aberta no editor (ex: jogador.tscn ou arena.tscn)
	var raiz_atual := EditorInterface.get_edited_scene_root()
	var atualizou_cena_atual := false
	if raiz_atual != null:
		atualizou_cena_atual = _injetar_em_nos_compativeis(raiz_atual, anim)
		if atualizou_cena_atual:
			EditorInterface.mark_scene_as_unsaved()
			EditorInterface.save_scene()
			print("Atualizado e salvo na cena aberta: ", raiz_atual.scene_file_path)

	# 2. Se a cena aberta não for a arena, também injeta direto na cena arena em disco
	var caminho_atual := raiz_atual.scene_file_path if raiz_atual != null else ""
	if caminho_atual != CAMINHO_CENA_ARENA and ResourceLoader.exists(CAMINHO_CENA_ARENA):
		var packed_arena := ResourceLoader.load(CAMINHO_CENA_ARENA) as PackedScene
		if packed_arena != null:
			var instancia_arena := packed_arena.instantiate()
			var alterou_arena := _injetar_em_nos_compativeis(instancia_arena, anim)
			if alterou_arena:
				var nova_packed := PackedScene.new()
				if nova_packed.pack(instancia_arena) == OK:
					var err := ResourceSaver.save(nova_packed, CAMINHO_CENA_ARENA)
					if err == OK:
						print("Sucesso! Animação injetada e salva também em: ", CAMINHO_CENA_ARENA)
					else:
						push_error("Falha ao salvar a cena arena: " + str(err))
			instancia_arena.queue_free()

	if not atualizou_cena_atual:
		print("Verifique se o nó do jogador na cena ativa tem o caminho: ", CAMINHO_ANIM_PLAYER)

func _injetar_em_nos_compativeis(raiz: Node, anim_base: Animation) -> bool:
	var alterou := false
	var candidatos: Array[Node] = [raiz]
	_coletar_descendentes(raiz, candidatos)

	for no in candidatos:
		if no is CharacterBody3D or no.name.to_lower().contains("jogador") or no.is_in_group("jogador") or no.is_in_group("Jogador"):
			var ap := no.get_node_or_null(CAMINHO_ANIM_PLAYER) as AnimationPlayer
			if ap != null:
				_aplicar_no_animation_player(ap, anim_base.duplicate(true))
				alterou = true

	# Fallback caso o AnimationPlayer esteja em algum caminho filho da cena
	if not alterou:
		for no in candidatos:
			if no is AnimationPlayer and str(no.get_path()).contains("Correr_modelo"):
				_aplicar_no_animation_player(no as AnimationPlayer, anim_base.duplicate(true))
				alterou = true

	return alterou

func _coletar_descendentes(no: Node, lista: Array[Node]) -> void:
	for filho in no.get_children():
		lista.append(filho)
		_coletar_descendentes(filho, lista)

func _aplicar_no_animation_player(anim_player: AnimationPlayer, anim: Animation) -> void:
	var lib: AnimationLibrary = null
	if anim_player.has_animation_library(NOME_BIBLIOTECA):
		lib = anim_player.get_animation_library(NOME_BIBLIOTECA)
	else:
		lib = AnimationLibrary.new()
		anim_player.add_animation_library(NOME_BIBLIOTECA, lib)

	if lib.has_animation(NOME_ANIM_NO_PLAYER):
		lib.remove_animation(NOME_ANIM_NO_PLAYER)

	lib.add_animation(NOME_ANIM_NO_PLAYER, anim)

	if lib.resource_path != "" and not lib.resource_path.contains("::"):
		ResourceSaver.save(lib, lib.resource_path)

func _carregar_animacao() -> Animation:
	if ResourceLoader.exists(CAMINHO_RES):
		var res := ResourceLoader.load(CAMINHO_RES)
		if res is Animation:
			return (res as Animation).duplicate(true)
		if res is AnimationLibrary:
			var lib := res as AnimationLibrary
			for nome in lib.get_animation_list():
				return lib.get_animation(nome).duplicate(true)

	if ResourceLoader.exists(CAMINHO_FBX):
		var cena_fbx := ResourceLoader.load(CAMINHO_FBX) as PackedScene
		if cena_fbx != null:
			var instancia := cena_fbx.instantiate()
			var anim := _buscar_animacao_na_arvore(instancia)
			instancia.queue_free()
			if anim != null:
				return anim.duplicate(true)

	return null

func _buscar_animacao_na_arvore(no: Node) -> Animation:
	if no is AnimationPlayer:
		var ap := no as AnimationPlayer
		for nome in ap.get_animation_list():
			var a := ap.get_animation(nome)
			if a != null:
				return a
	for filho in no.get_children():
		var encontrada := _buscar_animacao_na_arvore(filho)
		if encontrada != null:
			return encontrada
	return null
