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

;;Variables propias del control de la IA
timerTurbo   == 20
timerCharco  == 15
timerArena   == 10
timerBache   == 40
maxH         == -14
thirdH       == -6
 
ai_system_init::

ret
ai_system_timer::

  ld a, tim(ix)
  cp #0
  ret z
  dec a
  ld tim(ix), a

ret

physics_system_positionFromLine:

  ld a, line(ix)
  sla a
  sla a
  sla a
  add a, #posYinit
  add a, offset(ix)
  ld posY(ix), a

ret

physics_system_jump:
  ld a, jump(ix)
  dec a
  ld jump(ix), a
  cp #3
  jr z, jump_3
  cp #2
  jr z, jump_2
  cp #1
  jr z, jump_1
  cp #0
  jr z, jump_0
  ret

  jump_3:
    ;ld velX(ix), #1
    ld a, #maxH
    ld b, #thirdH
    add b
    add b
    ld offset(ix), a
  ret

  jump_2:
    ;ld velX(ix), #1
    ld a, #maxH
    ld b, #thirdH
    sub b
    ld offset(ix), a
  ret

  jump_1:
    ;ld velX(ix), #1
    ld a, #maxH
    sra a
    ld offset(ix), a
  ret

  jump_0:
    ;ld velX(ix), #1
    ld offset(ix), #2
  ret


es_player1:
   ;;Guarda en HL la velocidad del player
    ld l, velX(ix)
    jp es_player2
ret

ai_system_up_tile_check:
  ;;-------Es la tile encima tuya segura?------------------------
        ld c, rltv_pos(ix)    ;;Miramos la columna actual         
        ld b, line(ix)
        dec b                 ;;En la linea de arriba a la actual
        call PointAtTilemap
        ld a, (hl)      
        cp #12  ;;Tile normal
        jr nz, no_normal1
          ld b,line(ix)
          dec b
          ld line(ix), b ;;Finalmente lo movemos a la posicion
        jr no_turbo1 ;;Si es una tile normal encima tuyo, no comprobar si es un turbo
        no_normal1:
        cp #10 
        jr nz, no_turbo1
          ld b,line(ix)
          dec b
          ld line(ix), b ;;Finalmente lo movemos a la posicion
        no_turbo1:        
  ;;------------------------------------------------------------

ret

ai_system_down_tile_check:
  ;;-------Es la tile abajo tuya segura?------------------------
        ld c, rltv_pos(ix)    ;;Miramos la columna actual         
        ld b, line(ix)
        inc b                 ;;En la linea de abajo a la actual
        call PointAtTilemap
        ld a, (hl)      
        cp #12  ;;Tile normal
        jr nz, no_normal2
          ld b,line(ix)
          inc b
          ld line(ix), b ;;Finalmente lo movemos a la posicion
        jr no_turbo2 ;;Si es una tile normal abajo tuyo, no comprobar si es un turbo
        no_normal2:
        cp #10 
        jr nz, no_turbo2
          ld b,line(ix)
          inc b
          ld line(ix), b ;;Finalmente lo movemos a la posicion
        no_turbo2:        
  ;;------------------------------------------------------------

ret

ai_system_check_around:
;;---------Es la tile de arriba o abajo de la que queremos evitar segura?----------
;;---------Si es segura, es la tile de tu columna para ir a ella segura?-----------
jr nz, no_charcoo
        ;;Si está en uno de los bordes, pasar directamente al de al lado
        ld a,b
        cp #2
        jr nz, no_borde ;;Añadir que si es un bache lo de al lado, lo mejor es comerse el charco

        ld c, rltv_pos(ix)             
        ld b, line(ix)
        inc c                 ;;Miramos la columna siguiente a la actual
        inc b                 ;;En la linea de abajo a la actual
        call PointAtTilemap
        ld a, (hl)
        cp #24    ;;Tile de bache  
        jr z, no_usar
        ld line(ix), #3
        no_usar:

        jp no_charcoo
        no_borde:
        cp #5
        jr nz, no_borde1

        ld c, rltv_pos(ix)             
        ld b, line(ix)
        inc c                 ;;Miramos la columna siguiente a la actual
        dec b                 ;;En la linea de arriba a la actual
        call PointAtTilemap
        ld a, (hl)
        cp #24    ;;Tile de bache  
        jr z, no_usar1
        ld line(ix), #4
        no_usar1:

        jp no_charcoo
        no_borde1:
        
        ;;Si no esta en uno de los bordes
        ;;Primero miramos si esta libre la linea siguiente arriba o abajo, y si no lo esta nada
        ;;pero si esta miramos si nuestra columna ha ese lado esta libre o es turbo para decidir ir, sino nada

        ld c, rltv_pos(ix)             
        ld b, line(ix)
        inc c                 ;;Miramos la columna siguiente a la actual
        dec b                 ;;En la linea de arriba a la actual
        call PointAtTilemap
        ld a, (hl)      
        cp #12  ;;Tile normal
        jr nz, no_normall
        ;;La cosa es segura, decidir si ir

        ;;Es la tile encima tuya segura?
        call ai_system_up_tile_check

        jr no_charcoo ;;Siguiente arriba es tile normal, no turbo, saltamos
        no_normall:
        cp #10  ;;Tile turbo
        jr nz, no_turboo
        ;;La cosa es segura, decidir si ir
        
        ;;Es la tile encima tuya segura?
        call ai_system_up_tile_check

        jr no_charcoo
        no_turboo:


        ;;La tile encima de la objetivo no fue buena, probemos con la de abajo


        ld c, rltv_pos(ix)             
        ld b, line(ix)
        inc c                 ;;Miramos la columna siguiente a la actual
        inc b                 ;;En la linea de abajo a la actual
        call PointAtTilemap
        ld a, (hl)      
        cp #12  ;;Tile normal
        jr nz, no_normal_
        ;;La cosa es segura, decidir si ir

        ;;Es la tile abajo tuya segura?
        call ai_system_down_tile_check

        jr no_charcoo ;;Siguiente abajo es tile normal, no turbo, saltamos
        no_normal_:
        cp #10  ;;Tile turbo
        jr nz, no_turbo_
        ;;La cosa es segura, decidir si ir
        
        ;;Es la tile abajo tuya segura?
        call ai_system_down_tile_check
        jr no_charcoo
        no_turbo_:

      no_charcoo:
;----------------------------------------------------------------------------------
ret

ai_system_update::
call entityman_getEntityArray_IX
call entityman_getNumEntities_A

   ai_loop:
    push af
    ;; Comprobar si es ia
    ld a, player(ix)
    cp #1
    jp z, es_player2

    ;;SECCION 1: Deteccion de tiles especiales
      ld b, line(ix)                  ;; Comprobamos la línea en la que estamos
      ld c, rltv_pos(ix)              ;; La posicion en x del jugador me da la columna del tilemap a mirar
      call PointAtTilemap
      ld a, (hl)                      ;; HL apunta al tile bajo el jugador, cargo su id en A

      ;;Tile turbo y timer
      cp #10                         ;; 10 es el id del tile turbo
      jr nz, no_turbo    
      ld turbo(ix), #timerTurbo
      ld sprite(ix),#suelo        
      ld velX(ix), #2
      no_turbo:
     
      ;;Tile charco
      cp #11                         ;; 11 es el id del tile charco
      jr nz, no_charco  
      ld turbo(ix), #timerCharco
      ld sprite(ix),#suelo  
      ld velX(ix), #11
      no_charco:

      ;;Tile arena
      cp #26                         ;; 26 es el id del tile arena
      jr nz, no_arena 
      ld turbo(ix), #timerArena
      ld sprite(ix),#suelo  
      ld velX(ix), #10
      no_arena:

      ;;Tile bache
      cp #24                         ;; 24 es el id del tile bache
      jr nz, no_bache
      ld a, sprite(ix)
      cp #cab1                       ;;Si la ia esta haciendo caballito no le afecta el bache
      jr z, no_bache 
      ;;Si ya esta caida la ia, no se vuelve a entrar en las instrucciones, para evitar un bucle infinito
      cp #caida
      jr z, ya_caido    
      ld turbo(ix), #timerBache
      ld sprite(ix),#caida 
      ;;Se añade aqui directamente el tiempo de la velocidad para evitar
      ;;que se mueva una tile inmediatamente despues de detectarla
      ld tim(ix), #40  
      ya_caido:

      no_bache:

      ;;Decrementamos el contador de turbo/charco
      dec turbo(ix)
      jr nz, sigue_estado
      ld sprite(ix),#suelo 
      ld velX(ix), #4
      sigue_estado:

      ;;---Manejador de las rampas----
      ;;Control rampa de subida
      ld b, #3                       
      ld c, rltv_pos(ix)
      call PointAtTilemap
      ld a, (hl)
      cp #2   ;;Tile de subida
      jr nz,no_hay_slope
      ld sprite(ix), #cab1
      ld a, #maxH
      sra a
      ld offset(ix), a   
      
      ;;Utilizamos los valores puestos en el offset para calcular la posY(ix)
      ;call physics_system_positionFromLine

      no_hay_slope:

      ;;Las siguientes no pueden ocurrir sin que haya anteriormente un offset, asi que comprobamos
      ld a,offset(ix)
      cp #2
      jp z, no_offset

      ;;Control tile normal sobre rampa
      ld b, #3                       
      ld c, rltv_pos(ix)
      call PointAtTilemap
      ld a, (hl)
      cp #12  ;;Tile de normal (subida de rampa)
      jr nz, no_normal
       
      ld a, #maxH
      ld offset(ix), a    
      ld sprite(ix), #suelo


      ;;Utilizamos los valores puestos en el offset para calcular la posY(ix)
      ;call physics_system_positionFromLine
       
      no_normal:
      
      ;;Control rampa de bajada
      ld b, #3                       
      ld c, rltv_pos(ix)
      call PointAtTilemap
      ld a, (hl)
      cp #7 ;;Tile de bajada
      jr nz, no_bajada
      ld a, velX(ix)
      cp #10
      jr z, no_saltar

      ld sprite(ix), #suelo
      ld velX(ix),#6 ;;Para verlo mas lento
      ld a, jump(ix) ;;Si no es 0 jump(ix) es que ya esta saltando
      cp #0
      jr nz, ya_saltando
      ld jump(ix), #3 ;;Fases del metodo jump a usar
      ya_saltando:
      call physics_system_jump

      jr seguir

      no_saltar:
      ld sprite(ix), #bajada
      ld a, #maxH
      sra a
      ld offset(ix), a
     
      seguir:

       ;;Utilizamos los valores puestos en el offset para calcular la posY(ix)
      ;call physics_system_positionFromLine

      no_bajada:

      no_offset:
      ;;Miramos si la tile anterior es una tile de bajada para volver a colocar el offset por defecto
      ld c, rltv_pos(ix)             
      ld b, #3
      dec c                 ;;Miramos la columna anterior a la actual
      call PointAtTilemap
      ld a, (hl)                     
      cp #7                          
      jr nz, no_rampa_atras
      ld velX(ix), #4 ;;Se reestablece la velocidad normal
      ld a, #2
      ld offset(ix), a

       ;;Utilizamos los valores puestos en el offset para calcular la posY(ix)
      ;call physics_system_positionFromLine

      no_rampa_atras:
      
      ;;Utilizamos los valores puestos en el offset para calcular la posY(ix)
      call physics_system_positionFromLine

    ;;SECCION 2: Toma de decisiones cada cierta frecuencia

    ;;--------------------------------------------------------------------------------
      ;;En el juego hay presentes tres IAs, que identificamos por su color y que
      ;;cuentan cada una con un comportamiento diferente en el juego.
      ;;-La ia amarilla (3) es la ia de menor habilidad y solo es capaz de
      ;; de esquivar obtaculos, ademas de saltar baches si tiene tiempo de verlos venir.
      ;;-La ia verde (1) es la ia de habilidad media y es capaz de esquivar obstaculos,
      ;; saltar baches si lo ve con tiempo y ademas busca y va a los turbos cercanos.
      ;;-La ia roja (2) es la ia de mayor habilidad y es capaz de esquivar obstaculos,
      ;; saltar baches practicamente siempre y buscar y ir a los turbos cercanos.
    ;;--------------------------------------------------------------------------------

    ;;En ia utilizamos la varible lock para contar cuanto duran algunas acciones de la misma
    ;;Aqui reducimos dicho contador si es menor que cero
    ;-----------------------
    ld a, lock_mov(ix)
    cp #0
    jr z, no_dec
    dec a
    ld lock_mov(ix), a 
    no_dec:
    ;-----------------------

    ;;La ia toma decisiones cada un cierto tiempo establecido
    ld a, abs_pos(ix)
    dec a
    jp nz, no_decide
      ld abs_pos(ix), #2 ;;Reiniciamos el contador de decision
      ld a,color(ix)
      cp #1
      jr nz, amarillo1  ;;Diferencia de velocidad de decision segun sea verde o amarillo
      ld abs_pos(ix), #3  ;;Dificultad normal 12
      jr no_amarillo1
      amarillo1:
      ld abs_pos(ix), #4
      no_amarillo1:


      ;;Detecciones y decisiones a una tile de distancia
      ld c, rltv_pos(ix)             
      ld b, line(ix)
      inc c                 ;;Miramos la columna siguiente a la actual
      call PointAtTilemap
      ld a, (hl) 

      ;-----------------------                    
      cp #11  ;;Deteccion de charco
      call ai_system_check_around
      ;-----------------------

      ;-----------------------
      cp #26 ;;Deteccion de arena
      call ai_system_check_around
      ;-----------------------

      ;-----------------------
      ;Detecciones y decisiones a dos tiles de distancia
      ;;Si es la ia roja la deteccion es infalibe
      ld a,color(ix)
      cp #2
      jr z, es_roja

      ld c, rltv_pos(ix)             
      ld b, line(ix)
      inc c                 ;;Miramos a dos columnas de la actual
      inc c
      call PointAtTilemap
      ld a, (hl) 
      ;-----------------------
      cp #24 ;;Deteccion de bache
      jr nz, no_bache_delante
      ld sprite(ix), #cab1
      ld a,color(ix)
      cp #1
      jr nz, amarillo  ;;Diferencia de reflejos segun sea verde o amarillo
      ld lock_mov(ix), #8  ;;Dificultad normal 12
      jr no_amarillo
      amarillo:
      ld lock_mov(ix), #12
      no_amarillo:
      jr no_es_roja
      no_bache_delante:
      ;-----------------------
      es_roja:
      ld c, rltv_pos(ix)             
      ld b, line(ix)
      inc c                 ;;Miramos a dos columnas de la actual
      call PointAtTilemap
      ld a, (hl) 
      cp #24 ;;Deteccion de bache
      jr nz, no_bache_delante1
      ld sprite(ix), #cab1
      jr no_es_roja         ;;Es roja pero usamos esto para salir
      no_bache_delante1:

      ld c, rltv_pos(ix)             
      ld b, line(ix)        ;;Solo volver al suelo si la tile actual no es un bache
      call PointAtTilemap
      ld a, (hl) 
      cp #24 ;;Deteccion de bache
      jr z, no_es_roja
      ld sprite(ix), #suelo 

      no_es_roja:


      ;;Busqueda y movimiento a turbos cercanos     ;;Dificultad niveles avanzados
      ;-----------------------
      ;;Si es la ia amarilla no busca turbos
      ld a, color(ix)
      cp #3
      jr z, no_necesario
        ;;Comprobar primero que no hay un turbo delante del jugador ni en el jugador
        ld c, rltv_pos(ix)             
        ld b, line(ix)
        inc c     ;;Tile delante del jugador
        call PointAtTilemap
        ld a, (hl) 
        cp #10
        jr z, no_necesario

        ld c, rltv_pos(ix)             
        ld b, line(ix)
        ;;Tile del jugador
        call PointAtTilemap
        ld a, (hl)
        cp #10
        jr z, no_necesario


        ;Turbo arriba delante del jugador
        ;Solo ir si tile arriba esta libre 
        ld c, rltv_pos(ix)             
        ld b, line(ix)
        dec b     ;;Tile encima del jugador
        inc c
        call PointAtTilemap
        ld a, (hl) 
        cp #10 ;;Tile de turbo
        jr nz, no_tile_turbo
        ld c, rltv_pos(ix)             
        ld b, line(ix)
        dec b     ;;Tile encima del jugador
        call PointAtTilemap
        ld a, (hl) 
        ld b, line(ix)
        dec b     ;;Tile encima del jugador

        cp #10    ;;Tile de turbo (tile segura)
        jr nz, no_ir
        ld line(ix), b
        jr no_tile_turbo
        no_ir:
        cp #12 ;; Tile normal (tile segura)
        jr nz, no_ir2
        ld line(ix), b
        no_ir2:
        jr no_tile_turbo1
        no_tile_turbo:


        ;Turbo delante abajo del jugador
        ;Solo ir si tile abajo esta libre 
        ld c, rltv_pos(ix)             
        ld b, line(ix)
        inc b     ;;Tile encima del jugador
        inc c
        call PointAtTilemap
        ld a, (hl) 
        cp #10 ;;Tile de turbo
        jr nz, no_tile_turbo1
        ld c, rltv_pos(ix)             
        ld b, line(ix)
        inc b     ;;Tile abajo del jugador
        call PointAtTilemap
        ld a, (hl) 
        ld b, line(ix)
        inc b     ;;Tile abajo del jugador
        cp #10 ;; Tile de turbo (tile segura)
        jr nz, no_ir_
        ld line(ix), b
        jr no_tile_turbo1
        no_ir_:
        cp #12 ;; Tile normal (tile segura)
        jr nz, no_ir2_
        ld line(ix), b
        no_ir2_:

        no_tile_turbo1:

        no_necesario:
      ;-----------------------

      jr fin_decisiones
    no_decide:
     ld abs_pos(ix),a
    fin_decisiones:


    ;;SECCION 3: Incremento de la velocidad o reinicio
    ;Timer para medir cada cuantos ciclos avanza la ia
    
    ld a, tim(ix)
    dec a
    ld tim(ix), a
    cp #0
    jr nz, tim_no_es_0
    ld a, velX(ix)
    ld tim(ix), a ;;Numero de ciclos (determina la velocidad de la ia)
    
    ;Movimiento actual, tile a tile
    ld a, jump(ix)
    cp #0
    jr nz, saltar_mov

    ;;No te puedes mover si ya has completado todas las vueltas
    ld a, lap(ix)
    cp #4
    jr z, saltar_mov_fin

    ld a, #179
    cp rltv_pos(ix)
    jr z,reiniciar
    ;;No se reinicia, incrementamos su posicion
    inc rltv_pos(ix)

      ld a,rltv_pos(ix)
      cp #1
      jr nz, no_lap
        ld a, lap(ix)
        inc a 
        ld lap(ix),a
        cp #4
        jr nz, no_final 
        push ix 
        call entityman_getEntityArray_IX

          ld a, abs_pos(ix)
          inc a
          ld abs_pos(ix),a

        pop ix

          ld position(ix), a

        no_final:
      no_lap:

    jr salir
    reiniciar:
    ld rltv_pos(ix), #0
    salir:

    saltar_mov_fin:


    saltar_mov:
    ;Movimiento legacy de AI, conservar para caso de emergencia

    ;ld a, posX(ix)
    ;inc a
    ;inc a
    ;inc a
    ;inc a
    ;;;予約 
    ;ld posX(ix), a

    ;Comprobacion de si la velX del player es 1
    ;ld a,l
    ;cp #1
    ;jr nz, saltar
    ; ld a, posX(ix)
    ; sub #8
    ; ld posX(ix), a
    ; saltar:

   tim_no_es_0:

   es_player2:
    pop af

    dec a
    ret z

    ld bc, #entity_size
    add ix, bc

   jp ai_loop
    
ret
