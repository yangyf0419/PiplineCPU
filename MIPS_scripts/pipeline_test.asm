# pipeline_test.asm
# test pipeline hazard

# -------- initialization
addi $s1, $zero, 1
addi $s2, $zero, 2
addi $s3, $zero, 3

sw $s1, 0($zero)
sw $s2, 4($zero)
sw $s3, 8($zero)


# data hazard & structure hazard
# reference @ textbook P120 - P124
# -------- test 1
add $t0, $s1, $s2 # $t0 = 3
add $t1, $s1, $s3 # $t1 = 4
# data hazard #3-5 #1-5
add $t0, $t0, $t1 # $t0 = 7

# -------- test 2
lw $t0, 4($zero) # $t0 = 2
# structure hazard
add $t1, $s2, $s3 # $t1 = 5
# data hazard #2-5
add $t2, $t0, $s1 # $t2 = 3

# -------- test 3
lw $t0, 8($zero) # $t0 = 3
# data hazard #4-5
add $t2, $t0, $s1 # $t2 = 4

# -------- test 4
lw $t0, 4($zero) # $t0 = 2
# data hazard #4-6
sw $t0, 12($zero)
lw $t1, 12($zero)

# control hazard
# reference @ textbook P124 - P126
jal jump_back 
# addi $t2, $zero, 5
beq $s2, $t0, end
# addi $t0, $zero, 7
nop
jump_back:
nop
nop
jr $ra
end:
nop
j end