BasicUpstart2(Entry)

#import "./lib/c64.asm"

.label ElementCount = $00fd
.label Swap = $00fe

ElementArray:
.fill 128, random() * 128
__ElementArray:

Entry:
    lda #__ElementArray - ElementArray - 1
    sta ElementCount        // Store len(ElementArray) - 1

    lda #$01                // There's no work to be done if len(ElementArray) <= 1
    cmp ElementCount
    bpl Exit
                            // Setup zeropage (0x00fb, 0x00fc) to point to ElementArray
    lda #<ElementArray      // Low byte of address
    sta $00fb
    lda #>ElementArray      // High byte of address
    sta $00fc

!Outer:
    lda #$00                // Reset swap flag
    sta Swap

    ldx ElementCount
    ldy #$00

!Inner:
    lda ($fb), y
    iny
    cmp ($fb), y            // Compare ElementArray[y] to ElementArray[y + 1]
    bmi !SkipSwap+          // Swap if ElementArray[y] > ElementArray[y + 1]

    pha
    lda ($fb), y            // Load ElementArray[y + 1]
    dey
    sta ($fb), y            // Set ElementArray[y] := ElementArray[y + 1]
    iny
    pla
    sta ($fb), y            // Set ElementArray[y + 1] := ElementArray[y]

    WaitForVsync()          // Let's waste some cycles (312 * 63?)
    stx VIC.BORDER_COLOR

    lda #$01
    sta Swap                // Set swap flag to true

!SkipSwap:
    dex
    bne !Inner-

    lda #$00                // If no swap was performed we're done
    cmp Swap
    beq Exit

    dec ElementCount
    bne !Outer-

Exit:
    lda #$0e              // Reset background color
    sta VIC.BORDER_COLOR

    rts
