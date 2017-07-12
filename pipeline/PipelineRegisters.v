//Pipeline registers
`timescale 1ns/1ns

/*
The interfaces of each module are arranged the way as follows:
	module xx_xx_Register({common input signal},
							{peculiar input signal},
							{output signal});
*/

// IF/ID Register
module IF_ID_Register(sysclk,reset,IF_Flush,
					IF_ID_Write,IF_PC_plus_4,IF_Instruction,
					ID_Instruction,ID_PC_plus_4);

input sysclk,reset;
input IF_Flush;
input IF_ID_Write;		// solve the problem of hazard
//input Hazard_Detection;		//To deal with branch and jump instructions
input [31:0] IF_Instruction;
input [31:0] IF_PC_plus_4;
output [31:0] ID_Instruction;
output [31:0] ID_PC_plus_4;

reg [31:0] Instruction_reg;
reg [31:0] PC_plus_4_reg;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		//PC_plus_4_reg <= 32'h80000004;
		Instruction_reg <= 32'b0;
	end
	else begin
		if(IF_Flush)	
			Instruction_reg <= 32'b0;
		else begin
			if(IF_ID_Write)		
				Instruction_reg <= IF_Instruction;
		end
		PC_plus_4_reg <= IF_PC_plus_4;
	end
end

assign ID_Instruction = Instruction_reg;
assign ID_PC_plus_4 = PC_plus_4_reg;

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
					ID_PC_plus_4,
					ID_DataBusB,
					ID_ALUSrc2,
					ID_LUOut,
					ID_IRQ,
					ID_branchIRQ,
					// output 
					EX_ctrlSignal,
					WB_ctrlSignal,
					MEM_ctrlSignal,
					Rs,Rt,Rd,
					output_DataBusA,
					output_DataBusB,
					EX_ConBA,
					EX_PC_plus_4,
					EX_DataBusB,
					EX_ALUSrc2,
					EX_LUOut,
					EX_IRQ,
					EX_branchIRQ);

input sysclk,reset;		
//input flush;	// deal with branch hazzard
input [16:0] wholeSignal;	//the whole control signal
input [4:0] IF_ID_RegisterRs,IF_ID_RegisterRt,IF_ID_RegisterRd;
input [31:0] input_DataBusA,input_DataBusB;
input [31:0] ID_ConBA,ID_PC_plus_4,ID_DataBusB;
input ID_ALUSrc2;
input [31:0] ID_LUOut;
input ID_IRQ,ID_branchIRQ;

output [31:0] EX_ConBA,EX_PC_plus_4;
output [11:0] EX_ctrlSignal;
output [1:0] MEM_ctrlSignal;
output [2:0] WB_ctrlSignal;
output [4:0] Rs,Rt,Rd;
output [31:0] output_DataBusA,output_DataBusB,EX_DataBusB;
output EX_ALUSrc2;
output [31:0] EX_LUOut;
output EX_IRQ;
output reg EX_branchIRQ;

reg [11:0] EX_ctrlSignal_reg;
reg [1:0] MEM_ctrlSignal_reg;
reg [2:0] WB_ctrlSignal_reg;
reg [4:0] Rs_reg,Rt_reg,Rd_reg;
reg [31:0] Reg_processed_DataBusA,Reg_processed_DataBusB;
reg [31:0] Reg_DataBusB;
reg [31:0] ConBA_reg,PC_plus_4_reg;
reg ALUSrc2_reg;
reg [31:0] LUOut_reg;
reg IRQ_reg;

always @(posedge sysclk or negedge reset) begin
	if (~reset) begin
		EX_ctrlSignal_reg <= 12'b0;
		MEM_ctrlSignal_reg <= 2'b0;
		WB_ctrlSignal_reg <= 3'b0;
		Rs_reg <= 5'b0;
		Rt_reg <= 5'b0; 
		Rd_reg <= 5'b0;
		Reg_processed_DataBusA <= 32'b0;
		Reg_processed_DataBusB <= 32'b0;
		ConBA_reg <= 32'b0;
		//PC_plus_4_reg <= 32'h80000004;
		Reg_DataBusB <= 32'b0;
		ALUSrc2_reg <= 0;
		LUOut_reg <= 32'b0;
	end
	else begin
		EX_ctrlSignal_reg <= wholeSignal[11:0];
		MEM_ctrlSignal_reg <= wholeSignal[13:12];
		WB_ctrlSignal_reg <= wholeSignal[16:14];

		Rs_reg <= IF_ID_RegisterRs;
		Rt_reg <= IF_ID_RegisterRt;
		Rd_reg <= IF_ID_RegisterRd;

		Reg_processed_DataBusA <= input_DataBusA;
		Reg_processed_DataBusB <= input_DataBusB;

		ConBA_reg <= ID_ConBA;

		PC_plus_4_reg <= ID_PC_plus_4;

		Reg_DataBusB <= ID_DataBusB;

		ALUSrc2_reg <= ID_ALUSrc2;

		LUOut_reg <= ID_LUOut;

		IRQ_reg <= ID_IRQ;

		EX_branchIRQ <= ID_branchIRQ;
	end

end

	assign EX_ctrlSignal = EX_ctrlSignal_reg;
	assign MEM_ctrlSignal = MEM_ctrlSignal_reg;
	assign WB_ctrlSignal = WB_ctrlSignal_reg;
	assign Rs = Rs_reg;
	assign Rt = Rt_reg;
	assign Rd = Rd_reg;
	assign output_DataBusA = Reg_processed_DataBusA;
	assign output_DataBusB = Reg_processed_DataBusB;
	assign EX_ConBA = ConBA_reg;
	assign EX_PC_plus_4 = PC_plus_4_reg;
	assign EX_DataBusB = Reg_DataBusB;
	assign EX_ALUSrc2 = ALUSrc2_reg;
	assign EX_LUOut = LUOut_reg;
	assign EX_IRQ = IRQ_reg;

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
						EX_IRQ,
						EX_branchIRQ,
						// output
						MEM_ALUOut,
						WB_ctrlSignal,
						MEM_ctrlSignal,
						EX_MEM_RegisterRd,
						MEM_DataBusB,
						MEM_PC_plus_4,
						MEM_IRQ,
						MEM_branchIRQ);

input sysclk,reset;		
input [1:0] ID_EX_MEM_ctrlSignal;
input [2:0] ID_EX_WB_ctrlSignal;
input [31:0] EX_DataBusB,EX_ALUOut,EX_PC_plus_4;
input [4:0] EX_AddrC;
input EX_IRQ,EX_branchIRQ;

output [31:0] MEM_ALUOut,MEM_DataBusB,MEM_PC_plus_4;
output [1:0] MEM_ctrlSignal;
output [2:0] WB_ctrlSignal;
output [4:0] EX_MEM_RegisterRd;
output reg MEM_IRQ,MEM_branchIRQ;

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
		//PC_plus_4_reg <= 32'h80000004;
	end
	else begin
		AddrC_reg <= EX_AddrC;

		ALUOut_reg <= EX_ALUOut;

		DataBusB_reg <= EX_DataBusB;

		MEM_ctrlSignal_reg <= ID_EX_MEM_ctrlSignal;

		WB_ctrlSignal_reg <= ID_EX_WB_ctrlSignal;

		PC_plus_4_reg <= EX_PC_plus_4;

		MEM_IRQ <= EX_IRQ;
		MEM_branchIRQ <= EX_branchIRQ;
	end



end

	assign EX_MEM_RegisterRd = AddrC_reg;
	assign MEM_ALUOut = ALUOut_reg;
	assign MEM_DataBusB = DataBusB_reg;
	assign MEM_ctrlSignal = MEM_ctrlSignal_reg;
	assign WB_ctrlSignal = WB_ctrlSignal_reg;
	assign MEM_PC_plus_4 = PC_plus_4_reg;

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
						MEM_IRQ,
						MEM_branchIRQ,
						// output
						WB_ctrlSignal,
						ReadData_Out,
						WB_ALUOut,
						MEM_WB_RegisterRd,
						WB_PC_plus_4,
						WB_IRQ,
						WB_branchIRQ);

input sysclk,reset;		
input [31:0] MEM_ALUOut;
input [31:0] MEM_PC_plus_4;
input [2:0] EX_MEM_WB_ctrlSignal;
input [4:0] EX_MEM_RegisterRd;
input [31:0] ReadData;
input MEM_IRQ,MEM_branchIRQ;

output [31:0] ReadData_Out;
output [4:0] MEM_WB_RegisterRd;
output [2:0] WB_ctrlSignal;
output [31:0] WB_ALUOut;
output [31:0] WB_PC_plus_4;
output reg WB_IRQ,WB_branchIRQ;

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
		//PC_plus_4_reg <= 32'h80000004;
	end
	else begin
		ReadData_reg <= ReadData;

		Rd_reg <= EX_MEM_RegisterRd;

		WB_ctrlSignal_reg <= EX_MEM_WB_ctrlSignal;

		ALUOut_reg <= MEM_ALUOut;

		PC_plus_4_reg <= MEM_PC_plus_4;

		WB_IRQ <= MEM_IRQ;
		WB_branchIRQ <= MEM_branchIRQ;
	end

end

	assign ReadData_Out = ReadData_reg;
	assign MEM_WB_RegisterRd = Rd_reg;
	assign WB_ctrlSignal = WB_ctrlSignal_reg;
	assign WB_ALUOut = ALUOut_reg;
	assign WB_PC_plus_4 = PC_plus_4_reg;

endmodule
// MEM/WB Register END



// Register part finished