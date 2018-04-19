// N64 'Bare Metal' CPU Instruction Timing (NTSC) Test Demo by krom (Peter Lemon):
arch n64.cpu
endian msb
output "VI_FIELD_SWITCH.N64", create
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

  ScreenNTSC(640, 480, BPP32|INTERLACE|AA_MODE_2, $A0100000) // Screen NTSC: 640x480, 32BPP, Interlace, Resample Only, DRAM Origin = $A0100000

  lui a0,$A010 // A0 = VRAM Start Offset
  la a1,$A0100000+((SCREEN_X*SCREEN_Y*BYTES_PER_PIXEL)-BYTES_PER_PIXEL) // A1 = VRAM End Offset
  lli t0,$000000FF // T0 = Black
ClearScreen:
  sw t0,0(a0)
  bne a0,a1,ClearScreen
  addi a0,4 // Delay Slot



  PrintString($A0100000,0,16,FontBlack,PAGEBREAK,39) // Print Text String To VRAM Using Font At X,Y Position


  PrintString($A0100000,16,32,FontRed,FIELD1,6) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,0
  lli t5,512
  lli t8,520
  INITWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t8,INITWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  ADDWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,ADDWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  ADDWAITEND:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,ADDWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  ADDWAITEND1:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,ADDWAITEND1 // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD4 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  ADDWAITEND2:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,ADDWAITEND2 // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD5 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  ADDWAITEND3:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,ADDWAITEND3 // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD6 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  ADDWAITEND4:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,ADDWAITEND4 // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD7 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  ADDWAITEND5:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,ADDWAITEND5 // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD8 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data

  //
  PrintString($A0100000,140,32,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,156,32,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,300,32,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,316,32,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,460,32,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,476,32,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,140,56,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,156,56,FontBlack,COUNTWORD4,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,300,56,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,316,56,FontBlack,COUNTWORD5,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,460,56,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,476,56,FontBlack,COUNTWORD6,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,140,80,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,156,80,FontBlack,COUNTWORD7,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,300,80,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,316,80,FontBlack,COUNTWORD8,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //


  PrintString($A0100000,16,112,FontRed,FIELD2,6) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,0
  lli t5,512
  lli t8,519
  OINITWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t8,OINITWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  OADDWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,OADDWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  OADDWAITEND:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,OADDWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  OADDWAITEND1:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,OADDWAITEND1 // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD4 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  OADDWAITEND2:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,OADDWAITEND2 // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD5 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  OADDWAITEND3:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,OADDWAITEND3 // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD6 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  OADDWAITEND4:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,OADDWAITEND4 // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD7 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  OADDWAITEND5:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    beq t6,t9,OADDWAITEND5 // Wait For Scanline To Reach End Of Vertical Blank
    nop // T0 = Instruction Count Word Data (Delay Slot)
  la t7,COUNTWORD8 // T1 = COUNTWORD Offset
  sw t6,0(t7) // COUNTWORD = Word Data
  lli t9,0
  add t9,t9,t6

  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data

  //
  PrintString($A0100000,140,112,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,156,112,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,300,112,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,316,112,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,460,112,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,476,112,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,140,136,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,156,136,FontBlack,COUNTWORD4,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,300,136,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,316,136,FontBlack,COUNTWORD5,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,460,136,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,476,136,FontBlack,COUNTWORD6,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,140,160,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,156,160,FontBlack,COUNTWORD7,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //
  PrintString($A0100000,300,160,FontBlack,DOLLAR,0) // Print Text String To VRAM Using Font At X,Y Position
  PrintValue($A0100000,316,160,FontBlack,COUNTWORD8,3) // Print HEX Chars To VRAM Using Font At X,Y Position
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

FIELD1:
  db "FIELD 1"
FIELD2:
  db "FIELD 2"

DOLLAR:
  db "$"

PAGEBREAK:
  db "----------------------------------------"

align(8) // Align 64-Bit
VALUEWORDA:
  dw -123456789
VALUEWORDB:
  dw 1

COUNTWORD:
  dw 0
COUNTWORD1:
  dw 0
COUNTWORD2:
  dw 0
COUNTWORD3:
  dw 0
COUNTWORD4:
  dw 0
COUNTWORD5:
  dw 0
COUNTWORD6:
  dw 0
COUNTWORD7:
  dw 0
COUNTWORD8:
  dw 0

insert FontBlack, "FontBlack16x16.bin"
insert FontGreen, "FontGreen16x16.bin"
insert FontRed, "FontRed16x16.bin"
