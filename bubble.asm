BasicUpstart2(Entry)

#import "./lib/c64.asm"

Elements:
.fill 128, random() * 128

ElementCount:
.byte * - Elements - 1  // Store len(Elements) - 1

Swap:
.byte 0

Entry:
    lda #$01            // There's no work to be done if len(Elements) <= 1
    cmp ElementCount
    bpl Exit

                        // Setup zeropage (0x00fb, 0x00fc) to point to Elements
    lda #<Elements      // Low byte of address
    sta $00fb
    lda #>Elements      // High byte of address
    sta $00fc

!Outer:
    ldx ElementCount
    ldy #$00

!Inner:
    lda ($fb), y
    iny
    cmp ($fb), y        // Compare Elements[y] to Elements[y + 1]
    bmi !SkipSwap+      // Swap if Elements[y] > Elements[y + 1]

    pha
    lda ($fb), y        // Load Elements[y + 1]
    dey
    sta ($fb), y        // Set Elements[y] := Elements[y + 1]
    iny
    pla
    sta ($fb), y        // Set Elements[y + 1] := Elements[y]

    WaitForVsync()      // Let's waste some cycles (312 * 63?)
    stx VIC.BORDER_COLOR

    lda #$01
    sta Swap            // Set swap flag to true

!SkipSwap:
    dex
    bne !Inner-

    lda #$00            // If no swap was performed we're done
    cmp Swap
    beq Exit

    lda #$00            // Reset swap flag
    sta Swap

    dec ElementCount
    bne !Outer-

Exit:
    lda #$0e           // Reset background color
    sta VIC.BORDER_COLOR

    rts
