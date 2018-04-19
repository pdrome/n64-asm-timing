// Evaluating VI_V_CURRENT_LINE output based on CP0 Count Register by pdrome
// Based heavily on N64 'Bare Metal' CPU Instruction Timing (PAL) Test Demo by krom (Peter Lemon):
arch n64.cpu
endian msb
output "VI_CURRENT_REG_TEST.N64", create
fill 1052672 // Set ROM Size

// Setup Frame Buffer
constant SCREEN_X(640)
constant SCREEN_Y(480)
constant BYTES_PER_PIXEL(4)

// Setup Characters
constant CHAR_X(16)
constant CHAR_Y(16)

origin $00000000
base $80000000 // Entry Point Of Code
include "LIB/N64.INC" // Include N64 Definitions
include "LIB/N64_HEADER.ASM" // Include 64 Byte Header & Vector Table
insert "LIB/N64_BOOTCODE.BIN" // Include 4032 Byte Boot Code

macro PrintString(vram, xpos, ypos, fontfile, string, length) { // Print Text String To VRAM Using Font At X,Y Position
  li a0,{vram}+({xpos}*BYTES_PER_PIXEL)+(SCREEN_X*BYTES_PER_PIXEL*{ypos}) // A0 = Frame Buffer Pointer (Place text at XY Position)
  la a1,{fontfile} // A1 = Characters
  la a2,{string} // A2 = Text Offset
  lli t0,{length} // T0 = Number of Text Characters to Print
  {#}DrawChars:
    lli t1,CHAR_X-1 // T1 = Character X Pixel Counter
    lli t2,CHAR_Y-1 // T2 = Character Y Pixel Counter

    lb t3,0(a2) // T3 = Next Text Character
    addi a2,1

    sll t3,10 // Add Shift to Correct Position in Font (*256: CHAR_X*CHAR_Y*BYTES_PER_PIXEL)
    add t3,a1

    {#}DrawCharX:
      lw t4,0(t3) // Load Font Text Character Pixel
      addi t3,BYTES_PER_PIXEL
      sw t4,0(a0) // Store Font Text Character Pixel into Frame Buffer
      addi a0,BYTES_PER_PIXEL

      bnez t1,{#}DrawCharX // IF (Character X Pixel Counter != 0) DrawCharX
      subi t1,1 // Decrement Character X Pixel Counter

      addi a0,(SCREEN_X*BYTES_PER_PIXEL)-CHAR_X*BYTES_PER_PIXEL // Jump Down 1 Scanline, Jump Back 1 Char
      lli t1,CHAR_X-1 // Reset Character X Pixel Counter
      bnez t2,{#}DrawCharX // IF (Character Y Pixel Counter != 0) DrawCharX
      subi t2,1 // Decrement Character Y Pixel Counter

    li t5,((SCREEN_X*BYTES_PER_PIXEL)*CHAR_Y)-CHAR_X*BYTES_PER_PIXEL // Jump To Start Of Next Char
    sub a0,t5 // Jump To Start Of Next Char
    bnez t0,{#}DrawChars // Continue to Print Characters
    subi t0,1 // Subtract Number of Text Characters to Print
}

macro PrintValue(vram, xpos, ypos, fontfile, value, length) { // Print HEX Chars To VRAM Using Font At X,Y Position
  li a0,{vram}+({xpos}*BYTES_PER_PIXEL)+(SCREEN_X*BYTES_PER_PIXEL*{ypos}) // A0 = Frame Buffer Pointer (Place text at XY Position)
  la a1,{fontfile} // A1 = Characters
  la a2,{value} // A2 = Value Offset
  li t0,{length} // T0 = Number of HEX Chars to Print
  {#}DrawHEXChars:
    lli t1,CHAR_X-1 // T1 = Character X Pixel Counter
    lli t2,CHAR_Y-1 // T2 = Character Y Pixel Counter

    lb t3,0(a2) // T3 = Next 2 HEX Chars
    addi a2,1

    srl t4,t3,4 // T4 = 2nd Nibble
    andi t4,$F
    subi t5,t4,9
    bgtz t5,{#}HEXLetters
    addi t4,$30 // Delay Slot
    j {#}HEXEnd
    nop // Delay Slot

    {#}HEXLetters:
    addi t4,7
    {#}HEXEnd:

    sll t4,10 // Add Shift to Correct Position in Font (*256: CHAR_X*CHAR_Y*BYTES_PER_PIXEL)
    add t4,a1

    {#}DrawHEXCharX:
      lw t5,0(t4) // Load Font Text Character Pixel
      addi t4,4
      sw t5,0(a0) // Store Font Text Character Pixel into Frame Buffer
      addi a0,4

      bnez t1,{#}DrawHEXCharX // IF (Character X Pixel Counter != 0) DrawCharX
      subi t1,1 // Decrement Character X Pixel Counter

      addi a0,(SCREEN_X*BYTES_PER_PIXEL)-CHAR_X*BYTES_PER_PIXEL // Jump down 1 Scanline, Jump back 1 Char
      lli t1,CHAR_X-1 // Reset Character X Pixel Counter
      bnez t2,{#}DrawHEXCharX // IF (Character Y Pixel Counter != 0) DrawCharX
      subi t2,1 // Decrement Character Y Pixel Counter

    li t6,((SCREEN_X*BYTES_PER_PIXEL)*CHAR_Y)-CHAR_X*BYTES_PER_PIXEL // Jump To Start Of Next Char
    sub a0,t6 // Jump To Start Of Next Char

    lli t2,CHAR_Y-1 // Reset Character Y Pixel Counter

    andi t4,t3,$F // T4 = 1st Nibble
    subi t5,t4,9
    bgtz t5,{#}HEXLettersB
    addi t4,$30 // Delay Slot
    j {#}HEXEndB
    nop // Delay Slot

    {#}HEXLettersB:
    addi t4,7
    {#}HEXEndB:

    sll t4,10 // Add Shift to Correct Position in Font (*256: CHAR_X*CHAR_Y*BYTES_PER_PIXEL)
    add t4,a1

    {#}DrawHEXCharXB:
      lw t5,0(t4) // Load Font Text Character Pixel
      addi t4,4
      sw t5,0(a0) // Store Font Text Character Pixel into Frame Buffer
      addi a0,4

      bnez t1,{#}DrawHEXCharXB // IF (Character X Pixel Counter != 0) DrawCharX
      subi t1,1 // Decrement Character X Pixel Counter

      addi a0,(SCREEN_X*BYTES_PER_PIXEL)-CHAR_X*BYTES_PER_PIXEL // Jump down 1 Scanline, Jump back 1 Char
      lli t1,CHAR_X-1 // Reset Character X Pixel Counter
      bnez t2,{#}DrawHEXCharXB // IF (Character Y Pixel Counter != 0) DrawCharX
      subi t2,1 // Decrement Character Y Pixel Counter

    li t6,((SCREEN_X*BYTES_PER_PIXEL)*CHAR_Y)-CHAR_X*BYTES_PER_PIXEL // Jump To Start Of Next Char
    sub a0,t6 // Jump To Start Of Next Char

    bnez t0,{#}DrawHEXChars // Continue to Print Characters
    subi t0,1 // Subtract Number of Text Characters to Print
}

Start:
  include "LIB/N64_GFX.INC" // Include Graphics Macros
  N64_INIT() // Run N64 Initialisation Routine

  ScreenPAL(640, 480, BPP32|INTERLACE|AA_MODE_2, $A0100000) // Screen PAL: 640x480, 32BPP, Interlace, Resample Only, DRAM Origin = $A0100000

  lui a0,$A010 // A0 = VRAM Start Offset
  la a1,$A0100000+((SCREEN_X*SCREEN_Y*BYTES_PER_PIXEL)-BYTES_PER_PIXEL) // A1 = VRAM End Offset
  lli t0,$000000FF // T0 = Black
ClearScreen:
  sw t0,0(a0)
  bne a0,a1,ClearScreen
  addi a0,4 // Delay Slot


  PrintString($A0100000,212,16,FontRed,CP09REGISTER,7) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,356,16,FontRed,VICURRENTLINE,16) // Print Text String To VRAM Using Font At X,Y Position


  PrintString($A0100000,0,32,FontBlack,PAGEBREAK,39) // Print Text String To VRAM Using Font At X,Y Position

  // INITIAL VALUES
  li t7,0
  li t9,0
  mfc0 t9,r9  //store for later use
  la t7,STOREWORD1
  sw t9,0(t7)
  //
  lui t3,VI_BASE
  lli t4,2
  lw t6,VI_V_CURRENT_LINE(t3)
  la t7,STOREWORD2
  sw t6,0(t7)


  // MTC0 RUN and corresponding immediate values
  li t7,0
  li t8,0
  mtc0 t8,r9
  mfc0 t8,r9
  la t7,STOREWORD3
  sw t8,0(t7)
  //
  lui t3,VI_BASE
  lli t4,2
  lw t6,VI_V_CURRENT_LINE(t3)
  la t7,STOREWORD4
  sw t6,0(t7)


  // Approximately 2,000 ops before reading CNT REGISTER and VI_V_CURRENT_LINE again
  lli t0,1
  lli t1,1000
  OPSLOOP1:
    bne t0,t1,OPSLOOP1
    addiu t0,1
  //
  li t7,0
  li t8,0
  mfc0 t8,r9
  la t7,STOREWORD5
  sw t8,0(t7)
  //
  lui t3,VI_BASE
  lli t4,2
  lw t6,VI_V_CURRENT_LINE(t3)
  la t7,STOREWORD6
  sw t6,0(t7)


  // Approximately another 2,000 ops before reading CNT REGISTER and VI_V_CURRENT_LINE again (4000 ops total)
  lli t0,1
  lli t1,1000
  OPSLOOP2:
    bne t0,t1,OPSLOOP2
    addiu t0,1
  //
  li t7,0
  li t8,0
  mfc0 t8,r9
  la t7,STOREWORD7
  sw t8,0(t7)
  //
  lui t3,VI_BASE
  lli t4,2
  lw t6,VI_V_CURRENT_LINE(t3)
  la t7,STOREWORD8
  sw t6,0(t7)


  // Approximately another 846,000 ops before reading CNT REGISTER and VI_V_CURRENT_LINE again (850,000 ops total)
  li t0,1
  li t1,423000
  OPSLOOP3:
    bne t0,t1,OPSLOOP3
    addiu t0,1
  //
  li t7,0
  li t8,0
  mfc0 t8,r9
  la t7,STOREWORD9
  sw t8,0(t7)
  //
  lui t3,VI_BASE
  lli t4,2
  lw t6,VI_V_CURRENT_LINE(t3)
  la t7,STOREWORD10
  sw t6,0(t7)


  // Approximately another 850,000 ops before reading CNT REGISTER and VI_V_CURRENT_LINE again (1,700,000 ops total)
  li t0,1
  li t1,425000
  OPSLOOP4:
    bne t0,t1,OPSLOOP4
    addiu t0,1
  //
  li t7,0
  li t8,0
  mfc0 t8,r9
  la t7,STOREWORD11
  sw t8,0(t7)
  //
  lui t3,VI_BASE
  lli t4,2
  lw t6,VI_V_CURRENT_LINE(t3)
  la t7,STOREWORD12
  sw t6,0(t7)


  // Restore old value of CP0_COUNT_REG to evaluate effect
  li t7,0
  li t8,0
  mtc0 t9,r9
  mfc0 t8,r9
  la t7,STOREWORD13
  sw t8,0(t7)
  //
  lui t3,VI_BASE
  lli t4,2
  lw t6,VI_V_CURRENT_LINE(t3)
  la t7,STOREWORD14
  sw t6,0(t7)


  //
  PrintString($A0100000,0,48,FontRed,INIT_VALS,10) // Print Text String To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,196,48,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,212,48,FontBlack,STOREWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,484,48,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,500,48,FontBlack,STOREWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,0,72,FontRed,MTC_T,10) // Print Text String To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,196,72,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,212,72,FontBlack,STOREWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,484,72,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,500,72,FontBlack,STOREWORD4,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,0,96,FontRed,OPS1,10) // Print Text String To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,196,96,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,212,96,FontBlack,STOREWORD5,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,484,96,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,500,96,FontBlack,STOREWORD6,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,0,120,FontRed,OPS2,10) // Print Text String To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,196,120,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,212,120,FontBlack,STOREWORD7,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,484,120,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,500,120,FontBlack,STOREWORD8,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,0,144,FontRed,OPS3,10) // Print Text String To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,196,144,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,212,144,FontBlack,STOREWORD9,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,484,144,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,500,144,FontBlack,STOREWORD10,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,0,168,FontRed,OPS4,10) // Print Text String To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,196,168,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,212,168,FontBlack,STOREWORD11,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,484,168,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,500,168,FontBlack,STOREWORD12,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,0,192,FontRed,OLD_VAL,10) // Print Text String To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,196,192,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,212,192,FontBlack,STOREWORD13,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,484,192,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,500,192,FontBlack,STOREWORD14,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //





  PrintString($A0100000,0,360,FontBlack,PAGEBREAK,39) // Print Text String To VRAM Using Font At X,Y Position


Loop:
  WaitScanline($1E0) // Wait For Scanline To Reach Vertical Blank
  WaitScanline($1E2)

  lli t0,$00000800 // Even Field
  sw t0,VI_Y_SCALE(a0)

  WaitScanline($1E0) // Wait For Scanline To Reach Vertical Blank
  WaitScanline($1E2)

  li t0,$02000800 // Odd Field
  sw t0,VI_Y_SCALE(a0)

  j Loop
  nop // Delay Slot

INIT_VALS:
  db "  INIT VALS"
MTC_T:
  db "   MTC0 RUN"
OPS1:
  db "+~2.0E3 OPS"
OPS2:
  db "+~4.0E3 OPS"
OPS3:
  db "+~8.5E5 OPS"
OPS4:
  db "+~1.7E6 OPS"
OLD_VAL:
  db "OLD CP0_CNT"

CP09REGISTER:
  db "CP09-CNT"
VICURRENTLINE:
  db "VI_V_CURRENT_LINE"
FAIL:
  db "FAIL"
PASS:
  db "PASS"

DOLLAR:
  db "$"

PAGEBREAK:
  db "----------------------------------------"

align(8) // Align 64-Bit
VALUEWORDA:
  dw -123456789
VALUEWORDB:
  dw 1


STOREWORD1:
  dw 0
STOREWORD2:
  dw 0
STOREWORD3:
  dw 0
STOREWORD4:
  dw 0
STOREWORD5:
  dw 0
STOREWORD6:
  dw 0
STOREWORD7:
  dw 0
STOREWORD8:
  dw 0
STOREWORD9:
  dw 0
STOREWORD10:
  dw 0
STOREWORD11:
  dw 0
STOREWORD12:
  dw 0
STOREWORD13:
  dw 0
STOREWORD14:
  dw 0

insert FontBlack, "FontBlack16x16.bin"
insert FontGreen, "FontGreen16x16.bin"
insert FontRed, "FontRed16x16.bin"
