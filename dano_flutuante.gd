
extends Label3D

const FONTE_METALICA: FontFile = preload("res://SairaCondensed-ExtraBold.ttf")

@export var velocidade_subida: float = 1.8
@export var tempo_vida: float = 0.75

var tempo_atual: float = 0.0
var camadas: Array[Label3D] = []


func configurar(valor_dano: int, eh_critico: bool = false) -> void:
	text = str(valor_dano)
	font = FONTE_METALICA

	# HEADSHOT: 110 | DANO NO CORPO: 72
	font_size = 110 if eh_critico else 72

	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	outline_size = 12
	pixel_size = 0.005

	var cor_base: Color
	var cor_clara: Color
	var cor_escura: Color

	if eh_critico:
		# HEADSHOT: VERMELHO ESCURO
		cor_base = Color(0.42, 0.015, 0.025)
		cor_clara = Color(0.62, 0.10, 0.12)
		cor_escura = Color(0.08, 0.005, 0.01)
	else:
		# CORPO: SOMENTE TONS DE CINZA CLAROS
		cor_base = Color(0.76, 0.78, 0.81)
		cor_clara = Color(0.95, 0.96, 0.98)
		cor_escura = Color(0.62, 0.65, 0.69)

	modulate = cor_base
	outline_modulate = Color(0.015, 0.015, 0.02)

	_criar_camadas(cor_base, cor_clara, cor_escura)


func _criar_camadas(
	cor_base: Color,
	cor_clara: Color,
	cor_escura: Color
) -> void:
	for camada in camadas:
		if is_instance_valid(camada):
			camada.queue_free()

	camadas.clear()

	# CAMADA 1: SOMBRA E CONTORNO
	_criar_camada(
		Color(0.015, 0.015, 0.02),
		Vector3(0.018, -0.025, -0.015),
		5
	)

	# CAMADA 2: PROFUNDIDADE
	_criar_camada(
		cor_escura,
		Vector3(0.0, -0.012, -0.008),
		3
	)

	# CAMADA 3: REFLEXO CLARO
	_criar_camada(
		cor_clara,
		Vector3(-0.008, 0.012, 0.012),
		2
	)

	# CAMADA 4: BRILHO CENTRAL
	_criar_camada(
		cor_base.lightened(0.15),
		Vector3.ZERO,
		0
	)


func _criar_camada(
	cor: Color,
	deslocamento: Vector3,
	contorno: int
) -> Label3D:
	var camada := Label3D.new()

	camada.text = text
	camada.font = FONTE_METALICA
	camada.font_size = font_size
	camada.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	camada.no_depth_test = true
	camada.outline_size = contorno
	camada.outline_modulate = Color(0.015, 0.015, 0.02)
	camada.modulate = cor
	camada.position = deslocamento
	camada.pixel_size = pixel_size

	add_child(camada)
	camadas.append(camada)

	return camada


func _process(delta: float) -> void:
	tempo_atual += delta

	# SUBIDA SUAVE
	global_position.y += velocidade_subida * delta

	# DESAPARECIMENTO GRADUAL
	var progresso := clampf(tempo_atual / tempo_vida, 0.0, 1.0)
	var alpha := 1.0 - progresso

	modulate.a = alpha
	outline_modulate.a = alpha

	for camada in camadas:
		if is_instance_valid(camada):
			camada.modulate.a = alpha
			camada.outline_modulate.a = alpha

	if tempo_atual >= tempo_vida:
		queue_free()
