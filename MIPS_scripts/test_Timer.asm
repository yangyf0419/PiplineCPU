
j initial
j interruption
j exception

begin:
addi $t0, $zero, -5000000
sw $t0, 0($t9)
addi $t0, $zero, -1
sw $t0, 4($t9)
sw $s5, 8($t9)
loop:
lw $a0, 16($t9)
sw $a0, 12($t9) # ligh up LEDs
andi $t0, $a0, 15
sw $t0, 128($zero)
srl $t0, $a0, 4
sw $t0, 256($zero)
lw $k1, 0($s4) # get 4-bit number to be showed
sll $k1, $k1, 2
lw $k1, 0($k1) # interpret the 4-bit number into 7-bit digitube level
add $k1, $k1, $s4 # use $k1 to control digitube at 0x40000014
sw $k1, 20($t9)
sll $s4, $s4, 1 # adjust the mask to get digitube
bne $s4, $s3, jump_one # if $s4 has been left-shifted 4 times
srl $s4, $s4, 2 # then shift back
jump_one:
j loop

#----- Initialization ------#
initial: # setup at the begining of the program
addi $ra, $zero, 12 # set $ra as the first line of the program
lui $k1, 32768 # $k1 = 8'h80000000
lui $t9, 16384 # $t9 = 8'h40000000
addi $s7, $zero, 2 # $s7 = 8'h00000002
addi $s6, $zero, 1 # $s6 = 8'h00000001
addi $s5, $zero, 3 # $s5 = 8'h00000003
addi $s4, $zero, 128 # $s4 = 8'h00000080
addi $s3, $zero, 512 # $s3 = 8'h00000800

# Use Data Memory as BCD Module
# 7'b1000000
addi $t0, $zero, 64
sw $t0, 0($zero)
# 7'b1111001
addi $t0, $zero, 121
sw $t0, 4($zero)
# 7'b0100100
addi $t0, $zero, 36
sw $t0, 8($zero)
# 7'b0110000
addi $t0, $zero, 48
sw $t0, 12($zero)
# 7'b0011001
addi $t0, $zero, 25
sw $t0, 16($zero)
# 7'b0010010
addi $t0, $zero, 18
sw $t0, 20($zero)
# 7'b0000010
addi $t0, $zero, 2
sw $t0, 24($zero)
# 7'b1111000
addi $t0, $zero, 120
sw $t0, 28($zero)
# 7'b0000000
sw $zero, 32($zero)
# 7'b0010000
addi $t0, $zero, 16
sw $t0, 36($zero)
# 7'b0001000
addi $t0, $zero, 8
sw $t0, 40($zero)
# 7'b0000011
addi $t0, $zero, 3
sw $t0, 44($zero)
# 7'b1000110
addi $t0, $zero, 70
sw $t0, 48($zero)
# 7'b0100001
addi $t0, $zero, 33
sw $t0, 52($zero)
# 7'b0000110
addi $t0, $zero, 6
sw $t0, 56($zero)
# 7'b0001110
addi $t0, $zero, 14
sw $t0, 60($zero)

jr $ra # begin the normal program
#----------- end -----------#

#---- Interrupt Handler ----#
interruption:
jr $26
#----------- end -----------#

#---- Exception Handler ----#
exception:
jr $26
#----------- end -----------#