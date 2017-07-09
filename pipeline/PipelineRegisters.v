//Pipeline registers
`timescale 1ns/1ns

/*
The interfaces of each module are arranged the way as follows:
	module xx_xx_Register({common input signal},
							{peculiar input signal},
							{output signal});
*/

// IF/ID Register
module IF_ID_Register(sysclk,reset,IF_ID_Write
					Hazard_Detection,IF_PC,IF_Instruction,
					ID_Instruction,ID_PC);

input sysclk,reset;
input IF_ID_Write;		// solve the problem of hazard
//input Hazard_Detection;		//To deal with branch and jump instructions
input [31:0] IF_Instruction;
input [31:0] IF_PC;
output reg [31:0] ID_Instruction;
output reg [31:0] ID_PC;

reg [31:0] Instruction_reg;
reg [31:0] PC_reg;
reg [31:0] ID_Instruction;
reg [31:0] ID_PC;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		PC_reg <= 32'h80000000;
		Instruction_reg <= 32'b0;
	end
	else begin
		if(IF_ID_Write)		Instruction_reg <= IF_Instruction;
		ID_Instruction <= Instruction_reg;
		/*if(Hazard_Detection) 
			Instruction_reg <= 32'b0;
			ID_Instruction <= 32'b0;
		else
			Instruction_reg <= IF_Instruction;
			ID_Instruction <= Instruction_reg;*/
		PC_reg <= IF_PC;
		ID_PC <= PC_reg;
	end
end

endmodule


// ID/EX Register
module ID_EX_Register(sysclk,reset,flush
					wholeSignal,IF_ID_RegisterRs,IF_ID_RegisterRt,IF_ID_RegisterRd,input_DataBusA,input_DataBusB,
					EX_ctrlSignal,WB_ctrlSignal,MEM_ctrlSignal,Rs,Rt,Rd,output_DataBusA,output_DataBusB);

input sysclk,reset;		
input flush;	// deal with branch hazzard
input [20:0] wholeSignal;	//the whole control signal
input [4:0] IF_ID_RegisterRs,IF_ID_RegisterRt,IF_ID_RegisterRd;
input [31:0] input_DataBusA,input_DataBusB;
output reg [15:0] EX_ctrlSignal;
output reg [1:0] MEM_ctrlSignal;
output reg [2:0] WB_ctrlSignal;
output reg [4:0] Rs,Rt,Rd;
output reg [31:0] output_DataBusA,output_DataBusB;

reg [14:0] EX_ctrlSignal_reg;
reg [1:0] MEM_ctrlSignal_reg;
reg [2:0] WB_ctrlSignal_reg;
reg [4:0] Rs_reg,Rt_reg,Rd_reg;
reg [31:0] Reg_DataBusA,Reg_DataBusB;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		EX_ctrlSignal_reg <= 15'b0;
		MEM_ctrlSignal_reg <= 2'b0;
		WB_ctrlSignal_reg <= 3'b0;
		Rs_reg <= 5'b0;
		Rt_reg <= 5'b0; 
		Rd_reg <= 5'b0;
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
// ID/EX Register END


// EX/MEM Register
module EX_MEM_Register(sysclk,reset,
						ID_EX_WB_ctrlSignal,ID_EX_MEM_ctrlSignal,EX_input_B,EX_ALUOut,EX_AddrC,RdMux,
						MEM_ALUOut,WB_ctrlSignal,MEM_ctrlSignal,AddrC,EX_MEM_RegisterRd,MEM_B);

input sysclk,reset;		
input [1:0] ID_EX_MEM_ctrlSignal;
input [2:0] ID_EX_WB_ctrlSignal;
input [31:0] EX_input_B,EX_ALUOut;
input [4:0] EX_AddrC,RdMux;
output reg [31:0] MEM_ALUOut,MEM_B;
output reg [1:0] MEM_ctrlSignal;
output reg [2:0] WB_ctrlSignal;
output reg [4:0] AddrC,EX_MEM_RegisterRd;

reg [4:0] AddrC_reg,Rd_reg;
reg [31:0] ALUOut_reg,B_reg;
reg [1:0] MEM_ctrlSignal_reg;
reg [2:0] WB_ctrlSignal_reg;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		AddrC_reg <= 5'b0;
		Rd_reg <= 5'b0;
		ALUOut_reg <= 32'b0;
		B_reg <= 32'b0;
		MEM_ctrlSignal_reg <= 2'b0;
		WB_ctrlSignal_reg <= 3'b0;
	end
	else begin
		AddrC_reg <= EX_AddrC;
		AddrC <= AddrC_reg;

		Rd_reg <= RdMux;
		EX_MEM_RegisterRd <= Rd_reg;

		ALUOut_reg <= EX_ALUOut;
		MEM_ALUOut <= ALUOut_reg;

		B_reg <= EX_input_B;
		MEM_B <= B_reg;

		MEM_ctrlSignal_reg <= ID_EX_MEM_ctrlSignal;
		MEM_ctrlSignal <= MEM_ctrlSignal_reg;

		WB_ctrlSignal_reg <= ID_EX_WB_ctrlSignal;
		WB_ctrlSignal <= WB_ctrlSignal_reg;
	end
end

endmodule
// EX/MEM Register END


// MEM/WB Register
module MEM_WB_Register(sysclk,reset,
						MEM_ALUOut,EX_MEM_WB_ctrlSignal,EX_MEM_RegisterRd,ReadData,AddrC_in
						WB_ctrlSignal,ReadData_Out,WB_ALUOut,MEM_WB_RegisterRd,AddrC_out);

input sysclk,reset;		
input [31:0] MEM_ALUOut;
input [2:0] EX_MEM_WB_ctrlSignal;
input [4:0] EX_MEM_RegisterRd;
input [31:0] ReadData;
input [4:0] AddrC_in;
output reg [31:0] ReadData_Out;
output reg [4:0] MEM_WB_RegisterRd;
output reg [2:0] WB_ctrlSignal;
output reg [31:0] WB_ALUOut;
output reg [4:0] AddrC_out;

reg [4:0] AddrC_reg;
reg [31:0] ReadData_reg;
reg [4:0] Rd_reg;
reg [2:0] WB_ctrlSignal_reg;
reg [31:0] ALUOut_reg;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		ReadData_reg <= 32'b0;
		Rd_reg <= 5'b0;
		WB_ctrlSignal_reg <= 3'b0;
		ALUOut_reg <= 32'b0;
		AddrC_reg <= 5'b0;
	end
	else begin
		ReadData_reg <= ReadData;
		ReadData_Out <= ReadData_reg;

		Rd_reg <= EX_MEM_RegisterRd;
		MEM_WB_RegisterRd <= Rd_reg;

		WB_ctrlSignal_reg <= EX_MEM_WB_ctrlSignal;
		WB_ctrlSignal <= WB_ctrlSignal_reg;

		ALUOut_reg <= MEM_ALUOut;
		WB_ALUOut <= ALUOut_reg;

		AddrC_reg <= AddrC_in;
		AddrC_out <= AddrC_reg;
	end
end

endmodule
// MEM/WB Register END



// Register part finished