j initial
j interruption
j exception
begin:
addi $a0, $zero, 12345 #(0x3039)
sw $a0, 12($t9)
addiu $a1, $zero, -11215 #(0xd431)
sw $a1, 12($t9)      
sll $a2, $a1, 16 
sw $a2, 12($t9)    
sra $a3, $a2, 16 
sw $a3, 12($t9)     
beq $a3, $a1, L1 
lui $a0, -11111 #(0xd499)
L1:
add $t0, $a2, $a0 
sw $t0, 12($t9) 
sra $t1, $t0, 8  
sw $t1, 12($t9)       
addi $t2, $zero, -12345 #(0xcfc7)
sw $t2, 12($t9)      
slt $v0, $a0, $t2
sw $v0, 12($t9)      
sltu $v1, $a0, $t2
sw $v1, 12($t9)         
Loop:
j Loop

initial:
addi $ra, $zero, 12
lui $t9, 16384
jr $ra
interruption:
jr $26
exception:
jr $26