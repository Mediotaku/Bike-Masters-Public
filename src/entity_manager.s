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

;;
;; Entity Manager
;;
.include "cpctelera.h.s"
.include "header.h.s"


;;Estas variables podrían ir en el header

_num_entities::    .db 0
_last_elem_ptr::   .dw _entity_array
_entity_array::    .ds max_entities*entity_size

;;Funciones de carga de variables utilizadas en el main
entityman_getEntityArray_IX::
    ld ix, #_entity_array
    ret

entityman_getNumEntities_A::
    ld a, (_num_entities)
    ret


;Crear la entidad con los datos declarados en el main
entityman_create::

  ;; Cargamos en de el puntero al último elemento del _entity_array
  ;; cargamos en bc el tamaño
  ;; Usamos ldir para copiar de hl

  ld de, (_last_elem_ptr)
  ld bc, #entity_size ;;Variables globales con almohadilla
  ldir

  ld a, (_num_entities)
  inc a
  ld (_num_entities), a

  ld hl, (_last_elem_ptr)
  ld bc, #entity_size
  add hl, bc
  ld (_last_elem_ptr), hl

ret

entityman_restart::

  ld a, #scrollRestanteInit
  ld (#scrollRestante), a

  call resetTilemapEM

  xor a
  ld (#_num_entities), a
  ld (#scrollMove), a

  ld hl, #_entity_array
  ld (_last_elem_ptr), hl


ret
