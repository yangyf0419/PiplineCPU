addi $a0, $zero, 12345 #(0x3039)
addiu $a1, $zero, -11215 #(0xd431)
sll $a2, $a1, 16
sra $a3, $a2, 16
beq $a3, $a1, L1
lui $a0, -11111 #(0xd499)
L1:
add $t0, $a2, $a0
sra $t1, $t0, 8
addi $t2, $zero, -12345 #(0xcfc7)
slt $v0, $a0, $t2
sltu $v1, $a0, $t2
Loop:
j Loop