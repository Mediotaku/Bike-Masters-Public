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

int_counter: .db 06
int_handler::
    ld a, (int_counter)
    dec a
    jr nz, _continue
    ;; Sexta interrupcion
        ;; cpctm_setBorder_asm HW_BRIGHT_WHITE
        call smg_SoundUpdate

        call cpct_scanKeyboard_if_asm

        ld a, #6 ;; Reiniciar contador
    _continue:
        ld (int_counter), a

        ;; ld h, a
        ;; ld l, #16
        ;; call cpct_setPALColour_asm
    ei
reti
