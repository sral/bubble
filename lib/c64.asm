VIC: {
    .label CONTROL_REG1 = $d011
    .label RASTERLINE = $d012
    .label BORDER_COLOR = $d020
    // .label BACKGROUND_COLOR = $d021
    // .label MEMORY_SETUP = $d018
}


.macro WaitForVsync() {
    !:
        lda VIC.CONTROL_REG1
        and #%10000000   // Bit 7 is set if raster line > $ff
        beq !-

        lda #$21
        cmp VIC.RASTERLINE
        bne !-
}