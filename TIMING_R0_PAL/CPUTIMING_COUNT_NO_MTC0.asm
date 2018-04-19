// N64 CPU Instruction Timing (PAL) using CP0 Count Register by pdrome
// Based heavily on N64 'Bare Metal' CPU Instruction Timing (PAL) Test Demo by krom (Peter Lemon):
arch n64.cpu
endian msb
output "CPUTIMING_COUNT_NO_MTC0.N64", create
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


  PrintString($A0100000,136,8,FontRed,CP09REGISTER1,5) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,272,8,FontRed,CP09REGISTER2,5) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,408,8,FontRed,CP09REGISTER3,5) // Print Text String To VRAM Using Font At X,Y Position
  PrintString($A0100000,560,8,FontRed,INSTPERVIHEX,4) // Print Text String To VRAM Using Font At X,Y Position


  PrintString($A0100000,0,24,FontBlack,PAGEBREAK,39) // Print Text String To VRAM Using Font At X,Y Position


  PrintString($A0100000,0,40,FontRed,ADD,2) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ADDWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,ADDWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ADDWAITEND:
    add t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,ADDWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,40,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,40,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,40,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,40,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,56,FontRed,ADDI,3) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ADDIWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,ADDIWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ADDIWAITEND:
    addi t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,ADDIWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,56,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,56,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,56,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,56,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,72,FontRed,ADDIU,4) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ADDIUWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,ADDIUWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ADDIUWAITEND:
    addiu t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,ADDIUWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,72,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,72,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,72,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,72,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,88,FontRed,ADDU,3) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ADDUWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,ADDUWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ADDUWAITEND:
    addu t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,ADDUWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,88,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,88,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,88,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,88,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,104,FontRed,AND,2) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ANDWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,ANDWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ANDWAITEND:
    and t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,ANDWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,104,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,104,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,104,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,104,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,120,FontRed,ANDI,3) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ANDIWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,ANDIWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  ANDIWAITEND:
    andi t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,ANDIWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,120,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,120,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,120,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,120,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,136,FontRed,DADD,3) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DADDWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DADDWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DADDWAITEND:
    dadd t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DADDWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,136,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,136,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,136,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,136,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,152,FontRed,DADDI,4) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DADDIWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DADDIWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DADDIWAITEND:
    daddi t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DADDIWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,152,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,152,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,152,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,152,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,168,FontRed,DADDIU,5) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DADDIUWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DADDIUWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DADDIUWAITEND:
    daddiu t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DADDIUWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Datan
  //
  PrintValue($A0100000,104,168,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,168,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,168,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,168,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,184,FontRed,DADDU,4) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DADDUWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DADDUWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DADDUWAITEND:
    daddu t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DADDUWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,184,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,184,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,184,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,184,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,200,FontRed,DDIV,3) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DDIVWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DDIVWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DDIVWAITEND:
    ddiv t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DDIVWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,200,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,200,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,200,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,200,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,216,FontRed,DDIVU,4) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DDIVUWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DDIVUWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DDIVUWAITEND:
    ddivu t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DDIVUWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,216,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,216,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,216,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,216,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,232,FontRed,DIV,2) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DIVWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DIVWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DIVWAITEND:
    div t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DIVWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,232,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,232,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,232,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,232,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,248,FontRed,DIVU,3) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DIVUWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DIVUWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DIVUWAITEND:
    divu t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DIVUWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,248,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,248,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,248,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,248,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,264,FontRed,DMULT,4) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DMULTWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DMULTWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DMULTWAITEND:
    dmult t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DMULTWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,264,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,264,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,264,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,264,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,280,FontRed,DMULTU,5) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DMULTUWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DMULTUWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DMULTUWAITEND:
    dmultu t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DMULTUWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,280,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,280,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,280,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,280,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,296,FontRed,DSLL,3) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSLLWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSLLWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSLLWAITEND:
    dsll t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSLLWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,296,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,296,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,296,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,296,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,312,FontRed,DSLL32,5) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSLL32WAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSLL32WAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSLL32WAITEND:
    dsll32 t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSLL32WAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,312,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,312,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,312,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,312,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,328,FontRed,DSLLV,4) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSLLVWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSLLVWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSLLVWAITEND:
    dsllv t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSLLVWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,328,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,328,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,328,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,328,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,344,FontRed,DSRA,3) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRAWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSRAWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRAWAITEND:
    dsra t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSRAWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,344,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,344,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,344,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,344,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,360,FontRed,DSRA32,5) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRA32WAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSRA32WAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRA32WAITEND:
    dsra32 t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSRA32WAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,360,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,360,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,360,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,360,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,376,FontRed,DSRAV,4) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRAVWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSRAVWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRAVWAITEND:
    dsrav t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSRAVWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,376,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,376,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,376,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,376,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,392,FontRed,DSRL,3) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRLWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSRLWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRLWAITEND:
    dsrl t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSRLWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,392,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,392,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,392,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,392,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,408,FontRed,DSRL32,5) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRL32WAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSRL32WAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRL32WAITEND:
    dsrl32 t1,1 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSRL32WAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,408,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,408,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,408,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,408,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,424,FontRed,DSRLV,4) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRLVWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSRLVWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSRLVWAITEND:
    dsrlv t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSRLVWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,424,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,424,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,424,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,424,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,440,FontRed,DSUB,3) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSUBWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSUBWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSUBWAITEND:
    dsub t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSUBWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,440,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,440,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,440,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,440,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //

  PrintString($A0100000,0,456,FontRed,DSUBU,4) // Print Text String To VRAM Using Font At X,Y Position
  lli t0,0 // T0 = Instruction Count
  la t1,VALUEWORDA // T1 = Word Data Offset
  lw t1,0(t1)      // T1 = Word Data
  la t2,VALUEWORDB // T2 = Word Data Offset
  lw t2,0(t2)      // T2 = Word Data
  lui t3,VI_BASE
  lli t4,2
  lli t5,$200
  li t7,0
  li t8,0
  //mtc0 t8,r9
  mfc0 t8,r9
  la t7,COUNTWORD1 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSUBUWAITSTART:
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t4,DSUBUWAITSTART // Wait For Scanline To Reach Start Of Vertical Blank
    nop // Delay Slot
  mfc0 t8,r9
  la t7,COUNTWORD2 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  DSUBUWAITEND:
    dsubu t1,t2 // Test Instruction
    lw t6,VI_V_CURRENT_LINE(t3) // T6 = Current Scan Line
    sync // Sync Load
    bne t6,t5,DSUBUWAITEND // Wait For Scanline To Reach End Of Vertical Blank
    addiu t0,1 // T0 = Instruction Count Word Data (Delay Slot)
  mfc0 t8,r9
  la t7,COUNTWORD3 // T1 = COUNTWORD Offset
  sw t8,0(t7) // COUNTWORD = Word Data
  la t1,COUNTWORD // T1 = COUNTWORD Offset
  sw t0,0(t1) // COUNTWORD = Word Data
  //
  PrintValue($A0100000,104,456,FontBlack,COUNTWORD1,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,240,456,FontBlack,COUNTWORD2,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,376,456,FontBlack,COUNTWORD3,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  PrintValue($A0100000,512,456,FontBlack,COUNTWORD,3) // Print HEX Chars To VRAM Using Font At X,Y Position
  //


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

ADD:
  db "ADD"
ADDI:
  db "ADDI"
ADDIU:
  db "ADDIU"
ADDU:
  db "ADDU"
AND:
  db "AND"
ANDI:
  db "ANDI"
DADD:
  db "DADD"
DADDI:
  db "DADDI"
DADDIU:
  db "DADDIU"
DADDU:
  db "DADDU"
DDIV:
  db "DDIV"
DDIVU:
  db "DDIVU"
DIV:
  db "DIV"
DIVU:
  db "DIVU"
DMULT:
  db "DMULT"
DMULTU:
  db "DMULTU"
DSLL:
  db "DSLL"
DSLL32:
  db "DSLL32"
DSLLV:
  db "DSLLV"
DSRA:
  db "DSRA"
DSRA32:
  db "DSRA32"
DSRAV:
  db "DSRAV"
DSRL:
  db "DSRL"
DSRL32:
  db "DSRL32"
DSRLV:
  db "DSRLV"
DSUB:
  db "DSUB"
DSUBU:
  db "DSUBU"
MULT:
  db "MULT"
MULTU:
  db "MULTU"
NOR:
  db "NOR"
OR:
  db "OR"
ORI:
  db "ORI"
SLL:
  db "SLL"
SLLV:
  db "SLLV"
SRA:
  db "SRA"
SRAV:
  db "SRAV"
SRL:
  db "SRL"
SRLV:
  db "SRLV"
SUB:
  db "SUB"
SUBU:
  db "SUBU"
XOR:
  db "XOR"
XORI:
  db "XORI"

CP09REGISTER1:
  db "CP0-91"
CP09REGISTER2:
  db "CP0-92"
CP09REGISTER3:
  db "CP0-93"
INSTPERVIHEX:
  db "Op/VI"
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

ADDCOUNT:
  dw $0000DB1C
ADDICOUNT:
  dw $0000DB1B
ADDIUCOUNT:
  dw $0000DB1C
ADDUCOUNT:
  dw $0000DB1B
ANDCOUNT:
  dw $0000DB1B
ANDICOUNT:
  dw $0000DB1C
DADDCOUNT:
  dw $0000DB1B
DADDICOUNT:
  dw $0000DB1C
DADDIUCOUNT:
  dw $0000DB1F
DADDUCOUNT:
  dw $0000DB1F
DDIVCOUNT:
  dw $00003EEC
DDIVUCOUNT:
  dw $00003EEC
DIVCOUNT:
  dw $00005E71
DIVUCOUNT:
  dw $00005E71
DMULTCOUNT:
  dw $0000B3B7
DMULTUCOUNT:
  dw $0000B3BA
DSLLCOUNT:
  dw $0000DB1B
DSLL32COUNT:
  dw $0000DB1C
DSLLVCOUNT:
  dw $0000DB1B
DSRACOUNT:
  dw $0000DB1C
DSRA32COUNT:
  dw $0000DB1F
DSRAVCOUNT:
  dw $0000DB1F
DSRLCOUNT:
  dw $0000DB1F
DSRL32COUNT:
  dw $0000DB1B
DSRLVCOUNT:
  dw $0000DB1B
DSUBCOUNT:
  dw $0000DB1F
DSUBUCOUNT:
  dw $0000DB1F

COUNTWORD:
  dw 0
COUNTWORD1:
  dw 0
COUNTWORD2:
  dw 0
COUNTWORD3:
  dw 0

insert FontBlack, "FontBlack16x16.bin"
insert FontGreen, "FontGreen16x16.bin"
insert FontRed, "FontRed16x16.bin"
