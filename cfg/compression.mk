##-----------------------------LICENSE NOTICE------------------------------------
##  This file is part of CPCtelera: An Amstrad CPC Game Engine
##  Copyright (C) 2018 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU Lesser General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##------------------------------------------------------------------------------
############################################################################
##                        CPCTELERA ENGINE                                ##
##                 Automatic compression utilities                        ##
##------------------------------------------------------------------------##
## This file is intended for users to automate the generation of          ##
## compressed files and their inclusion in users' projects.               ##
############################################################################

## COMPRESSION EXAMPLE (Uncomment lines to use)
##

## First 3 calls to ADD2PACK add enemy, hero and background
## graphics (previously converted to binary data) into the
## compressed group 'mygraphics'. After that, call to PACKZX7B
## compresses all the data and generates an array with the result
## that is placed in src/mygraphics.c & src/mygraphics.h, ready
## to be included and used by other modules.
##
#$(eval $(call ADD2PACK,mygraphics,gfx/enemy.bin))
#$(eval $(call ADD2PACK,mygraphics,gfx/hero.bin))
#$(eval $(call ADD2PACK,mygraphics,gfx/background.bin))
#$(eval $(call PACKZX7B,mygraphics,src/))
$(eval $(call ADD2PACK,1_pack,src/1.bin))
$(eval $(call PACKZX7B,1_pack,src/))

$(eval $(call ADD2PACK,2_pack,src/2.bin))
$(eval $(call PACKZX7B,2_pack,src/))

$(eval $(call ADD2PACK,3_pack,src/3.bin))
$(eval $(call PACKZX7B,3_pack,src/))

$(eval $(call ADD2PACK,4_pack,src/4.bin))
$(eval $(call PACKZX7B,4_pack,src/))

$(eval $(call ADD2PACK,5_pack,src/5.bin))
$(eval $(call PACKZX7B,5_pack,src/))

$(eval $(call ADD2PACK,6_pack,src/6.bin))
$(eval $(call PACKZX7B,6_pack,src/))

$(eval $(call ADD2PACK,7_pack,src/7.bin))
$(eval $(call PACKZX7B,7_pack,src/))

$(eval $(call ADD2PACK,8_pack,src/8.bin))
$(eval $(call PACKZX7B,8_pack,src/))

$(eval $(call ADD2PACK,9_pack,src/9.bin))
$(eval $(call PACKZX7B,9_pack,src/))

$(eval $(call ADD2PACK,10_pack,src/10.bin))
$(eval $(call PACKZX7B,10_pack,src/))

$(eval $(call ADD2PACK,11_pack,src/11.bin))
$(eval $(call PACKZX7B,11_pack,src/))

$(eval $(call ADD2PACK,12_pack,src/12.bin))
$(eval $(call PACKZX7B,12_pack,src/))

$(eval $(call ADD2PACK,13_pack,src/13.bin))
$(eval $(call PACKZX7B,13_pack,src/))

$(eval $(call ADD2PACK,14_pack,src/14.bin))
$(eval $(call PACKZX7B,14_pack,src/))

$(eval $(call ADD2PACK,15_pack,src/15.bin))
$(eval $(call PACKZX7B,15_pack,src/))

$(eval $(call ADD2PACK,16_pack,src/16.bin))
$(eval $(call PACKZX7B,16_pack,src/))

$(eval $(call ADD2PACK,17_pack,src/17.bin))
$(eval $(call PACKZX7B,17_pack,src/))

$(eval $(call ADD2PACK,18_pack,src/18.bin))
$(eval $(call PACKZX7B,18_pack,src/))

$(eval $(call ADD2PACK,fondo_pack,src/fondo.bin))
$(eval $(call PACKZX7B,fondo_pack,src/))

$(eval $(call ADD2PACK,menu_pack,src/menu.bin))
$(eval $(call PACKZX7B,menu_pack,src/))

$(eval $(call ADD2PACK,controls_pack,src/controls.bin))
$(eval $(call PACKZX7B,controls_pack,src/))

$(eval $(call ADD2PACK,lvl_pack,src/lvl.bin))
$(eval $(call PACKZX7B,lvl_pack,src/))

$(eval $(call ADD2PACK,cup_pack,src/cup.bin))
$(eval $(call PACKZX7B,cup_pack,src/))

$(eval $(call ADD2PACK,youwon_pack,src/youwon.bin))
$(eval $(call PACKZX7B,youwon_pack,src/))

$(eval $(call ADD2PACK,youlost_pack,src/youlost.bin))
$(eval $(call PACKZX7B,youlost_pack,src/))

$(eval $(call ADD2PACK,leave_pack,src/leave.bin))
$(eval $(call PACKZX7B,leave_pack,src/))






############################################################################
##              DETAILED INSTRUCTIONS AND PARAMETERS                      ##
##------------------------------------------------------------------------##
##                                                                        ##
## Macros used for compression are ADD2PACK and PACKZX7B:                 ##
##                                                                        ##
##	ADD2PACK: Adds files to packed (compressed) groups. Each call to this ##
##  		  macro will add a file to a named compressed group.          ##
##  PACKZX7B: Compresses all files in a group into a single binary and    ##
##            generates a C-array and a header to comfortably use it from ##
##            inside your code.                                           ##
##                                                                        ##
##------------------------------------------------------------------------##
##                                                                        ##
##  $(eval $(call ADD2PACK,<packname>,<file>))                            ##
##                                                                        ##
##		Sequentially adds <file> to compressed group <packname>. Each     ##
## call to this macro adds a new <file> after the latest one added.       ##
## packname could be any valid C identifier.                              ##
##                                                                        ##
##  Parameters:                                                           ##
##  (packname): Name of the compressed group where the file will be added ##
##  (file)    : File to be added at the end of the compressed group       ##
##                                                                        ##
##------------------------------------------------------------------------##
##                                                                        ##
##  $(eval $(call PACKZX7B,<packname>,<dest_path>))                       ##
##                                                                        ##
##		Compresses all files in the <packname> group using ZX7B algorithm ##
## and generates 2 files: <packname>.c and <packname>.h that contain a    ##
## C-array with the compressed data and a header file for declarations.   ##
## Generated files are moved to the folder <dest_path>.                   ##
##                                                                        ##
##  Parameters:                                                           ##
##  (packname) : Name of the compressed group to use for packing          ##
##  (dest_path): Destination path for generated output files              ##
##                                                                        ##
############################################################################
##                                                                        ##
## Important:                                                             ##
##  * Do NOT separate macro parameters with spaces, blanks or other chars.##
##    ANY character you put into a macro parameter will be passed to the  ##
##    macro. Therefore ...,src/sprites,... will represent "src/sprites"   ##
##    folder, whereas ...,  src/sprites,... means "  src/sprites" folder. ##
##  * You can omit parameters by leaving them empty.                      ##
##  * Parameters (4) and (5) are optional and generally not required.     ##
############################################################################
