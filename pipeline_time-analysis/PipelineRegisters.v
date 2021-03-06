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
	output reg [31:0] ID_Instruction;
	output reg [31:0] ID_PC_plus_4;

	always @(posedge sysclk or negedge reset) begin
		if (~reset) begin
			//PC_plus_4_reg <= 32'h80000004;
			ID_Instruction <= 32'b0;
		end
		else begin
			if(IF_Flush)	
				ID_Instruction <= 32'b0;
			else begin
				if(IF_ID_Write)		
					ID_Instruction <= IF_Instruction;
			end
			ID_PC_plus_4 <= IF_PC_plus_4;
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
					//input_DataBusB,
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
					//output_DataBusB,
					EX_ConBA,
					EX_PC_plus_4,
					EX_DataBusB,
					EX_ALUSrc2,
					EX_LUOut,
					EX_IRQ,
					EX_branchIRQ);

	input sysclk,reset;		
	//input flush;	// deal with branch hazzard
	input [15:0] wholeSignal;	//the whole control signal
	input [4:0] IF_ID_RegisterRs,IF_ID_RegisterRt,IF_ID_RegisterRd;
	input [31:0] input_DataBusA;//input_DataBusB;
	input [31:0] ID_ConBA,ID_PC_plus_4,ID_DataBusB;
	input ID_ALUSrc2;
	input [31:0] ID_LUOut;
	input ID_IRQ;
	input [1:0] ID_branchIRQ;

	output reg [31:0] EX_ConBA,EX_PC_plus_4;
	output reg [10:0] EX_ctrlSignal;
	output reg [1:0] MEM_ctrlSignal;
	output reg [2:0] WB_ctrlSignal;
	output reg [4:0] Rs,Rt,Rd;
	output reg [31:0] output_DataBusA,EX_DataBusB;
	output reg EX_ALUSrc2;
	output reg [31:0] EX_LUOut;
	output reg EX_IRQ;
	output reg [1:0] EX_branchIRQ;

	always @(posedge sysclk or negedge reset) begin
		if (~reset) begin
			EX_ctrlSignal <= 11'b0;
			MEM_ctrlSignal <= 2'b0;
			WB_ctrlSignal <= 3'b0;
			Rs <= 5'b0;
			Rt <= 5'b0; 
			Rd <= 5'b0;
			output_DataBusA <= 32'b0;
			//Reg_processed_DataBusB <= 32'b0;
			EX_ConBA <= 32'b0;
			EX_DataBusB <= 32'b0;
			EX_ALUSrc2 <= 0;
			EX_LUOut <= 32'b0;
		end
		else begin
			EX_ctrlSignal <= wholeSignal[10:0];
			MEM_ctrlSignal <= wholeSignal[12:11];
			WB_ctrlSignal <= wholeSignal[15:13];

			Rs <= IF_ID_RegisterRs;
			Rt <= IF_ID_RegisterRt;
			Rd <= IF_ID_RegisterRd;

			output_DataBusA <= input_DataBusA;

			EX_ConBA <= ID_ConBA;

			EX_PC_plus_4 <= ID_PC_plus_4;

			EX_DataBusB <= ID_DataBusB;

			EX_ALUSrc2 <= ID_ALUSrc2;

			EX_LUOut <= ID_LUOut;

			EX_IRQ <= ID_IRQ;

			EX_branchIRQ <= ID_branchIRQ;
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
						EX_IRQ,
						EX_branchIRQ,
						EX_B,
						EX_BOut,
						// output
						MEM_ALUOut,
						WB_ctrlSignal,
						MEM_ctrlSignal,
						EX_MEM_RegisterRd,
						MEM_DataBusB,
						MEM_PC_plus_4,
						MEM_IRQ,
						MEM_branchIRQ,
						MEM_B,
						MEM_BOut);

	input sysclk,reset;		
	input [1:0] ID_EX_MEM_ctrlSignal;
	input [2:0] ID_EX_WB_ctrlSignal;
	input [31:0] EX_DataBusB,EX_ALUOut,EX_PC_plus_4;
	input [4:0] EX_AddrC;
	input EX_IRQ;
	input [1:0] EX_branchIRQ;
	input EX_B;
	input EX_BOut;

	output reg [31:0] MEM_ALUOut,MEM_DataBusB;
	output reg [31:0] MEM_PC_plus_4;
	output reg [1:0] MEM_ctrlSignal;
	output reg [2:0] WB_ctrlSignal;
	output reg [4:0] EX_MEM_RegisterRd;
	output reg MEM_IRQ;
	output reg [1:0] MEM_branchIRQ;
	output reg MEM_B;
	output reg MEM_BOut;

	always @(posedge sysclk or negedge reset) begin
		if (~reset) begin
			EX_MEM_RegisterRd <= 5'b0;
			MEM_ALUOut <= 32'b0;
			MEM_DataBusB <= 32'b0;
			MEM_ctrlSignal <= 2'b0;
			WB_ctrlSignal <= 3'b0;
			MEM_IRQ <= 1'b0;
			MEM_branchIRQ <= 2'b0;
			MEM_B <= 1'b0;
			MEM_BOut <= 1'b0;
		end
		else begin
			EX_MEM_RegisterRd <= EX_AddrC;

			MEM_ALUOut <= EX_ALUOut;

			MEM_DataBusB <= EX_DataBusB;

			MEM_ctrlSignal <= ID_EX_MEM_ctrlSignal;

			WB_ctrlSignal <= ID_EX_WB_ctrlSignal;

			MEM_PC_plus_4 <= EX_PC_plus_4;

			MEM_IRQ <= EX_IRQ;
			MEM_branchIRQ <= EX_branchIRQ;
			MEM_B <= EX_B;
			MEM_BOut <= EX_BOut;
		end
	end

endmodule
// EX/MEM Register END


// MEM/WB Register
module MEM_WB_Register(sysclk,
						reset,
						MEM_RegWrite,
						MEM_DataBusC,
						EX_MEM_RegisterRd,
						MEM_IRQ,
						// output
						WB_RegWrite,
						WB_DataBusC,
						MEM_WB_RegisterRd,
						WB_IRQ);

	input sysclk,reset;	
	input MEM_RegWrite;
	input [31:0] MEM_DataBusC;
	input [4:0] EX_MEM_RegisterRd;
	input MEM_IRQ;

	output reg WB_RegWrite;
	output reg [31:0] WB_DataBusC;
	output reg [4:0] MEM_WB_RegisterRd;
	output reg WB_IRQ;

	always @(posedge sysclk or negedge reset) begin
		if (~reset) begin
			WB_RegWrite <= 1'b0;
			MEM_WB_RegisterRd <= 5'b0;
			WB_DataBusC <= 32'b0;
			WB_IRQ <= 0;
		end
		else begin
			WB_RegWrite <= MEM_RegWrite;

			MEM_WB_RegisterRd <= EX_MEM_RegisterRd;

			WB_DataBusC <= MEM_DataBusC;
			WB_IRQ <= MEM_IRQ;
		end
	end

endmodule
// MEM/WB Register END

// Register part finished