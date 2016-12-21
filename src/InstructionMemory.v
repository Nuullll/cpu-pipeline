
module InstructionMemory(
    input rst_n,
    input [31:0] Address,
    output [31:0] Instruction
);

    reg [31:0] ROM [255:0];
    assign Instruction = ROM[Address[9:2]];

    always @(negedge rst_n) begin
        ROM[0] <= 32'h241c1001;
        // addiu $gp, $zero, 0x1001    # $gp: pointer of input data
        ROM[1] <= 32'h001ce400;
        // sll $gp, $gp, 16            # $gp = 0x10010000
        ROM[2] <= 32'h27970040;
        // addiu $s7, $gp, 0x40        # $s7 = 0x10010040: pointer of cipher key
        ROM[3] <= 32'h27960400;
        // addiu $s6, $gp, 0x400       # $s6 = 0x10010400: pointer of sbox
        ROM[4] <= 32'h24100040;
        // addiu $s0, $zero, 0x40
        ROM[5] <= 32'h2411008d;
        // addiu $s1, $zero, 0x8d         # initial RC[0] (0x8d*02 = 01)
        ROM[6] <= 32'h241202d0;
        // addiu $s2, $zero, 0x2d0            # end of loop
        ROM[7] <= 32'h02177820;
        // add $t7, $s0, $s7
        ROM[8] <= 32'h8de8fff0;
        // lw $t0, -16($t7)
        ROM[9] <= 32'h8de9fff4;
        // lw $t1, -12($t7)
        ROM[10] <= 32'h8deafff8;
        // lw $t2, -8($t7)
        ROM[11] <= 32'h8debfffc;
        // lw $t3, -4($t7)
        ROM[12] <= 32'h31ee003f;
        // andi $t6, $t7, 0x3f
        ROM[13] <= 32'h15c00019;
        // bne $t6, $zero, KeyExpansionNext
        ROM[14] <= 32'h00112020;
        // add $a0, $zero, $s1
        ROM[15] <= 32'h0c1000a6;
        // jal Multiply02
        ROM[16] <= 32'h00028820;
        // add $s1, $zero, $v0
        ROM[17] <= 32'h010b6026;
        // xor $t4, $t0, $t3
        ROM[18] <= 32'h010c4026;
        // xor $t0, $t0, $t4
        ROM[19] <= 32'h016c5826;
        // xor $t3, $t3, $t4
        ROM[20] <= 32'h010a6026;
        // xor $t4, $t0, $t2
        ROM[21] <= 32'h010c4026;
        // xor $t0, $t0, $t4
        ROM[22] <= 32'h014c5026;
        // xor $t2, $t2, $t4
        ROM[23] <= 32'h01096026;
        // xor $t4, $t0, $t1
        ROM[24] <= 32'h010c4026;
        // xor $t0, $t0, $t4
        ROM[25] <= 32'h012c4826;
        // xor $t1, $t1, $t4
        ROM[26] <= 32'h00084080;
        // sll $t0, $t0, 2
        ROM[27] <= 32'h02c84020;
        // add $t0, $s6, $t0
        ROM[28] <= 32'h8d080000;
        // lw $t0, 0($t0)
        ROM[29] <= 32'h00094880;
        // sll $t1, $t1, 2
        ROM[30] <= 32'h02c94820;
        // add $t1, $s6, $t1
        ROM[31] <= 32'h8d290000;
        // lw $t1, 0($t1)
        ROM[32] <= 32'h000a5080;
        // sll $t2, $t2, 2
        ROM[33] <= 32'h02ca5020;
        // add $t2, $s6, $t2
        ROM[34] <= 32'h8d4a0000;
        // lw $t2, 0($t2)
        ROM[35] <= 32'h000b5880;
        // sll $t3, $t3, 2
        ROM[36] <= 32'h02cb5820;
        // add $t3, $s6, $t3
        ROM[37] <= 32'h8d6b0000;
        // lw $t3, 0($t3)
        ROM[38] <= 32'h01114026;
        // xor $t0, $t0, $s1   # $t0 ^ RC[j]
        ROM[39] <= 32'h8decffc0;
        // lw $t4, -64($t7)
        ROM[40] <= 32'h01886026;
        // xor $t4, $t4, $t0
        ROM[41] <= 32'hadec0000;
        // sw $t4, 0($t7)
        ROM[42] <= 32'h8decffc4;
        // lw $t4, -60($t7)
        ROM[43] <= 32'h01896026;
        // xor $t4, $t4, $t1
        ROM[44] <= 32'hadec0004;
        // sw $t4, 4($t7)
        ROM[45] <= 32'h8decffc8;
        // lw $t4, -56($t7)
        ROM[46] <= 32'h018a6026;
        // xor $t4, $t4, $t2
        ROM[47] <= 32'hadec0008;
        // sw $t4, 8($t7)
        ROM[48] <= 32'h8decffcc;
        // lw $t4, -52($t7)
        ROM[49] <= 32'h018b6026;
        // xor $t4, $t4, $t3
        ROM[50] <= 32'hadec000c;
        // sw $t4, 12($t7)
        ROM[51] <= 32'h22100010;
        // add $s0, $s0, 0x10
        ROM[52] <= 32'h12120001;
        // beq $s0, $s2, AddRoundKey0
        ROM[53] <= 32'h08100007;
        // j KeyExpansionLoop
        ROM[54] <= 32'h2410003c;
        // addiu $s0, $zero, 0x3c
        ROM[55] <= 32'h021c7020;
        // add $t6, $s0, $gp
        ROM[56] <= 32'h02177820;
        // add $t7, $s0, $s7
        ROM[57] <= 32'h8dc80000;
        // lw $t0, 0($t6)      
        ROM[58] <= 32'h8de90000;
        // lw $t1, 0($t7)
        ROM[59] <= 32'h01094026;
        // xor $t0, $t0, $t1
        ROM[60] <= 32'hadc80000;
        // sw $t0, 0($t6)
        ROM[61] <= 32'h12000002;
        // beq $s0, $zero, RoundLoopInitial
        ROM[62] <= 32'h2210fffc;
        // addi $s0, $s0, -4
        ROM[63] <= 32'h08100037;
        // j AddRoundKey0Loop
        ROM[64] <= 32'h24150009;
        // addiu $s5, $zero, 9
        ROM[65] <= 32'h2410003c;
        // addiu $s0, $zero, 0x3c
        ROM[66] <= 32'h021c7020;
        // add $t6, $s0, $gp
        ROM[67] <= 32'h8dc80000;
        // lw $t0, 0($t6)
        ROM[68] <= 32'h00084080;
        // sll $t0, $t0, 2   
        ROM[69] <= 32'h02c86820;
        // add $t5, $s6, $t0   # address of sbox item
        ROM[70] <= 32'h8da90000;
        // lw $t1, 0($t5)
        ROM[71] <= 32'hadc90000;
        // sw $t1, 0($t6)
        ROM[72] <= 32'h12000002;
        // beq $s0, $zero, ShiftRows
        ROM[73] <= 32'h2210fffc;
        // addi $s0, $s0, -4
        ROM[74] <= 32'h08100042;
        // j SubBytesLoop
        ROM[75] <= 32'h8f880004;
        // lw $t0, 0x04($gp)
        ROM[76] <= 32'h8f890014;
        // lw $t1, 0x14($gp)
        ROM[77] <= 32'h8f8a0024;
        // lw $t2, 0x24($gp)
        ROM[78] <= 32'h8f8b0034;
        // lw $t3, 0x34($gp)
        ROM[79] <= 32'h010b6026;
        // xor $t4, $t0, $t3
        ROM[80] <= 32'h010c4026;
        // xor $t0, $t0, $t4
        ROM[81] <= 32'h016c5826;
        // xor $t3, $t3, $t4
        ROM[82] <= 32'h010a6026;
        // xor $t4, $t0, $t2
        ROM[83] <= 32'h010c4026;
        // xor $t0, $t0, $t4
        ROM[84] <= 32'h014c5026;
        // xor $t2, $t2, $t4
        ROM[85] <= 32'h01096026;
        // xor $t4, $t0, $t1
        ROM[86] <= 32'h010c4026;
        // xor $t0, $t0, $t4
        ROM[87] <= 32'h012c4826;
        // xor $t1, $t1, $t4
        ROM[88] <= 32'haf880004;
        // sw $t0, 0x04($gp)
        ROM[89] <= 32'haf890014;
        // sw $t1, 0x14($gp)
        ROM[90] <= 32'haf8a0024;
        // sw $t2, 0x24($gp)
        ROM[91] <= 32'haf8b0034;
        // sw $t3, 0x34($gp)
        ROM[92] <= 32'h8f880008;
        // lw $t0, 0x08($gp)
        ROM[93] <= 32'h8f890018;
        // lw $t1, 0x18($gp)
        ROM[94] <= 32'h8f8a0028;
        // lw $t2, 0x28($gp)
        ROM[95] <= 32'h8f8b0038;
        // lw $t3, 0x38($gp)
        ROM[96] <= 32'h010a6026;
        // xor $t4, $t0, $t2
        ROM[97] <= 32'h010c4026;
        // xor $t0, $t0, $t4
        ROM[98] <= 32'h014c5026;
        // xor $t2, $t2, $t4
        ROM[99] <= 32'h012b6026;
        // xor $t4, $t1, $t3
        ROM[100] <= 32'h012c4826;
        // xor $t1, $t1, $t4
        ROM[101] <= 32'h016c5826;
        // xor $t3, $t3, $t4
        ROM[102] <= 32'haf880008;
        // sw $t0, 0x08($gp)
        ROM[103] <= 32'haf890018;
        // sw $t1, 0x18($gp)
        ROM[104] <= 32'haf8a0028;
        // sw $t2, 0x28($gp)
        ROM[105] <= 32'haf8b0038;
        // sw $t3, 0x38($gp)
        ROM[106] <= 32'h8f88000c;
        // lw $t0, 0x0c($gp)
        ROM[107] <= 32'h8f89001c;
        // lw $t1, 0x1c($gp)
        ROM[108] <= 32'h8f8a002c;
        // lw $t2, 0x2c($gp)
        ROM[109] <= 32'h8f8b003c;
        // lw $t3, 0x3c($gp)
        ROM[110] <= 32'h01096026;
        // xor $t4, $t0, $t1
        ROM[111] <= 32'h010c4026;
        // xor $t0, $t0, $t4
        ROM[112] <= 32'h012c4826;
        // xor $t1, $t1, $t4
        ROM[113] <= 32'h010a6026;
        // xor $t4, $t0, $t2
        ROM[114] <= 32'h010c4026;
        // xor $t0, $t0, $t4
        ROM[115] <= 32'h014c5026;
        // xor $t2, $t2, $t4
        ROM[116] <= 32'h010b6026;
        // xor $t4, $t0, $t3
        ROM[117] <= 32'h010c4026;
        // xor $t0, $t0, $t4
        ROM[118] <= 32'h016c5826;
        // xor $t3, $t3, $t4
        ROM[119] <= 32'haf88000c;
        // sw $t0, 0x0c($gp)
        ROM[120] <= 32'haf89001c;
        // sw $t1, 0x1c($gp)
        ROM[121] <= 32'haf8a002c;
        // sw $t2, 0x2c($gp)
        ROM[122] <= 32'haf8b003c;
        // sw $t3, 0x3c($gp)
        ROM[123] <= 32'h12a00030;
        // beq $s5, $zero, AddRoundKey     # last round
        ROM[124] <= 32'h0810007d;
        // j MixColumns
        ROM[125] <= 32'h24140030;
        // addiu $s4, $zero, 0x30
        ROM[126] <= 32'h029c7820;
        // add $t7, $s4, $gp
        ROM[127] <= 32'h8df00000;
        // lw $s0, 0x00($t7)
        ROM[128] <= 32'h8df10004;
        // lw $s1, 0x04($t7)
        ROM[129] <= 32'h8df20008;
        // lw $s2, 0x08($t7)
        ROM[130] <= 32'h8df3000c;
        // lw $s3, 0x0c($t7)
        ROM[131] <= 32'h00102020;
        // add $a0, $zero, $s0
        ROM[132] <= 32'h0c1000a6;
        // jal Multiply02          # $v0 = 02*$a0
        ROM[133] <= 32'h00024020;
        // add $t0, $zero, $v0
        ROM[134] <= 32'h00112020;
        // add $a0, $zero, $s1
        ROM[135] <= 32'h0c1000a6;
        // jal Multiply02
        ROM[136] <= 32'h00024820;
        // add $t1, $zero, $v0
        ROM[137] <= 32'h00122020;
        // add $a0, $zero, $s2
        ROM[138] <= 32'h0c1000a6;
        // jal Multiply02
        ROM[139] <= 32'h00025020;
        // add $t2, $zero, $v0
        ROM[140] <= 32'h00132020;
        // add $a0, $zero, $s3
        ROM[141] <= 32'h0c1000a6;
        // jal Multiply02
        ROM[142] <= 32'h00025820;
        // add $t3, $zero, $v0
        ROM[143] <= 32'h01096026;
        // xor $t4, $t0, $t1
        ROM[144] <= 32'h01916026;
        // xor $t4, $t4, $s1
        ROM[145] <= 32'h01926026;
        // xor $t4, $t4, $s2
        ROM[146] <= 32'h01936026;
        // xor $t4, $t4, $s3
        ROM[147] <= 32'hadec0000;
        // sw $t4, 0x00($t7)
        ROM[148] <= 32'h02096026;
        // xor $t4, $s0, $t1
        ROM[149] <= 32'h018a6026;
        // xor $t4, $t4, $t2
        ROM[150] <= 32'h01926026;
        // xor $t4, $t4, $s2
        ROM[151] <= 32'h01936026;
        // xor $t4, $t4, $s3
        ROM[152] <= 32'hadec0004;
        // sw $t4, 0x04($t7)
        ROM[153] <= 32'h02116026;
        // xor $t4, $s0, $s1
        ROM[154] <= 32'h018a6026;
        // xor $t4, $t4, $t2
        ROM[155] <= 32'h018b6026;
        // xor $t4, $t4, $t3
        ROM[156] <= 32'h01936026;
        // xor $t4, $t4, $s3
        ROM[157] <= 32'hadec0008;
        // sw $t4, 0x08($t7)
        ROM[158] <= 32'h01106026;
        // xor $t4, $t0, $s0
        ROM[159] <= 32'h01916026;
        // xor $t4, $t4, $s1
        ROM[160] <= 32'h01926026;
        // xor $t4, $t4, $s2
        ROM[161] <= 32'h018b6026;
        // xor $t4, $t4, $t3
        ROM[162] <= 32'hadec000c;
        // sw $t4, 0x0c($t7)
        ROM[163] <= 32'h12800008;
        // beq $s4, $zero, AddRoundKey
        ROM[164] <= 32'h2294fff0;
        // addi $s4, $s4, -16
        ROM[165] <= 32'h0810007e;
        // j MixColumnsLoop
        ROM[166] <= 32'h000471c2;
        // srl $t6, $a0, 7     # get the MSB
        ROM[167] <= 32'h00041040;
        // sll $v0, $a0, 1     # $v0 = $a0 << 1
        ROM[168] <= 32'h11c00002;
        // beq $t6, $zero, Multiply02Return
        ROM[169] <= 32'h240e011b;
        // addiu $t6, $zero, 0x011b    # remove the out-range "1"
        ROM[170] <= 32'h004e1026;
        // xor $v0, $v0, $t6   # $v0 = $v0 ^ 0x011b
        ROM[171] <= 32'h03e00008;
        // jr $ra
        ROM[172] <= 32'h22f70040;
        // addi $s7, $s7, 0x40
        ROM[173] <= 32'h2410003c;
        // addiu $s0, $zero, 0x3c
        ROM[174] <= 32'h021c7020;
        // add $t6, $s0, $gp
        ROM[175] <= 32'h02177820;
        // add $t7, $s0, $s7
        ROM[176] <= 32'h8dc80000;
        // lw $t0, 0($t6)      
        ROM[177] <= 32'h8de90000;
        // lw $t1, 0($t7)
        ROM[178] <= 32'h01094026;
        // xor $t0, $t0, $t1
        ROM[179] <= 32'hadc80000;
        // sw $t0, 0($t6)
        ROM[180] <= 32'h12000002;
        // beq $s0, $zero, RoundLoopNext
        ROM[181] <= 32'h2210fffc;
        // addi $s0, $s0, -4
        ROM[182] <= 32'h081000ae;
        // j AddRoundKeyLoop
        ROM[183] <= 32'h12a00002;
        // beq $s5, $zero, Exit
        ROM[184] <= 32'h22b5ffff;
        // addi $s5, $s5, -1
        ROM[185] <= 32'h08100041;
        // j RoundLoop
        ROM[186] <= 32'h081000ba;
        // j Exit
    end
endmodule
