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
.include "1_pack.h.s"
.include "fondo_pack.h.s"

;;=========== CONSTANTES PARA COMPRESION ================
decompress_buffer = 0x0040  ;; Direccion de inicio del buffer
levelmaxsize = _1_pack_size  ;; Tamanyo del nivel mas grande
decompress_buffer_end = decompress_buffer + levelmaxsize - 1   ;; Final de la zona de decompresion
tileset_ptr = decompress_buffer_end + 2  ;; Principio del tileset
tilemap_ptr = decompress_buffer + 0

;;=========== VARIABLES PARA DOBLE BUFFER ================
video_ptr: .dw #0x8000

;;
;; PointAtTilemap
;; Returns a pointer to the position in memory of a tile
;; PARAMS:
;;    B: Row of the tilemap, starting at 0 at the top
;;    C: Column of the tilemap, starting at 0 at the leftmost
;; MODIFIES:
;;    DE
;; RETURNS:
;;    HL: Pointer to tile in tilemap
;;
PointAtTilemap::
   ld hl, #tilemap_ptr
   ld d, #0
   ld e, #_lvl1_W

   xor a       ;; a = 0
   cp b        ;; a - b (row)
   jr z, endloopTileAt     ;; Si b es 0 no hay que desplazarnos de fila
   loopTileAt:
      add hl, de
   djnz loopTileAt
   endloopTileAt:

   add hl, bc  ;; Sumamos el desplazamiento en X (columns)
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SwitchVideoBuffer
;;  Cambia de buffer de video entre C000 y 8000
;;
;; MODIFIES:
;;    AF, BC, HL, DE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SwitchVideoBuffer::
   page = . +1
   ld l, #0x20
   call cpct_setVideoMemoryPage_asm
   ld hl, #page
   ld a, #0x10
   xor (hl)    ;; Un xor de 10 con 20 da 30 y viceversa.
   ld (page), a

   ld hl, #video_ptr+1
   ld a, #0x40
   xor (hl)
   ld (video_ptr+1), a
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DibujarFondo
;;  Descomprime el fondo en ambos buffers de video
;;
;; MODIFIES:
;;  HL, DE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DibujarFondo::
  ld hl, #_fondo_pack_end
  ld de, #0xFFFF
  call cpct_zx7b_decrunch_s_asm
  ld hl, #_fondo_pack_end
  ld de, #0xBFFF
  call cpct_zx7b_decrunch_s_asm

ret

DibujarMenu::
  ld hl, #_menu_pack_end
  ld de, #0xFFFF
  call cpct_zx7b_decrunch_s_asm
  ld hl, #_menu_pack_end
  ld de, #0xBFFF
  call cpct_zx7b_decrunch_s_asm

ret


DibujarControles::
  ld hl, #_controls_pack_end
  ld de, #0xFFFF
  call cpct_zx7b_decrunch_s_asm
  ld hl, #_controls_pack_end
  ld de, #0xBFFF
  call cpct_zx7b_decrunch_s_asm

ret


DibujarRally::
  ld hl, #_cup_pack_end
  ld de, #0xFFFF
  call cpct_zx7b_decrunch_s_asm
  ld hl, #_cup_pack_end
  ld de, #0xBFFF
  call cpct_zx7b_decrunch_s_asm

ret

DibujarLvl::

  ld hl, #_lvl_pack_end
  ld de, #0xFFFF
  call cpct_zx7b_decrunch_s_asm
  ld hl, #_lvl_pack_end
  ld de, #0xBFFF
  call cpct_zx7b_decrunch_s_asm

ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; depackage_level
;;  Descomprime un tilemap
;;
;; PARAMS:
;;  A: Numero de tilemap
;; MODIFIES:
;;  A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
depackage_level::
    cp #1
    jp z, level1
    cp #2
    jp z, level2
    cp #3
    jp z, level3
    cp #4
    jp z, level4
    cp #5
    jp z, level5
    cp #6
    jp z, level6
    cp #7
    jp z, level7
    cp #8
    jp z, level8
    cp #9
    jp z, level9
    cp #10
    jp z, level10
    cp #11
    jp z, level11
    cp #12
    jp z, level12
    cp #13
    jp z, level13
    cp #14
    jp z, level14
    cp #15
    jp z, level15
    cp #16
    jp z, level16
    cp #17
    jp z, level17
    cp #18
    jp z, level18

    level1:
      ld hl, #_1_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret
    level2:
      ld hl, #_2_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret
    level3:
      ld hl, #_3_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret
    level4:
      ld hl, #_4_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret
    level5:
      ld hl, #_5_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret
    level6:
      ld hl, #_6_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level7:
      ld hl, #_7_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level8:
      ld hl, #_8_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level9:
      ld hl, #_9_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level10:
      ld hl, #_10_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level11:
      ld hl, #_11_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level12:
      ld hl, #_12_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level13:
      ld hl, #_13_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level14:
      ld hl, #_14_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level15:
      ld hl, #_15_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level16:
      ld hl, #_16_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level17:
      ld hl, #_17_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

    level18:
      ld hl, #_18_pack_end
      ld de, #decompress_buffer_end
      call cpct_zx7b_decrunch_s_asm
      ret

ret

;;=========== VARIABLES PARA SCROLL ================
scrollRestante:: .dw #_lvl1_W - 20
scrollRestanteInit:: .dw #_lvl1_W - 20

scrollMove:: .db 0

principioTilemap = #tilemap_ptr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; render_system_init
;;  Se ejecuta una sola vez al principio de la ejecucion
;;  para inicializar cosas relativas al render
;;
;; MODIFIES: HL, DE, BC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
render_system_init::
  ;; Limpiar el doble buffer, que empieza lleno de datos basura
  ld hl, #0x8000
  ld de, #0x8001
  ld (hl), #00
  ld bc, #0x4000
  ldir

  ;; Poner video mode a 0
  ld c, #0
  call cpct_setVideoMode_asm

  ;; Paleta
  ld hl, #_palette
  ld de, #16
  call cpct_setPalette_asm

  ;; Configurar el tilemap
  ld bc, #0x0714    ;; B = 6, C = 0x14 = 20 (ancho de la pantalla)
  ld de, #_lvl1_W
  ld hl, #tileset_ptr
  call cpct_etm_setDrawTilemap4x8_ag_asm

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; render_system_race_status
;;  Actualiza constantemente los marcadores de las
;;  estadisticas de la carrera actual
;;
;; MODIFIES: HL, DE, BC, IY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
render_system_race_status::

  ;;Marcador de vueltas

  call entityman_getEntityArray_IX
  ld a,lap(ix)
  cp #3
  jr nz, otro
  ld   hl, #_lap3
  push hl
  jr end
  otro:
  cp #2
  jr nz,otro2
  ld   hl, #_lap2
  push hl
  jr end
  otro2:
  cp #1
  jr nz, otro3
  ld   hl, #_lap1
  push hl
  jr end
  otro3:
  jr no_dibujar
  end:

  ld   de, #0xC735
  ld c, #12
  ld b, #16
  call cpct_drawSprite_asm
  pop hl
  ld   de, #0x8735
  ld c, #12
  ld b, #16
  call cpct_drawSprite_asm

  no_dibujar:

ret

dibujar_lvl_tilemap::
  ;; Dibujar tilemap

  ld hl, (video_ptr)
  ld de, #alturaCarretera
  add hl, de             ;; C550/8550 linea 18 de la pantalla
  tilemap = . + 1            ;; Empieza apuntando al primer tile del tilemap
  ld de, #tilemap_ptr
  push hl
  pop hl
  call cpct_etm_drawTilemap4x8_ag_asm

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; render_system_update
;;  Se ejecuta una vez por iteración del main loop
;;  para dibujar el fondo y las entidades en pantalla
;;
;; PARAMS:
;;  A: Numero de entidades
;;  IX: Estructura de datos de las entidades
;; MODIFIES: A, HL, DE, BC, lvpl(ix), lvph(ix)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
render_system_update::

  call dibujar_lvl_tilemap

  ;; Hacer scroll
  ld hl, (scrollRestante)      ;; Contador del scroll
  ex de, hl                    ;; Tendremos que cambiar esto por
  ld a, (scrollMove)           ;; Si scrollMove == 1 desplazamos el mapa
  cp #0
  jr z, p_no_pulsada

    dec e                      ;; Disminuir contador
    jr z, resetTilemap         ;; Si estamos en el punto de loop, resetear el scroll
        ld hl, (tilemap)       ;; Incrementa el puntero al primer tile para que apunte al siguiente
        inc hl
        jr guardarTilemap

    resetTilemap::
        ;; ;; Cambiar contador de vueltas
        ;; ld bc, #0x04AE
        ;; push de
        ;; call PointAtTilemap
        ;; pop de
        ;; inc (hl)

        ld hl, #principioTilemap
        ld de, #_lvl1_W - 20 ;; punto en el que se debe loopear el scroll
    guardarTilemap:   ;; Guardar los registros en las variables
    ld (tilemap), hl
    ex de, hl
    ld (scrollRestante), hl
  p_no_pulsada:
    ;;cpctm_setBorder_asm HW_CYAN


  call entityman_getEntityArray_IX
  ld a,lap(ix)
  cp #1
  jr nz, no_ini
  ld a,rltv_pos(ix)
  cp #1
  jr nz, no_ini
  ;;Inicializacion de los marcadores
  call render_system_race_status
  no_ini:

call entityman_getEntityArray_IX
call entityman_getNumEntities_A

ren_loop:   ;; Renderizar las entidades
  push af

    ;; Comprobar si es el player
    ld a, player(ix)
    cp #0
    jr z, no_es_player

    ;;;; Borramos dibujando un cuadrado de color de fondo
    ;ld e, lvpl(ix)
    ;ld d, lvph(ix)
    ;;;xor a


    ;; Dibujar sprite con mascara
    jr continuar_player

    ;;Esta funcion nos calcula si la IA se encuentra
    ;;en una columna que este en pantalla y la dibuja
    no_es_player:
    or a ;Limpiar el carry
       push ix
       call entityman_getEntityArray_IX
       ld a,rltv_pos(ix)
       pop ix
    ;;En pantalla hay 20 tiles, luego de la columna player-1 a la player+18
    dec a ;Limite inferior de pantalla
    ld b,a
    inc a
    add a,#19 ;Limite superior de pantalla (se resta de 21 para que se vea como llega al final)
    ld c,a

    ;Teniendo en cuenta overflow
    cp #179
    jr nc, overflow ;Si hay overflow del limite superior quiere decir que estoy en el final del tilemap
    ld a, rltv_pos(ix) ;Cargamos en a la posicion de la IA
    jr no_overflow
    overflow:
    ;Si hay overflow hay dos posibilidades: que la IA haya sobre pasado el limite del mapa o no
    ld a, rltv_pos(ix)
    cp b
    jr nc, no_sobrepasa
    ;Sobrepasa el limite
    add a, #179
    no_sobrepasa:

    no_overflow:

    ;Sin tener en cuenta overflow
    ;ld a, rltv_pos(ix)

    cp b
    jp c, salir ;Si tiene carry, es negativo y salimos, sino, seguimos
    ;ld a,rltv_pos(ix)
    cp c
    jp nc,salir ;Si no tiene carry, es positivo o 0 y salimos, sino, seguimos

    ;;Ajustamos posX(ix) a la posicion relativa, si esta en pantalla
    ;ld a, rltv_pos(ix)
    sub b ;;Restamos de a el limite inferior para saber cuanto esta adelantado de la pantalla
    ;;Loop para multiplicar cuanto esta adelantada la ia en pantalla por 4 (medida de un tile)
    ld b,a ;Cargamos el resultado en b, para utilizar add en a
    xor a
    mult_loop:
    add a, #4 ;;Usamos a para almacenar el resultado
    dec b
    jr nz,mult_loop

    ld posX(ix), a

    continuar_player:

    ;;----Colocar segun la posicion conseguida si se ha terminado la carrera----
    push ix
    call entityman_getEntityArray_IX
    ld a, lap(ix)
    cp #4
    pop ix
    jp nz, next

     ld a, lap(ix)
     cp #4
     jp nz, next
      ld a, position(ix)
      cp #1
      jr nz, next1
      ld posX(ix), #20
      ld posY(ix), #posYinit+16+2

      ld hl, (video_ptr)
      ex de, hl
      ld a,posX(ix)
      add #4
      ld   c, a
      ld   b, posY(ix)
      call cpct_getScreenPtr_asm
      ex de, hl
      ld hl, #_flag1
      ld c, #4
      ld b, #8
      call cpct_drawSprite_asm
      next1:
      cp #2
      jr nz, next2
      ld posX(ix), #16
      ld posY(ix), #posYinit+24+2

      ld hl, (video_ptr)
      ex de, hl
      ld a,posX(ix)
      add #4
      ld   c, a
      ld   b, posY(ix)
      call cpct_getScreenPtr_asm
      ex de, hl
      ld hl, #_flag2
      ld c, #4
      ld b, #8
      call cpct_drawSprite_asm
      next2:
      cp #3
      jr nz, next3
      ld posX(ix), #12
      ld posY(ix), #posYinit+32+2

      ld hl, (video_ptr)
      ex de, hl
      ld a,posX(ix)
      add #4
      ld   c, a
      ld   b, posY(ix)
      call cpct_getScreenPtr_asm
      ex de, hl
      ld hl, #_flag3
      ld c, #4
      ld b, #8
      call cpct_drawSprite_asm
      next3:
      cp #4
      jr nz, next4
      ld posX(ix), #8
      ld posY(ix), #posYinit+40+2

      ld hl, (video_ptr)
      ex de, hl
      ld a,posX(ix)
      add #4
      ld   c, a
      ld   b, posY(ix)
      call cpct_getScreenPtr_asm
      ex de, hl
      ld hl, #_flag4
      ld c, #4
      ld b, #8
      call cpct_drawSprite_asm
      next4:
    next:

    ;;Hora de dibujar el sprite
    ld hl, (video_ptr)
    ex de, hl
    ld a, sprite(ix)
    cp #5               ;;Si es planta hay que dibujarlo mas arriba
    jr nz, no_es_planta
    ld   c, posX(ix)
    ld   b, posY(ix)
    ld a, b
    sub #6
    ld b,a
    jr si_es_planta
    no_es_planta:
    ld   c, posX(ix)
    ld   b, posY(ix)
    si_es_planta:
    call cpct_getScreenPtr_asm

    ;;Dibujo del sprite usando la posicion, sea player o IA
    ex de, hl
    ld a, sprite(ix)
    cp #1
    jr z, cabop1
    cp #2
    jr z, cabop2
    cp #3
    jr z, caidaop
    cp #4
    jr z, bajadaop
    cp #5
    jr z, plantaop
    jr default

    cabop1:
      ld hl, #_spriteCab1
      jr drawSP

    cabop2:
      ld hl, #_spriteCab2
      jr drawSP

    caidaop:
      ld hl, #_caida
      jr drawSP

    bajadaop:
      ld hl, #_bajada
      jr drawSP

    plantaop:
      ld hl, #_planta
      jr drawSP

    default:
      ld hl, #_spritearray
      jr drawSP



    drawSP::
      ;; Apuntar a la variacion del sprite en HL correspondiente al color de la entidad
      ld a, color(ix)
      cp #0
      jr z, endloopColor  ;; Si color = 0, es el player y estamos en el sprite que toca
      ld bc, #0x180
      loopColor:
        add hl, bc  ;; Las variaciones están a 0x180 bytes de distancia en memoria
        dec a
      jr nz, loopColor
      endloopColor:
      ld a, sprite(ix)
      cp #5
      jr nz, no_planta
      ld c, #10
      ld b, #16
      jr es_planta
      no_planta:
      ld c, #4
      ld b, #8
      es_planta:
      call cpct_drawSpriteMasked_asm


    ;;No se dibuja si sale por aquí
    salir:

  continuar:
  pop af

  dec a
  jr z, cambiaBuffer  ;; Si ha dibujado todas las entidades cambia el buffer

  ld bc, #entity_size
  add ix, bc

jp ren_loop
  cambiaBuffer:
    call SwitchVideoBuffer
ret


resetTilemapEM::

  ld hl, #principioTilemap
  ld de, #_lvl1_W - 20 ;; punto en el que se debe loopear el scroll
  ld (tilemap), hl
  ex de, hl
  ld (scrollRestante), hl

ret
