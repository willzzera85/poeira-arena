@tool
extends EditorScript

const NOMES_CASAS := ["CasaOposta", "CasaMortalTeste", "CasaArena"]

func _run() -> void:
	var raiz := EditorInterface.get_edited_scene_root()
	if raiz == null:
		push_error("Nenhuma cena aberta no editor.")
		return

	var apagados := 0
	for nome in NOMES_CASAS:
		var no := raiz.get_node_or_null(nome)
		if no != null:
			no.queue_free()
			apagados += 1

	if apagados > 0:
		EditorInterface.mark_scene_as_unsaved()
		print("Removidos ", apagados, " nó(s) de casa da cena.")
	else:
		print("Nenhum nó de casa encontrado na cena atual.")
