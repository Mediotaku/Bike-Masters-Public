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

;############################################################################
;##                            BIKE MASTERS                                ##
;##              An Amstrad CPC Game created with CPCtelera                ##
;##------------------------------------------------------------------------##
;##                              Authors:                                  ##
;## - Eduardo Gómez Martínez: Art, Levels, Physics                         ##
;## - Alberto Benavent Ramón: Music, Tilemap, Scroll                       ##
;## - José Vicente Tomás Pérez: AI logic and physics                       ##
;############################################################################


.include "cpctelera.h.s"
.include "header.h.s"
.area _DATA

;;
;; Start of _CODE area
;;
.area _CODE

_player: .db 4, #posYinit+16, 0, 0, 0, 2, 0, 1, 0, 0, #acceleration, #acceleration, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0
;;     PosX, PosY, velX, velY, wheelie, line, offset, speedRamp, turbo, empty,  Acc, timerRight,  timerY, poswheelie, player, sprite, rltv_pos, lock, vuelta, abs_pos, position, color

_ai1: .db 4, #posYinit+24,  4, 0, 0, 3, 2, 2, 0, 0, #acceleration, 10, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1
;;     PosX, PosY, velX (en IA es la velocidad real), velY, wheelie, line, offset, speedRamp, turbo, empty,  Acc, timerRight,  timerY, poswheelie, player, sprite, rltv_pos, lock(en ia controla acciones temporales) , vuelta, abs_pos (en ia se utiliza como timer de decision), posicion, color

_ai2: .db 4, #posYinit+32,  4, 0, 0, 4, 2, 3, 0, 0, #acceleration, 10, 0, 0, 0, 0, 1, 0, 1, 1, 0, 2
;;     PosX, PosY, velX (en IA es la velocidad real), velY, wheelie, line, offset, speedRamp, turbo, empty,  Acc, timerRight,  timerY, poswheelie, player, sprite, rltv_pos, lock, vuelta, abs_pos, posicion, color

_ai3: .db 4, #posYinit+40,  4, 0, 0, 5, 2, 3, 0, 0, #acceleration, 10, 0, 0, 0, 0, 1, 0, 1, 1, 0, 3
;;     PosX, PosY, velX (en IA es la velocidad real), velY, wheelie, line, offset, speedRamp, turbo, empty,  Acc, timerRight,  timerY, poswheelie, player, sprite, rltv_pos, lock, vuelta,abs_pos, posicion, color

_first_lvl:: .db 0
_lvl_amount:: .db 0


_main::
   ld sp, #0x8000 ;; Mover la pila fuera del doble buffer

   ld hl, #int_handler
   call cpct_waitVSYNC_asm
   halt
   halt
   call cpct_waitVSYNC_asm
   call cpct_setInterruptHandler_asm  ;; Al cambiar las interrupciones por las nuestras deshabilitamos el firmware

   call render_system_init
   
    _reiniciar_con_musica::

   ld de, #_g_music
   call cpct_akp_musicInit_asm

   ld de, #_g_sfx      ;; DE = Pointer to SFX Music
   call cpct_akp_SFXInit_asm   ;; Initialize instruments for SFX





   _reiniciar::
   xor a
   ld (_first_lvl), a
   call entityman_restart
   cpctm_setBorder_asm HW_WHITE


   call main_menu
   cup_chosen::
   call entityman_restart
   ld a, (_lvl_amount)
   ld b, a
   ld a, (_first_lvl)
   add a, b
   level_chosen:

   push af
   ;; Parar la musica
   ld de, #_g_sfx
   call cpct_akp_musicInit_asm
   ;; Sonido inicio carrera
   ld a, #notaDoCentral
   ld (noteSFX), a
   ld hl, #0x0004
   ld (currentSFX), hl

   cpctm_setBorder_asm HW_BLUE
   call DibujarFondo
   ld a, #1
   ld (first_endgame), a


   ld a, #0x70
   ld (timer_endgame), a
   pop af
   call depackage_level
   call dibujar_lvl_tilemap
   call SwitchVideoBuffer
   call dibujar_lvl_tilemap
   ld a, #0xA0
   start_loop:
    halt
    halt
    dec a
    cp #0
   jp nz, start_loop


   ld hl, #_player
   call entityman_create

   ;;Pasas la posicion inicial del objeto
   ld hl, #_ai1
   call entityman_create

   ld hl, #_ai2
   call entityman_create

   ld hl, #_ai3
   call entityman_create

   ;; Loop forever
loop:

  ;call game_system_update

  ;cpctm_setBorder_asm HW_RED

  call game_system_update

  ;cpctm_setBorder_asm HW_SKY_BLUE


  ;; FALTA UN ENTITY MANAGER INIT
  ;ld hl, #Key_F
  ;call cpct_isKeyPressed_asm
  ;jp nz, end_menu


jr    loop

main_menu:
  push af
  call DibujarMenu
  ;; Parar efectos de sonido
  ld hl, #0x0000
  ld (currentSFX), hl
  pop af



  ;Pen
  ;ld    h, #0
  ;ld    l, #1

  ;call cpct_setDrawCharM0_asm   ;; Set draw char colours

  ;ld   de, #CPCT_VMEM_START_ASM
  ;ld    b, #24
  ;ld    c, #0

  ;call cpct_getScreenPtr_asm

  ;ld   iy, #startstr
  ;call cpct_drawStringM0_asm

  loop_mm:
    ld hl, #Key_1
    call cpct_isKeyPressed_asm
    jp nz, rally

    ld hl, #Key_2
    call cpct_isKeyPressed_asm
    jp nz, lvlSelector

    ld hl, #Key_3
    call cpct_isKeyPressed_asm
    jp nz, controles
  jr loop_mm

  seleccionar_nivel_1:
    ld a, #1
    ret
  seleccionar_nivel_2:
    ld a, #2
ret

screensize 	= #0x4000

controles:

  push af
    call DibujarControles
  pop af

  loop_ctrl:
    call cpct_isAnyKeyPressed_asm
    jp nz, main_menu

  jr loop_ctrl

ret


rally:
  xor a
  ld (_lvl_amount), a
  ld (_first_lvl), a

  push af
    call DibujarRally
  pop af



  loop_rally:

    ld hl, #Key_1
    call cpct_isKeyPressed_asm
    jp nz, cup_chosen_1

    ld hl, #Key_2
    call cpct_isKeyPressed_asm
    jp nz, cup_chosen_2

    ld hl, #Key_3
    call cpct_isKeyPressed_asm
    jp nz, cup_chosen_3

    ld hl, #Key_4
    call cpct_isKeyPressed_asm
    jp nz, cup_chosen_4

    ld hl, #Key_5
    call cpct_isKeyPressed_asm
    jp nz, cup_chosen_5

    ld hl, #Key_6
    call cpct_isKeyPressed_asm
    jp nz, cup_chosen_6

    ld hl, #Key_Del
    call cpct_isKeyPressed_asm
    jp nz, _reiniciar

    ld hl, #Key_Esc
    call cpct_isKeyPressed_asm
    jp nz, _reiniciar
  jr loop_rally

    cup_chosen_1:
      ld a, #1
      ld (_first_lvl), a
      jp cup_chosen

    cup_chosen_2:
      ld a, #4
      ld (_first_lvl), a
      jp cup_chosen

    cup_chosen_3:
      ld a, #7
      ld (_first_lvl), a
      jp cup_chosen

    cup_chosen_4:
      ld a, #10
      ld (_first_lvl), a
      jp cup_chosen

    cup_chosen_5:
      ld a, #13
      ld (_first_lvl), a
      jp cup_chosen

    cup_chosen_6:
      ld a, #16
      ld (_first_lvl), a
      jp cup_chosen

ret


lvlSelector:

  push af
    call DibujarLvl
  pop af

  loop_lvl:
    ld hl, #Key_A
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_1

    ld hl, #Key_B
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_2

    ld hl, #Key_C
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_3

    ld hl, #Key_D
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_4

    ld hl, #Key_E
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_5

    ld hl, #Key_F
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_6

    ld hl, #Key_G
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_7

    ld hl, #Key_H
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_8

    ld hl, #Key_I
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_9

    ld hl, #Key_J
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_10

    ld hl, #Key_K
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_11

    ld hl, #Key_L
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_12

    ld hl, #Key_M
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_13

    ld hl, #Key_N
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_14

    ld hl, #Key_O
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_15

    ld hl, #Key_P
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_16

    ld hl, #Key_Q
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_17

    ld hl, #Key_R
    call cpct_isKeyPressed_asm
    jp nz, level_chosen_18

    ld hl, #Key_Del
    call cpct_isKeyPressed_asm
    jp nz, _reiniciar

    ld hl, #Key_Esc
    call cpct_isKeyPressed_asm
    jp nz, _reiniciar

  jp loop_lvl

  level_chosen_1:
    ld a, #1
    jp level_chosen

  level_chosen_2:
    ld a, #2
    jp level_chosen

  level_chosen_3:
    ld a, #3
    jp level_chosen

  level_chosen_4:
    ld a, #4
    jp level_chosen

  level_chosen_5:
    ld a, #5
    jp level_chosen

  level_chosen_6:
    ld a, #6
    jp level_chosen

  level_chosen_7:
    ld a, #7
    jp level_chosen

  level_chosen_8:
    ld a, #8
    jp level_chosen

  level_chosen_9:
    ld a, #9
    jp level_chosen

  level_chosen_10:
    ld a, #10
    jp level_chosen

  level_chosen_11:
    ld a, #11
    jp level_chosen

  level_chosen_12:
    ld a, #12
    jp level_chosen

  level_chosen_13:
    ld a, #13
    jp level_chosen

  level_chosen_14:
    ld a, #14
    jp level_chosen

  level_chosen_15:
    ld a, #15
    jp level_chosen

  level_chosen_16:
    ld a, #16
    jp level_chosen

  level_chosen_17:
    ld a, #17
    jp level_chosen

  level_chosen_18:
    ld a, #18
    jp level_chosen

ret



end_menu:


  ;Pen
  ld    h, #0
  ld    l, #4

  call cpct_setDrawCharM0_asm   ;; Set draw char colours

  ld   de, #CPCT_VMEM_START_ASM
  ld    b, #24
  ld    c, #16

  call cpct_getScreenPtr_asm

  ld   iy, #endstr
  call cpct_drawStringM0_asm

  loop_em:
  halt
  halt
  halt
  call cpct_isAnyKeyPressed_f_asm

  jr z, loop_em

  call clearScreen


jp _reiniciar

clearScreen:

 ld hl, #0xC000
 ld de, #0xC000+1
 ld bc, #screensize-1
 ld (hl), #0
 ldir

ret
