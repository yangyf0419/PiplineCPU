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

output:
sw $a0, 12($t9) # ligh up LEDs

j begin


#----- Initialization ------#
initial: # setup at the begining of the program
addi $ra, $zero, 12 # set $ra as the first line of the program
lui $k1, 32768 # $k1 = 8'h80000000
lui $t9, 16384 # $t9 = 8'h40000000
addi $s7, $zero, 2 # $s7 = 8'h00000002

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