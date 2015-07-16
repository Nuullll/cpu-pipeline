
module InstructionMemory(Address, Instruction);
    input [31:0] Address;
    output reg [31:0] Instruction;

    always @(*)
        case (Address[9:2])
            // j       Reset
            8'd0: Instruction <= 32'h08000003;
            // j       Break
            8'd1: Instruction <= 32'h08000031;
            // j       Exception
            8'd2: Instruction <= 32'h0800007a;
            // addi    $gp,  $zero,  0
            8'd3: Instruction <= 32'h201c0000;
            // addi    $t0,  $zero,  0x0040
            8'd4: Instruction <= 32'h20080040;
            // sw      $t0,  0($gp)
            8'd5: Instruction <= 32'haf880000;
            // addi    $t0,  $zero,  0x0079
            8'd6: Instruction <= 32'h20080079;
            // sw      $t0,  4($gp)
            8'd7: Instruction <= 32'haf880004;
            // addi    $t0,  $zero,  0x0024
            8'd8: Instruction <= 32'h20080024;
            // sw      $t0,  8($gp)
            8'd9: Instruction <= 32'haf880008;
            // addi    $t0,  $zero,  0x0030
            8'd10: Instruction <= 32'h20080030;
            // sw      $t0,  12($gp)
            8'd11: Instruction <= 32'haf88000c;
            // addi    $t0,  $zero,  0x0019
            8'd12: Instruction <= 32'h20080019;
            // sw      $t0,  16($gp)
            8'd13: Instruction <= 32'haf880010;
            // addi    $t0,  $zero,  0x0012
            8'd14: Instruction <= 32'h20080012;
            // sw      $t0,  20($gp)
            8'd15: Instruction <= 32'haf880014;
            // addi    $t0,  $zero,  0x0002
            8'd16: Instruction <= 32'h20080002;
            // sw      $t0,  24($gp)
            8'd17: Instruction <= 32'haf880018;
            // addi    $t0,  $zero,  0x0078
            8'd18: Instruction <= 32'h20080078;
            // sw      $t0,  28($gp)
            8'd19: Instruction <= 32'haf88001c;
            // addi    $t0,  $zero,  0x0000
            8'd20: Instruction <= 32'h20080000;
            // sw      $t0,  32($gp)
            8'd21: Instruction <= 32'haf880020;
            // addi    $t0,  $zero,  0x0010
            8'd22: Instruction <= 32'h20080010;
            // sw      $t0,  36($gp)
            8'd23: Instruction <= 32'haf880024;
            // addi    $t0,  $zero,  0x0008
            8'd24: Instruction <= 32'h20080008;
            // sw      $t0,  40($gp)
            8'd25: Instruction <= 32'haf880028;
            // addi    $t0,  $zero,  0x0003
            8'd26: Instruction <= 32'h20080003;
            // sw      $t0,  44($gp)
            8'd27: Instruction <= 32'haf88002c;
            // addi    $t0,  $zero,  0x0046
            8'd28: Instruction <= 32'h20080046;
            // sw      $t0,  48($gp)
            8'd29: Instruction <= 32'haf880030;
            // addi    $t0,  $zero,  0x0021
            8'd30: Instruction <= 32'h20080021;
            // sw      $t0,  52($gp)
            8'd31: Instruction <= 32'haf880034;
            // addi    $t0,  $zero,  0x0006
            8'd32: Instruction <= 32'h20080006;
            // sw      $t0,  56($gp)
            8'd33: Instruction <= 32'haf880038;
            // addi    $t0,  $zero,  0x000e
            8'd34: Instruction <= 32'h2008000e;
            // sw      $t0,  60($gp)
            8'd35: Instruction <= 32'haf88003c;
            // lui     $s2,  0x4000
            8'd36: Instruction <= 32'h3c124000;
            // addi    $t0,  $zero,  0x00ff
            8'd37: Instruction <= 32'h200800ff;
            // sw      $t0,  20($s2)
            8'd38: Instruction <= 32'hae480014;
            // sw      $zero,  8($s2)
            8'd39: Instruction <= 32'hae400008;
            // addi    $t0,  $zero,  0xfff0
            8'd40: Instruction <= 32'h2008fff0;
            // sw      $t0,  0($s2)
            8'd41: Instruction <= 32'hae480000;
            // addi    $t0,  $zero,  0xffff
            8'd42: Instruction <= 32'h2008ffff;
            // sw      $t0,  4($s2)
            8'd43: Instruction <= 32'hae480004;
            // addi    $t0,  $zero,  3
            8'd44: Instruction <= 32'h20080003;
            // sw      $t0,  8($s2)
            8'd45: Instruction <= 32'hae480008;
            // addi    $s3,  $zero,  0x00c0
            8'd46: Instruction <= 32'h201300c0;
            // sll     $zero,  $zero,  0
            8'd47: Instruction <= 32'h00000000;
            // jr      $s3
            8'd48: Instruction <= 32'h02600008;
            // lw      $t0,  8($s2)
            8'd49: Instruction <= 32'h8e480008;
            // andi    $t0,  $t0,  0xfff9
            8'd50: Instruction <= 32'h3108fff9;
            // sw      $t0,  8($s2)
            8'd51: Instruction <= 32'hae480008;
            // addi    $a0,  $s0,  0
            8'd52: Instruction <= 32'h22040000;
            // addi    $a1,  $s1,  0
            8'd53: Instruction <= 32'h22250000;
            // beq     $a0,  $zero,  Scan
            8'd54: Instruction <= 32'h1080001e;
            // beq     $a1,  $zero,  Opr1zero
            8'd55: Instruction <= 32'h10a0001c;
            // addi    $t0,  $zero,  0
            8'd56: Instruction <= 32'h20080000;
            // addi    $t1,  $zero,  0
            8'd57: Instruction <= 32'h20090000;
            // addi    $t2,  $zero,  1
            8'd58: Instruction <= 32'h200a0001;
            // and     $t3,  $a0,  $t2
            8'd59: Instruction <= 32'h008a5824;
            // bne     $t3,  $zero,  Loop2
            8'd60: Instruction <= 32'h15600003;
            // addi    $t0,  $t0,  1
            8'd61: Instruction <= 32'h21080001;
            // srl     $a0,  $a0,  1
            8'd62: Instruction <= 32'h00042042;
            // j       Loop1
            8'd63: Instruction <= 32'h0800003b;
            // and     $t3,  $a1,  $t2
            8'd64: Instruction <= 32'h00aa5824;
            // bne     $t3,  $zero,  Loop3
            8'd65: Instruction <= 32'h15600003;
            // addi    $t1,  $t1,  1
            8'd66: Instruction <= 32'h21290001;
            // srl     $a1,  $a1,  1
            8'd67: Instruction <= 32'h00052842;
            // j       Loop2
            8'd68: Instruction <= 32'h08000040;
            // beq     $a0,  $a1,  Skip
            8'd69: Instruction <= 32'h10850007;
            // sub     $t3,  $a0,  $a1
            8'd70: Instruction <= 32'h00855822;
            // bgtz    $t3,  Positive
            8'd71: Instruction <= 32'h1d600003;
            // sub     $t3,  $a1,  $a0
            8'd72: Instruction <= 32'h00a45822;
            // addi    $a1,  $t3,  0
            8'd73: Instruction <= 32'h21650000;
            // j       Loop3
            8'd74: Instruction <= 32'h08000045;
            // addi    $a0,  $t3,  0
            8'd75: Instruction <= 32'h21640000;
            // j       Loop3
            8'd76: Instruction <= 32'h08000045;
            // sub     $t3,  $t1,  $t0
            8'd77: Instruction <= 32'h01285822;
            // bgtz    $t3,  Loop4
            8'd78: Instruction <= 32'h1d600001;
            // addi    $t0,  $t1,  0
            8'd79: Instruction <= 32'h21280000;
            // beq     $t0,  $zero,  Scan
            8'd80: Instruction <= 32'h11000004;
            // sub     $t0,  $t0,  $t2
            8'd81: Instruction <= 32'h010a4022;
            // sll     $a0,  $a0,  1
            8'd82: Instruction <= 32'h00042040;
            // j       Loop4
            8'd83: Instruction <= 32'h08000050;
            // addi    $a0,  $zero,  0
            8'd84: Instruction <= 32'h20040000;
            // addi    $v0,  $a0,  0
            8'd85: Instruction <= 32'h20820000;
            // sw      $v0,  12($s2)
            8'd86: Instruction <= 32'hae42000c;
            // lw      $t0,  20($s2)
            8'd87: Instruction <= 32'h8e480014;
            // srl     $t1,  $t0,  8
            8'd88: Instruction <= 32'h00084a02;
            // andi    $t1,  $t1,  0x000f
            8'd89: Instruction <= 32'h3129000f;
            // sll     $t1,  $t1,  1
            8'd90: Instruction <= 32'h00094840;
            // addi    $t2,  $zero,  0x0010
            8'd91: Instruction <= 32'h200a0010;
            // bne     $t1,  $t2,  Select
            8'd92: Instruction <= 32'h152a0001;
            // addi    $t1,  $zero,  0x0001
            8'd93: Instruction <= 32'h20090001;
            // addi    $t3,  $zero,  0x0001
            8'd94: Instruction <= 32'h200b0001;
            // addi    $t4,  $zero,  0x0002
            8'd95: Instruction <= 32'h200c0002;
            // addi    $t5,  $zero,  0x0004
            8'd96: Instruction <= 32'h200d0004;
            // addi    $t6,  $zero,  0x0008
            8'd97: Instruction <= 32'h200e0008;
            // beq     $t1,  $t3,  Digi1
            8'd98: Instruction <= 32'h112b0004;
            // beq     $t1,  $t4,  Digi2
            8'd99: Instruction <= 32'h112c0005;
            // beq     $t1,  $t5,  Digi3
            8'd100: Instruction <= 32'h112d0006;
            // beq     $t1,  $t6,  Digi4
            8'd101: Instruction <= 32'h112e0007;
            // addi    $t1,  $zero,  0x0001
            8'd102: Instruction <= 32'h20090001;
            // srl     $t2,  $s0,  4
            8'd103: Instruction <= 32'h00105102;
            // j       Display
            8'd104: Instruction <= 32'h0800006f;
            // andi    $t2,  $s0,  0x000f
            8'd105: Instruction <= 32'h320a000f;
            // j       Display
            8'd106: Instruction <= 32'h0800006f;
            // srl     $t2,  $s1,  4
            8'd107: Instruction <= 32'h00115102;
            // j       Display
            8'd108: Instruction <= 32'h0800006f;
            // andi    $t2,  $s1,  0x000f
            8'd109: Instruction <= 32'h322a000f;
            // j       Display
            8'd110: Instruction <= 32'h0800006f;
            // sll     $t2,  $t2,  2
            8'd111: Instruction <= 32'h000a5080;
            // add     $t3,  $gp,  $t2
            8'd112: Instruction <= 32'h038a5820;
            // lw      $t2,  0($t3)
            8'd113: Instruction <= 32'h8d6a0000;
            // sll     $t1,  $t1,  8
            8'd114: Instruction <= 32'h00094a00;
            // add     $t0,  $t1,  $t2
            8'd115: Instruction <= 32'h012a4020;
            // sw      $t0,  20($s2)
            8'd116: Instruction <= 32'hae480014;
            // lw      $t0,  8($s2)
            8'd117: Instruction <= 32'h8e480008;
            // addi    $t1,  $zero,  0x0002
            8'd118: Instruction <= 32'h20090002;
            // or      $t0,  $t0,  $t1
            8'd119: Instruction <= 32'h01094025;
            // sw      $t0,  8($s2)
            8'd120: Instruction <= 32'hae480008;
            // jr      $k0
            8'd121: Instruction <= 32'h03400008;
            // jr      $k1
            8'd122: Instruction <= 32'h03600008;
            default: Instruction <= 32'h00000000;
        endcase
endmodule
