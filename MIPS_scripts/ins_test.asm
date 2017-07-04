# ins_test.asm

lui $t0, -256 # $t0 = 0x00ff0000
addi $t1, $t0, 257 # $t1 = 0x00ff0101
srl $s0, $t1, 8 # $s0 = 0x0000ff01
sll $s1, $s0, 16 # $s1 = 0xff010000
sra $s2, $s1, 12 # $s2 = 0xfffff010
slt $s3, $s1, $s2 # $s3 = 0x00000001
sub $s4, $s3, $zero # $s4 = 0x00000001

L1:
blez $s4, L2
subu $s4, $s4, $s3 # $s4 = 0
jal L1
L2:
bltz $s4, L3
addiu $s4, $s4, -1 # $s4 = -1
nop
jr $ra # j L2
L3:
bgtz $s4, L4
addu $s4, $s4, $t1 # $s4 = 0x00ff0100
xor $s4, $s4, $s2 # $s4 = 0xff00f110
nor $s4, $s4, $s2 # $s4 = 0x00000eef
andi $s4, $s4, 271 # $s4 = 0x0000000f
sltiu $t2, $s2, 3 # $t2 = 0x00000000
slti $t3, $s2, 2 # $t3 = 0x00000001
or $t3, $t3, $s2 # $t3 = 0xfffff011
and $s4, $t3, $s4 # $s4 = 0x00000001
j L3
L4:
addi $t4, $zero, 92 # $t4 = 0x0000005C
sw $s2, 4($t4)
beq $s4, $s4, L6
L5: lw $t5, 4($t4) # $t5 = 0xfffff010
L6:
bne $s2, $t5, L5
jalr $ra, $t4








