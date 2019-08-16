BasicUpstart2(Start)

#import "./lib/c64.asm"

Elements:
.fill 128, random() * 128

ElementCount:
.byte * - Elements - 1  // Store len(Elements) - 1

Swap:
.byte 0

Start:
    lda #$01            // There's no work to be done if len(Elements) <= 1
    cmp ElementCount
    bpl Exit

    ldx ElementCount
    ldy #$00

!Inner:
    lda Elements, y     // Read Elements[y]
    iny
    cmp Elements, y     // Compare Elements[y] to Elements[y + 1]
    bmi SkipSwap        // Swap if Elements[y] > Elements[y + 1]

    pha                 // Push Elements[y]
    lda Elements, y     // Load Elements[y + 1]
    dey
    sta Elements, y     // Store Elements[y] := Elements[y + 1]
    iny
    pla                 // Pop Elements[y]
    sta Elements, y     // Store Elements[y + 1] := previous Elements[y]

    WaitForVsync()      // Let's waste some cycles (312 * 63?)
    stx VIC.BORDER_COLOR

    lda #$01
    sta Swap            // Set swap flag to true

SkipSwap:
    dex
    bne !Inner-

    lda #$00            // If no swap was performed we're done
    cmp Swap
    beq Exit

    lda #$00            // Reset swap flag
    sta Swap

    dec ElementCount
    bne Start

Exit:
    lda #$0e           // Reset background color
    sta VIC.BORDER_COLOR

    rts
