// hazard_units.v
// flush_detection_units.v
// hazard_detection_unit, bypassing_unit

// check

module hazard_detection_unit(ID_EX_MemRead,
							ID_EX_RegisterRt,
							IF_ID_RegisterRs,
							IF_ID_RegisterRt,
							// output
							IF_ID_Write,
							PC_Write,
							ctrl_Mux);

input ID_EX_MemRead;
input [4:0] ID_EX_RegisterRt,IF_ID_RegisterRs,IF_ID_RegisterRt;
output IF_ID_Write,PC_Write,ctrl_Mux;

assign IF_ID_Write = ( ID_EX_MemRead & ( (ID_EX_RegisterRt == IF_ID_RegisterRs) | (ID_EX_RegisterRt == IF_ID_RegisterRt) ) )? 1'b0 : 1'b1;
assign PC_Write = ( ID_EX_MemRead & ( (ID_EX_RegisterRt == IF_ID_RegisterRs) | (ID_EX_RegisterRt == IF_ID_RegisterRt) ) )? 1'b0 : 1'b1;
assign ctrl_Mux = ( ID_EX_MemRead & ( (ID_EX_RegisterRt == IF_ID_RegisterRs) | (ID_EX_RegisterRt == IF_ID_RegisterRt) ) )? 1'b0 : 1'b1;

endmodule

module flush_detection_units(EX_B,
							EX_ALUOut,
							ID_J,
							// output
							IF_Flush,
							ID_Flush,
							EX_Flush);

// EX_PCSrc is used to tell whether the intruction at EX stage is branch
input EX_B;
// tell whether Branch happens
input [31:0] EX_ALUOut;
// used to tell whether the intruction at ID stage is jump
input ID_J;

// stall the pipeline when the instruction is of "branch" or "jump" type
output IF_Flush;
output ID_Flush;
output EX_Flush;

assign IF_Flush = (ID_J | (EX_B & EX_ALUOut));
assign ID_Flush = EX_B & EX_ALUOut;
assign EX_Flush = EX_B & EX_ALUOut;

endmodule



module bypassing_unit(ID_EX_RegisterRs,
					  ID_EX_RegisterRt,
					  EX_MEM_RegisterRd,
					  EX_MEM_RegWrite,
					  MEM_WB_RegisterRd,
					  MEM_WB_RegWrite,
					  // output
					  ForwardA,
					  ForwardB);

input [4:0] ID_EX_RegisterRs,ID_EX_RegisterRt,EX_MEM_RegisterRd,MEM_WB_RegisterRd;
input EX_MEM_RegWrite,MEM_WB_RegWrite;
output [1:0] ForwardA,ForwardB;

// Attention: ForwarB is the control signal of two muxes.
// One mux is designed for the DatabusB of sw or lw
// And the other is for the Immediate part of sw or lw

assign ForwardA =   // 2'b10
					( EX_MEM_RegWrite & (EX_MEM_RegisterRd != 5'b0) & (EX_MEM_RegisterRd == ID_EX_RegisterRs) )? 2'b10:
					// 2'b01
					( MEM_WB_RegWrite & (MEM_WB_RegisterRd != 5'b0) 
						& (MEM_WB_RegisterRd == ID_EX_RegisterRs) )? 2'b01:
					// 2'b00
					2'b00;

assign ForwardB =	// 2'b10
					( EX_MEM_RegWrite & (EX_MEM_RegisterRd != 5'b0) & (EX_MEM_RegisterRd == ID_EX_RegisterRt) )? 2'b10:
					// 2'b01
					( MEM_WB_RegWrite & (MEM_WB_RegisterRd != 5'b0) 
						& (MEM_WB_RegisterRd == ID_EX_RegisterRt) )? 2'b01: 
					// 2'b00
					2'b00;


endmodule

