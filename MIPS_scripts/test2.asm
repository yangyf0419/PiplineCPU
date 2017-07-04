addi $a0, $zero, 3 #(0x0003)
addi $sp, $sp, 256 #(0x0100)
jal sum
Loop:
beq $zero, $zero, Loop 
sum: 
addi $sp, $sp, -8 #(0xfff8)
sw $ra, 4($sp)
sw $a0, 0($sp) 
slti $t0, $a0, 1 #(0x0001)
beq $t0, $zero, L1 
xor $v0, $zero, $zero 
addi $sp, $sp, 8 
jr $ra 
L1:
addi $a0, $a0, -1 
jal sum 
lw $a0, 0($sp)  
lw $ra, 4($sp) 
addi $sp, $sp, 8 
add $v0, $a0, $v0 
jr $ra 