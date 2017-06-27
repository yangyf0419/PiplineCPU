//单周期整体部分
`timescale 1ns/1ps

module MonocyclicCpu (reset, clk);
	input reset;
	input clk;

	reg [31:0] PC;
	wire [31:0] PC_next;
	always @(posedge clk or  negedge reset) begin
		if (~reset)
			PC <= 32'h00000000;
		else 
			PC <= PC_next;
	end

	
	wire [31:0] Instruction;
	InstructionMemory instruction_memory1(.Address(PC),.Instruction(Instruction));

	wire [2:0] PCSrc;
	wire [1:0] RegDst;
	wire RegWr;
	wire ALUSrc1;
	wire ALUSrc2;
	wire ALUFun;
	wire Sign;
	wire MemWrite;
	wire MemRead;
	wire [1:0] MemtoReg;	
	wire ExtOp;
	wire LUOp;
	wire [31:0] ALUOut;

	Control control1(
		.OpCode(Instruction[31:26]), .Funct(Instruction[5:0]),
		.PCSrc(PCSrc), .ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .RegDst(RegDst),
		.RegWr(RegWr), .ALUFun(ALUFun), .Sign(Sign), .MemWrite(MemWrite),
		.MemRead(MemRead), .MemtoReg(MemtoReg), .ExtOp(ExtOp),
		.LUOp(LUOp), .ALUOut(ALUOut)  );

	wire [31:0] DataBusA;
	wire [31:0] DataBusB;
	wire [31:0] DataBusC;
	wire [4:0] AddrC;
	wire [4:0] Xp;		//这里指定为常量26，即发生中断或者异常时，返回地址将保存到$26寄存器中
	wire [4:0] Ra;
	wire [4:0] Rd;
	wire [4:0] Rt;
	wire [4:0] Rs;
	wire [4:0] Shamt;		//位移量
	wire [15:0] Imm16;		//16位的立即数
	wire [25:0] JT;		//跳转到指定地址

	assign JT = Instruction[25:0];
	assign Imm16 = Instruction[15:0];
	assign Rd = Instruction[15:11];
	assign Rt = Instruction[20:16];
	assign Rs = Instruction[25:21];
	assign Shamt = Instruction[10:6];
	Xp <= 5'b11010;
	Ra <= 5'b11111;

	//Register FIle的Addrc
	assign AddrC = 
		(RegDst == 2'b00)? Rd : 
		(RegDst == 2'b01)? Rt :
		(RegDst == 2'b10)? Ra :
		Xp;

	RegisterFile register_file1(
		.WrC(RegWr), .AddrC(AddrC), .AddrA(Rs), 
		.AddrB(Rt), .ReadDataA(DataBusA), .ReadDataB(DataBusB),
		.WriteDataC(DataBusC)   );

	wire [31:0] Imm_deal;		//ALUSrc2对应的选择器的1输入口
	wire [31:0] ext_imm;		//EXT32的输出
	assign Imm_deal = (LUOp)? {Imm16 , 16'b0} : ;

	//ALU的两个输入
	wire [31:0] A;
	wire [31:0] B;

	assign A = (ALUSrc1)? {27'b0 , Shamt} : DataBusA;
	assign B = (ALUSrc2)?;

	//与PC相关的输入
	wire [31:0] PC_plus_4;
	wire ComBA;		//PC+4 与指令中 16 位立即数左移 2 位后的数值之和，对应branch
	wire DataBusA;		//$ra
	wire ILLOP;		//发生中断时，ILLOP（常量 0x80000004）
	wire XADR;		//发生异常时，XADR（常量 0x80000008）
	wire linkRegister;		//jalr的跳转地址
	wire [31:0] PC_deal;		//由ALUOut信号控制的选择器的输出

	ILLOP <= 32'h80000004;
	XADR <= 32'h80000008;

	
	assign PC_plus_4 = PC + 32'd4;
	assign PC_deal = (ALUOut[0])? ComBA : PC_plus_4;

	assign PC_next = 
		(PCSrc == 3'b000)? PC_plus_4 :
		(PCSrc == 3'b001)? PC_deal :
		(PCSrc == 3'b010)? JT :
		(PCSrc == 3'b011)? DataBusA :
		(PCSrc == 3'b100)? ILLOP :
		(PCSrc == 3'b101)? XADR : 
		(PCSrc == 3'b110)? linkRegister : 
		32'h00000000;

endmodule