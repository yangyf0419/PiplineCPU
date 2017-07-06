# mcd.asm
# get the maximum common divisor of two 8-bit numbers

#---- Register Contents ----#
# $a0(4) - First Input Number
# $a1(5) - Second Input Number
#
# $s3(19) - A Mask to Reset Digitube - 8'h00000800
# $s4(20) - A Mask to Control Digitube - 8'h00000080
# $s5(21) - A Mask to Set TCON[1:0] to 11 - 8'h00000003
# $s6(22) - A Mask to Set UART_CON[0] to 1 - 8'h00000001
# $s7(23) - A Mask to Set UART_CON[1]/TCON[1] to 1 - 8'h00000002
# $t9(25) - Base of Peripheral - 8'h40000000
# $k0(26) - Next PC of Interruption / Exception
#----------- end -----------#

#----= Useful Constant =----#
# Set [1:0] to 0 - 8'hFFFFFFFC - (-4)
# Get [3] - 8'h00000008 - 8
# Get [2] - 8'h00000004 - 4
# Get [3:0] - 8'h0000000f - 15
# Set [2:1] to 0 - 8'hFFFFFFF9 - (-7)
# Address of low 4 bit of the first number - 0x00000080 - 128
# Address of high 4 bit of the first number - 0x00000100 - 256
# Address of low 4 bit of the second number - 0x00000200 - 512
# Address of high 4 bit of the second number - 0x00000400 - 1024
#----------- end -----------#
j initial
j interruption
j exception

begin:
sw $s7, 32($t9) # enable UART_RX
get_first:
lw $t0, 32($t9) # get UART_CON
andi $t1, $t0, 8 # get UART_CON[3]
beq $t1, $zero, get_first # if !RX_Status, keep on
andi $t0, $t0, -4
sw $t0, 32($t9) # stop receiving
lw $a0, 28($t9) # first Number
# line 10
andi $t0, $a0, 15 # low 4 bit of first number
sw $t0, 128($zero)
srl $t0, $a0, 4 # high 4 bit of first number
sw $t0, 256($zero)

sw $s7, 32($t9) # enable UART_RX
get_second:
lw $t0, 32($t9) # get UART_CON
andi $t1, $t0, 8 # get UART_CON[3]
beq $t1, $zero, get_second # if !RX_Status, keep on
andi $t0, $t0, -4
sw $t0, 32($t9) # stop receiving
# line 20
lw $a1, 28($t9) # second number
andi $t0, $a1, 15 # low 4 bit of second number
sw $t0, 512($zero)
srl $t0, $a1, 4 # high 4 bit of second number
sw $t0, 1024($zero)

# start the timer
addi $t0, $zero, -5000000
sw $t0, 0($t9)
addi $t0, $zero, -1
sw $t0, 4($t9)
sw $s5, 8($t9)

loop:
# line 30
beq $a0, $a1, output
sub $t0, $a0, $a1
bltz $t0, less
# if a0 > a1
sub $a0, $a0, $a1
j loop
# if a0 < a1
less:
sub $a1, $a1, $a0
j loop

output:
sw $a0, 12($t9) # ligh up LEDs
sw $a0, 24($t9)
sw $s6, 32($t9)
waiting:
# line 40
lw $t0, 32($t9) # get UART_CON
andi $t1, $t0, 4 # get UART_CON[2]
beq $t1, $zero, waiting # if !TX_Status, keep on
sw $t0, 32($t9) # stop sending

j begin


#----- Initialization ------#
initial: # setup at the begining of the program
addi $ra, $zero, 12 # set $ra as the first line of the program
lui $k1, 32768 # $k1 = 8'h80000000
lui $t9, 16384 # $t9 = 8'h40000000
addi $s7, $zero, 2 # $s7 = 8'h00000002
addi $s6, $zero, 1 # $s6 = 8'h00000001
addi $s5, $zero, 3 # $s5 = 8'h00000003
addi $s4, $zero, 128 # $s4 = 8'h00000080
addi $s3, $zero, 2048 # $s3 = 8'h00000800

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
lw $k1, 8($t9) # get TCON
andi $k1, $k1, -7
sw $k1, 8($t9) # stop timer
lw $k1, 0($s4) # get 4-bit number to be showed
lw $k1, 0($k1) # interpret the 4-bit number into 7-bit digitube level
add $k1, $k1, $s4 # use $k1 to control digitube at 0x40000014
sw $k1, 20($t9)
sll $s4, $s4, 1 # adjust the mask to get digitube
bne $s4, $s3, jump_one # if $s4 has been left-shifted 4 times
srl $s4, $s4, 4 # then shift back
jump_one:
lw $k1, 8($t9) # get TCON
or $k1, $k1, $s7
sw $k1, 8($t9) # start timer again
jr $26
#----------- end -----------#

#---- Exception Handler ----#
exception:
jr $26
#----------- end -----------#