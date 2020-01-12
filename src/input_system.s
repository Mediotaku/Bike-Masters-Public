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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; input_system_update
;;  Se ejecuta una vez por iteración del main loop
;;  para comprobar el input del teclado
;;
;; PARAMS:
;;  IX: Estructura de datos de las entidades
;; MODIFIES:
;;  A, HL, player(ix), velX(ix), velY(ix), wheelie(ix)
;; RETURNS:
;;  A: 1 if entity is player, otherwise 0
;;  velX(ix): 1 if right key pressed, otherwise 0
;;  velY(ix): 1 if up key pressed, -1 if down key pressed, otherwise 0
;;  wheelie(ix): 1 if left key pressed, otherwise 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
input_system_update::

  call entityman_getEntityArray_IX
  call entityman_getNumEntities_A

  ;;Comprobacion de que es el player
  ld a, player(ix)
  cp #0
  jp z, no_es_player

  ld velX(ix), #0
  ld velY(ix), #0
  ld wheelie(ix), #0
  ;ld color(ix), #11

  call cpct_isAnyKeyPressed_f_asm
  ret z

  ;; P
  ld hl, #Key_Esc
  call cpct_isKeyPressed_asm
  call nz, leavefr

  ld hl, #Key_P
  call cpct_isKeyPressed_asm
  jr z, nprk
  ld velX(ix), #1

  ld a, jump(ix)
  cp #0
  ret nz

  ld a, lock_mov(ix)
  cp #0
  ret nz

  ;;ld rltv_pos(ix), #1

 ;;Esto se borrará en un futuro
  ;startstr: .asciz "Prueba";
  ;ld   iy, #startstr
  ;ld de, #0xC000
  ;ld    b, #24
  ;ld    c, #16
  ;call cpct_drawStringM1_asm

  nprk: ;;Joystick derecho

    ld hl, #Joy0_Fire1
    call cpct_isKeyPressed_asm
    jr z, npr
    ld velX(ix), #1

  npr:

    ld hl, #Key_O
    call cpct_isKeyPressed_asm
    jr z, nplk
    ld wheelie(ix), #1

  nplk:

    ld hl, #Joy0_Fire2
    call cpct_isKeyPressed_asm
    jr z, npl
    ld wheelie(ix), #1


  npl:

    ld hl, #Key_Q
    call cpct_isKeyPressed_asm
    jr z, npuk
    ld velY(ix), #1

  npuk:

    ld hl, #Joy0_Up
    call cpct_isKeyPressed_asm
    jr z, npu
    ld velY(ix), #1

  npu:

    ld hl, #Key_A
    call cpct_isKeyPressed_asm
    jr z, npdk ;;ret z
    ld velY(ix), #-1

  npdk:

    ld hl, #Joy0_Down
    call cpct_isKeyPressed_asm
    ret z
    ;;jr z, esc ;;ret z
    ld velY(ix), #-1


  esc: ;;Joystick derecho

    ld hl, #Key_Del
    call cpct_isKeyPressed_asm
    ret z
      ;; Return pulsada, volver al menu tras poner musica
      ld de, #_g_music
      call cpct_akp_musicInit_asm

      jp _reiniciar
    ret

    ;;Cambiando la posición de la ia
    no_es_player:
    ;ld hl, #Key_CursorRight
    ;call cpct_isKeyPressed_asm
    ;jr z, parado
    ;ld a, posX(ix)
    ;dec a
    ;dec a
    ;dec a
    ;dec a
    ;ld posX(ix), a
    ;parado:

ret
