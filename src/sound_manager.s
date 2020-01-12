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

SFXchannel = 2 ;; 1 izquierdo, 2 central, 3 derecho.
currentSFX:: .dw #0 ;; Permite reproducir sonidos. 2 bytes [ loop 0/1 | num sonido (0 = silencio) ]
noteSFX:: .dw 36

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; smg_SoundUpdate
;;  Plays the corresponding sound & music for this interrupt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
smg_SoundUpdate::
    call cpct_akp_musicPlay_asm
    call smg_PlaySFX
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; smg_PlaySFX
;;  Plays the SFX set with smg_SetSFX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
smg_PlaySFX::
    ld hl, (currentSFX)
    ld a, l ;; En l de currentSFX se guarda el instrumento, 0 = no suena
    cp #0
    ret z ;; No sound to play
    
    ld a, h ;; En h de currentSFX se guarda si es loop, 0 = no loop
    ex de, hl   ;; Guardo los datos del instrumento a tocar
    cp #0
    jr nz, checkloopSFX
    dontloopSFX:
        ld hl, #0
        ld (currentSFX), hl ;; Reseteo currentSFX para que no suene en el siguiente frame
        jr jump_playSFX
    checkloopSFX::
        ld a, #SFXchannel    ;; Canal central
        call cpct_akp_SFXGetInstrument_asm  ;; Compruebo si suena algo en el canal central
        ld a, l
        cp #0
        ret nz  ;; A mitad de reproducirse, asi que no hago nada

    jump_playSFX:
    ex de, hl   ;; Recupero el instrumento
    ;; (1B L ) sfx_num	Number of the instrument in the SFX Song (>0), same as the number given to the instrument in Arkos Tracker.
    ;; (1B H ) volume	Volume [0-15], 0 = off, 15 = maximum volume.
    ;; (1B E ) note	Note to be played with the given instrument [0-143]
    ;; (1B D ) speed	Speed (0 = As original, [1-255] = new Speed (1 is fastest))
    ;; (2B BC) inverted_pitch	Inverted Pitch (-0xFFFF -> 0xFFFF).  0 is no pitch.  The higher the pitch, the lower the sound.
    ;; (1B A ) channel_bitmask	Bitmask representing channels to use for reproducing the sound (Ch.A = 001 (1), Ch.B = 010 (2), Ch.C = 100 (4))

    ld h, #15 ;; Maximo volumen
    ld a, (noteSFX)
    ld e, a ;; Nota
    ld d, #0  ;; Velocidad inicial
    ld bc, #0 ;; Tono inicial
    ld a, #SFXchannel  ;; Canal
    call cpct_akp_SFXPlay_asm
ret