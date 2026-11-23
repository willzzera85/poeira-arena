@tool
extends EditorScript

# Caminho do AnimationPlayer na cena aberta atualmente
const CAMINHO_ANIM_PLAYER: String = "ModeloVisual/Correr_modelo/AnimationPlayer"
# Pasta onde estão os arquivos .res / .anim novos
const PASTA_ANIMACOES: String = "res://Jogador/"
# Nome da biblioteca destino ("" = Global, ou "Correr_modelo")
const NOME_BIBLIOTECA: String = "Correr_modelo"

func _run() -> void:
	var cena: Node = get_editor_interface().get_edited_scene_root()
	if cena == null:
		push_error("Abra a cena do jogador antes de rodar.")
		return

	var anim_player: AnimationPlayer = cena.get_node_or_null(CAMINHO_ANIM_PLAYER) as AnimationPlayer
	if anim_player == null:
		push_error("AnimationPlayer não encontrado em: " + CAMINHO_ANIM_PLAYER)
		return

	var bib: AnimationLibrary = anim_player.get_animation_library(NOME_BIBLIOTECA)
	if bib == null:
		bib = AnimationLibrary.new()
		anim_player.add_animation_library(NOME_BIBLIOTECA, bib)

	var dir: DirAccess = DirAccess.open(PASTA_ANIMACOES)
	if dir == null:
		push_error("Não foi possível abrir a pasta: " + PASTA_ANIMACOES)
		return

	dir.list_dir_begin()
	var arquivo: String = dir.get_next()
	while arquivo != "":
		var eh_diretorio: bool = dir.current_is_dir()
		if not eh_diretorio and (arquivo.ends_with(".res") or arquivo.ends_with(".anim")):
			var caminho_completo: String = PASTA_ANIMACOES.path_join(arquivo)
			var recurso: Resource = load(caminho_completo)
			var nome_limpo: String = arquivo.get_basename()

			if recurso is Animation:
				var anim_extraida: Animation = (recurso as Animation).duplicate(true)
				if bib.has_animation(nome_limpo):
					bib.remove_animation(nome_limpo)
				bib.add_animation(nome_limpo, anim_extraida)
				print("Importada: ", nome_limpo)

			elif recurso is AnimationLibrary:
				var lib_origem: AnimationLibrary = recurso as AnimationLibrary
				var nomes_anim: PackedStringArray = lib_origem.get_animation_list()
				for anim_nome: String in nomes_anim:
					var nome_final: String = anim_nome if nomes_anim.size() > 1 else nome_limpo
					var anim_lib: Animation = lib_origem.get_animation(anim_nome).duplicate(true)
					if bib.has_animation(nome_final):
						bib.remove_animation(nome_final)
					bib.add_animation(nome_final, anim_lib)
					print("Importada da library: ", nome_final)

		arquivo = dir.get_next()

	dir.list_dir_end()
	print("Concluído! Pressione Ctrl+S na cena para salvar.")
