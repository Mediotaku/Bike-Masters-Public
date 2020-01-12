;; This file is part of Bike Masters.
;;  Copyright (C) 2019 Alberto Benavent Ramon (http://abramaran.com/)
;;  Copyright (C) 2019 Eduardo Gomez Martinez (@Edugomez98)
;;  Copyright (C) 2019 Jose Vicente Tomas Perez (http://mediotaku.xyz/)
;;
;;     Bike Masters is free software: you can redistribute it and/or modify
;;     it under the terms of the GNU General Public License as published by
;;     the Free Software Foundation, either version 3 of the License, or
;;     (at your option) any later version.
;; 
;;     Bike Masters is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;     GNU General Public License for more details.
;; 
;;     You should have received a copy of the GNU General Public License
;;     along with Bike Masters.  If not, see <https://www.gnu.org/licenses/>.

.include "cpctelera.h.s"
.include "header.h.s"
.include "1.h.s"

snd_Entity   == entity_size*2
end_line     == 50

speed        == 4
timerY       == 4

speedY       == 3 ;; Velocidad con la que aumenta o disminuye Y en las rampas

lineStart    == 1
lineEnd      == 6

ground       == 0
wheelie1     == 1
wheelie2     == 20
fall         == 40
again        == 70
maxH         == -14
thirdH       == -6
timerTurbo   == 20

turboSpeed   == 2
normalSpeed  == 3
rampSpeed    == 6
puddleSpeed  == 9

timer_endgame:: .db #0x70
first_endgame:: .db #0x01


physics_system_update::

phys_loop:
  push af

  ;; Comprobar si es el player
  ld a, player(ix)
  cp #0
  jr z, no_es_player

  call physics_system_positionFromLine

  ;; Contador para mirar cada cuanto se puede mover, velocidad actual. Con esto se controla la velocidad del jugador.
  call physics_system_timer

  call physics_system_turbo

  ld a, #0
  ld (scrollMove), a
  call endgame

  rally_end:

  ld a, tim(ix)
  cp #0
  jr nz, tim_no_es_0  ;; Si el temporizador no es 0 no se mueve el jugador


    ld a, jump(ix)
    cp #0
    jr z, not_airbound
    call physics_system_jump
    call physics_system_move
    jr airbound

    not_airbound:
    ;; Funcion que comprueba cual es la aceleración que tiene en ese momento
    call physics_system_accel
    ;; Funcion que mueve si tiene aceleracion y es el momento el jugador
    call physics_system_move

  tim_no_es_0:
  ld a, jump(ix)
  cp #0
  jr nz, airbound

  call physics_system_collision

  ;; Funcion que permite cambiar de linea
  call physics_system_changeLine

  ;;Funcion que gestiona el caballito
  call physics_system_wheelie
  jr no_es_player
  airbound:
  ;; En el aire no hago ruido
  ;ld hl, #0x0000
  ;ld (currentSFX), hl

  no_es_player:
  pop af

  dec a
  ret z

  ld bc, #entity_size
  add ix, bc

jr phys_loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_collision
;; Colisiona con: Charco, boost, rampa arriba y rampa abajo
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a, de, hl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
physics_system_collision:

  ;; Comprobar si estoy en un turbo
  turbo_tile:

    ld b, line(ix)                  ;; Comprobamos la línea en la que estamos
    ld c, rltv_pos(ix)              ;; La posicion en x del jugador me da la columna del tilemap a mirar
    call PointAtTilemap
    ld a, (hl)                      ;; HL apunta al tile bajo el jugador, cargo su id en A
    sub #10                         ;; 10 es el id del tile turbo
    jr nz, no_turbo
      ex de, hl
      ex de, hl
      ld turbo(ix), #timerTurbo     ;; Pongo el turbo al timer

  no_turbo:

  puddle_tile:

    ld a, (hl)                      ;; HL apunta al tile bajo el jugador, cargo su id en A
    sub #11                         ;; 11 es el id del tile charco
    jr z, slow
    ld a, (hl)
    sub #26
    jr z, slow
    jr no_puddle
    slow:
      ld sRamp(ix), #puddleSpeed
      ld b, sRamp(ix)               ;; Que la velocidad a la que se puede ir (velocidad sin turbo)
      ld a, acc(ix)                 ;; Si la aceleración actual es mas baja (más rápido)
      cp b
      jr nc, no_puddle
      ld acc(ix), b                 ;; Ponemos a velocidad normal la moto
      jr slope_up

  no_puddle:
    ld sRamp(ix), #normalSpeed      ;; Si no hay charco volvemos a la velocidad actual

  slope_up:
    ld b, #3                        ;; Miramos solo la línea 3 pues no van a haber rampas individuales
    ld c, rltv_pos(ix)
    call PointAtTilemap
    ld a, (hl)                      ;; HL apunta al tile bajo el jugador, cargo su id en A
    sub #2
    jr nz, no_slope_up
      ld a, wh(ix)
      cp #0
      jr nz, no_wh_slope_up
      ld sprite(ix), #cab1
      no_wh_slope_up:
      ld a, #maxH
      sra a
      ld offset(ix), a
      jr slope_prev_up

  no_slope_up:
    ld a, wh(ix)
    cp #0
    jr nz, slope_prev_up ;;Comprobamos si está haciendo el caballito
    ld sprite(ix), #suelo ;; Si no lo esta haciendo lo ponemos apuntando al suelo

  slope_prev_up:
    ld b, #3
    dec c
    call PointAtTilemap
    ld a, (hl)                      ;; HL apunta al tile bajo el jugador, cargo su id en A
    sub #2
    jr nz, no_slope_prev_up
        ld a, #maxH
        ld offset(ix), a

  no_slope_prev_up:


  slope_down:
    ld b, #3
    ld c, rltv_pos(ix)
    call PointAtTilemap
    ld a, (hl)
    sub #7
    jr nz, no_slope_down
      ld a, acc(ix)
      cp #normalSpeed
      jr z, normalJump
      jr nc, notJump
        ld acc(ix), #normalSpeed
      normalJump:
      ld jump(ix), #3
      call physics_system_jump
      jr slope_prev_down

    notJump:
      ld sprite(ix), #bajada
      ld a, #maxH
      sra a
      ld offset(ix), a
      jr slope_prev_down

  no_slope_down:


  slope_prev_down:
    ld c, rltv_pos(ix)              ;; La posicion en x del jugador me da la columna del tilemap a mirar
    ld b, #3
    dec c
    call PointAtTilemap
    ld a, (hl)                      ;; HL apunta al tile bajo el jugador, cargo su id en A
    sub #7
    jr nz, no_slope_prev_down
      ld a, #2
      ld offset(ix), a
      ld a, jump(ix)
      cp #0
      jr nz, no_slope_prev_down
      ld a, wh(ix)
      cp #0
      jr nz, no_slope_prev_down
      ld sprite(ix), #suelo


  no_slope_prev_down:

  tile_normal:
    ld b, line(ix)                  ;; De momento compruebo siempre en el segundo carril (fila 3 del tilemap)
    ld c, rltv_pos(ix)              ;; La posicion en x del jugador me da la columna del tilemap a mirar
    call PointAtTilemap
    ld a, (hl)                      ;; HL apunta al tile bajo el jugador, cargo su id en A
    sub #12
    jr nz, no_tile_normal

      ld a, wh(ix)
      cp #0
      jr nz, seguimos_tile_normal ;;Comprobamos si está haciendo el caballito
      ld sprite(ix), #suelo ;; Si no lo esta haciendo lo ponemos apuntando al suelo

      seguimos_tile_normal:
      ld a, turbo(ix)
      cp #0
      jr nz, no_tile_normal
        ;;cpctm_setBorder_asm HW_RED    ;; Estoy en un turbo, lo indico
        ld sRamp(ix), #normalSpeed
        ld b, sRamp(ix) ;; Que la velocidad a la que se puede ir (velocidad sin turbo)
        ld a, acc(ix)   ;; Si la aceleración actual es mas baja (más rápido)
        cp b
        jr nc, no_tile_normal
          ld acc(ix), b ;; Ponemos a velocidad normal la moto

  no_tile_normal:

  bache:

    ld a, (hl)
    sub #24
    jr nz, no_bache
      ld a, wh(ix)
      cp #0
      jr nz, no_bache
        ;cpctm_setBorder_asm HW_RED
        call fall_wh

  no_bache:

  planta:

    ld a, (hl)
    sub #25
    jr nz, no_planta
      ld a, wh(ix)
      cp #0
      jr nz, no_planta
        ;cpctm_setBorder_asm HW_RED
        call fall_planta_wh

  no_planta:

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_turbo
;; Está el turbo activado?
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
physics_system_turbo::

  ;ld a, offset(ix) ;; Sino está en una rampa o en el aire
  ;cp #0

  ;ret nz

  ld a, turbo(ix) ;; Si el turbo esta activado
  cp #0
  jr nz, stillTurboing
  ;; Turbo no activado
    ld sRamp(ix), #normalSpeed ;; Velocidad sin turbo
    ld a, acc(ix)   ;; Si la aceleración actual es mas baja (más rápido)
    ld b, sRamp(ix) ;; Que la velocidad a la que se puede ir (velocidad sin turbo)
    cp b
    ret nc
    ld acc(ix), b ;; Ponemos a velocidad normal la moto
  ret

  stillTurboing:
  ;; Turbo activado
    ld sRamp(ix), #turboSpeed ;; Ponemos la velocidad del turbo
    ld a, turbo(ix)           ;; Bajamos el contador del turmo
    dec a
    ld turbo(ix), a           ;; Ponemos el timer

ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_move
;; Movimiento normal y aceleracion de la entidad
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a, hl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
physics_system_move:

  ;;No te puedes mover si ya has completado todas las vueltas
  ld a, lap(ix)
  cp #4
  jr z, no_mover

  ld a, acc(ix)
  ld tim(ix), a

  ld a, #0
  ld (scrollMove), a

  ;RIGHT
  ld a, acc(ix)
  cp #acceleration
  ret z

  ; Sonido moto
  ld l, a
  ld a, #10
  sub l
  add a, #notaDoCentral - 2
  ld (noteSFX), a
  ld hl, #0x0101
  ld (currentSFX), hl


  ;ld a, posX(ix)
  ;inc a
  ;ld posX(ix), a
  temp_mv:
  ld a, #1
  ld (scrollMove), a
  ;; lineaMove:: ld a, rltv_pos(ix) ;; Para ver el valor de rltv_pos(ix) en el debug

  ;; Comprobar si rltv_pos(ix) esta al maximo
  ld a, #_lvl1_W - 21   ;; Se tiene que resetear antes de llegar al final por eso es 21 y no 20
  cp rltv_pos(ix)
  jr z, reset_rltv_pos
  ;; No esta al maximo: incrementar
  inc rltv_pos(ix)

  ;;Contador de vueltas
  ld a,rltv_pos(ix)
  cp #1
  jr nz, no_lap
    ld a, lap(ix)
    inc a
    ld lap(ix),a

    ;;Actualizacion de los marcadores
    call render_system_race_status

    cp #4
    jr nz, no_final

    ld a, abs_pos(ix)
    inc a
    ld abs_pos(ix),a

    ld position(ix), a

    no_final:
  no_lap:

  ;;Calculo de la posicion


  ret
  ;; Esta al maximo: poner a 0
  reset_rltv_pos::
  ld rltv_pos(ix), #0

  no_mover:

ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_accel
;; Gestiona la aceleracion
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
physics_system_accel:

  ;RIGHT
  ld a, velX(ix)
  cp #0
  jr z, resetAcc_accel

  ld a, acc(ix)
  cp sRamp(ix)
  ;;cp #speed
  ret z
  dec a
  ld acc(ix), a

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; resetAcc_accel
;; Resetea la aceleracion
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
resetAcc_accel:
  ld a, acc(ix)
  cp #acceleration
  ret z
  inc a
  ld acc(ix), a

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_jump
;; Se llamará si terminas una rampa y vas a una alta velocidad
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
physics_system_jump:
  ;cpctm_setBorder_asm HW_RED
  ld a, jump(ix)
  dec a
  ld jump(ix), a
  cp #5
  jr z, jump_5
  cp #4
  jr z, jump_4
  cp #3
  jr z, jump_3
  cp #2
  jr z, jump_2
  cp #1
  jr z, jump_1
  cp #0
  jr z, jump_0
  ret

  jump_5:
    ld velX(ix), #1
  ret

  jump_4:
    ld velX(ix), #1
    ld velX(ix), #1
    ld a, #maxH
    ld b, #thirdH
    add b
    ld offset(ix), a
  ret

  jump_3:
    ld velX(ix), #1
    ld a, #maxH
    ld b, #thirdH
    add b
    add b
    ld offset(ix), a
  ret

  jump_2:
    ld velX(ix), #1
    ld a, #maxH
    ld b, #thirdH
    sub b
    ld offset(ix), a
  ret

  jump_1:
    ld velX(ix), #1
    ld a, #maxH
    sra a
    ld offset(ix), a
  ret

  jump_0:
    ld offset(ix), #2
    ld velX(ix), #1
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_timer
;; Gestiona el timer de velocidad
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
physics_system_timer:

  ld a, tim(ix)
  cp #0
  ret z
  dec a
  ld tim(ix), a

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_changeLine
;; Gestiona el cambio de linea con un timeout
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
physics_system_changeLine:

   ;;No te puedes mover si ya has completado todas las vueltas
    ld a, lap(ix)
    cp #4
    jr z, saltar_mov

  ld a, timY(ix)
  cp #timerY
  jr z, move_changeLine

  inc a
  ld timY(ix), a
  ret

;;Lectura de teclas
;;
  move_changeLine:

  up_changeLine:
    ld a, velY(ix)
    cp #1
    jr nz, down_changeLine


    ld a, line(ix)
    dec a
    cp #lineStart
    ret z ;; Salimos si estamos en la linea de inicio (que es la linea 0, las movibles son 1, 2, 3, 4)
    ld line(ix), a

    jr end_changeLine

  down_changeLine:
    ld a, velY(ix)
    cp #-1
    ret nz

    ld a, line(ix)
    inc a
    cp #lineEnd
    ret z ;; Salimos si estamos en la linea final
    ld line(ix), a

  end_changeLine:
    ; Multiplicamos por 8 corriendo 3 veces
    call physics_system_positionFromLine
    ld posY(ix), a
    ld a, #0
    ld timY(ix), a

    saltar_mov:

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_positionFromLine
;; Calcula la posicion en Y con respecto a la línea. necesita la línea cargada en a
;; line * 8 + posYinit + offset
;; PARAMS:
;;    ix: entidad actual
;; MODIFIES:
;;    a
;; RETURNS:
;;    a: Posicion de la entidad
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
physics_system_positionFromLine:

  ld a, line(ix)
  sla a
  sla a
  sla a
  add a, #posYinit
  add a, offset(ix)
  ld posY(ix), a

ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_changeLine
;; Gestiona el caballito con un timeout
;; Hay 3 posiciones de caballito y cuando se llega a la maxima nos hemos caido
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
physics_system_wheelie:

  ; Si la aceleracion es el valor máximo no nos estamos moviendo
  ld a, acc(ix)
  cp #acceleration
  jp z, notMoving_wh
  jp moving_wh

  ; Si no nos movemos decrecemos el contador del caballito, es decir, volvemos a tierra
  notMoving_wh:
    ld a, wh(ix)
    cp #0
    ret z
    dec a
    ld wh(ix), a
    jr wheelie_wh

  ; Si nos movemos aumentamos el contador del caballito
  moving_wh:
    ld a, wheelie(ix)
    cp #1
    jr nz, notMoving_wh
    ld a, wh(ix)
    inc a
    ld wh(ix), a

  ; Hacemos el caballito que cambia de sprite segun la posicion del caballito
  wheelie_wh:
    ld b, wh(ix);;mayor
    ld a, #fall ;;menor
    sub a, b
    jr c, again_wh

    ld a, wh(ix)
    cp #ground
    jr z, ground_wh
    cp #wheelie1
    jr z, pos1_wh
    cp #wheelie2
    jr z, pos2_wh
    cp #fall
    jr z, fall_wh
    cp #again
    jr z, again_wh
    ret nz

  ground_fall_wh:

    ld wh(ix), #0
    ld lock_mov(ix), #0
    call temp_mv

  ground_wh:
    ;call clear
    ;ld a, #0xFF
    ld sprite(ix), #suelo ;Default
    ;call paint
    ret

  pos1_wh:

    ;call clear
    ;ld a, #11
    ld sprite(ix), #cab1 ;Cab1
    ;call paint
    ret

  pos2_wh:

    ;call clear
    ;ld a, #22
    ld sprite(ix), #cab2 ;Cab2
    ;call paint
    ret

  fall_wh:
    ;; Reproducir efecto de sonido numero 3 (caida) una vez
    ld hl, #0x0003
    ld (currentSFX), hl

    ;call clear
    ;ld a, #33
    ld sprite(ix), #caida ;caida
    ;call paint
    ld wh(ix), #again
    call resetAcc_accel
    ret

  fall_planta_wh:
    ;; Reproducir efecto de sonido numero 3 (caida) una vez
    ld hl, #0x0003
    ld (currentSFX), hl

    ;call clear
    ;ld a, #33
    ld sprite(ix), #plantasp ;planta
    ;call paint
    ld wh(ix), #again
    call resetAcc_accel
    ret

  again_wh:
    ld a, wheelie(ix)
    ld lock_mov(ix), #1
    ;ld sprite(ix), #caida ;caida
    cp #1
    jr nz, notPressed_wh
    ld a, wh(ix)
    dec a
    dec a
    ld wh(ix), a

  notPressed_wh:
    ld a, #acceleration

    ld tim(ix), a
    ld acc(ix), a
    ld b, wh(ix);;mayor
    dec b
    ld a, #fall ;;menor
    sub a, b
    jr z, ground_fall_wh

    ret

ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_ramp_up
;; Calcula la subida de la rampa
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a, b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
physics_system_ramp_up::
  ld a, offset(ix)
  ld b, #speedY
  sub b
  cp #maxH
  ret c
  ld offset(ix), a
  ld a, #rampSpeed
  ld sRamp(ix), a   ;; Cambiamos la velocidad a la que se puede mover por la de la rampa
  ld a, acc(ix)
  cp #rampSpeed
  ret nc
  ld a, #rampSpeed
  ld acc(ix), a
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; physics_system_ramp_up
;; Calcula la bajada de la rampa
;; PARAMS:
;;    ix (entity pointer)
;; MODIFIES:
;;    a, b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

physics_system_ramp_down::
  ld a, offset(ix)
  ld b, #speedY
  add b
  cp #speedY
  jr z, ground_ramp_down
  ld offset(ix), a
  ld a, #rampSpeed
  ld sRamp(ix), a   ;; Cambiamos la velocidad a la que se puede mover por la de la rampa
  ld a, acc(ix)
  cp #rampSpeed
  ret nc
  ld a, #rampSpeed
  ld acc(ix), a

  ground_ramp_down:
  ld offset(ix), #0
  ld sRamp(ix), #2  ;; Cambiamos la velocidad a la que se puede mover por la de la rampa
ret




;;Pulsando la tecla F el corredor se cae, por motivos de test
physics_system_fall: ;;TODO: ver si esto hay que borrarlo

  ld a, player(ix)
  cp #0
  ret z

  ld hl, #Key_F
  call cpct_isKeyPressed_asm
  jp nz, fall_wh

ret

physics_system_col:

    ld a, player(ix)
    cp #0
    ret z
    ld c, #0
  loop_col: ;; hacer de manera menos sucia
      ;inc c
      ld a, posX-entity_size(ix)
      cp posX(ix)
      jr nz, col1
      ld a, posY-entity_size(ix)
      cp posY(ix)
      jr nz, col1
      ld a, posX(ix)
      inc a
      ld posX(ix), a
      jp fall_wh

  col1:
      ld a, posX-snd_Entity(ix)
      cp posX(ix)
      jr nz, end_col
      ld a, posY-snd_Entity(ix)
      cp posY(ix)
      jr nz, end_col
      ld a, posX(ix)
      inc a
      ld posX(ix), a
      jp fall_wh

      ;ld a, c
      ;cp #max_entities
      ;jr nz, loop_col
  end_col:
ret

win:

  ld a, (_first_lvl)
  cp #0
  jp z, wonalone
  ld a, (_lvl_amount)
  inc a
  ld (_lvl_amount), a
  cp #3
  jp nz, not_finished

  call youwon
  jp _reiniciar_con_musica

  not_finished:

  jp cup_chosen

wonalone:

  call youwon
  call _reiniciar_con_musica
ret

youwon::


  ld hl, #_youwon_pack_end
  ld de, #0xFFFF
  call cpct_zx7b_decrunch_s_asm
  ld hl, #_youwon_pack_end
  ld de, #0xBFFF
  call cpct_zx7b_decrunch_s_asm


  call cpct_drawSprite_asm
  ld a, #0xFF
  loop_cd_yw:
    halt
    halt
    dec a
    cp #0
  jp nz, loop_cd_yw



  loop_yw:
  call cpct_isAnyKeyPressed_f_asm
  jr z, loop_yw

ret

youlost::


  ld hl, #_youlost_pack_end
  ld de, #0xFFFF
  call cpct_zx7b_decrunch_s_asm
  ld hl, #_youlost_pack_end
  ld de, #0xBFFF
  call cpct_zx7b_decrunch_s_asm


  call cpct_drawSprite_asm
  ld a, #0xFF
  loop_cd_yl:
    halt
    halt
    dec a
    cp #0
  jp nz, loop_cd_yl



  loop_yl:

  call cpct_isAnyKeyPressed_f_asm
  jr z, loop_yl
  jp _reiniciar_con_musica

ret

leavefr::

  ld hl, #0x0000
  ld (currentSFX), hl
  ld hl, #_leave_pack_end
  ld de, #0xFFFF
  call cpct_zx7b_decrunch_s_asm
  ld hl, #_leave_pack_end
  ld de, #0xBFFF
  call cpct_zx7b_decrunch_s_asm


  call cpct_drawSprite_asm
  ld a, #0xFF
  loop_leavefr:
    dec a
    cp #0
  jp nz, loop_leavefr



  loop_fr:

    ld hl, #Key_N
    call cpct_isKeyPressed_asm
    jr nz, fondo_fr

    ld hl, #Key_Esc
    call cpct_isKeyPressed_asm
    jr nz, fondo_fr

    ld hl, #Key_Y
    call cpct_isKeyPressed_asm
    jp nz, _reiniciar_con_musica

  jr z, loop_fr

  fondo_fr:
    push af
    call DibujarFondo
    call render_system_race_status
    pop af
  ret

ret

endgame:

  ld a, position(ix)
  cp #0
  jp z, notEG
    ld a, (first_endgame)
    cp #1
    jr nz, notFirstEndgame
      ld hl, #0x0000
      ld (currentSFX), hl
      ld de, #_g_victoria
      call cpct_akp_musicInit_asm
      xor a
      ld (first_endgame), a
    notFirstEndgame:
    ;cpctm_setBorder_asm HW_RED
    ld a, (timer_endgame)
    dec a
    ld (timer_endgame), a
    cp #0
    jp nz, notEG
      ld a, position(ix)
      cp #1
      jp z, win
      cp #0
      jp nz, youlost


  notEG:
ret
