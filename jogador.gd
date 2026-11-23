extends CharacterBody3D



@export var velocidade_corrida: float = 8.5

@export var velocidade_recuo: float = 4.5

@export var velocidade_lateral: float = 4.5

@export var impulso_esquiva: float = 7.5

@export var duracao_esquiva: float = 0.55

@export var janela_roll_cancel: float = 0.30

@export var duracao_ataque: float = 0.65



# >> REGULE A DISTANCIA DO IMPULSO DO CHUTE AQUI (EX.: 0.35 = MENOS, 1.0 = MAIS) <<<

var distancia_impulso_chute: float = 2.3



@export var forca_salto: float = 4.1

@export var gravidade_salto: float = 18.0

@export var duracao_janela: float = 0.65

@export var velocidade_anim_janela: float = 1.70



# TEMPO INICIAL DA ANIMAÇÃO DO MORTAL (EM SEGUNDOS):

# Ex.: 0.0 = começa do início | 0.15 = pula os primeiros frames da preparação

@export_range(0.0, 1.5, 0.01) var tempo_inicio_anim_janela: float = 0.15



@export var blend_saida_janela: float = 0.24

@export var distancia_apos_janela: float = 1.35

@export var distancia_maxima_janela: float = 3.5

@export var avanco_deteccao_janela: float = 1.05

@export var comprimento_caixa_janela: float = 2.2

@export var altura_arco_janela: float = 0.80



# ALTURA VISUAL DO MORTAL: 1.0 = original, maior = mais alto, menor = mais baixo

@export var altura_mortal: float = 0.5



# AJUSTE PARA AS PERNAS PASSAREM NA PAREDE DURANTE O MORTAL:

# Reduz o arco vertical durante o giro para que o tronco passe no vão e as pernas atravessem a parede superior/inferior sem empurrar o personagem

@export var fator_arco_mortal_parede: float = 0.38

@export var afundamento_giro_mortal: float = 0.14



@export var largura_vao_janela: float = 2.4

@export var margem_lateral_vao_janela: float = 0.25

@export var sensibilidade_rato: float = 0.003

@export var sensibilidade_vertical: float = 0.0006

@export var altura_pivo_camera: float = 1.63

@export var ajuste_altura_camera_cabeca: float = 0.34

@export var limite_vertical_camera_graus: float = 60.0



# RECUO DA CÂMARA

@export var intensidade_recuo: float = 0.17

@export var suavidade_subida_recuo: float = 2.0

@export var velocidade_recuperacao_recuo: float = 1.0



var recuo_alvo: float = 0.0

var recuo_atual: float = 0.0



# VIDA E DANOS

@export var vida_maxima: float = 100.0

@export var dano_arma: int = 25

@export var multiplicador_headshot: float = 2.5

@export var dano_chute: float = 35.0

var vida_atual: float = 100.0



# MORTE E RENASCIMENTO IMEDIATO

var esta_morto: bool = false

const CANTOS_RESPAWN = [

	Vector3(16.0, 0.0, 16.0),

	Vector3(-16.0, 0.0, 16.0),

	Vector3(16.0, 0.0, -16.0),

	Vector3(-16.0, 0.0, -16.0)

]



# MUNIÇÃO, RAJADA E RECARGA

@export_group("Munição, Rajada e Recarga")

@export var municao_infinita_teste: bool = true

@export var capacidade_pente: int = 30

@export var municao_reserva: int = 150

@export var tempo_recarga: float = 2.62

@export var balas_por_rajada: int = 8 # 0 = usa capacidade_pente inteira

@export var recarregar_ao_acabar_rajada: bool = true



@export_group("Áudio da Arma")

@export var audio_disparo: AudioStream = preload("res://Sons/tiro_miniuzi.wav")

@export var audio_recarga: AudioStream = preload("res://Sons/recarga_miniuzi.wav")

@export_range(-20.0, 6.0, 0.5) var volume_disparo_db: float = 0.0

@export_range(-20.0, 6.0, 0.5) var volume_recarga_db: float = 0.0



var municao_atual: int = 30

var balas_restantes_rajada: int = 8

var esta_recarregando: bool = false

var timer_recarga: float = 0.0

var label_municao: Label = null



const ScriptDanoFlutuante = preload("res://dano_flutuante.gd")

const CAMINHO_ANIMACAO_PISTOLA: String = "res://Jogador/pistola.res"

const CAMINHO_ANIMACAO_PULAR_JANELA: String = "res://Jogador/pular_janela.res"



# MIRA E CÂMERA

@export var fov_camera_normal: float = 73.0

@export var fov_camera_mira: float = 43.0

@export var deslocamento_ombro_camera: float = 0.42

@export var deslocamento_ombro_mira: float = 0.44

@export var distancia_spring_arm_normal: float = 2.75

@export var distancia_spring_arm_mira: float = 1.65

@export var velocidade_transicao_mira: float = 8.0



# SUAVIZAÇÃO DA CÂMARA AO ENCONTRAR OBSTÁCULOS (PORTAS/PAREDES)

@export var velocidade_camera_obstaculo: float = 10.0

@export var margem_camera_obstaculo: float = 0.18

var camera_mascara_colisao_original: int = 0

var camera_distancia_suave: float = 0.0



@export var tamanho_mira: int = 28



# AIM ASSIST

@export var ativar_aim_assist: bool = true

@export var raio_aim_assist_ecra: float = 100.0

@export var forca_aim_assist_livre: float = 0.01

@export var forca_aim_assist_mira: float = 0.07

@export_range(0.0, 2.0, 0.05) var multiplicador_aim_vertical: float = 0.0



# ROTAÇÃO DO TRONCO DURANTE OS DISPAROS

@export var limite_giro_tronco_graus: float = 105.0

@export var maximo_giro_tronco_graus: float = 65.0

@export var velocidade_giro_tronco: float = 12.0

@export var limite_inclinacao_mira_graus: float = 45.0

@export var velocidade_inclinacao_mira: float = 10.0



# MINI UZI

@export var arma_equipada: bool = true

@export var nome_osso_mao_direita: String = "mixamorig10_RightHand"

@export var osso_costas: String = "mixamorig10_Spine2"

@export var deslocamento_arma_na_mao: Vector3 = Vector3(0.025, 0.145, 0.02)

@export var rotacao_arma_na_mao: Vector3 = Vector3(84.0, 92.0, 0.0)

@export var deslocamento_arma_costas: Vector3 = Vector3(-0.09, 0.0, -0.15)

@export var rotacao_arma_costas: Vector3 = Vector3(90.0, 90.0, 180.0)

@export var escala_arma: float = 0.48

@export var rotacao_modelo_arma_local: Vector3 = Vector3(-4.0, 0.0, 0.0)

@export var deslocamento_boca_cano: Vector3 = Vector3(0.0, 0.025, -0.31)

@export var intervalo_disparo: float = 0.15

@export var alcance_disparo: float = 1000.0

@export var forca_rotacao_arma_alvo: float = 18.0

@export var limite_rotacao_arma_graus: float = 55.0



# ANIMAÇÕES

@export var anim_parado: String = "Correr_modelo/parado"

@export var anim_frente: String = "Correr_modelo/correr_novo"

@export var anim_tras: String = "Correr_modelo/andar_tras"

@export var anim_esq: String = "Correr_modelo/andar_esq"

@export var anim_dir: String = "Correr_modelo/andar_dir"

var anim_salto: String = "Correr_modelo/pulo_novo"

@export var anim_queda: String = "Correr_modelo/queda"

@export var anim_esquiva: String = "Correr_modelo/rolar"

@export var anim_chute: String = "Correr_modelo/chute"

var anim_pular_janela: String = "Correr_modelo/mortal"



# ANIMAÇÃO DA PISTOLA

@export var anim_levantar_pistola: String = "pistola"

@export var anim_recarga: String = "Correr_modelo/Reloading"

@export var duracao_anim_recarga_original: float = 0.0

@export var tempo_recarga_sincronizado: float = 2.62



@onready var animation_player: AnimationPlayer = $ModeloVisual/Correr_modelo/AnimationPlayer

@onready var pivo_camera: Node3D = $PivoCamera

@onready var camera_3d: Camera3D = $PivoCamera/SpringArm3D/Camera3D

var spring_arm_ref: SpringArm3D = null

var pivo_camera_vertical: Node3D = null

@onready var hud: Node = get_node_or_null("HUD")

@onready var barra_vida: ProgressBar = get_node_or_null("HUD/BarraVida") as ProgressBar

var som_disparo: AudioStreamPlayer = null

var som_recarga: AudioStreamPlayer = null



var animation_overlay: AnimationPlayer = null

var anim_recarga_extraida: Animation = null

var tempo_anim_recarga_decorrido: float = 0.0

var velocidade_anim_recarga_atual: float = 1.0

var ossos_superiores_recarga: Array[int] = []

var rotacoes_repouso_recarga: Array[Quaternion] = []

var pistola_levantada: bool = false

var pistola_pressionada: bool = false

var skeleton_player: Skeleton3D = null

var ossos_tronco: Array[int] = []

var ossos_inclinacao_mira: Array[int] = []

var pesos_inclinacao_mira: Array[float] = []

var angulo_tronco_atual: float = 0.0

var angulo_tronco_alvo: float = 0.0

var inclinacao_mira_atual: float = 0.0

var inclinacao_mira_alvo: float = 0.0

var direcao_mira_tronco: Vector3 = Vector3.ZERO

var esta_atirando: bool = false

var corpo_deve_seguir_mira: bool = false

var corpo_travado_na_mira: bool = false

var alvo_giro_oponente_ativo: bool = false

var direcao_giro_oponente_fixa: Vector3 = Vector3.ZERO

var esta_mirando: bool = false

var label_mira: Label = null

var modelo_arma: Node3D = null

var visual_arma: Node3D = null

var anexo_arma: BoneAttachment3D = null

var anexo_costas: BoneAttachment3D = null

var arma_nas_costas: bool = false

var ponto_boca_cano: Marker3D = null

var tempo_para_disparar: float = 0.0

var corrida_automatica: bool = false

var corrida_automatica_antes_mortal: bool = false



var esta_a_esquivar: bool = false

var esta_a_atacar: bool = false

var esta_a_saltar_janela: bool = false

var direcao_esquiva: Vector3 = Vector3.ZERO

var velocidade_atual_esquiva: float = 0.0

var tempo_esquiva_restante: float = 0.0

var tempo_ataque_restante: float = 0.0

var tempo_janela_restante: float = 0.0

var posicao_inicial_janela: Vector3 = Vector3.ZERO

var posicao_alvo_janela: Vector3 = Vector3.ZERO

var alvo_janela: Vector3 = Vector3.ZERO

var collision_layer_original_janela: int = 0

var collision_mask_original_janela: int = 0

var colisao_janela_desativada: bool = false



var buffer_esquiva_timer: float = 0.0

var buffer_salto_roll_timer: float = 0.0

const TEMPO_BUFFER_MAX: float = 0.25



var angulo_ataque: float = 0.0

var direcao_ataque: Vector3 = Vector3.ZERO

var oponentes_atingidos: Array = []

var ponto_alvo_arma_mundo: Vector3 = Vector3.ZERO

var tem_alvo_arma_mundo: bool = false



# =========================================================

# FUNÇÃO READY

# =========================================================

func _ready() -> void:

	anim_salto = "Correr_modelo/pulo_novo"

	anim_pular_janela = "Correr_modelo/mortal"

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	set_process_priority(1001)



	skeleton_player = get_node_or_null("ModeloVisual/Correr_modelo/Skeleton3D") as Skeleton3D

	if skeleton_player:

		for nome_osso in ["mixamorig10_Spine", "mixamorig10_Spine1", "mixamorig10_Spine2"]:

			var indice_osso := skeleton_player.find_bone(nome_osso)

			if indice_osso >= 0:

				ossos_tronco.append(indice_osso)

			else:

				push_warning("Não encontrei o osso do tronco: " + nome_osso)



		var configuracao_inclinacao := [

			["mixamorig10_Neck", 0.10],

			["mixamorig10_Head", 0.06],

			["mixamorig10_LeftArm", 0.28],

			["mixamorig10_LeftForeArm", 0.30],

			["mixamorig10_RightArm", 0.42],

			["mixamorig10_RightForeArm", 0.48]

		]

		for item in configuracao_inclinacao:

			var nome_inclinacao: String = item[0]

			var peso_inclinacao: float = item[1]

			var indice_inclinacao := skeleton_player.find_bone(nome_inclinacao)

			if indice_inclinacao >= 0:

				ossos_inclinacao_mira.append(indice_inclinacao)

				pesos_inclinacao_mira.append(peso_inclinacao)

			else:

				push_warning("Não encontrei o osso para inclinação da mira: " + nome_inclinacao)



		_preparar_animacao_recarga_superior()



	vida_atual = vida_maxima

	atualizar_barra_vida()

	add_to_group("Jogador")

	add_to_group("jogador")

	municao_atual = 999999 if municao_infinita_teste else maxi(capacidade_pente, 1)

	resetar_contador_rajada()

	esta_recarregando = false

	timer_recarga = 0.0

	tempo_anim_recarga_decorrido = 0.0

	label_municao = get_node_or_null("HUD/LabelMunicao") as Label

	atualizar_hud_municao()

	configurar_audios_arma()

	corrigir_opacidade_modelo()

	ativar_colisao_chute(false)

	_configurar_area_dano_chute()



	if pivo_camera:

		var posicao_pivo := pivo_camera.position

		posicao_pivo.y = altura_pivo_camera

		pivo_camera.position = posicao_pivo

		pivo_camera.rotation.x = 0.0

		var spring_arm := pivo_camera.get_node_or_null("SpringArm3D") as SpringArm3D

		if spring_arm:

			spring_arm_ref = spring_arm

			spring_arm_ref.spring_length = distancia_spring_arm_normal

			camera_distancia_suave = distancia_spring_arm_normal

			camera_mascara_colisao_original = spring_arm_ref.collision_mask

			# A colisão nativa encurta o braço instantaneamente; a distância será controlada por raycast suavizado.

			spring_arm_ref.collision_mask = 0

			pivo_camera_vertical = Node3D.new()

			pivo_camera_vertical.name = "PivoCameraVertical_Automatico"

			pivo_camera.add_child(pivo_camera_vertical)

			pivo_camera_vertical.transform = Transform3D.IDENTITY

			spring_arm.reparent(pivo_camera_vertical, true)

		else:

			push_error("SpringArm3D não encontrado como filho direto de PivoCamera.")



	if skeleton_player and pivo_camera:

		await get_tree().process_frame

		skeleton_player.force_update_all_bone_transforms()

		var indice_cabeca := skeleton_player.find_bone("mixamorig10_Head")

		if indice_cabeca >= 0:

			var pose_cabeca_esqueleto: Transform3D = skeleton_player.get_bone_global_pose(indice_cabeca)

			var cabeca_mundo: Vector3 = skeleton_player.global_transform * pose_cabeca_esqueleto.origin

			var posicao_pivo_mundo: Vector3 = pivo_camera.global_position

			posicao_pivo_mundo.y = cabeca_mundo.y + ajuste_altura_camera_cabeca

			pivo_camera.global_position = posicao_pivo_mundo

		else:

			push_warning("Osso mixamorig10_Head não encontrado; mantendo altura_pivo_camera como alternativa.")



	if camera_3d:

		camera_3d.fov = fov_camera_normal

		camera_3d.h_offset = deslocamento_ombro_camera



	criar_mira_hud()



	if arma_equipada:

		criar_arma_provisoria()



	configurar_animacao_pular_janela()



	for anim_path in [anim_chute, anim_esquiva, anim_pular_janela, anim_salto, anim_frente, anim_parado, anim_queda]:

		if animation_player and animation_player.has_animation(anim_path):

			var anim = animation_player.get_animation(anim_path)

			if anim:

				if anim_path == anim_pular_janela:

					anim.loop_mode = Animation.LOOP_NONE

				for i in range(anim.get_track_count()):

					var track_path = str(anim.track_get_path(i))

					if anim.track_get_type(i) == Animation.TYPE_POSITION_3D and "Hips" in track_path:

						if anim.track_get_key_count(i) > 0:

							var base_y: float = anim.track_get_key_value(i, 0).y

							for k in range(anim.track_get_key_count(i)):

								var pos = anim.track_get_key_value(i, k)

								pos.x = 0.0

								pos.z = 0.0

								if anim_path == anim_pular_janela:

									pos.y = base_y + (pos.y - base_y) * altura_mortal

								anim.track_set_key_value(i, k, pos)



	if arma_equipada:

		criar_animacao_overlay_pistola()

		_preparar_animacao_recarga_superior()



func configurar_animacao_pular_janela() -> void:

	if animation_player == null:

		return

	var recurso_janela: Resource = load(CAMINHO_ANIMACAO_PULAR_JANELA)

	if recurso_janela == null:

		push_warning("Não foi possível carregar animação da janela: " + CAMINHO_ANIMACAO_PULAR_JANELA)

		return



	var anim_extraida: Animation = null

	if recurso_janela is Animation:

		anim_extraida = (recurso_janela as Animation).duplicate(true)

	elif recurso_janela is AnimationLibrary:

		var lib := recurso_janela as AnimationLibrary

		if lib.has_animation("pular_janela"):

			anim_extraida = lib.get_animation("pular_janela").duplicate(true)

		elif lib.has_animation("mortal"):

			anim_extraida = lib.get_animation("mortal").duplicate(true)

		else:

			var nomes := lib.get_animation_list()

			if nomes.size() > 0:

				anim_extraida = lib.get_animation(nomes[0]).duplicate(true)



	if anim_extraida == null:

		push_warning("Nenhuma animação válida encontrada em: " + CAMINHO_ANIMACAO_PULAR_JANELA)

		return



	anim_extraida.loop_mode = Animation.LOOP_NONE

	var biblioteca_global := animation_player.get_animation_library("")

	if biblioteca_global == null:

		biblioteca_global = AnimationLibrary.new()

		animation_player.add_animation_library("", biblioteca_global)

	if biblioteca_global.has_animation(anim_pular_janela):

		biblioteca_global.remove_animation(anim_pular_janela)

	biblioteca_global.add_animation(anim_pular_janela, anim_extraida)

	print("Animação da janela carregada de: ", CAMINHO_ANIMACAO_PULAR_JANELA)



# =========================================================

# ATUALIZAÇÃO DA BARRA DE VIDA E HUD DE MUNIÇÃO

# =========================================================

func atualizar_barra_vida() -> void:

	if not is_instance_valid(barra_vida):

		return

	barra_vida.max_value = vida_maxima

	barra_vida.value = vida_atual



func atualizar_hud_municao() -> void:

	if not is_instance_valid(label_municao):

		label_municao = get_node_or_null("HUD/LabelMunicao") as Label

	if not is_instance_valid(label_municao):

		return

	if municao_infinita_teste:

		if balas_por_rajada > 0:

			label_municao.text = "%d / ∞" % balas_restantes_rajada

		else:

			label_municao.text = "∞"

	else:

		label_municao.text = "%d / %d" % [municao_atual, municao_reserva]



func resetar_contador_rajada() -> void:

	if balas_por_rajada > 0:

		if municao_infinita_teste:

			balas_restantes_rajada = balas_por_rajada

		else:

			balas_restantes_rajada = mini(balas_por_rajada, municao_atual)

	else:

		balas_restantes_rajada = municao_atual



# =========================================================

# CONFIGURAÇÃO AUTOMÁTICA DA ÁREA DO CHUTE

# =========================================================

func _configurar_area_dano_chute() -> void:

	var area: Area3D = get_node_or_null("ModeloVisual/AreaDanoChute")

	if area == null:

		area = get_node_or_null("ModeloVisual/Correr_modelo/Skeleton3D/AreaDanoChute")

	if area == null:

		return

	if not area.body_entered.is_connected(_on_area_dano_chute_body_entered):

		area.body_entered.connect(_on_area_dano_chute_body_entered)

	area.monitoring = false

	area.monitorable = true



# =========================================================

# CORREÇÃO DA OPACIDADE DO MODELO

# =========================================================

func corrigir_opacidade_modelo() -> void:

	var modelo := get_node_or_null("ModeloVisual")

	if modelo == null:

		return

	_corrigir_opacidade_recursiva(modelo)



func _corrigir_opacidade_recursiva(no: Node) -> void:

	if no.name == "MiniUziSemCoronha":

		return

	if no is MeshInstance3D:

		var malha := no as MeshInstance3D

		if malha.material_override != null:

			var material_global := malha.material_override.duplicate(true)

			if material_global is BaseMaterial3D:

				material_global.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED

				var cor_global: Color = material_global.albedo_color

				cor_global.a = 1.0

				material_global.albedo_color = cor_global

				malha.material_override = material_global

		if malha.mesh != null:

			for indice in range(malha.mesh.get_surface_count()):

				var material_superficie := malha.get_active_material(indice)

				if material_superficie == null:

					continue

				var material_novo := material_superficie.duplicate(true)

				if material_novo is BaseMaterial3D:

					material_novo.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED

					var cor: Color = material_novo.albedo_color

					cor.a = 1.0

					material_novo.albedo_color = cor

					malha.set_surface_override_material(indice, material_novo)

	for filho in no.get_children():

		_corrigir_opacidade_recursiva(filho)



# =========================================================

# CONTROLE CONTÍNUO

# =========================================================

func _process(delta: float) -> void:

	if esta_morto:

		parar_som_disparo()

		cancelar_recarga()

		return



	if esta_a_esquivar:

		cancelar_recarga()



	atualizar_recarga(delta)

	atualizar_rotacao_tronco(delta)



	if esta_recarregando:

		_aplicar_pose_recarga_superior()



	if recuo_alvo > 0.0001 or recuo_atual > 0.0001:

		recuo_alvo = move_toward(recuo_alvo, 0.0, velocidade_recuperacao_recuo * delta)

		var recuo_anterior := recuo_atual

		recuo_atual = lerp(recuo_atual, recuo_alvo, clampf(suavidade_subida_recuo * delta, 0.0, 1.0))

		var diferenca_recuo := recuo_atual - recuo_anterior

		if pivo_camera_vertical and is_instance_valid(pivo_camera_vertical):

			pivo_camera_vertical.rotation.x += diferenca_recuo

			var limite_vertical := deg_to_rad(limite_vertical_camera_graus)

			pivo_camera_vertical.rotation.x = clampf(pivo_camera_vertical.rotation.x, -limite_vertical, limite_vertical)



	if not arma_equipada or animation_overlay == null:

		return



	if esta_a_esquivar or esta_a_atacar or esta_a_saltar_janela or arma_nas_costas or esta_recarregando:

		if pistola_levantada:

			pistola_levantada = false

			animation_overlay.stop()

		parar_som_disparo()

		_resetar_rotacao_arma_alvo(delta)

		return



	var segurando_tiro := pistola_pressionada or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	if segurando_tiro and not arma_nas_costas and not esta_recarregando:

		pistola_pressionada = true

		levantar_pistola()

		iniciar_som_disparo()

	else:

		if pistola_levantada:

			pistola_levantada = false

			animation_overlay.stop()

		parar_som_disparo()



	processar_mira_e_aim_assist(delta)

	atualizar_orientacao_arma_alvo(delta)



func _resetar_rotacao_arma_alvo(delta: float) -> void:

	if is_instance_valid(visual_arma):

		visual_arma.rotation_degrees = visual_arma.rotation_degrees.lerp(

			rotacao_modelo_arma_local,

			clampf(delta * forca_rotacao_arma_alvo, 0.0, 1.0)

		)



func _encontrar_ponto_oponente_na_mira() -> Dictionary:

	var resultado := {"encontrado": false, "ponto": Vector3.ZERO, "dir": Vector3.ZERO}

	if not is_instance_valid(camera_3d):

		return resultado

	var tamanho_tela := get_viewport().get_visible_rect().size

	var centro_tela := tamanho_tela * 0.5

	var espaco := get_world_3d().direct_space_state

	var candidatos: Array[Node] = []

	for nodo in get_tree().get_nodes_in_group("oponente"):

		if is_instance_valid(nodo) and nodo is Node3D and nodo != self:

			candidatos.append(nodo)

	for nodo in get_tree().get_nodes_in_group("inimigo"):

		if is_instance_valid(nodo) and nodo is Node3D and nodo != self and nodo not in candidatos:

			candidatos.append(nodo)

	var melhor_dist := INF

	var melhor_ponto := Vector3.ZERO

	var melhor_dir := Vector3.ZERO

	for nodo in candidatos:

		var op_node := nodo as Node3D

		var ponto_alvo := op_node.global_position + Vector3(0.0, 1.35, 0.0)

		if camera_3d.is_position_behind(ponto_alvo):

			continue

		var pos_ecra := camera_3d.unproject_position(ponto_alvo)

		if pos_ecra.x < 0.0 or pos_ecra.x > tamanho_tela.x or pos_ecra.y < 0.0 or pos_ecra.y > tamanho_tela.y:

			continue

		var dist_ecra := centro_tela.distance_to(pos_ecra)

		if dist_ecra > maxf(raio_aim_assist_ecra * 2.2, 220.0):

			continue

		var query_visao := PhysicsRayQueryParameters3D.new()

		query_visao.from = camera_3d.global_position

		query_visao.to = ponto_alvo

		query_visao.exclude = [get_rid(), op_node]

		query_visao.collide_with_bodies = true

		query_visao.collide_with_areas = false

		var hit := espaco.intersect_ray(query_visao)

		if not hit.is_empty():

			var col := hit.collider as Node

			if col != null and not _verificar_se_e_inimigo(col):

				continue

		if dist_ecra < melhor_dist:

			melhor_dist = dist_ecra

			melhor_ponto = ponto_alvo

			var dir_calc := ponto_alvo - global_position

			if dir_calc.length_squared() > 0.0001:

				melhor_dir = dir_calc.normalized()

	if melhor_dist < INF:

		resultado["encontrado"] = true

		resultado["ponto"] = melhor_ponto

		resultado["dir"] = melhor_dir

	return resultado



func atualizar_orientacao_arma_alvo(delta: float) -> void:

	if not is_instance_valid(visual_arma) or not is_instance_valid(modelo_arma) or arma_nas_costas:

		return

	if not esta_atirando and not esta_mirando:

		_resetar_rotacao_arma_alvo(delta)

		return

	var info_op := _encontrar_ponto_oponente_na_mira()

	var dir_desejada := Vector3.ZERO

	if info_op["encontrado"]:

		dir_desejada = info_op["dir"]

		ponto_alvo_arma_mundo = info_op["ponto"]

		tem_alvo_arma_mundo = true

	elif direcao_mira_tronco.length_squared() > 0.0001:

		dir_desejada = direcao_mira_tronco.normalized()

		tem_alvo_arma_mundo = false

	elif is_instance_valid(camera_3d):

		var centro := get_viewport().get_visible_rect().size * 0.5

		dir_desejada = camera_3d.project_ray_normal(centro).normalized()

		tem_alvo_arma_mundo = false

	if dir_desejada.length_squared() <= 0.0001:

		_resetar_rotacao_arma_alvo(delta)

		return

	var parent_arma := modelo_arma.get_parent() as Node3D

	if parent_arma == null:

		return

	var basis_pai_sem_escala := parent_arma.global_transform.basis.orthonormalized()

	var dir_no_pai := (basis_pai_sem_escala.inverse() * dir_desejada).normalized()

	var basis_modelo := modelo_arma.transform.basis.orthonormalized()

	var dir_no_modelo := (basis_modelo.inverse() * dir_no_pai).normalized()

	var yaw_local := clampf(

		atan2(-dir_no_modelo.x, -dir_no_modelo.z),

		-deg_to_rad(limite_rotacao_arma_graus),

		deg_to_rad(limite_rotacao_arma_graus)

	)

	var pitch_local := clampf(

		asin(clampf(dir_no_modelo.y, -1.0, 1.0)),

		-deg_to_rad(limite_rotacao_arma_graus * 0.75),

		deg_to_rad(limite_rotacao_arma_graus * 0.75)

	)

	var rot_base_rad := Vector3(

		deg_to_rad(rotacao_modelo_arma_local.x),

		deg_to_rad(rotacao_modelo_arma_local.y),

		deg_to_rad(rotacao_modelo_arma_local.z)

	)

	var quat_base := Quaternion.from_euler(rot_base_rad)

	var quat_ajuste := Quaternion(Vector3.UP, yaw_local) * Quaternion(Vector3.RIGHT, pitch_local)

	var quat_final := quat_base * quat_ajuste

	var euler_alvo_graus := quat_final.get_euler() * (180.0 / PI)

	visual_arma.rotation_degrees = visual_arma.rotation_degrees.lerp(

		euler_alvo_graus,

		clampf(delta * forca_rotacao_arma_alvo, 0.0, 1.0)

	)



func _obter_direcao_oponente_nas_costas() -> Vector3:

	var visual_node := get_node_or_null("ModeloVisual") as Node3D

	if not is_instance_valid(visual_node) or not is_instance_valid(camera_3d):

		return Vector3.ZERO

	var frente_modelo := visual_node.global_transform.basis.z

	frente_modelo.y = 0.0

	if frente_modelo.length_squared() <= 0.0001:

		return Vector3.ZERO

	frente_modelo = frente_modelo.normalized()

	var espaco := get_world_3d().direct_space_state

	var tamanho_tela := get_viewport().get_visible_rect().size

	var centro_tela := tamanho_tela * 0.5

	var raio_mira := maxf(raio_aim_assist_ecra, 150.0)

	var candidatos: Array[Node] = []

	for nodo in get_tree().get_nodes_in_group("oponente"):

		if is_instance_valid(nodo) and nodo is Node3D and nodo != self:

			candidatos.append(nodo)

	for nodo in get_tree().get_nodes_in_group("inimigo"):

		if is_instance_valid(nodo) and nodo is Node3D and nodo != self and nodo not in candidatos:

			candidatos.append(nodo)

	var melhor_dir := Vector3.ZERO

	var menor_dist_ecra := raio_mira

	for nodo in candidatos:

		var op_node := nodo as Node3D

		var vetor_op := op_node.global_position - global_position

		vetor_op.y = 0.0

		if vetor_op.length_squared() <= 0.0001:

			continue

		var dir_op := vetor_op.normalized()

		if frente_modelo.dot(dir_op) > 0.15:

			continue

		var pos_alvo := op_node.global_position + Vector3(0.0, 1.25, 0.0)

		if camera_3d.is_position_behind(pos_alvo):

			continue

		var pos_ecra := camera_3d.unproject_position(pos_alvo)

		if pos_ecra.x < 0.0 or pos_ecra.x > tamanho_tela.x or pos_ecra.y < 0.0 or pos_ecra.y > tamanho_tela.y:

			continue

		var dist_ecra := centro_tela.distance_to(pos_ecra)

		if dist_ecra > menor_dist_ecra:

			continue

		var query_visao := PhysicsRayQueryParameters3D.new()

		query_visao.from = camera_3d.global_position

		query_visao.to = pos_alvo

		query_visao.exclude = [get_rid(), op_node]

		query_visao.collide_with_bodies = true

		query_visao.collide_with_areas = false

		var resultado_visao := espaco.intersect_ray(query_visao)

		if not resultado_visao.is_empty():

			var colisor := resultado_visao.collider as Node

			if colisor != null and not _verificar_se_e_inimigo(colisor):

				continue

		menor_dist_ecra = dist_ecra

		melhor_dir = dir_op

	return melhor_dir



func atualizar_rotacao_tronco(delta: float) -> void:

	var visual_node := get_node_or_null("ModeloVisual") as Node3D

	if not is_instance_valid(skeleton_player) or ossos_tronco.is_empty() or not is_instance_valid(visual_node):

		return



	angulo_tronco_alvo = 0.0

	inclinacao_mira_alvo = 0.0



	if not esta_atirando:

		corpo_travado_na_mira = false

		corpo_deve_seguir_mira = false

		alvo_giro_oponente_ativo = false

		direcao_giro_oponente_fixa = Vector3.ZERO



	if esta_atirando and direcao_mira_tronco.length_squared() > 0.0001:

		var direcao_local := visual_node.global_transform.basis.inverse() * direcao_mira_tronco

		direcao_local = direcao_local.normalized()



		var distancia_horizontal := Vector2(direcao_local.x, direcao_local.z).length()

		var inclinacao := atan2(direcao_local.y, maxf(distancia_horizontal, 0.0001))

		inclinacao_mira_alvo = clampf(inclinacao, -deg_to_rad(limite_inclinacao_mira_graus), deg_to_rad(limite_inclinacao_mira_graus))



		var direcao_horizontal := Vector3(direcao_local.x, 0.0, direcao_local.z)

		if direcao_horizontal.length_squared() > 0.0001:

			direcao_horizontal = direcao_horizontal.normalized()

			var angulo_relativo := atan2(direcao_horizontal.x, direcao_horizontal.z)

			var limite_corpo := deg_to_rad(limite_giro_tronco_graus)



			if alvo_giro_oponente_ativo:

				corpo_travado_na_mira = true

				corpo_deve_seguir_mira = true

				angulo_tronco_alvo = 0.0

			else:

				if absf(angulo_relativo) > limite_corpo:

					corpo_travado_na_mira = true

				corpo_deve_seguir_mira = corpo_travado_na_mira



				if not corpo_deve_seguir_mira:

					var amplitude_esq := deg_to_rad(maximo_giro_tronco_graus)

					var magnitude_igual := minf(absf(angulo_relativo), amplitude_esq)

					var sinal_direcao := signf(angulo_relativo)

					angulo_tronco_alvo = sinal_direcao * magnitude_igual



	angulo_tronco_atual = lerp_angle(angulo_tronco_atual, angulo_tronco_alvo, clampf(delta * velocidade_giro_tronco, 0.0, 1.0))

	inclinacao_mira_atual = lerpf(inclinacao_mira_atual, inclinacao_mira_alvo, clampf(delta * velocidade_inclinacao_mira, 0.0, 1.0))



	var pesos_tronco := [0.25, 0.35, 0.40]

	for i in range(ossos_tronco.size()):

		var indice_osso: int = ossos_tronco[i]

		var peso: float = pesos_tronco[min(i, pesos_tronco.size() - 1)]

		var rotacao_animacao := skeleton_player.get_bone_pose_rotation(indice_osso)

		var rotacao_horizontal := Quaternion(Vector3.UP, angulo_tronco_atual * peso)

		var rotacao_vertical := Quaternion(Vector3.RIGHT, -inclinacao_mira_atual * peso * 0.65)

		skeleton_player.set_bone_pose_rotation(indice_osso, rotacao_horizontal * rotacao_animacao * rotacao_vertical)



	for i in range(ossos_inclinacao_mira.size()):

		var indice_osso: int = ossos_inclinacao_mira[i]

		var peso: float = pesos_inclinacao_mira[i]

		var rotacao_animacao := skeleton_player.get_bone_pose_rotation(indice_osso)

		var rotacao_vertical := Quaternion(Vector3.RIGHT, -inclinacao_mira_atual * peso)

		skeleton_player.set_bone_pose_rotation(indice_osso, rotacao_animacao * rotacao_vertical)



	if esta_recarregando:

		_aplicar_pose_recarga_superior()



func _tem_linha_de_visao_para_ponto(espaco: PhysicsDirectSpaceState3D, origem: Vector3, destino: Vector3, alvo_node: Node) -> bool:

	var query_visao := PhysicsRayQueryParameters3D.new()

	query_visao.from = origem

	query_visao.to = destino

	query_visao.exclude = [get_rid(), alvo_node]

	query_visao.collide_with_bodies = true

	query_visao.collide_with_areas = false

	var resultado_visao := espaco.intersect_ray(query_visao)

	if resultado_visao.is_empty():

		return true

	var colisor := resultado_visao.collider as Node

	if colisor != null and _verificar_se_e_inimigo(colisor):

		return true

	return false



func processar_mira_e_aim_assist(delta: float) -> void:

	if not is_instance_valid(camera_3d):

		return

	var tamanho_tela := get_viewport().get_visible_rect().size

	var centro_tela := tamanho_tela * 0.5

	var encontrou_inimigo := false

	var espaco := get_world_3d().direct_space_state

	var query := PhysicsShapeQueryParameters3D.new()

	var esfera := SphereShape3D.new()

	esfera.radius = 100.0

	query.shape = esfera

	query.transform = Transform3D(Basis(), global_position)

	query.exclude = [get_rid()]

	query.collide_with_bodies = true

	query.collide_with_areas = true

	var resultados := espaco.intersect_shape(query, 256)

	var melhor_alvo_ecra: Vector2 = Vector2.ZERO

	var menor_distancia_ecra: float = raio_aim_assist_ecra



	for resultado in resultados:

		var corpo = resultado.collider as Node

		if _verificar_se_e_inimigo(corpo):

			var pos_cabeca: Vector3 = corpo.global_position + Vector3(0, 1.55, 0)

			var pos_peito: Vector3 = corpo.global_position + Vector3(0, 1.0, 0)

			var pontos_teste: Array[Vector3] = []

			if not camera_3d.is_position_behind(pos_cabeca) and _tem_linha_de_visao_para_ponto(espaco, camera_3d.global_position, pos_cabeca, corpo):

				pontos_teste.append(pos_cabeca)

			if not camera_3d.is_position_behind(pos_peito) and _tem_linha_de_visao_para_ponto(espaco, camera_3d.global_position, pos_peito, corpo):

				pontos_teste.append(pos_peito)

			for ponto_visivel in pontos_teste:

				var pos_ecra = camera_3d.unproject_position(ponto_visivel)

				var distancia_ecra = centro_tela.distance_to(pos_ecra)

				if distancia_ecra < menor_distancia_ecra:

					menor_distancia_ecra = distancia_ecra

					melhor_alvo_ecra = pos_ecra

					encontrou_inimigo = true



	if encontrou_inimigo and ativar_aim_assist and pivo_camera:

		var diff = melhor_alvo_ecra - centro_tela

		var forca = forca_aim_assist_mira if esta_mirando else forca_aim_assist_livre

		pivo_camera.rotate_y(-diff.x * forca * delta)

		if pivo_camera_vertical and multiplicador_aim_vertical > 0.0:

			var fator_vertical: float = forca * multiplicador_aim_vertical

			pivo_camera_vertical.rotate_x(-diff.y * fator_vertical * delta)

			var limite_vertical := deg_to_rad(limite_vertical_camera_graus)

			pivo_camera_vertical.rotation.x = clampf(pivo_camera_vertical.rotation.x, -limite_vertical, limite_vertical)



	var mira_no := get_node_or_null("HUD/TextureRect") as TextureRect

	var oponente_na_mira := encontrou_inimigo and menor_distancia_ecra < 60.0

	if is_instance_valid(label_mira):

		label_mira.visible = false

		label_mira.add_theme_color_override("font_color", Color.RED if oponente_na_mira else Color.WHITE)

	if is_instance_valid(mira_no):

		mira_no.visible = true

		mira_no.modulate = Color.RED if oponente_na_mira else Color.WHITE

		centralizar_mira(mira_no)



func _verificar_se_e_inimigo(alvo: Node) -> bool:

	var receptor: Node = alvo

	while receptor != null:

		if receptor == self:

			return false

		if receptor.has_method("receber_dano") or receptor.has_method("levar_dano") or receptor.is_in_group("inimigo") or receptor.is_in_group("oponente"):

			return true

		receptor = receptor.get_parent()

	return false



# =========================================================

# RECEBER DANO E RENASCIMENTO

# =========================================================

func levar_dano(quantidade: float) -> void:

	if esta_morto:

		return

	vida_atual = clampf(vida_atual - quantidade, 0.0, vida_maxima)

	atualizar_barra_vida()

	if vida_atual <= 0.0:

		iniciar_renascimento()



func iniciar_renascimento() -> void:

	if esta_morto:

		return

	_restaurar_colisao_apos_janela()

	esta_morto = true

	velocity = Vector3.ZERO

	esta_a_atacar = false

	esta_a_esquivar = false

	esta_a_saltar_janela = false

	esta_mirando = false

	corrida_automatica = false

	pistola_pressionada = false

	pistola_levantada = false

	esta_atirando = false

	alvo_giro_oponente_ativo = false

	direcao_giro_oponente_fixa = Vector3.ZERO

	direcao_mira_tronco = Vector3.ZERO

	angulo_tronco_atual = 0.0

	angulo_tronco_alvo = 0.0

	inclinacao_mira_atual = 0.0

	inclinacao_mira_alvo = 0.0

	tem_alvo_arma_mundo = false

	parar_som_disparo()

	cancelar_recarga()

	municao_atual = 999999 if municao_infinita_teste else maxi(capacidade_pente, 1)

	resetar_contador_rajada()

	atualizar_hud_municao()

	buffer_esquiva_timer = 0.0

	buffer_salto_roll_timer = 0.0

	tempo_para_disparar = 0.0

	recuo_alvo = 0.0

	recuo_atual = 0.0

	if pivo_camera_vertical and is_instance_valid(pivo_camera_vertical):

		pivo_camera_vertical.rotation.x = 0.0

	ativar_colisao_chute(false)

	abaixar_pistola()

	if animation_player:

		animation_player.stop()



	var oponente = get_tree().get_first_node_in_group("oponente")

	var pontos_validos: Array[Vector3] = []

	for ponto in CANTOS_RESPAWN:

		if is_instance_valid(oponente) and oponente is Node3D:

			if ponto.distance_to(oponente.global_position) >= 4.0:

				pontos_validos.append(ponto)

		else:

			pontos_validos.append(ponto)



	if pontos_validos.is_empty():

		pontos_validos = CANTOS_RESPAWN.duplicate()



	var nova_posicao: Vector3 = pontos_validos.pick_random()

	global_position = nova_posicao

	velocity = Vector3.ZERO

	reset_physics_interpolation()



	vida_atual = vida_maxima

	atualizar_barra_vida()

	var modelo = get_node_or_null("ModeloVisual")

	if modelo:

		modelo.visible = true

		modelo.position = Vector3.ZERO

	esta_a_atacar = false

	esta_a_esquivar = false

	esta_a_saltar_janela = false

	esta_mirando = false

	esta_morto = false

	ativar_colisao_chute(false)



# =========================================================

# ÁUDIO DA ARMA (DISPARO E RECARGA) E SISTEMA DE RECARGA

# =========================================================

func _resolver_stream_disparo() -> AudioStream:

	if audio_disparo != null:

		return audio_disparo

	if ResourceLoader.exists("res://Sons/tiro_miniuzi.wav"):

		return load("res://Sons/tiro_miniuzi.wav") as AudioStream

	return null



func _resolver_stream_recarga() -> AudioStream:

	if audio_recarga != null:

		return audio_recarga

	if ResourceLoader.exists("res://Sons/recarga_miniuzi.wav"):

		return load("res://Sons/recarga_miniuzi.wav") as AudioStream

	return null



func configurar_audios_arma() -> void:

	if is_instance_valid(som_disparo):

		som_disparo.queue_free()

	som_disparo = AudioStreamPlayer.new()

	som_disparo.name = "SomDisparoMiniUzi"

	var stream_tiro := _resolver_stream_disparo()

	if stream_tiro != null:

		var stream_duplicado := stream_tiro.duplicate() as AudioStream

		if stream_duplicado is AudioStreamWAV:

			(stream_duplicado as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_DISABLED

		som_disparo.stream = stream_duplicado

	else:

		push_warning("Áudio de disparo não encontrado em res://Sons/tiro_miniuzi.wav.")

	som_disparo.volume_db = volume_disparo_db

	add_child(som_disparo)



	if is_instance_valid(som_recarga):

		som_recarga.queue_free()

	som_recarga = AudioStreamPlayer.new()

	som_recarga.name = "SomRecargaArma"

	som_recarga.volume_db = volume_recarga_db

	var stream_rec := _resolver_stream_recarga()

	if stream_rec != null:

		som_recarga.stream = stream_rec

	add_child(som_recarga)



func iniciar_som_disparo() -> void:

	if not is_instance_valid(som_disparo):

		return

	if not arma_equipada or arma_nas_costas or esta_morto or esta_recarregando:

		parar_som_disparo()

		return

	if esta_a_esquivar or esta_a_atacar or esta_a_saltar_janela:

		parar_som_disparo()

		return

	if not pistola_pressionada and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):

		parar_som_disparo()

		return

	if not municao_infinita_teste and municao_atual <= 0:

		parar_som_disparo()

		return

	if balas_por_rajada > 0 and balas_restantes_rajada <= 0:

		parar_som_disparo()

		return



	if som_disparo.stream == null:

		var stream_tiro := _resolver_stream_disparo()

		if stream_tiro != null:

			var stream_duplicado := stream_tiro.duplicate() as AudioStream

			if stream_duplicado is AudioStreamWAV:

				(stream_duplicado as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_DISABLED

			som_disparo.stream = stream_duplicado

	if som_disparo.stream == null:

		return



	som_disparo.volume_db = volume_disparo_db

	if not som_disparo.playing:

		som_disparo.play()



func parar_som_disparo() -> void:

	if is_instance_valid(som_disparo) and som_disparo.playing:

		som_disparo.stop()



func pode_recarregar() -> bool:

	if esta_morto or not arma_equipada or arma_nas_costas:

		return false

	if esta_recarregando:

		return false

	if esta_a_esquivar or esta_a_atacar or esta_a_saltar_janela:

		return false

	if municao_infinita_teste:

		return true

	return municao_atual < capacidade_pente and municao_reserva > 0



func iniciar_recarga(automatica_por_falta_bala: bool = false) -> void:

	if not pode_recarregar():

		return

	esta_atirando = false

	pistola_pressionada = false

	pistola_levantada = false

	corpo_travado_na_mira = false

	corpo_deve_seguir_mira = false

	alvo_giro_oponente_ativo = false

	direcao_giro_oponente_fixa = Vector3.ZERO

	if animation_overlay != null:

		animation_overlay.stop()

	parar_som_disparo()

	esta_recarregando = true

	var dur_alvo := tempo_recarga_sincronizado if tempo_recarga_sincronizado > 0.05 else tempo_recarga

	timer_recarga = maxf(dur_alvo, 0.1)

	_iniciar_animacao_recarga_superior(timer_recarga)



	if not is_instance_valid(som_recarga):

		configurar_audios_arma()

	var stream_rec := _resolver_stream_recarga()

	if is_instance_valid(som_recarga) and stream_rec != null:

		if som_recarga.stream != stream_rec:

			som_recarga.stream = stream_rec

		som_recarga.volume_db = volume_recarga_db

		som_recarga.stop()

		som_recarga.play(0.0)



	if automatica_por_falta_bala:

		print("Rajada/munição encerrada: som do tiro finalizado e recarga iniciada.")

	else:

		print("Recarga manual iniciada.")



func _garantir_som_recarga_ativo() -> void:

	if not esta_recarregando or esta_a_esquivar:

		if is_instance_valid(som_recarga) and som_recarga.playing:

			som_recarga.stop()

		return

	if not is_instance_valid(som_recarga):

		configurar_audios_arma()

	var stream_rec := _resolver_stream_recarga()

	if is_instance_valid(som_recarga) and stream_rec != null:

		if som_recarga.stream != stream_rec:

			som_recarga.stream = stream_rec

		som_recarga.volume_db = volume_recarga_db

		if not som_recarga.playing:

			var pos_estimada := maxf(tempo_anim_recarga_decorrido, 0.0)

			if stream_rec.get_length() > 0.0:

				som_recarga.play(minf(pos_estimada, maxf(stream_rec.get_length() - 0.05, 0.0)))

			else:

				som_recarga.play(0.0)



func atualizar_recarga(delta: float) -> void:

	if not esta_recarregando:

		return

	if esta_morto or arma_nas_costas or esta_a_esquivar or esta_a_atacar or esta_a_saltar_janela or not is_on_floor():

		cancelar_recarga()

		return

	_garantir_som_recarga_ativo()

	tempo_anim_recarga_decorrido += delta

	timer_recarga -= delta

	if timer_recarga <= 0.0:

		concluir_recarga()



func concluir_recarga() -> void:

	esta_recarregando = false

	timer_recarga = 0.0

	if municao_infinita_teste:

		municao_atual = 999999

	else:

		var faltando: int = capacidade_pente - municao_atual

		var transferir: int = mini(faltando, municao_reserva)

		municao_atual += transferir

		municao_reserva -= transferir

	resetar_contador_rajada()

	atualizar_hud_municao()



func cancelar_recarga() -> void:

	esta_recarregando = false

	timer_recarga = 0.0

	tempo_anim_recarga_decorrido = 0.0

	if is_instance_valid(som_recarga) and som_recarga.playing:

		som_recarga.stop()



func _obter_nome_animacao_recarga() -> String:

	if animation_player == null:

		return ""

	if anim_recarga != "" and animation_player.has_animation(anim_recarga):

		return anim_recarga

	var lista := animation_player.get_animation_list()

	for nome in lista:

		var low := nome.to_lower()

		if "reload" in low or "recarg" in low or "load" in low:

			return nome

	return ""



func _buscar_animacao_recarga_em_disco(dir_path: String = "res://") -> Animation:

	var dir := DirAccess.open(dir_path)

	if dir == null:

		return null

	dir.list_dir_begin()

	var nome_arq := dir.get_next()

	while nome_arq != "":

		if not nome_arq.begins_with("."):

			var caminho := dir_path.path_join(nome_arq)

			if dir.current_is_dir():

				var encontrada := _buscar_animacao_recarga_em_disco(caminho)

				if encontrada != null:

					dir.list_dir_end()

					return encontrada

			else:

				var baixo := nome_arq.to_lower()

				if ("reload" in baixo or "recarg" in baixo) and (baixo.ends_with(".res") or baixo.ends_with(".anim") or baixo.ends_with(".tres")):

					var rec := ResourceLoader.load(caminho)

					if rec is Animation:

						dir.list_dir_end()

						return (rec as Animation).duplicate(true)

					elif rec is AnimationLibrary:

						var lib := rec as AnimationLibrary

						for n in lib.get_animation_list():

							var n_low := n.to_lower()

							if "reload" in n_low or "recarg" in n_low or lib.get_animation_list().size() == 1:

								dir.list_dir_end()

								return lib.get_animation(n).duplicate(true)

		nome_arq = dir.get_next()

	dir.list_dir_end()

	return null



func _carregar_recurso_animacao_direto(caminho: String) -> Animation:

	if not ResourceLoader.exists(caminho):

		return null

	var rec := ResourceLoader.load(caminho)

	if rec is Animation:

		return (rec as Animation).duplicate(true)

	if rec is AnimationLibrary:

		var lib := rec as AnimationLibrary

		for n in lib.get_animation_list():

			var n_low := n.to_lower()

			if "reload" in n_low or "recarg" in n_low:

				return lib.get_animation(n).duplicate(true)

		if lib.get_animation_list().size() > 0:

			return lib.get_animation(lib.get_animation_list()[0]).duplicate(true)

	return null



func _localizar_animacao_recarga_base() -> Animation:

	var nome := _obter_nome_animacao_recarga()

	if nome != "" and animation_player != null:

		return animation_player.get_animation(nome)

	var direto := _carregar_recurso_animacao_direto("res://Jogador/Reloading.res")

	if direto != null:

		return direto

	return _buscar_animacao_recarga_em_disco("res://")



func _extrair_nome_osso_da_trilha(path_str: String) -> String:

	var partes_colon := path_str.split(":")

	var ultimo := partes_colon[partes_colon.size() - 1]

	var partes_barra := ultimo.split("/")

	return partes_barra[partes_barra.size() - 1].strip_edges()



func _preparar_animacao_recarga_superior() -> void:

	ossos_superiores_recarga.clear()

	rotacoes_repouso_recarga.clear()

	anim_recarga_extraida = null

	duracao_anim_recarga_original = 0.0

	if skeleton_player == null:

		return



	var nomes_superiores := [

		"mixamorig10_Spine",

		"mixamorig10_Spine1",

		"mixamorig10_Spine2",

		"mixamorig10_Neck",

		"mixamorig10_Head",

		"mixamorig10_LeftShoulder",

		"mixamorig10_LeftArm",

		"mixamorig10_LeftForeArm",

		"mixamorig10_LeftHand",

		"mixamorig10_RightShoulder",

		"mixamorig10_RightArm",

		"mixamorig10_RightForeArm",

		"mixamorig10_RightHand"

	]

	for nome_osso in nomes_superiores:

		var idx := skeleton_player.find_bone(nome_osso)

		if idx >= 0:

			ossos_superiores_recarga.append(idx)

			rotacoes_repouso_recarga.append(skeleton_player.get_bone_rest(idx).basis.get_rotation_quaternion())



	var anim_base := _localizar_animacao_recarga_base()

	if anim_base != null:

		anim_recarga_extraida = anim_base.duplicate(true)

		remover_trilhas_inferiores(anim_recarga_extraida)

		duracao_anim_recarga_original = maxf(anim_recarga_extraida.length, 0.05)

		var casados := 0

		for t in range(anim_recarga_extraida.get_track_count()):

			if anim_recarga_extraida.track_get_type(t) == Animation.TYPE_ROTATION_3D:

				var osso_nome := _extrair_nome_osso_da_trilha(str(anim_recarga_extraida.track_get_path(t)))

				for b_idx in ossos_superiores_recarga:

					if skeleton_player.get_bone_name(b_idx) == osso_nome:

						casados += 1

						break

		print("Recarga preparada: anim=", _obter_nome_animacao_recarga(), " dur=", duracao_anim_recarga_original, " trilhas_superiores=", casados)

	elif animation_player != null:

		print("AVISO: Animação de recarga não encontrada. Animações no AnimationPlayer: ", animation_player.get_animation_list())



func _iniciar_animacao_recarga_superior(duracao_alvo: float) -> void:

	tempo_anim_recarga_decorrido = 0.0

	if anim_recarga_extraida == null:

		_preparar_animacao_recarga_superior()

	var dur_base := duracao_anim_recarga_original if duracao_anim_recarga_original > 0.05 else maxf(duracao_alvo, 0.1)

	velocidade_anim_recarga_atual = dur_base / maxf(duracao_alvo, 0.05)



	if is_instance_valid(animation_overlay):

		animation_overlay.stop()



	var nome_rec := _obter_nome_animacao_recarga()

	if nome_rec != "" and animation_player != null and velocity.length() <= 0.1:

		animation_player.play(nome_rec, 0.08, velocidade_anim_recarga_atual)



	_aplicar_pose_recarga_superior()



func _aplicar_pose_recarga_superior() -> void:

	if not esta_recarregando or esta_a_esquivar or skeleton_player == null:

		return

	if anim_recarga_extraida == null or duracao_anim_recarga_original <= 0.001 or ossos_superiores_recarga.is_empty():

		return



	var tempo_amostra := fmod(tempo_anim_recarga_decorrido * velocidade_anim_recarga_atual, duracao_anim_recarga_original)

	var track_count := anim_recarga_extraida.get_track_count()

	for t in range(track_count):

		if anim_recarga_extraida.track_get_type(t) != Animation.TYPE_ROTATION_3D:

			continue

		var path_str := str(anim_recarga_extraida.track_get_path(t))

		var osso_trilha := _extrair_nome_osso_da_trilha(path_str)

		if osso_trilha == "":

			continue

		var idx_osso := -1

		for b_idx in ossos_superiores_recarga:

			if skeleton_player.get_bone_name(b_idx) == osso_trilha:

				idx_osso = b_idx

				break

		if idx_osso >= 0:

			var rot_anim := anim_recarga_extraida.rotation_track_interpolate(t, tempo_amostra)

			skeleton_player.set_bone_pose_rotation(idx_osso, rot_anim)



	skeleton_player.force_update_all_bone_transforms()



func abaixar_pistola() -> void:

	pistola_pressionada = false

	esta_atirando = false

	pistola_levantada = false

	alvo_giro_oponente_ativo = false

	direcao_giro_oponente_fixa = Vector3.ZERO

	tem_alvo_arma_mundo = false

	parar_som_disparo()

	if animation_overlay != null:

		animation_overlay.stop()



# =========================================================

# ANIMAÇÃO OVERLAY DA PISTOLA

# =========================================================

func criar_animacao_overlay_pistola() -> void:

	if animation_player == null:

		push_error("AnimationPlayer do personagem não encontrado.")

		return

	var recurso_pistola: Resource = load(CAMINHO_ANIMACAO_PISTOLA)

	if recurso_pistola == null:

		push_error("Não foi possível carregar: " + CAMINHO_ANIMACAO_PISTOLA)

		return



	var anim_original: Animation = null

	if recurso_pistola is Animation:

		anim_original = recurso_pistola as Animation

	elif recurso_pistola is AnimationLibrary:

		var biblioteca_origem := recurso_pistola as AnimationLibrary

		if biblioteca_origem.has_animation(anim_levantar_pistola):

			anim_original = biblioteca_origem.get_animation(anim_levantar_pistola)

		elif biblioteca_origem.has_animation("pistola"):

			anim_original = biblioteca_origem.get_animation("pistola")

		else:

			var lista_animacoes: PackedStringArray = biblioteca_origem.get_animation_list()

			if lista_animacoes.size() > 0:

				anim_original = biblioteca_origem.get_animation(lista_animacoes[0])

	else:

		push_error("O arquivo pistola.res não é uma Animation nem uma AnimationLibrary.")

		return



	if anim_original == null:

		push_error("Não foi encontrada uma animação válida dentro de pistola.res.")

		return



	if is_instance_valid(animation_overlay):

		animation_overlay.queue_free()



	animation_overlay = AnimationPlayer.new()

	animation_overlay.name = "AnimationPlayerPistola"

	animation_player.get_parent().add_child(animation_overlay)

	animation_overlay.root_node = animation_player.root_node

	animation_overlay.process_priority = 1000

	animation_overlay.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE



	var anim_pistola: Animation = anim_original.duplicate(true)

	remover_trilhas_inferiores(anim_pistola)

	anim_pistola.loop_mode = Animation.LOOP_LINEAR



	var biblioteca := AnimationLibrary.new()

	var erro_adicionar := biblioteca.add_animation("pistola", anim_pistola)

	if erro_adicionar != OK:

		push_error("Não foi possível adicionar a animação pistola à biblioteca.")

		animation_overlay.queue_free()

		animation_overlay = null

		return



	var erro_biblioteca := animation_overlay.add_animation_library("pistola_overlay", biblioteca)

	if erro_biblioteca != OK:

		push_error("Não foi possível criar a biblioteca de animação da pistola.")

		animation_overlay.queue_free()

		animation_overlay = null

		return



	print("Animação da pistola carregada com sucesso: ", CAMINHO_ANIMACAO_PISTOLA)



func remover_trilhas_inferiores(animacao: Animation) -> void:

	if animacao == null:

		return

	var palavras_inferiores = ["hips", "upleg", "leg", "foot", "toebase"]

	for i in range(animacao.get_track_count() - 1, -1, -1):

		var caminho := str(animacao.track_get_path(i)).to_lower()

		var remover := false

		for palavra in palavras_inferiores:

			if palavra in caminho:

				remover = true

				break

		if remover:

			animacao.remove_track(i)



func levantar_pistola() -> void:

	if animation_overlay == null or arma_nas_costas or esta_recarregando or esta_morto:

		return

	if esta_a_esquivar or esta_a_atacar or esta_a_saltar_janela:

		return

	if pistola_levantada:

		return

	pistola_levantada = true

	animation_overlay.play("pistola_overlay/pistola", 0.12, 1.3)



# =========================================================

# ROLL CANCEL / SALTO APÓS ESQUIVA

# =========================================================

func _executar_salto_ou_janela() -> void:

	cancelar_recarga()

	var w_pressionado = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)

	if w_pressionado or corrida_automatica:

		if tentar_iniciar_janela():

			iniciar_pular_janela()

			return

	velocity.y = forca_salto

	if animation_player and animation_player.has_animation(anim_salto):

		animation_player.play(anim_salto, 0.06)



func _tentar_roll_cancel() -> bool:

	if not esta_a_esquivar or not is_on_floor():

		return false

	if tempo_esquiva_restante > janela_roll_cancel:

		return false



	cancelar_recarga()

	esta_a_esquivar = false

	velocidade_atual_esquiva = 0.0

	tempo_esquiva_restante = 0.0

	buffer_salto_roll_timer = 0.0



	var visual_node = get_node_or_null("ModeloVisual")

	if visual_node:

		visual_node.position = Vector3.ZERO

		if direcao_esquiva.length_squared() > 0.0001:

			visual_node.rotation.y = atan2(direcao_esquiva.x, direcao_esquiva.z)



	if direcao_esquiva.length_squared() > 0.0001:

		var vel_saida := maxf(impulso_esquiva * 0.75, velocidade_corrida * 0.85)

		velocity.x = direcao_esquiva.x * vel_saida

		velocity.z = direcao_esquiva.z * vel_saida



	_executar_salto_ou_janela()

	return true



# =========================================================

# ENTRADAS

# =========================================================

func _unhandled_input(event: InputEvent) -> void:

	if esta_morto:

		return

	if Input.is_key_pressed(KEY_ESCAPE):

		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE



	if event is InputEventKey and event.pressed and not event.is_echo():

		if event.keycode == KEY_Q:

			iniciar_recarga(false)

		if event.keycode == KEY_2 or event.keycode == KEY_KP_2:

			if arma_equipada:

				guardar_arma_nas_costas(not arma_nas_costas)

		if event.keycode == KEY_1 or event.keycode == KEY_KP_1:

			corrida_automatica = true

		if event.keycode == KEY_SHIFT and not esta_a_esquivar:

			cancelar_recarga()

			buffer_esquiva_timer = TEMPO_BUFFER_MAX

		if event.keycode == KEY_SPACE:

			if esta_a_esquivar:

				buffer_salto_roll_timer = TEMPO_BUFFER_MAX

				_tentar_roll_cancel()

			elif is_on_floor() and not esta_a_atacar and not esta_a_saltar_janela:

				_executar_salto_ou_janela()



	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:

		esta_mirando = event.pressed

		if event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:

			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		if label_mira:

			label_mira.visible = false



	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:

			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:

				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

			if arma_equipada and not arma_nas_costas:

				pistola_pressionada = true

				if not esta_recarregando and not esta_a_esquivar and not esta_a_atacar and not esta_a_saltar_janela:

					if balas_por_rajada > 0 and balas_restantes_rajada <= 0:

						resetar_contador_rajada()

					iniciar_som_disparo()

					levantar_pistola()

					iniciar_disparo()

			elif not esta_a_esquivar and not esta_a_atacar and not esta_a_saltar_janela and is_on_floor():

				iniciar_ataque()

		else:

			pistola_pressionada = false

			esta_atirando = false

			corpo_travado_na_mira = false

			corpo_deve_seguir_mira = false

			alvo_giro_oponente_ativo = false

			direcao_giro_oponente_fixa = Vector3.ZERO

			parar_som_disparo()

			if arma_equipada:

				abaixar_pistola()



	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and pivo_camera:

		pivo_camera.rotate_y(-event.relative.x * sensibilidade_rato)

		if pivo_camera_vertical:

			pivo_camera_vertical.rotate_x(-event.relative.y * sensibilidade_vertical)

			var limite_vertical := deg_to_rad(limite_vertical_camera_graus)

			pivo_camera_vertical.rotation.x = clampf(pivo_camera_vertical.rotation.x, -limite_vertical, limite_vertical)



# =========================================================

# CRIAÇÃO DA MINI UZI MILITAR

# =========================================================

func criar_arma_provisoria() -> void:

	var esqueleto := get_node_or_null("ModeloVisual/Correr_modelo/Skeleton3D") as Skeleton3D

	if esqueleto == null:

		return

	var indice_osso := esqueleto.find_bone(nome_osso_mao_direita)

	if indice_osso == -1:

		return



	anexo_arma = BoneAttachment3D.new()

	anexo_arma.name = "AnexoArmaMaoDireita"

	anexo_arma.bone_name = nome_osso_mao_direita

	esqueleto.add_child(anexo_arma)



	var indice_osso_costas := esqueleto.find_bone(osso_costas)

	if indice_osso_costas != -1:

		anexo_costas = BoneAttachment3D.new()

		anexo_costas.name = "AnexoArmaCostas"

		anexo_costas.bone_name = osso_costas

		esqueleto.add_child(anexo_costas)



	modelo_arma = Node3D.new()

	modelo_arma.name = "MiniUziSemCoronha"

	modelo_arma.position = deslocamento_arma_na_mao

	modelo_arma.rotation_degrees = rotacao_arma_na_mao

	modelo_arma.scale = Vector3.ONE * escala_arma

	anexo_arma.add_child(modelo_arma)



	visual_arma = Node3D.new()

	visual_arma.name = "VisualMiniUzi"

	visual_arma.rotation_degrees = rotacao_modelo_arma_local

	modelo_arma.add_child(visual_arma)



	var material_corpo := StandardMaterial3D.new()

	material_corpo.albedo_color = Color(0.22, 0.32, 0.13)

	material_corpo.metallic = 0.35

	material_corpo.roughness = 0.68



	var material_metal := StandardMaterial3D.new()

	material_metal.albedo_color = Color(0.025, 0.032, 0.027)

	material_metal.metallic = 0.82

	material_metal.roughness = 0.32



	var material_empunhadura := StandardMaterial3D.new()

	material_empunhadura.albedo_color = Color(0.018, 0.024, 0.019)

	material_empunhadura.roughness = 0.92



	var material_detalhes := StandardMaterial3D.new()

	material_detalhes.albedo_color = Color(0.12, 0.19, 0.085)



	_adicionar_peca_arma("CorpoPrincipal", BoxMesh.new(), Vector3(0.0, 0.0, 0.0), Vector3(0.145, 0.145, 0.31), material_corpo)

	_adicionar_peca_arma("TampaSuperior", BoxMesh.new(), Vector3(0.0, 0.085, -0.005), Vector3(0.115, 0.035, 0.27), material_metal)

	_adicionar_peca_arma("ParteTraseira", BoxMesh.new(), Vector3(0.0, 0.015, 0.145), Vector3(0.135, 0.13, 0.045), material_corpo)



	var cano := CylinderMesh.new()

	cano.top_radius = 0.026

	cano.bottom_radius = 0.026

	cano.height = 0.14

	_adicionar_peca_arma("CanoCurto", cano, Vector3(0.0, 0.025, -0.225), Vector3.ONE, material_metal, Vector3(90.0, 0.0, 0.0))



	var boca := CylinderMesh.new()

	boca.top_radius = 0.033

	boca.bottom_radius = 0.033

	boca.height = 0.018

	_adicionar_peca_arma("BocaDoCano", boca, Vector3(0.0, 0.025, -0.305), Vector3.ONE, material_detalhes, Vector3(90.0, 0.0, 0.0))



	_adicionar_peca_arma("Carregador", BoxMesh.new(), Vector3(0.0, -0.155, 0.015), Vector3(0.085, 0.22, 0.105), material_metal)

	_adicionar_peca_arma("BaseCarregador", BoxMesh.new(), Vector3(0.0, -0.27, 0.015), Vector3(0.09, 0.025, 0.11), material_detalhes)

	_adicionar_peca_arma("Empunhadura", BoxMesh.new(), Vector3(0.0, -0.145, 0.12), Vector3(0.085, 0.19, 0.085), material_empunhadura, Vector3(-12.0, 0.0, 0.0))

	_adicionar_peca_arma("PainelEmpunhadura", BoxMesh.new(), Vector3(0.0, -0.15, 0.165), Vector3(0.065, 0.13, 0.012), material_corpo)

	_adicionar_peca_arma("MiraTraseira", BoxMesh.new(), Vector3(0.0, 0.115, 0.105), Vector3(0.055, 0.035, 0.035), material_metal)

	_adicionar_peca_arma("MiraFrontal", BoxMesh.new(), Vector3(0.0, 0.105, -0.22), Vector3(0.025, 0.035, 0.025), material_metal)

	_adicionar_peca_arma("TrilhoSuperior", BoxMesh.new(), Vector3(0.0, 0.108, -0.015), Vector3(0.045, 0.012, 0.16), material_detalhes)

	_adicionar_peca_arma("DetalheLateralDireito", BoxMesh.new(), Vector3(0.075, 0.015, 0.0), Vector3(0.012, 0.055, 0.12), material_metal)

	_adicionar_peca_arma("DetalheLateralEsquerdo", BoxMesh.new(), Vector3(-0.075, 0.015, 0.0), Vector3(0.012, 0.055, 0.12), material_metal)



	ponto_boca_cano = Marker3D.new()

	ponto_boca_cano.name = "PontoBocaCano"

	ponto_boca_cano.position = deslocamento_boca_cano

	visual_arma.add_child(ponto_boca_cano)



func _adicionar_peca_arma(nome: String, malha: Mesh, posicao: Vector3, escala: Vector3, material: Material, rotacao_graus: Vector3 = Vector3.ZERO) -> void:

	var peca := MeshInstance3D.new()

	peca.name = nome

	peca.mesh = malha

	peca.position = posicao

	peca.scale = escala

	peca.rotation_degrees = rotacao_graus

	peca.material_override = material

	visual_arma.add_child(peca)



func guardar_arma_nas_costas(guardar: bool) -> void:

	if modelo_arma == null:

		return

	arma_nas_costas = guardar

	cancelar_recarga()

	abaixar_pistola()

	if modelo_arma.get_parent():

		modelo_arma.get_parent().remove_child(modelo_arma)

	if guardar and anexo_costas:

		anexo_costas.add_child(modelo_arma)

		modelo_arma.position = deslocamento_arma_costas

		modelo_arma.rotation_degrees = rotacao_arma_costas

		modelo_arma.scale = Vector3.ONE * escala_arma

	elif anexo_arma:

		anexo_arma.add_child(modelo_arma)

		modelo_arma.position = deslocamento_arma_na_mao

		modelo_arma.rotation_degrees = rotacao_arma_na_mao

		modelo_arma.scale = Vector3.ONE * escala_arma



# =========================================================

# DISPARO E DANO

# =========================================================

func iniciar_disparo() -> void:

	if esta_morto or not arma_equipada or not is_instance_valid(camera_3d) or arma_nas_costas:

		return

	if esta_recarregando or esta_a_esquivar:

		return

	if tempo_para_disparar > 0.0:

		return



	if not municao_infinita_teste and municao_atual <= 0:

		parar_som_disparo()

		iniciar_recarga(true)

		return



	if balas_por_rajada > 0 and balas_restantes_rajada <= 0:

		parar_som_disparo()

		if recarregar_ao_acabar_rajada:

			iniciar_recarga(true)

		else:

			resetar_contador_rajada()

		return



	recuo_alvo += intensidade_recuo

	esta_atirando = true

	iniciar_som_disparo()



	var dir_oponente := _obter_direcao_oponente_nas_costas()

	if dir_oponente.length_squared() > 0.0001:

		alvo_giro_oponente_ativo = true

		direcao_giro_oponente_fixa = dir_oponente

	else:

		alvo_giro_oponente_ativo = false

		direcao_giro_oponente_fixa = Vector3.ZERO



	var tamanho_tela := get_viewport().get_visible_rect().size

	var centro_tela := tamanho_tela * 0.5

	var origem_mira := camera_3d.project_ray_origin(centro_tela)

	var direcao_camera := camera_3d.project_ray_normal(centro_tela).normalized()

	direcao_mira_tronco = direcao_camera.normalized()

	var fim_mira := origem_mira + direcao_camera * alcance_disparo



	var consulta := PhysicsRayQueryParameters3D.create(origem_mira, fim_mira)

	consulta.exclude = [get_rid()]

	consulta.collide_with_bodies = true

	consulta.collide_with_areas = true



	var impacto := get_world_3d().direct_space_state.intersect_ray(consulta)

	if not impacto.is_empty():

		var alvo: Node = impacto.collider as Node

		var ponto_impacto: Vector3 = impacto.position

		if _verificar_se_e_inimigo(alvo):

			var inimigo_raiz := _obter_raiz_inimigo(alvo)

			var altura_relativa := ponto_impacto.y - inimigo_raiz.global_position.y

			var eh_headshot := altura_relativa >= 1.35

			var dano_final := int(dano_arma * multiplicador_headshot) if eh_headshot else dano_arma

			_aplicar_dano_no_alvo(alvo, dano_final)

			_criar_numero_dano(ponto_impacto, dano_final, eh_headshot)



	tempo_para_disparar = intervalo_disparo

	if not municao_infinita_teste:

		municao_atual = maxi(municao_atual - 1, 0)

	if balas_por_rajada > 0:

		balas_restantes_rajada = maxi(balas_restantes_rajada - 1, 0)

	atualizar_hud_municao()



	var acabou_pente := (not municao_infinita_teste and municao_atual <= 0)

	var acabou_rajada := (balas_por_rajada > 0 and balas_restantes_rajada <= 0)

	if acabou_pente or (acabou_rajada and recarregar_ao_acabar_rajada):

		parar_som_disparo()

		iniciar_recarga(true)



func _criar_numero_dano(posicao_mundo: Vector3, valor: int, eh_critico: bool) -> void:

	var label_dano := Label3D.new()

	label_dano.set_script(ScriptDanoFlutuante)

	get_tree().current_scene.add_child(label_dano)

	var offset_aleatorio := Vector3(randf_range(-0.25, 0.25), randf_range(0.1, 0.3), randf_range(-0.25, 0.25))

	label_dano.global_position = posicao_mundo + offset_aleatorio

	label_dano.configurar(valor, eh_critico)



func _obter_raiz_inimigo(alvo: Node) -> Node3D:

	var receptor: Node = alvo

	while receptor != null:

		if receptor.has_method("receber_dano") or receptor.has_method("levar_dano") or receptor.is_in_group("inimigo") or receptor.is_in_group("oponente"):

			if receptor is Node3D:

				return receptor

		receptor = receptor.get_parent()

	return alvo as Node3D



func _aplicar_dano_no_alvo(alvo: Node, quantidade: int) -> void:

	var receptor: Node = alvo

	while receptor != null:

		if receptor.has_method("receber_dano"):

			receptor.receber_dano(quantidade)

			return

		if receptor.has_method("levar_dano"):

			receptor.levar_dano(float(quantidade))

			return

		receptor = receptor.get_parent()



# =========================================================

# HUD E AUXILIARES

# =========================================================

func criar_mira_hud() -> void:

	if hud == null:

		return

	label_mira = Label.new()

	label_mira.name = "Mira"

	label_mira.text = "+"

	label_mira.add_theme_font_size_override("font_size", tamanho_mira)

	label_mira.add_theme_color_override("font_color", Color.WHITE)

	label_mira.add_theme_color_override("font_shadow_color", Color.BLACK)

	label_mira.add_theme_constant_override("shadow_offset_x", 1)

	label_mira.add_theme_constant_override("shadow_offset_y", 1)

	label_mira.set_anchors_preset(Control.PRESET_CENTER)

	label_mira.size = Vector2(32, 32)

	label_mira.position = Vector2(-16, -16)

	label_mira.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	label_mira.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	label_mira.visible = false

	hud.add_child(label_mira)



	var mira_textura := get_node_or_null("HUD/TextureRect") as TextureRect

	if is_instance_valid(mira_textura):

		mira_textura.visible = true

		centralizar_mira(mira_textura)



func ativar_colisao_chute(ativar: bool) -> void:

	var area = get_node_or_null("ModeloVisual/AreaDanoChute")

	if not area:

		area = get_node_or_null("ModeloVisual/Correr_modelo/Skeleton3D/AreaDanoChute")

	if area:

		area.monitoring = ativar

		area.monitorable = ativar



func tentar_iniciar_janela() -> bool:

	var w_pressionado = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)

	if not w_pressionado and not corrida_automatica:

		return false



	var dir_frente: Vector3

	if pivo_camera:

		dir_frente = -pivo_camera.global_transform.basis.z

	else:

		dir_frente = -global_transform.basis.z

	dir_frente.y = 0.0

	if dir_frente.length_squared() <= 0.0001:

		return false

	dir_frente = dir_frente.normalized()



	var caixa_deteccao := BoxShape3D.new()

	caixa_deteccao.size = Vector3(1.2, 1.6, comprimento_caixa_janela)

	var centro_deteccao := global_position + Vector3(0.0, 1.1, 0.0) + dir_frente * avanco_deteccao_janela

	var angulo := atan2(dir_frente.x, dir_frente.z)

	var base_rotacao := Basis(Vector3.UP, angulo)



	var query := PhysicsShapeQueryParameters3D.new()

	query.shape = caixa_deteccao

	query.transform = Transform3D(base_rotacao, centro_deteccao)

	query.collision_mask = 8 # Camada 4 (1 << 3): apenas áreas *_MeioJanela

	query.exclude = [get_rid()]

	query.collide_with_bodies = false

	query.collide_with_areas = true



	var resultados := get_world_3d().direct_space_state.intersect_shape(query, 16)

	var area_janela_valida: Area3D = null

	var centro_alvo_no: Node3D = null

	var menor_dist_lateral := INF

	var meia_largura_permitida := maxf((largura_vao_janela * 0.5) - margem_lateral_vao_janela, 0.25)



	for item in resultados:

		var col := item.get("collider") as Node

		var area := _obter_area_janela_valida(col)

		if area == null:

			continue



		var marcador := area.get_node_or_null("CentroMortal") as Node3D

		var origem_centro := marcador.global_position if marcador != null else area.global_position



		var eixo_lateral := area.global_transform.basis.x

		eixo_lateral.y = 0.0

		if eixo_lateral.length_squared() <= 0.0001:

			eixo_lateral = Vector3(-dir_frente.z, 0.0, dir_frente.x)

		else:

			eixo_lateral = eixo_lateral.normalized()



		var nome_area := area.name.to_lower()

		var eixo_vao := eixo_lateral

		if "parede_janela_z" in nome_area or "parede_direita" in nome_area or "parede_esquerda" in nome_area:

			var z_area := area.global_transform.basis.z

			z_area.y = 0.0

			if z_area.length_squared() > 0.0001:

				eixo_vao = z_area.normalized()



		var delta_centro := global_position - origem_centro

		delta_centro.y = 0.0

		var deslocamento_ao_longo_do_vao := absf(delta_centro.dot(eixo_vao))

		if deslocamento_ao_longo_do_vao > meia_largura_permitida:

			continue



		if deslocamento_ao_longo_do_vao < menor_dist_lateral:

			menor_dist_lateral = deslocamento_ao_longo_do_vao

			area_janela_valida = area

			centro_alvo_no = marcador



	if area_janela_valida == null:

		return false



	var distancia_travessia := clampf(avanco_deteccao_janela + distancia_apos_janela, 2.0, distancia_maxima_janela)

	var origem_alinhamento := centro_alvo_no.global_position if centro_alvo_no != null else area_janela_valida.global_position

	var centro_plano := Vector3(origem_alinhamento.x, global_position.y, origem_alinhamento.z)

	var vetor_ate_centro := centro_plano - global_position

	var avanco_ate_centro := maxf(vetor_ate_centro.dot(dir_frente), 0.0)

	var distancia_total := maxf(distancia_travessia, avanco_ate_centro + distancia_apos_janela)



	alvo_janela = centro_plano + dir_frente * maxf(distancia_total - avanco_ate_centro, distancia_apos_janela)

	alvo_janela.y = global_position.y

	return true



func _obter_area_janela_valida(no: Node) -> Area3D:

	var atual: Node = no

	while atual != null:

		if atual is Area3D:

			var area := atual as Area3D

			if area.is_in_group("janela_mortal") or area.has_meta("janela_mortal"):

				return area

		atual = atual.get_parent()

	return null



func _desativar_colisao_para_janela() -> void:

	if colisao_janela_desativada:

		return

	collision_layer_original_janela = collision_layer

	collision_mask_original_janela = collision_mask

	collision_layer = 0

	collision_mask = 0

	colisao_janela_desativada = true



func _restaurar_colisao_apos_janela() -> void:

	if not colisao_janela_desativada:

		return

	collision_layer = collision_layer_original_janela

	collision_mask = collision_mask_original_janela

	colisao_janela_desativada = false



func iniciar_pular_janela() -> void:

	corrida_automatica_antes_mortal = corrida_automatica

	esta_a_saltar_janela = true

	corrida_automatica = false

	tempo_janela_restante = duracao_janela

	pistola_levantada = false

	cancelar_recarga()

	if animation_overlay != null:

		animation_overlay.stop()

	_desativar_colisao_para_janela()

	posicao_inicial_janela = global_position

	posicao_alvo_janela = alvo_janela

	velocity = Vector3.ZERO



	var visual_node = get_node_or_null("ModeloVisual")

	if visual_node and pivo_camera:

		var dir_frente = -pivo_camera.global_transform.basis.z

		dir_frente.y = 0.0

		dir_frente = dir_frente.normalized()

		if dir_frente != Vector3.ZERO:

			visual_node.rotation.y = atan2(dir_frente.x, dir_frente.z)



	print("Anim procurada: ", anim_pular_janela)

	if animation_player:

		print("Lista do AnimationPlayer: ", animation_player.get_animation_list())

		if animation_player.has_animation(anim_pular_janela):

			var anim_obj := animation_player.get_animation(anim_pular_janela)

			animation_player.play(anim_pular_janela, 0.04, velocidade_anim_janela)

			if anim_obj != null and tempo_inicio_anim_janela > 0.0:

				var tempo_salto := clampf(tempo_inicio_anim_janela, 0.0, maxf(anim_obj.length - 0.02, 0.0))

				animation_player.seek(tempo_salto, true)

		else:

			push_warning("Não encontrou a animação: " + anim_pular_janela)



func iniciar_esquiva() -> void:

	cancelar_recarga()

	esta_a_esquivar = true

	esta_a_atacar = false

	pistola_levantada = false

	buffer_salto_roll_timer = 0.0

	if animation_overlay != null:

		animation_overlay.stop()

	velocidade_atual_esquiva = impulso_esquiva

	tempo_esquiva_restante = duracao_esquiva

	buffer_esquiva_timer = 0.0

	ativar_colisao_chute(false)



	var w_p = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)

	var s_p = Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)

	var a_p = Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)

	var d_p = Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)



	var dir_input := Vector3.ZERO

	if w_p:

		dir_input.z -= 1

	if s_p:

		dir_input.z += 1

	if a_p:

		dir_input.x -= 1

	if d_p:

		dir_input.x += 1



	if dir_input != Vector3.ZERO and pivo_camera:

		direcao_esquiva = (pivo_camera.transform.basis * Vector3(dir_input.x, 0, dir_input.z)).normalized()

		direcao_esquiva.y = 0

		direcao_esquiva = direcao_esquiva.normalized()

	elif pivo_camera:

		direcao_esquiva = -pivo_camera.global_transform.basis.z

		direcao_esquiva.y = 0

		direcao_esquiva = direcao_esquiva.normalized()

		velocidade_atual_esquiva = impulso_esquiva * 0.7

	else:

		direcao_esquiva = -global_transform.basis.z



	if animation_player and animation_player.has_animation(anim_esquiva):

		animation_player.play(anim_esquiva, 0.1, 1.8)



func iniciar_ataque() -> void:

	esta_a_atacar = true

	corrida_automatica = false

	pistola_levantada = false

	cancelar_recarga()

	if animation_overlay != null:

		animation_overlay.stop()

	tempo_ataque_restante = duracao_ataque

	oponentes_atingidos.clear()



	var visual_node = get_node_or_null("ModeloVisual")

	if visual_node and pivo_camera:

		var dir_cam = -pivo_camera.global_transform.basis.z

		dir_cam.y = 0

		direcao_ataque = dir_cam.normalized()

		if direcao_ataque != Vector3.ZERO:

			angulo_ataque = atan2(direcao_ataque.x, direcao_ataque.z)

		else:

			angulo_ataque = visual_node.rotation.y

			direcao_ataque = -global_transform.basis.z

		visual_node.rotation.y = angulo_ataque



	if animation_player and animation_player.has_animation(anim_chute):

		animation_player.play(anim_chute, 0.1, 1.2)



func _on_area_dano_chute_body_entered(body: Node3D) -> void:

	if esta_morto or not esta_a_atacar or body == self:

		return

	var receptor: Node = body

	while receptor != null and receptor != self:

		if receptor.has_method("receber_dano"):

			if receptor in oponentes_atingidos:

				return

			receptor.receber_dano(int(dano_chute))

			oponentes_atingidos.append(receptor)

			return

		if receptor.has_method("levar_dano"):

			if receptor in oponentes_atingidos:

				return

			receptor.levar_dano(dano_chute)

			oponentes_atingidos.append(receptor)

			return

		receptor = receptor.get_parent()



# =========================================================

# FÍSICA E MOVIMENTO

# =========================================================

func _physics_process(delta: float) -> void:

	if esta_morto:

		return



	if esta_a_esquivar:

		cancelar_recarga()



	atualizar_recarga(delta)



	if tempo_para_disparar > 0.0:

		tempo_para_disparar = maxf(tempo_para_disparar - delta, 0.0)



	var botao_tiro := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	if botao_tiro and not arma_nas_costas:

		pistola_pressionada = true

		if arma_equipada and not esta_recarregando and not esta_a_esquivar and not esta_a_atacar and not esta_a_saltar_janela:

			iniciar_som_disparo()

			if tempo_para_disparar <= 0.0:

				iniciar_disparo()

	elif not botao_tiro and pistola_pressionada and not esta_atirando:

		pistola_pressionada = false

		parar_som_disparo()



	if spring_arm_ref and is_instance_valid(spring_arm_ref):

		var dist_alvo := distancia_spring_arm_mira if esta_mirando else distancia_spring_arm_normal

		var dist_obstaculo := dist_alvo

		if camera_mascara_colisao_original != 0:

			var origem_camera := spring_arm_ref.global_position

			var direcao_camera := -spring_arm_ref.global_transform.basis.z.normalized()

			var query_camera := PhysicsRayQueryParameters3D.new()

			query_camera.from = origem_camera

			query_camera.to = origem_camera + direcao_camera * dist_alvo

			query_camera.exclude = [get_rid()]

			query_camera.collision_mask = camera_mascara_colisao_original

			query_camera.collide_with_bodies = true

			query_camera.collide_with_areas = false

			var colisao_camera := get_world_3d().direct_space_state.intersect_ray(query_camera)

			if not colisao_camera.is_empty():

				dist_obstaculo = maxf(origem_camera.distance_to(colisao_camera.position) - margem_camera_obstaculo, 0.05)

		camera_distancia_suave = lerpf(camera_distancia_suave, dist_obstaculo, clampf(delta * velocidade_camera_obstaculo, 0.0, 1.0))

		spring_arm_ref.spring_length = camera_distancia_suave



	if camera_3d:

		var fov_alvo = fov_camera_mira if esta_mirando else fov_camera_normal

		camera_3d.fov = lerp(camera_3d.fov, fov_alvo, clampf(delta * velocidade_transicao_mira, 0.0, 1.0))

		var offset_alvo = deslocamento_ombro_mira if esta_mirando else deslocamento_ombro_camera

		camera_3d.h_offset = lerp(camera_3d.h_offset, offset_alvo, clampf(delta * velocidade_transicao_mira, 0.0, 1.0))



	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:

		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



	if buffer_esquiva_timer > 0.0:

		buffer_esquiva_timer -= delta

	if buffer_salto_roll_timer > 0.0:

		buffer_salto_roll_timer -= delta



	if buffer_esquiva_timer > 0.0 and is_on_floor() and not esta_a_esquivar:

		iniciar_esquiva()



	if not is_on_floor() and not esta_a_saltar_janela:

		velocity.y -= gravidade_salto * delta



	# TRAVESSIA DA JANELA (CORPO PASSA NO VÃO E PERNAS ATRAVESSAM A PAREDE NO MORTAL)

	if esta_a_saltar_janela:

		tempo_janela_restante -= delta

		var progresso = 1.0 - clamp(tempo_janela_restante / duracao_janela, 0.0, 1.0)

		var progresso_suave = smoothstep(0.0, 1.0, progresso)

		var pos_horizontal := posicao_inicial_janela.lerp(posicao_alvo_janela, progresso_suave)

		var onda_arco := sin(progresso_suave * PI)

		var elevacao_arco := onda_arco * (altura_arco_janela * fator_arco_mortal_parede) - (onda_arco * afundamento_giro_mortal)

		pos_horizontal.y = lerpf(posicao_inicial_janela.y, posicao_alvo_janela.y, progresso_suave) + elevacao_arco

		global_position = pos_horizontal

		velocity = Vector3.ZERO



		if tempo_janela_restante <= 0.0:

			corrida_automatica = corrida_automatica_antes_mortal

			corrida_automatica_antes_mortal = false

			esta_a_saltar_janela = false

			global_position = posicao_alvo_janela

			velocity = Vector3.ZERO

			_restaurar_colisao_apos_janela()

			if animation_player:

				if is_on_floor():

					var w_agora = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)

					var s_agora = Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)

					var a_agora = Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)

					var d_agora = Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)

					if w_agora or corrida_automatica or s_agora or a_agora or d_agora:

						if animation_player.has_animation(anim_frente):

							animation_player.play(anim_frente, blend_saida_janela)

					elif animation_player.has_animation(anim_parado):

						animation_player.play(anim_parado, blend_saida_janela)

				elif animation_player.has_animation(anim_queda):

					animation_player.play(anim_queda, blend_saida_janela)

		return



	# ATAQUE / CHUTE

	if esta_a_atacar:

		tempo_ataque_restante -= delta

		var velocidade_chute = distancia_impulso_chute / maxf(duracao_ataque, 0.01)

		velocity.x = direcao_ataque.x * velocidade_chute

		velocity.z = direcao_ataque.z * velocidade_chute

		velocity.y = 0.0



		@warning_ignore("confusable_local_declaration")

		var visual_node = get_node_or_null("ModeloVisual")

		if visual_node:

			visual_node.position = Vector3.ZERO

			visual_node.rotation.y = angulo_ataque



		if tempo_ataque_restante < (duracao_ataque - 0.15) and tempo_ataque_restante > 0.15:

			ativar_colisao_chute(true)

		else:

			ativar_colisao_chute(false)



		move_and_slide()

		if tempo_ataque_restante <= 0.2 and (buffer_esquiva_timer > 0.0 or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_S)):

			tempo_ataque_restante = 0.0



		if tempo_ataque_restante <= 0.0:

			esta_a_atacar = false

			ativar_colisao_chute(false)

			velocity.x = move_toward(velocity.x, 0, velocidade_corrida * delta * 10.0)

			velocity.z = move_toward(velocity.z, 0, velocidade_corrida * delta * 10.0)

			if visual_node:

				visual_node.position = Vector3.ZERO

				visual_node.rotation.y = angulo_ataque

		return



	# ESQUIVA — TRANSIÇÃO CORRIGIDA + ROLL CANCEL

	if esta_a_esquivar:

		cancelar_recarga()

		if buffer_salto_roll_timer > 0.0 and _tentar_roll_cancel():

			move_and_slide()

			return



		tempo_esquiva_restante -= delta

		if tempo_esquiva_restante <= 0.0:

			esta_a_esquivar = false

			velocidade_atual_esquiva = 0.0



			@warning_ignore("confusable_local_declaration")

			var visual_node = get_node_or_null("ModeloVisual")

			if visual_node:

				visual_node.position = Vector3.ZERO

				if direcao_esquiva.length_squared() > 0.0001:

					visual_node.rotation.y = atan2(

						direcao_esquiva.x,

						direcao_esquiva.z

					)



			if buffer_salto_roll_timer > 0.0 and is_on_floor():

				buffer_salto_roll_timer = 0.0

				if direcao_esquiva.length_squared() > 0.0001:

					velocity.x = direcao_esquiva.x * maxf(impulso_esquiva * 0.75, velocidade_corrida * 0.85)

					velocity.z = direcao_esquiva.z * maxf(impulso_esquiva * 0.75, velocidade_corrida * 0.85)

				_executar_salto_ou_janela()

				move_and_slide()

				return



			velocity.x = 0.0

			velocity.z = 0.0

			if animation_player and is_on_floor():

				@warning_ignore("confusable_local_declaration")

				var w_pressionado = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)

				@warning_ignore("confusable_local_declaration")

				var s_pressionado = Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)

				@warning_ignore("confusable_local_declaration")

				var a_pressionado = Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)

				@warning_ignore("confusable_local_declaration")

				var d_pressionado = Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)

				if w_pressionado or corrida_automatica or s_pressionado or a_pressionado or d_pressionado:

					animation_player.play(anim_frente, 0.08)

				else:

					animation_player.play(anim_parado, 0.08)

			move_and_slide()

			return



		velocity.x = direcao_esquiva.x * velocidade_atual_esquiva

		velocity.z = direcao_esquiva.z * velocidade_atual_esquiva

		if is_on_floor():

			velocity.y = 0.0

		else:

			velocity.y -= gravidade_salto * delta



		@warning_ignore("confusable_local_declaration")

		var visual_node = get_node_or_null("ModeloVisual")

		if visual_node and direcao_esquiva != Vector3.ZERO:

			var target_angle = atan2(direcao_esquiva.x, direcao_esquiva.z)

			visual_node.rotation.y = lerp_angle(

				visual_node.rotation.y,

				target_angle,

				clampf(delta * 25.0, 0.0, 1.0)

			)



		move_and_slide()

		return



	# MOVIMENTO NORMAL

	var w_pressionado = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)

	var s_pressionado = Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)

	var a_pressionado = Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)

	var d_pressionado = Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)



	if s_pressionado:

		corrida_automatica = false



	var esta_a_correr = w_pressionado or corrida_automatica



	var input_dir := Vector3.ZERO

	if esta_a_correr:

		input_dir.z -= 1

	if s_pressionado:

		input_dir.z += 1

	if a_pressionado:

		input_dir.x -= 1

	if d_pressionado:

		input_dir.x += 1



	var direction := Vector3.ZERO

	if input_dir.length_squared() > 1.0:

		input_dir = input_dir.normalized()



	if pivo_camera:

		var frente_camera := -pivo_camera.global_transform.basis.z

		frente_camera.y = 0.0

		frente_camera = frente_camera.normalized()

		var direita_camera := pivo_camera.global_transform.basis.x

		direita_camera.y = 0.0

		direita_camera = direita_camera.normalized()

		direction = -frente_camera * input_dir.z + direita_camera * input_dir.x

		direction.y = 0.0

		if direction.length_squared() > 0.0001:

			direction = direction.normalized()

	else:

		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.z)).normalized()



	var velocidade_atual := velocidade_corrida

	if esta_a_correr and not s_pressionado:

		velocidade_atual = velocidade_corrida

	elif s_pressionado:

		velocidade_atual = velocidade_recuo

	elif a_pressionado or d_pressionado:

		velocidade_atual = velocidade_lateral



	# ORIENTAÇÃO DO MODELO

	var visual_node = get_node_or_null("ModeloVisual")

	if visual_node and pivo_camera:

		visual_node.position = Vector3.ZERO

		if esta_atirando and not s_pressionado and (esta_a_correr or a_pressionado or d_pressionado):

			alvo_giro_oponente_ativo = false

			direcao_giro_oponente_fixa = Vector3.ZERO

			corpo_travado_na_mira = false

			corpo_deve_seguir_mira = false



		var direcao_para_olhar := Vector3.ZERO

		if esta_atirando and alvo_giro_oponente_ativo and direcao_giro_oponente_fixa.length_squared() > 0.0001:

			direcao_para_olhar = direcao_giro_oponente_fixa

		elif esta_atirando and corpo_deve_seguir_mira and direcao_mira_tronco.length_squared() > 0.0001:

			direcao_para_olhar = Vector3(

				direcao_mira_tronco.x,

				0.0,

				direcao_mira_tronco.z

			).normalized()

		elif direction.length_squared() > 0.0001:

			direcao_para_olhar = direction



		if direcao_para_olhar.length_squared() > 0.0001:

			var target_angle := atan2(direcao_para_olhar.x, direcao_para_olhar.z)

			visual_node.rotation.y = lerp_angle(

				visual_node.rotation.y,

				target_angle,

				clampf(delta * 15.0, 0.0, 1.0)

			)



	# MOVIMENTO HORIZONTAL E ANIMAÇÕES

	if direction != Vector3.ZERO:

		velocity.x = direction.x * velocidade_atual

		velocity.z = direction.z * velocidade_atual

		if is_on_floor() and animation_player:

			var frente_modelo: Vector3 = visual_node.global_transform.basis.z.normalized() if visual_node != null else global_transform.basis.z.normalized()

			var movendo_para_tras := direction.dot(frente_modelo) < -0.25

			var animacao_movimento := anim_tras if movendo_para_tras else anim_frente

			if animation_player.current_animation != animacao_movimento:

				animation_player.play(animacao_movimento, blend_saida_janela if animation_player.current_animation == anim_pular_janela else 0.08)

	else:

		velocity.x = move_toward(velocity.x, 0.0, velocidade_corrida * 15.0 * delta)

		velocity.z = move_toward(velocity.z, 0.0, velocidade_corrida * 15.0 * delta)

		if is_on_floor() and animation_player:

			var nome_rec := _obter_nome_animacao_recarga()

			if esta_recarregando and nome_rec != "":

				if animation_player.current_animation != nome_rec:

					animation_player.play(nome_rec, 0.08, velocidade_anim_recarga_atual)

			elif not esta_recarregando and animation_player.current_animation != anim_parado:

				animation_player.play(anim_parado, 0.1)



	# ANIMAÇÕES NO AR

	if not is_on_floor() and animation_player:

		if velocity.y > 0.1:

			if animation_player.has_animation(anim_salto) and animation_player.current_animation != anim_salto:

				animation_player.play(anim_salto, 0.1)

		else:

			if animation_player.has_animation(anim_queda) and animation_player.current_animation != anim_queda:

				animation_player.play(anim_queda, 0.1)



	move_and_slide()



func centralizar_mira(mira: TextureRect) -> void:

	var alvo := mira

	if alvo == null:

		alvo = get_node_or_null("HUD/TextureRect") as TextureRect

	if not is_instance_valid(alvo):

		return

	var tela := get_viewport().get_visible_rect().size

	var tamanho_real := alvo.size * alvo.scale

	var offset_cruz := Vector2.ZERO

	alvo.anchor_left = 0.0

	alvo.anchor_top = 0.0

	alvo.anchor_right = 0.0

	alvo.anchor_bottom = 0.0

	alvo.position = (tela - tamanho_real) * 0.5 + offset_cruz
