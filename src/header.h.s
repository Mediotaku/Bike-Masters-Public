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

.globl cpct_scanKeyboard_if_asm
.globl cpct_isAnyKeyPressed_f_asm
.globl cpct_isKeyPressed_asm
.globl cpct_waitVSYNC_asm
.globl cpct_getScreenPtr_asm
.globl cpct_setPalette_asm
.globl cpct_drawStringM0_asm
.globl cpct_setDrawCharM0_asm

;;entity manager
.globl _reiniciar
.globl _reiniciar_con_musica
.globl entityman_create
.globl entityman_restart
.globl entityman_getEntityArray_IX
.globl entityman_getNumEntities_A

.globl entity_size
.globl _entity_array

.globl _menu_pack_end
.globl _controls_pack_end
.globl _lvl_pack_end
.globl _cup_pack_end
.globl _youwon_pack_end
.globl _youlost_pack_end
.globl _leave_pack_end

.globl youwon
.globl youlost
.globl leavefr

.globl _lvl1_W
.globl _1_pack_size
.globl _1_pack_end
.globl _2_pack_end
.globl _3_pack_end
.globl _4_pack_end
.globl _5_pack_end
.globl _6_pack_end
.globl _7_pack_end
.globl _8_pack_end
.globl _9_pack_end
.globl _10_pack_end
.globl _11_pack_end
.globl _12_pack_end
.globl _13_pack_end
.globl _14_pack_end
.globl _15_pack_end
.globl _16_pack_end
.globl _17_pack_end
.globl _18_pack_end

.globl dibujar_lvl_tilemap
.globl SwitchVideoBuffer



;;interrupt manager
.globl cpct_setInterruptHandler_asm
.globl int_handler

;;input System
.globl input_system_update
.globl _main

;; Musica
.globl cpct_akp_musicInit_asm
.globl cpct_akp_musicPlay_asm
.globl cpct_akp_SFXInit_asm
.globl cpct_akp_SFXPlay_asm
.globl cpct_akp_SFXGetInstrument_asm

.globl currentSFX
.globl noteSFX
.globl smg_SoundUpdate
.globl _g_sfx
.globl _g_music
.globl _g_victoria

.globl first_endgame
;; game game_system_update

.globl game_system_update

;; physics System

.globl physics_system_update

;; AI System

.globl ai_system_update

;; .globl clearScreen
.globl DibujarFondo
.globl DibujarMenu
.globl DibujarControles
.globl DibujarLvl
.globl DibujarRally

.globl scrollRestante
.globl scrollRestanteInit
.globl resetTilemapEM

.globl render_system_init
.globl render_system_update
.globl render_system_race_status

;; .globl physics_system
.globl PointAtTilemap
.globl cup_chosen

;; .globl tilemap y scroll

.globl _palette
.globl cpct_setVideoMode_asm
.globl cpct_zx7b_decrunch_s_asm
.globl cpct_etm_setDrawTilemap4x8_ag_asm
.globl cpct_etm_drawTilemap4x8_ag_asm
.globl cpct_setVideoMemoryPage_asm
.globl cpct_isAnyKeyPressed_asm
.globl cpct_drawSprite_asm

.globl scrollMove
.globl depackage_level
;; .globl dibujar sprites

;; SPRITE RELATED THINGS
.globl cpct_drawSpriteMasked_asm
.globl cpct_drawSprite_asm
.globl _spritearray
.globl _spriteCab1
.globl _spriteCab2
.globl _spriteCab3
.globl _caida
.globl _bajada
.globl _planta
.globl _lap1
.globl _lap2
.globl _lap3
.globl _flag1
.globl _flag2
.globl _flag3
.globl _flag4

;;test

.globl physics_system_ramp_up
.globl physics_system_ramp_down
.globl physics_system_turbo
.globl _first_lvl
.globl _lvl_amount
.globl timer_endgame

;; .globl strings
.globl startstr
.globl endstr
;;CONSTANTES

posX      = 0
posY      = 1
velX      = 2
velY      = 3
wheelie   = 4
line      = 5
offset    = 6
sRamp     = 7
turbo     = 8
jump      = 9
acc       = 10
tim       = 11
timY      = 12
wh        = 13
player    = 14
sprite    = 15
rltv_pos  = 16
lock_mov  = 17
lap       = 18
abs_pos   = 19
position  = 20
color    = 21

posYinit  = 126

alturaCarretera = #0x0500 ;; con 0 en vez de C u 8 porque tiene que valer para ambos buffers

;;Variables de entorno
acceleration = 10
entity_size = 22
max_entities = 4

suelo   = 0
cab1    = 1
cab2    = 2
caida   = 3
bajada  = 4
plantasp= 5

screenstart = #0xC000

screensize 	= #0x4000

notaDoCentral = 36
