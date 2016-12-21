# aes.asm

# data
.data 0x10010000
# Input 
.word 0x32, 0x43, 0xf6, 0xa8, 0x88, 0x5a, 0x30, 0x8d, 0x31, 0x31, 0x98, 0xa2, 0xe0, 0x37, 0x07, 0x34
# Cipher key
.word 0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c

# sbox
# Address [0x10010400,0x10010800)
.data 0x10010400
.word 0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76, 0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0, 0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15, 0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75, 0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84, 0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf, 0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8, 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2, 0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73, 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb, 0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79, 0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08, 0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a, 0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e, 0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf, 0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16

.text
# Read input data pointer
Initial:
    addiu $gp, $zero, 0x1001    # $gp: pointer of input data
    sll $gp, $gp, 16            # $gp = 0x10010000
    addiu $s7, $gp, 0x40        # $s7 = 0x10010040: pointer of cipher key
    addiu $s6, $gp, 0x400       # $s6 = 0x10010400: pointer of sbox


KeyExpansion:
    addiu $s0, $zero, 0x40
    addiu $s1, $zero, 0x8d         # initial RC[0] (0x8d*02 = 01)
    addiu $s2, $zero, 0x2d0            # end of loop
KeyExpansionLoop:
    add $t7, $s0, $s7
    lw $t0, -16($t7)
    lw $t1, -12($t7)
    lw $t2, -8($t7)
    lw $t3, -4($t7)
    andi $t6, $t7, 0x3f
    bne $t6, $zero, KeyExpansionNext

    # i = multiple of 4
    # RC[j+1] = RC[j] * 02
    add $a0, $zero, $s1
    jal Multiply02
    add $s1, $zero, $v0
    # e.g. before: 0, 1, 2, 3
    # swap $t0, $t3
    # after: 3, 1, 2, 0
    xor $t4, $t0, $t3
    xor $t0, $t0, $t4
    xor $t3, $t3, $t4
    # swap $t0, $t2
    # after: 2, 1, 3, 0
    xor $t4, $t0, $t2
    xor $t0, $t0, $t4
    xor $t2, $t2, $t4
    # swap $t0, $t1
    # after: 1, 2, 3, 0
    xor $t4, $t0, $t1
    xor $t0, $t0, $t4
    xor $t1, $t1, $t4

    # SubBytes
    sll $t0, $t0, 2
    add $t0, $s6, $t0
    lw $t0, 0($t0)
    sll $t1, $t1, 2
    add $t1, $s6, $t1
    lw $t1, 0($t1)
    sll $t2, $t2, 2
    add $t2, $s6, $t2
    lw $t2, 0($t2)
    sll $t3, $t3, 2
    add $t3, $s6, $t3
    lw $t3, 0($t3)

    xor $t0, $t0, $s1   # $t0 ^ RC[j]

KeyExpansionNext:
    # w[i-4] ^ temp
    lw $t4, -64($t7)
    xor $t4, $t4, $t0
    sw $t4, 0($t7)

    lw $t4, -60($t7)
    xor $t4, $t4, $t1
    sw $t4, 4($t7)

    lw $t4, -56($t7)
    xor $t4, $t4, $t2
    sw $t4, 8($t7)

    lw $t4, -52($t7)
    xor $t4, $t4, $t3
    sw $t4, 12($t7)

    add $s0, $s0, 0x10
    beq $s0, $s2, AddRoundKey0
    j KeyExpansionLoop


# Round 0:
AddRoundKey0:
    # AddRoundKey(state, w[0,3])
    addiu $s0, $zero, 0x3c
AddRoundKey0Loop:
    add $t6, $s0, $gp
    add $t7, $s0, $s7
    lw $t0, 0($t6)      
    lw $t1, 0($t7)
    xor $t0, $t0, $t1
    sw $t0, 0($t6)

    beq $s0, $zero, RoundLoopInitial
    addi $s0, $s0, -4
    j AddRoundKey0Loop

RoundLoopInitial:
    addiu $s5, $zero, 9
RoundLoop:
# Round 1:
SubBytes:
    # SubBytes(state)
    addiu $s0, $zero, 0x3c
SubBytesLoop:
    add $t6, $s0, $gp
    lw $t0, 0($t6)
    sll $t0, $t0, 2   
    add $t5, $s6, $t0   # address of sbox item
    lw $t1, 0($t5)
    sw $t1, 0($t6)

    beq $s0, $zero, ShiftRows
    addi $s0, $s0, -4
    j SubBytesLoop

ShiftRows:
    # Row 0: Doing nothing
    # Row 1:
    lw $t0, 0x04($gp)
    lw $t1, 0x14($gp)
    lw $t2, 0x24($gp)
    lw $t3, 0x34($gp)
    # e.g. before: 0, 1, 2, 3
    # swap $t0, $t3
    # after: 3, 1, 2, 0
    xor $t4, $t0, $t3
    xor $t0, $t0, $t4
    xor $t3, $t3, $t4
    # swap $t0, $t2
    # after: 2, 1, 3, 0
    xor $t4, $t0, $t2
    xor $t0, $t0, $t4
    xor $t2, $t2, $t4
    # swap $t0, $t1
    # after: 1, 2, 3, 0
    xor $t4, $t0, $t1
    xor $t0, $t0, $t4
    xor $t1, $t1, $t4

    sw $t0, 0x04($gp)
    sw $t1, 0x14($gp)
    sw $t2, 0x24($gp)
    sw $t3, 0x34($gp)

    # Row 2:
    lw $t0, 0x08($gp)
    lw $t1, 0x18($gp)
    lw $t2, 0x28($gp)
    lw $t3, 0x38($gp)
    # e.g. before: 0, 1, 2, 3
    # swap $t0, $t2
    # after: 2, 1, 0, 3
    xor $t4, $t0, $t2
    xor $t0, $t0, $t4
    xor $t2, $t2, $t4
    # swap $t1, $t3
    # after: 2, 3, 0, 1
    xor $t4, $t1, $t3
    xor $t1, $t1, $t4
    xor $t3, $t3, $t4

    sw $t0, 0x08($gp)
    sw $t1, 0x18($gp)
    sw $t2, 0x28($gp)
    sw $t3, 0x38($gp)

    # Row 3:
    lw $t0, 0x0c($gp)
    lw $t1, 0x1c($gp)
    lw $t2, 0x2c($gp)
    lw $t3, 0x3c($gp)
    # e.g. before: 0, 1, 2, 3
    # swap $t0, $t1
    # after: 1, 0, 2, 3
    xor $t4, $t0, $t1
    xor $t0, $t0, $t4
    xor $t1, $t1, $t4
    # swap $t0, $t2
    # after: 2, 0, 1, 3
    xor $t4, $t0, $t2
    xor $t0, $t0, $t4
    xor $t2, $t2, $t4
    # swap $t0, $t3
    # after: 3, 0, 1, 2
    xor $t4, $t0, $t3
    xor $t0, $t0, $t4
    xor $t3, $t3, $t4

    sw $t0, 0x0c($gp)
    sw $t1, 0x1c($gp)
    sw $t2, 0x2c($gp)
    sw $t3, 0x3c($gp)

    beq $s5, $zero, AddRoundKey     # last round
    j MixColumns


MixColumns:
    addiu $s4, $zero, 0x30
MixColumnsLoop:
    add $t7, $s4, $gp
    lw $s0, 0x00($t7)
    lw $s1, 0x04($t7)
    lw $s2, 0x08($t7)
    lw $s3, 0x0c($t7)

    add $a0, $zero, $s0
    jal Multiply02          # $v0 = 02*$a0
    add $t0, $zero, $v0

    add $a0, $zero, $s1
    jal Multiply02
    add $t1, $zero, $v0

    add $a0, $zero, $s2
    jal Multiply02
    add $t2, $zero, $v0

    add $a0, $zero, $s3
    jal Multiply02
    add $t3, $zero, $v0

    xor $t4, $t0, $t1
    xor $t4, $t4, $s1
    xor $t4, $t4, $s2
    xor $t4, $t4, $s3
    sw $t4, 0x00($t7)

    xor $t4, $s0, $t1
    xor $t4, $t4, $t2
    xor $t4, $t4, $s2
    xor $t4, $t4, $s3
    sw $t4, 0x04($t7)

    xor $t4, $s0, $s1
    xor $t4, $t4, $t2
    xor $t4, $t4, $t3
    xor $t4, $t4, $s3
    sw $t4, 0x08($t7)

    xor $t4, $t0, $s0
    xor $t4, $t4, $s1
    xor $t4, $t4, $s2
    xor $t4, $t4, $t3
    sw $t4, 0x0c($t7)

    beq $s4, $zero, AddRoundKey
    addi $s4, $s4, -16
    j MixColumnsLoop

Multiply02: 
    # $v0 = 02*$a0
    srl $t6, $a0, 7     # get the MSB
    sll $v0, $a0, 1     # $v0 = $a0 << 1
    beq $t6, $zero, Multiply02Return
    addiu $t6, $zero, 0x011b    # remove the out-range "1"
    xor $v0, $v0, $t6   # $v0 = $v0 ^ 0x011b

Multiply02Return:
    jr $ra


AddRoundKey:
    addi $s7, $s7, 0x40
    addiu $s0, $zero, 0x3c
AddRoundKeyLoop:
    add $t6, $s0, $gp
    add $t7, $s0, $s7
    lw $t0, 0($t6)      
    lw $t1, 0($t7)
    xor $t0, $t0, $t1
    sw $t0, 0($t6)

    beq $s0, $zero, RoundLoopNext
    addi $s0, $s0, -4
    j AddRoundKeyLoop


RoundLoopNext:
    beq $s5, $zero, Exit
    addi $s5, $s5, -1
    j RoundLoop


Exit:
    j Exit




