; Copyright (C) 2020 Matt Currie <me@mattcurrie.com>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

SECTION "lib", ROMX
INCLUDE "mgblib/src/hardware.inc"
INCLUDE "mgblib/src/macros.asm"
    enable_cgb_mode
INCLUDE "mgblib/src/old_skool_outline_thick.asm"
INCLUDE "mgblib/src/display.asm"
INCLUDE "mgblib/src/print.asm"
INCLUDE "mgblib/src/misc/delay.asm"


SECTION "initial-register-values", WRAM0

wInitialA::
    DS 1

wInitialB::
    DS 1

wInitialC::
    DS 1


SECTION "boot", ROM0[$100]
    nop                                       
    jp main         

SECTION "header", ROM0[$104]
    ds $143-@, $0

SECTION "header-remainder", ROM0[$144]
    ds $150-@, $0

SECTION "main", ROM0[$150]

main::
    di
    ld sp, $cfff

    ld [wInitialA], a
    ld a, b
    ld [wInitialB], a
    ld a, c
    ld [wInitialC], a

    call ResetDisplay
    call ResetCursor
    call LoadFont

    lcd_on

    print_string_literal "which.gb v0.2.2\\n---------------\\n\\nseems to be a...\\n\\n"

    ld a, [wInitialA]
    cp $01
    jp z, is_dmg_or_sgb

    cp $ff
    jp z, is_mgb_or_sgb2

    cp $11
    jp z, is_cgb_or_agb

    print_string_literal "Unknown!"
    jp done



is_dmg_or_sgb::
    ld a, [wInitialB]
    cp $ff
    jr z, is_dmg0

    ld a, [wInitialC]
    cp $13
    jr z, is_dmgABC

is_sgb::
    print_string_literal "SGB-CPU 01"
    jp done

is_dmg0::
    print_string_literal "DMG-CPU"
    jp done

is_dmgABC::
    print_string_literal "DMG-CPU A/B/C"
    jp done



is_mgb_or_sgb2::
    ld a, [wInitialC]
    cp $13
    jr z, is_mgb

is_sgb2::
    print_string_literal "CPU SGB2"
    jp done    

is_mgb::
    print_string_literal "CPU MGB"
    jp done    



is_cgb_or_agb::
    ld a, [wInitialB]
    cp $00
    jr z, is_cgb

is_agb::
    print_string_literal "CPU AGB ?"
    jp done    

is_cgb::
    ; wave ram is not initialised on cgb0
    ld de, $ff00
    ld c, 8
    ld hl, $ff30
.loop:
    ld a, [hl+]
    cp e
    jp nz, is_cgb0
    ld a, [hl+]
    cp d
    jp nz, is_cgb0
    dec c
    jr nz, .loop

    ; if wave ram is initialised, its not cgb0
is_cgbABCDE::

    ; do some extra OAM writes
    ld hl, $fea0
    ld b, $55
    wait_vram_accessible
    ld [hl], b

    ld hl, $feb8
    ld b, $44
    wait_vram_accessible
    ld [hl], b

    ; read back value from $fea0
    ld hl, $fea0    
    wait_vram_accessible
    ld a, [hl]

    ; Expected values:
    ;   - cgb 0ABC: $44 - because $feb8 & ~$18 == $fea0, so more recent write overwrote $55
    ;   - cgb D: $55
    ;   - cgb E: $aa - ($fea0 & $f0) | (($fea0 & $f0) >> 4))
    
    cp $55
    jr z, is_cgbD

    cp $aa
    jr z, is_cgbE


is_cgbABC::
    call check_cgb_ab_or_c
    cp $f0
    jr nz, is_cgbC

is_cgbAB::
    print_string_literal "CPU CGB A/B"
    jp done

is_cgbC::
    print_string_literal "CPU CGB C"
    jp done

is_cgbD::
    print_string_literal "CPU CGB D"
    jp done

is_cgbE::
    print_string_literal "CPU CGB E"
    jp done

is_cgb0::
    print_string_literal "CPU CGB"
    jp done    


done:
    jr done




; Check some APU behavior to test if is a CGB CPU A/B or CPU CGB C
;
; @return a `$f0` on CPU CGB A/B, or `$f2` on CPU CGB C
check_cgb_ab_or_c::
    ld hl, rNR52
    ld [rDIV], a
    xor a
    ldh [rNR52], a
    cpl
    ldh [rNR52], a

    ld a, 63
    ld [rNR21], a

    ld a, $f0
    ld [rNR22], a

    ld a, $ff
    ld [rNR23], a

    ; trigger the channel with length counter disabled
    ld a, $80
    ld [rNR24], a

    ; frame sequencer's next step is one that doesn't
    ; clock the length counter
    delay $800

    ; set sound length to 1
    ld a, 63
    ld [rNR21], a

    ; trigger the channel with length counter disabled again,
    ; should stop the channel on CGB A/B
    ld a, $00
    ld [rNR24], a

    nop

    ld a, [hl]

    ret
