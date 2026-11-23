@tool
extends EditorScript

const NOME_CASA := "CasaXPreto"
const CAMADA_PAREDE := 1 # Camada 1: paredes e teto não atravessam andando
const MASCARA_MEIO_JANELA := 8 # Camada 4 (1 << 3)

# Posição no "X" preto da arena
@export var posicao_casa := Vector3(-6.5, 0.0, -5.5)
@export var rotacao_y_graus := 0.0

# Dimensões da casa
@export var largura_x := 5.5
@export var profundidade_z := 5.0
@export var altura_parede := 3.0
@export var espessura_parede := 0.25
@export var espessura_teto := 0.25

# Porta (do chão até altura_porta, sem peitoril)
@export var largura_porta := 1.4
@export var altura_porta := 2.2

# Janela ampla no centro da parede (tamanho exato do vão)
@export var largura_janela := 2.4
@export var altura_janela := 1.6
@export var base_janela_y := 0.85

# Profundidade de detecção do sensor ao redor da abertura da janela
@export var profundidade_sensor_janela := 1.4

func _run() -> void:
	var raiz := EditorInterface.get_edited_scene_root()
	if raiz == null:
		push_error("Nenhuma cena aberta no editor. Abra a cena da arena primeiro.")
		return

	var casa_antiga := raiz.get_node_or_null(NOME_CASA)
	if casa_antiga != null and is_instance_valid(casa_antiga):
		casa_antiga.free()

	var casa := Node3D.new()
	casa.name = NOME_CASA
	casa.position = posicao_casa
	casa.rotation_degrees = Vector3(0.0, rotacao_y_graus, 0.0)
	raiz.add_child(casa)
	casa.owner = raiz

	# 1. Parede dos fundos (sólida na camada 1)
	_add_box(
		casa,
		"ParedeFundo",
		Vector3(largura_x, altura_parede, espessura_parede),
		Vector3(0.0, altura_parede * 0.5, -profundidade_z * 0.5),
		raiz
	)

	# 2. Parede esquerda com PORTA (camada 1)
	_add_parede_porta_z(
		casa,
		"ParedeEsquerda_Porta",
		profundidade_z,
		altura_parede,
		espessura_parede,
		largura_porta,
		altura_porta,
		-largura_x * 0.5,
		raiz
	)

	# 3. Parede direita com JANELA + sensor no tamanho exato do vão
	_add_parede_janela_z(
		casa,
		"ParedeDireita_Janela",
		profundidade_z,
		altura_parede,
		espessura_parede,
		largura_janela,
		altura_janela,
		base_janela_y,
		largura_x * 0.5,
		raiz
	)

	# 4. Parede frontal com JANELA + sensor no tamanho exato do vão
	_add_parede_janela_x(
		casa,
		"ParedeFrente_Janela",
		largura_x,
		altura_parede,
		espessura_parede,
		largura_janela,
		altura_janela,
		base_janela_y,
		profundidade_z * 0.5,
		raiz
	)

	# 5. Teto (camada 1)
	_add_box(
		casa,
		"Teto",
		Vector3(largura_x + espessura_parede, espessura_teto, profundidade_z + espessura_parede),
		Vector3(0.0, altura_parede + espessura_teto * 0.5, 0.0),
		raiz
	)

	EditorInterface.mark_scene_as_unsaved()
	print("CasaXPreto gerada com sensor no tamanho exato do vão (%.2f x %.2f) e CentroMortal." % [largura_janela, altura_janela])

func _add_box(pai: Node, nome: String, tamanho: Vector3, pos: Vector3, dono: Node) -> void:
	if tamanho.x <= 0.01 or tamanho.y <= 0.01 or tamanho.z <= 0.01:
		return
	var box := CSGBox3D.new()
	box.name = nome
	box.size = tamanho
	box.position = pos
	box.use_collision = true
	box.collision_layer = CAMADA_PAREDE
	box.collision_mask = CAMADA_PAREDE
	pai.add_child(box)
	box.owner = dono

func _add_sensor_vao_janela(
	pai: Node,
	nome: String,
	pos_centro: Vector3,
	tamanho_box: Vector3,
	dono: Node
) -> void:
	var area := Area3D.new()
	area.name = nome
	area.position = pos_centro
	area.monitoring = true
	area.monitorable = true
	area.collision_layer = MASCARA_MEIO_JANELA
	area.collision_mask = MASCARA_MEIO_JANELA
	area.add_to_group("janela_mortal")
	area.set_meta("janela_mortal", true)

	var col := CollisionShape3D.new()
	col.name = nome + "_Col"
	var shape := BoxShape3D.new()
	shape.size = tamanho_box
	col.shape = shape

	# Marcador exato no centro do vão para alinhar a trajetória do mortal
	var centro_alvo := Marker3D.new()
	centro_alvo.name = "CentroMortal"
	centro_alvo.position = Vector3.ZERO

	pai.add_child(area)
	area.add_child(col)
	area.add_child(centro_alvo)

	area.owner = dono
	col.owner = dono
	centro_alvo.owner = dono

func _add_parede_porta_z(
	pai: Node,
	nome: String,
	comp_z: float,
	alt_y: float,
	esp_x: float,
	larg_porta: float,
	alt_porta: float,
	pos_x: float,
	dono: Node
) -> void:
	var lado_z := maxf((comp_z - larg_porta) * 0.5, 0.0)
	var topo_y := maxf(alt_y - alt_porta, 0.0)

	_add_box(pai, nome + "_Verga", Vector3(esp_x, topo_y, larg_porta), Vector3(pos_x, alt_porta + topo_y * 0.5, 0.0), dono)
	_add_box(pai, nome + "_Tras", Vector3(esp_x, alt_y, lado_z), Vector3(pos_x, alt_y * 0.5, -(larg_porta * 0.5 + lado_z * 0.5)), dono)
	_add_box(pai, nome + "_Frente", Vector3(esp_x, alt_y, lado_z), Vector3(pos_x, alt_y * 0.5, larg_porta * 0.5 + lado_z * 0.5), dono)

func _add_parede_janela_x(
	pai: Node,
	nome: String,
	comp_x: float,
	alt_y: float,
	esp_z: float,
	larg_jan: float,
	alt_jan: float,
	base_jan: float,
	pos_z: float,
	dono: Node
) -> void:
	var lado_x := maxf((comp_x - larg_jan) * 0.5, 0.0)
	var topo_y := maxf(alt_y - (base_jan + alt_jan), 0.0)

	_add_box(pai, nome + "_Peitoril", Vector3(larg_jan, base_jan, esp_z), Vector3(0.0, base_jan * 0.5, pos_z), dono)
	_add_box(pai, nome + "_Verga", Vector3(larg_jan, topo_y, esp_z), Vector3(0.0, base_jan + alt_jan + topo_y * 0.5, pos_z), dono)
	_add_box(pai, nome + "_Esq", Vector3(lado_x, alt_y, esp_z), Vector3(-(larg_jan * 0.5 + lado_x * 0.5), alt_y * 0.5, pos_z), dono)
	_add_box(pai, nome + "_Dir", Vector3(lado_x, alt_y, esp_z), Vector3(larg_jan * 0.5 + lado_x * 0.5, alt_y * 0.5, pos_z), dono)

	var centro_y := base_jan + alt_jan * 0.5
	_add_sensor_vao_janela(
		pai,
		nome + "_MeioJanela",
		Vector3(0.0, centro_y, pos_z),
		Vector3(larg_jan, alt_jan, profundidade_sensor_janela),
		dono
	)

func _add_parede_janela_z(
	pai: Node,
	nome: String,
	comp_z: float,
	alt_y: float,
	esp_x: float,
	larg_jan: float,
	alt_jan: float,
	base_jan: float,
	pos_x: float,
	dono: Node
) -> void:
	var lado_z := maxf((comp_z - larg_jan) * 0.5, 0.0)
	var topo_y := maxf(alt_y - (base_jan + alt_jan), 0.0)

	_add_box(pai, nome + "_Peitoril", Vector3(esp_x, base_jan, larg_jan), Vector3(pos_x, base_jan * 0.5, 0.0), dono)
	_add_box(pai, nome + "_Verga", Vector3(esp_x, topo_y, larg_jan), Vector3(pos_x, base_jan + alt_jan + topo_y * 0.5, 0.0), dono)
	_add_box(pai, nome + "_Tras", Vector3(esp_x, alt_y, lado_z), Vector3(pos_x, alt_y * 0.5, -(larg_jan * 0.5 + lado_z * 0.5)), dono)
	_add_box(pai, nome + "_Frente", Vector3(esp_x, alt_y, lado_z), Vector3(pos_x, alt_y * 0.5, larg_jan * 0.5 + lado_z * 0.5), dono)

	var centro_y := base_jan + alt_jan * 0.5
	_add_sensor_vao_janela(
		pai,
		nome + "_MeioJanela",
		Vector3(pos_x, centro_y, 0.0),
		Vector3(profundidade_sensor_janela, alt_jan, larg_jan),
		dono
	)
