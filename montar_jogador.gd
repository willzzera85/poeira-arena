@tool
extends EditorScript

const CAMINHO_CENA_JOGADOR: String = "res://Jogador/jogador.tscn"
const CAMINHO_ANIM_PLAYER_JOGADOR: NodePath = NodePath("ModeloVisual/Correr_modelo/AnimationPlayer")
const CAMINHO_ANIM_PLAYER_ARENA: NodePath = NodePath("Jogador/ModeloVisual/Correr_modelo/AnimationPlayer")
const SALVAR_CENA_ARENA_APOS_COPIAR: bool = true

func _run() -> void:
	if CAMINHO_CENA_JOGADOR.is_empty() or not ResourceLoader.exists(CAMINHO_CENA_JOGADOR):
		push_warning("Cena do jogador não encontrada em: " + CAMINHO_CENA_JOGADOR)
		return

	var packed_scene := ResourceLoader.load(CAMINHO_CENA_JOGADOR) as PackedScene
	if packed_scene == null:
		push_warning("Não foi possível carregar PackedScene de: " + CAMINHO_CENA_JOGADOR)
		return

	var raiz_arena := get_editor_interface().get_edited_scene_root()
	if raiz_arena == null:
		push_warning("Nenhuma cena aberta no editor para sincronizar.")
		return

	var instancia_temp := packed_scene.instantiate()
	var anim_origem := instancia_temp.get_node_or_null(CAMINHO_ANIM_PLAYER_JOGADOR) as AnimationPlayer
	if anim_origem == null:
		anim_origem = _buscar_primeiro_animation_player(instancia_temp)

	var anim_destino := raiz_arena.get_node_or_null(CAMINHO_ANIM_PLAYER_ARENA) as AnimationPlayer
	if anim_destino == null:
		var jogador_no := raiz_arena.find_child("Jogador", true, false)
		if jogador_no != null:
			anim_destino = _buscar_primeiro_animation_player(jogador_no)

	if anim_origem == null or anim_destino == null:
		push_warning("Não foi possível localizar ambos os AnimationPlayer (origem ou destino).")
		instancia_temp.queue_free()
		return

	var bibliotecas_copiadas := 0
	for nome_lib in anim_origem.get_animation_library_list():
		var lib_origem := anim_origem.get_animation_library(nome_lib)
		if lib_origem == null:
			continue
		var lib_duplicada := lib_origem.duplicate(true) as AnimationLibrary
		if anim_destino.has_animation_library(nome_lib):
			anim_destino.remove_animation_library(nome_lib)
		anim_destino.add_animation_library(nome_lib, lib_duplicada)
		bibliotecas_copiadas += 1

	print("Sincronização concluída! Bibliotecas copiadas: ", bibliotecas_copiadas)
	print("Animações agora no AnimationPlayer da Arena: ", anim_destino.get_animation_list())

	if SALVAR_CENA_ARENA_APOS_COPIAR:
		var err := get_editor_interface().save_scene()
		print("Salvar cena na Arena status: ", err)

	instancia_temp.queue_free()

func _buscar_primeiro_animation_player(raiz: Node) -> AnimationPlayer:
	if raiz is AnimationPlayer:
		return raiz as AnimationPlayer
	for filho in raiz.get_children():
		var achado := _buscar_primeiro_animation_player(filho)
		if achado != null:
			return achado
	return null
