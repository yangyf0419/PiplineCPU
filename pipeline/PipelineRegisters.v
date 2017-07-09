//Pipeline registers
`timescale 1ns/1ns

/*
The interfaces of each module are arranged the way as follows:
	module xx_xx_Register({common input signal},
							{peculiar input signal},
							{output signal});
*/

// IF/ID Register
module IF_ID_Register(sysclk,reset,
					IF_ID_Write,IF_PC_plus_4,IF_Instruction,
					ID_Instruction,ID_PC_plus_4);

input sysclk,reset;
input IF_ID_Write;		// solve the problem of hazard
//input Hazard_Detection;		//To deal with branch and jump instructions
input [31:0] IF_Instruction;
input [31:0] IF_PC_plus_4;
output reg [31:0] ID_Instruction;
output reg [31:0] ID_PC_plus_4;

reg [31:0] Instruction_reg;
reg [31:0] PC_plus_4_reg;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		PC_plus_4_reg <= 32'h0;
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
		PC_plus_4_reg <= IF_PC_plus_4;
		ID_PC_plus_4 <= PC_plus_4_reg;
	end
end

endmodule


// ID/EX Register
module ID_EX_Register(sysclk,
					reset,
					wholeSignal,
					IF_ID_RegisterRs,
					IF_ID_RegisterRt,
					IF_ID_RegisterRd,
					input_DataBusA,
					input_DataBusB,
					ID_ConBA,
					ID_JT,
					ID_PC_plus_4,
					ID_DataBusA,
					ID_DataBusB,
					// output 
					EX_ctrlSignal,
					WB_ctrlSignal,
					MEM_ctrlSignal,
					Rs,Rt,Rd,
					output_DataBusA,
					output_DataBusB,
					EX_ConBA,
					EX_JT,
					EX_PC_plus_4,
					EX_DataBusA,
					EX_DataBusB);

input sysclk,reset;		
//input flush;	// deal with branch hazzard
input [16:0] wholeSignal;	//the whole control signal
input [4:0] IF_ID_RegisterRs,IF_ID_RegisterRt,IF_ID_RegisterRd;
input [31:0] input_DataBusA,input_DataBusB;
input [31:0] EX_ConBA,EX_PC_plus_4,ID_DataBusA,ID_DataBusB;
input [25:0] EX_JT;
output reg [31:0] EX_ConBA,EX_PC_plus_4;
output reg [25:0] EX_JT;
output reg [11:0] EX_ctrlSignal;
output reg [1:0] MEM_ctrlSignal;
output reg [2:0] WB_ctrlSignal;
output reg [4:0] Rs,Rt,Rd;
output reg [31:0] output_DataBusA,output_DataBusB,EX_DataBusA,EX_DataBusB;

reg [11:0] EX_ctrlSignal_reg;
reg [1:0] MEM_ctrlSignal_reg;
reg [2:0] WB_ctrlSignal_reg;
reg [4:0] Rs_reg,Rt_reg,Rd_reg;
reg [31:0] Reg_processed_DataBusA,Reg_processed_DataBusB;
reg [31:0] Reg_DataBusA,Reg_DataBusB;
reg [31:0] ConBA_reg,PC_plus_4_reg;
reg [25:0] JT_reg;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		EX_ctrlSignal_reg <= 11'b0;
		MEM_ctrlSignal_reg <= 2'b0;
		WB_ctrlSignal_reg <= 3'b0;
		Rs_reg <= 5'b0;
		Rt_reg <= 5'b0; 
		Rd_reg <= 5'b0;
		Reg_processed_DataBusA <= 32'b0;
		Reg_processed_DataBusB <= 32'b0;
		JT_reg <= 26'b0;
		ConBA_reg <= 32'b0;
		PC_plus_4_reg <= 32'b0;
		Reg_DataBusA <= 32'b0;
		Reg_DataBusB <= 32'b0;
	end
	else begin
		EX_ctrlSignal_reg <= wholeSignal[11:0];
		MEM_ctrlSignal_reg <= wholeSignal[13:12];
		WB_ctrlSignal_reg <= wholeSignal[16:14];
		EX_ctrlSignal <= EX_ctrlSignal_reg;
		MEM_ctrlSignal <= MEM_ctrlSignal_reg;
		WB_ctrlSignal <= WB_ctrlSignal_reg;

		Rs_reg <= IF_ID_RegisterRs;
		Rt_reg <= IF_ID_RegisterRt;
		Rd_reg <= IF_ID_RegisterRd;
		Rs <= Rs_reg;
		Rt <= Rt_reg;  
		Rd <= Rd_reg;

		Reg_processed_DataBusA <= input_DataBusA;
		Reg_processed_DataBusB <= input_DataBusB;
		output_DataBusA <= Reg_processed_DataBusA;
		output_DataBusB <= Reg_processed_DataBusB;

		JT_reg <= ID_JT;
		EX_JT <= JT_reg;

		ConBA_reg <= ID_ConBA;
		EX_ConBA <= ConBA_reg;

		PC_plus_4_reg <= ID_PC_plus_4;
		EX_PC_plus_4 <= PC_plus_4_reg;

		Reg_DataBusA <= ID_DataBusA;
		EX_DataBusA <= Reg_DataBusA;
		Reg_DataBusB <= ID_DataBusB;
		EX_DataBusB <= Reg_DataBusB;
	end
end

endmodule
// ID/EX Register END


// EX/MEM Register
module EX_MEM_Register(sysclk,
						reset,
						ID_EX_WB_ctrlSignal,
						ID_EX_MEM_ctrlSignal,
						EX_DataBusB,
						EX_ALUOut,
						EX_AddrC,
						EX_PC_plus_4,
						// output
						MEM_ALUOut,
						WB_ctrlSignal,
						MEM_ctrlSignal,
						EX_MEM_RegisterRd,
						MEM_DataBusB,
						MEM_PC_plus_4);

input sysclk,reset;		
input [1:0] ID_EX_MEM_ctrlSignal;
input [2:0] ID_EX_WB_ctrlSignal;
input [31:0] EX_DataBusB,EX_ALUOut,EX_PC_plus_4;
input [4:0] EX_AddrC;
output reg [31:0] MEM_ALUOut,MEM_DataBusB,MEM_PC_plus_4;
output reg [1:0] MEM_ctrlSignal;
output reg [2:0] WB_ctrlSignal;
output reg [4:0] EX_MEM_RegisterRd;

reg [4:0] AddrC_reg;
reg [31:0] ALUOut_reg,DataBusB_reg;
reg [1:0] MEM_ctrlSignal_reg;
reg [2:0] WB_ctrlSignal_reg;
reg [31:0] PC_plus_4_reg;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		AddrC_reg <= 5'b0;
		ALUOut_reg <= 32'b0;
		DataBusB_reg <= 32'b0;
		MEM_ctrlSignal_reg <= 2'b0;
		WB_ctrlSignal_reg <= 3'b0;
		PC_plus_4_reg <= 32'b0;
	end
	else begin
		AddrC_reg <= EX_AddrC;
		EX_MEM_RegisterRd <= AddrC_reg;

		ALUOut_reg <= EX_ALUOut;
		MEM_ALUOut <= ALUOut_reg;

		DataBusB_reg <= EX_DataBusB;
		MEM_DataBusB <= DataBusB_reg;

		MEM_ctrlSignal_reg <= ID_EX_MEM_ctrlSignal;
		MEM_ctrlSignal <= MEM_ctrlSignal_reg;

		WB_ctrlSignal_reg <= ID_EX_WB_ctrlSignal;
		WB_ctrlSignal <= WB_ctrlSignal_reg;

		PC_plus_4_reg <= EX_PC_plus_4;
		MEM_PC_plus_4 <= PC_plus_4_reg;
	end
end

endmodule
// EX/MEM Register END


// MEM/WB Register
module MEM_WB_Register(sysclk,
						reset,
						MEM_ALUOut,
						MEM_PC_plus_4,
						EX_MEM_WB_ctrlSignal,
						EX_MEM_RegisterRd,
						ReadData,
						// output
						WB_ctrlSignal,
						ReadData_Out,
						WB_ALUOut,
						MEM_WB_RegisterRd,
						WB_PC_plus_4);

input sysclk,reset;		
input [31:0] MEM_ALUOut;
input [31:0] MEM_PC_plus_4
input [2:0] EX_MEM_WB_ctrlSignal;
input [4:0] EX_MEM_RegisterRd;
input [31:0] ReadData;
output reg [31:0] ReadData_Out;
output reg [4:0] MEM_WB_RegisterRd;
output reg [2:0] WB_ctrlSignal;
output reg [31:0] WB_ALUOut;
output reg [31:0] WB_PC_plus_4;

reg [31:0] ReadData_reg;
reg [4:0] Rd_reg;
reg [2:0] WB_ctrlSignal_reg;
reg [31:0] ALUOut_reg;
reg [31:0] PC_plus_4_reg;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		ReadData_reg <= 32'b0;
		Rd_reg <= 5'b0;
		WB_ctrlSignal_reg <= 3'b0;
		ALUOut_reg <= 32'b0;
		PC_plus_4_reg <= 32'b0;
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

		PC_plus_4_reg <= MEM_PC_plus_4;
		WB_PC_plus_4 <= PC_plus_4_reg;
	end
end

endmodule
// MEM/WB Register END



// Register part finished