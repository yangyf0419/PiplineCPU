<h1>Some notes about pipeline</h1>

<h2>Exception Handling</h2>
<div>
IF.Flush & ID.Flush：对于分支指令在EX阶段判断（提前判断也可以）， 在分支发生时刻取消ID和IF阶段的两条指令。<p style="text-decoration: underline;white-space: nowrap">不妨提前在ID阶段判断</p>这样可以不用在ID/EX里加入hazard判断，可以简化电路

IF.Flush：对于J类指令在ID阶段判断，并取消IF阶段指令。

IF.Flush 将 IF/ID 寄存器内的指令换成nop:
            
<code>sll $zero, $zero, 0</code>

ID.Flush 将 ID/EX 寄存器的指令换成nop:

<code>sll $zero, $zero, 0</code>
</div>

<h2>Detection Units</h2>
<div>
Hazard Detection Unit

Bypassing Unit
</div>

<h2>Register Part</h2>
<div>
IF/ID Register
    
    input: Flush, PC_Next, Instruction, Hazard_Detection

    output: PC, Instruction_data

    reg: Intruction_reg, PC_reg

    //arguable
    exception handling: if(Flush) Instruciton_data <= 32'b0;

    hazard handling: if(Hazard_Detection) Instruction_reg <= 32'b0;

ID/EX Register

    input: 

</div>