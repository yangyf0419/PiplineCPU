//Pipeline registers
`timescale 1ns/1ns

// IF/ID Register
module IF_ID_Register(sysclk,reset,flush,Hazard_Detection,PC_next,IF_Instruction,ID_Instruction,PC);

input sysclk,reset;
input flush;		//To deal with exception cases
input Hazard_Detection;		//To deal with branch and jump instructions
input [31:0] IF_Instruction;
input [31:0] PC_next;
output [31:0] ID_Instruction;
output [31:0] PC;

reg [31:0] Instruction_reg;
reg [31:0] PC_reg;
reg [31:0] ID_Instruction;
reg [31:0] PC;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		PC_reg <= 32'b0;
		Instruction_reg <= 32'b0;
		PC <= 32'h80000000;
	end
	else begin
		ID_Instruction <= Instruction_reg;
		if(Hazard_Detection) 
			Instruction_reg <= 32'b0;
		else
			Instruction_reg <= IF_Instruction;
		PC_reg <= PC_next;
		//Maybe some modification is in need here for exception handling
		PC <= PC_reg;
	end
end

endmodule


// ID/EX Register
module ID_EX_Register(sysclk,reset,flush,wholeSignal,
					IF_ID_RegisterRs,IF_ID_RegisterRt,IF_ID_RegisterRd,
					input_DataBusA,input_DataBusB,
					EX_ctrlSignal,WB_ctrlSignal,MEM_ctrlSignal,Rs,Rt,Rd,
					output_DataBusA,output_DataBusB);

input sysclk,reset;
input flush;		//To deal with exception cases
input [19:0] wholeSignal;	//the whole control signal
input [5:0] IF_ID_RegisterRs,IF_ID_RegisterRt,IF_ID_RegisterRd;
input [31:0] input_DataBusA,input_DataBusB;
output reg [14:0] EX_ctrlSignal;
output reg [1:0] MEM_ctrlSignal;
output reg [2:0] WB_ctrlSignal;
output reg [5:0] Rs,Rt,Rd;
output reg [31:0] output_DataBusA,output_DataBusB;

reg [14:0] EX_ctrlSignal_reg;
reg [1:0] MEM_ctrlSignal_reg;
reg [2:0] WB_ctrlSignal_reg;
reg [5:0] Rs_reg,Rt_reg,Rd_reg;
reg [31:0] Reg_DataBusA,Reg_DataBusB;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		EX_ctrlSignal_reg <= 15'b0;
		MEM_ctrlSignal_reg <= 2'b0;
		WB_ctrlSignal_reg <= 3'b0;
		Rs_reg <= 6'b0;
		Rt_reg <= 6'b0; 
		Rd_reg <= 6'b0;
		Reg_DataBusA <= 32'b0;
		Reg_DataBusB <= 32'b0;
	end
	else begin
		EX_ctrlSignal_reg <= wholeSignal[14:0];
		MEM_ctrlSignal_reg <= wholeSignal[16:15];
		WB_ctrlSignal_reg <= wholeSignal[19:17];
		EX_ctrlSignal <= EX_ctrlSignal_reg;
		MEM_ctrlSignal <= MEM_ctrlSignal_reg;
		WB_ctrlSignal <= WB_ctrlSignal_reg;

		Rs_reg <= IF_ID_RegisterRs;
		Rt_reg <= IF_ID_RegisterRt;
		Rd_reg <= IF_ID_RegisterRd;
		Rs <= Rs_reg;
		Rt <= Rt_reg;
		Rd <= Rd_reg;

		Reg_DataBusA <= input_DataBusA;
		Reg_DataBusB <= input_DataBusB;
		output_DataBusA <= Reg_DataBusA;
		output_DataBusB <= Reg_DataBusB;
	end
end

endmodule


// EX/MEM Register
module EX_MEM_Register(sysclk,reset,ID_EX_WB_ctrlSignal,ID_EX_MEM_ctrlSignal,
						EX_input_B,EX_ALUOut,EX_AddrC,)