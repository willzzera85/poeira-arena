
@tool
extends Node

@export var origem: CSGBox3D
@export var destino: CollisionShape3D

@export_tool_button("COPIAR CSG PARA COLISÃO")
var copiar = _copiar_colisao


func _copiar_colisao() -> void:

	if origem == null:
		push_error("Arraste o CSGBox3D para o campo Origem.")
		return

	if destino == null:
		push_error("Arraste o CollisionShape3D para o campo Destino.")
		return

	var nova_forma = BoxShape3D.new()
	nova_forma.size = origem.size

	destino.shape = nova_forma
	destino.global_transform = origem.global_transform

	print("Colisão copiada com sucesso!")
