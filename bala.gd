
extends Area3D

@export var velocidade_bala: float = 10000.0
@export var dano_bala: int = 25
@export var tempo_vida: float = 25.0

@export var detectar_areas: bool = false
@export var detectar_corpos: bool = true

var direcao: Vector3 = Vector3.FORWARD
var dono: Node3D = null
var dano_efetivo: float = 25.0
var tempo_restante: float = 0.0
var distancia_percorrida: float = 0.0
var distancia_maxima: float = 1000.0


func _ready() -> void:
	tempo_restante = tempo_vida
	monitoring = false
	monitorable = false


func configurar(
	direcao_disparo: Vector3,
	dono_disparo: Node3D = null,
	alcance: float = 1000.0,
	dano_customizado: float = -1.0
) -> void:
	direcao = direcao_disparo.normalized()
	dono = dono_disparo
	distancia_maxima = alcance

	if dano_customizado > 0.0:
		dano_efetivo = dano_customizado
	else:
		dano_efetivo = float(dano_bala)

	if direcao.length_squared() < 0.0001:
		direcao = Vector3.FORWARD

	print("BALA CRIADA | Dono: ", dono.name if is_instance_valid(dono) else "SEM DONO")


func _physics_process(delta: float) -> void:
	tempo_restante -= delta

	if tempo_restante <= 0.0:
		queue_free()
		return

	var distancia_restante := distancia_maxima - distancia_percorrida
	var distancia_passo := minf(velocidade_bala * delta, distancia_restante)

	if distancia_passo <= 0.0:
		queue_free()
		return

	var posicao_atual := global_position
	var proxima_posicao := posicao_atual + direcao * distancia_passo

	var consulta := PhysicsRayQueryParameters3D.create(
		posicao_atual,
		proxima_posicao
	)

	consulta.collide_with_bodies = detectar_corpos
	consulta.collide_with_areas = detectar_areas

	var exclusoes: Array[RID] = []
	exclusoes.append(get_rid())

	if is_instance_valid(dono):
		_adicionar_colisoes_do_jogador(dono, exclusoes)

	consulta.exclude = exclusoes

	var espaco_fisico := get_world_3d().direct_space_state
	var impacto := espaco_fisico.intersect_ray(consulta)

	if not impacto.is_empty():
		global_position = impacto.position

		var alvo: Node = impacto.collider as Node

		print("BALA ATINGIU: ", alvo.name)
		_processar_alvo(alvo)

		queue_free()
		return

	global_position = proxima_posicao
	distancia_percorrida += distancia_passo

	if distancia_percorrida >= distancia_maxima:
		queue_free()


func _adicionar_colisoes_do_jogador(
	no: Node,
	exclusoes: Array[RID]
) -> void:
	if no is CollisionObject3D:
		exclusoes.append(no.get_rid())

	for filho in no.get_children():
		_adicionar_colisoes_do_jogador(filho, exclusoes)


func _processar_alvo(alvo: Node) -> void:
	if alvo == null or alvo == self:
		return

	if is_instance_valid(dono):
		if alvo == dono or dono.is_ancestor_of(alvo):
			print("BALA BLOQUEADA: atingiu o próprio dono.")
			return

	var atual: Node = alvo

	while atual != null:
		if is_instance_valid(dono) and (atual == dono or dono.is_ancestor_of(atual)):
			print("BALA BLOQUEADA: alvo pertence ao dono.")
			return

		if atual.has_method("levar_dano"):
			print("DANO APLICADO | Dono: ", dono.name if is_instance_valid(dono) else "SEM DONO", " | Alvo: ", atual.name)
			atual.levar_dano(dano_efetivo)
			return

		if atual.has_method("receber_dano"):
			print("DANO APLICADO | Dono: ", dono.name if is_instance_valid(dono) else "SEM DONO", " | Alvo: ", atual.name)
			atual.receber_dano(int(dano_efetivo))
			return

		atual = atual.get_parent()
