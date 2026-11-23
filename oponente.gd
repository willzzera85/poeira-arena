
extends CharacterBody3D

@export var vida_maxima: int = 215
@export var velocidade: float = 3.5
@export var multiplicador_corrida: float = 1.8
@export var multiplicador_mira: float = 0.45
@export var velocidade_deslize: float = 11.0
@export var duracao_deslize: float = 0.65
@export var recarga_deslize: float = 2.4
@export var distancia_disparo: float = 25.0
@export var distancia_parada: float = 3.0
@export var distancia_corrida: float = 8.0
@export var distancia_deslize: float = 10.0
@export var distancia_mira: float = 12.0

@export var velocidade_bala_inimigo: float = 40.0
@export var fator_antecipacao: float = 0.8
@export var antecipacao_maxima: float = 0.5
@export var altura_mira: float = 1.3

@export var quantidade_particulas_sangue: int = 24
@export var velocidade_sangue_min: float = 2.5
@export var velocidade_sangue_max: float = 5.5
@export var duracao_sangue: float = 0.55
@export var altura_impacto_sangue: float = 1.0

const CENA_BALA: PackedScene = preload("res://bala.tscn")

const CANTOS_RESPAWN: Array[Vector3] = [
	Vector3(16.0, 0.0, 16.0),
	Vector3(16.0, 0.0, -16.0),
	Vector3(-16.0, 0.0, 16.0),
	Vector3(-16.0, 0.0, -16.0),
]

const ALTURA_EM_PE := 1.8
const ALTURA_DESLIZE := 0.9

var vida: int = 100
var gravidade: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var jogador: Node3D = null
var correndo := false
var mirando := false
var deslizando := false
var tempo_deslize := 0.0
var cooldown_deslize := 0.0
var direcao_deslize := Vector3.ZERO

var material_original: Material = null
var material_vermelho: StandardMaterial3D = null
var tween_impacto: Tween = null

@onready var ponto_disparo: Node3D = $PontoDisparo
@onready var timer_disparo: Timer = $Timer
@onready var barra_preenchimento: MeshInstance3D = $BarraVida/Preenchimento
@onready var colisao: CollisionShape3D = $CollisionShape3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var barra_vida: Node3D = $BarraVida
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var _barra_y_padrao := 2.15


func _ready() -> void:
	add_to_group("inimigo")
	add_to_group("oponente")
	vida = vida_maxima

	if colisao.shape:
		colisao.shape = colisao.shape.duplicate()

	_barra_y_padrao = barra_vida.position.y

	jogador = get_tree().get_first_node_in_group("Jogador")
	if not jogador:
		jogador = get_tree().get_first_node_in_group("jogador")
	if not jogador:
		var arvore_principal := get_tree().current_scene
		if arvore_principal:
			jogador = arvore_principal.find_child("Jogador", true, false)

	_preparar_material_impacto()

	if timer_disparo:
		if not timer_disparo.timeout.is_connected(_on_timer_disparo_timeout):
			timer_disparo.timeout.connect(_on_timer_disparo_timeout)

		timer_disparo.start()

	_atualizar_barra_vida()


func _preparar_material_impacto() -> void:
	if mesh == null:
		return

	material_original = mesh.material_override

	if material_original == null and mesh.mesh and mesh.mesh.get_surface_count() > 0:
		material_original = mesh.mesh.surface_get_material(0)

	material_vermelho = StandardMaterial3D.new()
	material_vermelho.albedo_color = Color(1.0, 0.025, 0.025, 1.0)
	material_vermelho.roughness = 0.6


func _physics_process(delta: float) -> void:
	if jogador == null or not is_instance_valid(jogador):
		jogador = get_tree().get_first_node_in_group("Jogador")
		if not jogador:
			jogador = get_tree().get_first_node_in_group("jogador")

		velocity.x = 0.0
		velocity.z = 0.0

		if not is_on_floor():
			velocity.y -= gravidade * delta

		move_and_slide()
		return

	if not is_on_floor():
		velocity.y -= gravidade * delta

	cooldown_deslize = maxf(cooldown_deslize - delta, 0.0)

	var posicao_alvo := Vector3(
		jogador.global_position.x,
		global_position.y,
		jogador.global_position.z
	)

	var distancia := global_position.distance_to(posicao_alvo)

	if distancia > 0.05:
		look_at(posicao_alvo, Vector3.UP)

	if distancia > distancia_deslize and _pode_deslizar():
		_iniciar_deslize(posicao_alvo)

	mirando = distancia <= distancia_mira and not deslizando
	correndo = distancia > distancia_corrida and not mirando and not deslizando and is_on_floor()

	if deslizando:
		_processar_deslize(delta)
	else:
		if nav_agent and distancia > distancia_parada:
			nav_agent.target_position = posicao_alvo

			if not nav_agent.is_navigation_finished():
				var proximo_ponto := nav_agent.get_next_path_position()
				var direcao := global_position.direction_to(proximo_ponto)
				direcao.y = 0.0
				direcao = direcao.normalized()

				var velocidade_atual := velocidade
				if correndo:
					velocidade_atual *= multiplicador_corrida
				elif mirando:
					velocidade_atual *= multiplicador_mira

				velocity.x = direcao.x * velocidade_atual
				velocity.z = direcao.z * velocidade_atual
			else:
				velocity.x = 0.0
				velocity.z = 0.0
		else:
			velocity.x = 0.0
			velocity.z = 0.0

	_atualizar_pose()
	move_and_slide()


func _pode_deslizar() -> bool:
	return not deslizando and is_on_floor() and cooldown_deslize <= 0.0


func _iniciar_deslize(posicao_alvo: Vector3) -> void:
	deslizando = true
	correndo = false
	mirando = false
	tempo_deslize = duracao_deslize

	direcao_deslize = (posicao_alvo - global_position).normalized()

	if direcao_deslize == Vector3.ZERO:
		direcao_deslize = -transform.basis.z

	velocity.x = direcao_deslize.x * velocidade_deslize
	velocity.z = direcao_deslize.z * velocidade_deslize

	_definir_capsula(ALTURA_DESLIZE)


func _processar_deslize(delta: float) -> void:
	tempo_deslize -= delta

	var fator := clampf(tempo_deslize / duracao_deslize, 0.0, 1.0)
	var velocidade_atual := lerpf(velocidade * 0.7, velocidade_deslize, fator)

	velocity.x = direcao_deslize.x * velocidade_atual
	velocity.z = direcao_deslize.z * velocidade_atual

	if tempo_deslize <= 0.0:
		_terminar_deslize()


func _terminar_deslize() -> void:
	deslizando = false
	cooldown_deslize = recarga_deslize
	_definir_capsula(ALTURA_EM_PE)


func _definir_capsula(altura: float) -> void:
	var forma := colisao.shape as CapsuleShape3D

	if forma == null:
		return

	forma.height = altura
	colisao.position.y = altura * 0.5
	mesh.position.y = altura * 0.5
	mesh.scale.y = altura / ALTURA_EM_PE


func _atualizar_pose() -> void:
	barra_vida.position.y = 1.15 if deslizando else _barra_y_padrao

	if timer_disparo:
		timer_disparo.wait_time = 0.75 if mirando else 1.2


func _on_timer_disparo_timeout() -> void:
	if jogador == null or not is_instance_valid(jogador):
		return

	if deslizando:
		return

	if global_position.distance_to(jogador.global_position) > distancia_disparo:
		return

	_disparar()


func _disparar() -> void:
	if jogador == null or not is_instance_valid(jogador):
		return

	var bala := CENA_BALA.instantiate()
	print("OPONENTE DISPAROU UMA BALA")

	get_tree().current_scene.add_child(bala)
	bala.global_transform = ponto_disparo.global_transform

	var ponto_alvo: Vector3 = jogador.global_position + Vector3.UP * altura_mira

	var velocidade_jogador := Vector3.ZERO

	if jogador is CharacterBody3D:
		velocidade_jogador = (jogador as CharacterBody3D).velocity

	var distancia_tiro := ponto_disparo.global_position.distance_to(ponto_alvo)
	var tempo_voo := distancia_tiro / maxf(velocidade_bala_inimigo, 0.1)
	tempo_voo = clampf(tempo_voo, 0.0, antecipacao_maxima)

	ponto_alvo += velocidade_jogador * tempo_voo * fator_antecipacao

	var direcao_tiro := (ponto_alvo - ponto_disparo.global_position).normalized()

	if not mirando:
		direcao_tiro = direcao_tiro.rotated(
			Vector3.UP,
			randf_range(-0.06, 0.06)
		)

	bala.configurar(direcao_tiro, self, 1000.0, 10.0)
	bala.velocidade_bala = velocidade_bala_inimigo
	bala.tempo_vida = 25.0
	bala.tempo_restante = 25.0


func receber_dano(quantidade: int) -> void:
	receber_dano_com_impacto(
		quantidade,
		global_position + Vector3.UP * altura_impacto_sangue
	)


func receber_dano_com_impacto(quantidade: int, ponto_impacto: Vector3) -> void:
	if quantidade <= 0 or vida <= 0:
		return

	_piscar_ao_receber_tiro()
	_criar_efeito_sangue(ponto_impacto)

	vida = maxi(vida - quantidade, 0)
	_atualizar_barra_vida()

	if vida <= 0:
		respawn()


func _piscar_ao_receber_tiro() -> void:
	if mesh == null or material_vermelho == null:
		return

	if tween_impacto != null and tween_impacto.is_running():
		tween_impacto.kill()

	mesh.material_override = material_vermelho

	tween_impacto = create_tween()
	tween_impacto.tween_interval(0.12)
	tween_impacto.tween_callback(
		func():
			if is_instance_valid(mesh):
				mesh.material_override = material_original
	)


func _criar_efeito_sangue(ponto_impacto: Vector3) -> void:
	var efeito := GPUParticles3D.new()

	efeito.name = "EfeitoSangue"
	efeito.amount = maxi(quantidade_particulas_sangue, 1)
	efeito.lifetime = duracao_sangue
	efeito.one_shot = true
	efeito.explosiveness = 1.0
	efeito.local_coords = false

	var material_particulas := ParticleProcessMaterial.new()

	material_particulas.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material_particulas.emission_sphere_radius = 0.08
	material_particulas.direction = Vector3(0.0, 0.4, 0.0)
	material_particulas.spread = 180.0
	material_particulas.initial_velocity_min = velocidade_sangue_min
	material_particulas.initial_velocity_max = velocidade_sangue_max
	material_particulas.gravity = Vector3(0.0, -9.8, 0.0)
	material_particulas.scale_min = 0.5
	material_particulas.scale_max = 1.3
	material_particulas.color = Color(0.65, 0.015, 0.025, 1.0)

	efeito.process_material = material_particulas

	var esfera := SphereMesh.new()
	esfera.radius = 0.035
	esfera.height = 0.07
	esfera.radial_segments = 6
	esfera.rings = 3

	var material_sangue := StandardMaterial3D.new()
	material_sangue.albedo_color = Color(0.65, 0.015, 0.025, 1.0)
	material_sangue.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	esfera.material = material_sangue
	efeito.draw_pass_1 = esfera

	get_tree().current_scene.add_child(efeito)

	efeito.global_position = ponto_impacto
	efeito.finished.connect(efeito.queue_free)
	efeito.emitting = true


func respawn() -> void:
	vida = vida_maxima
	velocity = Vector3.ZERO
	deslizando = false
	correndo = false
	mirando = false
	tempo_deslize = 0.0
	cooldown_deslize = 0.0

	_definir_capsula(ALTURA_EM_PE)

	global_position = _canto_respawn()

	_atualizar_barra_vida()


func _canto_respawn() -> Vector3:
	var opcoes := CANTOS_RESPAWN.duplicate()

	if jogador and is_instance_valid(jogador):
		opcoes = opcoes.filter(
			func(pos: Vector3) -> bool:
				return pos.distance_to(jogador.global_position) > 4.0
		)

	if opcoes.is_empty():
		opcoes = CANTOS_RESPAWN.duplicate()

	return opcoes[randi() % opcoes.size()]


func _atualizar_barra_vida() -> void:
	if barra_preenchimento == null:
		return

	var fracao := clampf(float(vida) / float(vida_maxima), 0.0, 1.0)

	barra_preenchimento.scale.x = maxf(fracao, 0.01)
	barra_preenchimento.position.x = (fracao - 1.0) * 0.5

	var material := barra_preenchimento.material_override as StandardMaterial3D

	if material:
		material.albedo_color = Color(0.15, 0.85, 0.2) if fracao > 0.3 else Color(0.9, 0.15, 0.1)
