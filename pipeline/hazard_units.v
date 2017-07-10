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
//assign flush = ( (EX_PCSrc == 3'b001) & EX_ALUOut );

endmodule

module flush_detection_units(EX_PCSrc,
							EX_ALUOut,
							ID_PCSrc,
							// output
							IF_Flush,
							ID_Flush,
							EX_Flush);

// EX_PCSrc is used to tell whether the intruction at EX stage is branch
input [2:0] EX_PCSrc;
// tell whether Branch happens
input [31:0] EX_ALUOut;
// used to tell whether the intruction at ID stage is jump
input [2:0] ID_PCSrc;

// stall the pipeline when the instruction is of "branch" or "jump" type
output IF_Flush;
output ID_Flush;
output EX_Flush;

assign IF_Flush = ( (EX_PCSrc == 3'b001) & EX_ALUOut ) | ( ID_PCSrc == 3'b001 ) | ( ID_PCSrc == 3'b011 );
assign ID_Flush = (EX_PCSrc == 3'b001) & EX_ALUOut;
assign EX_Flush = (EX_PCSrc == 3'b001) & EX_ALUOut;

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

assign ForwardA = 	// 2'b10
					( EX_MEM_RegWrite & (EX_MEM_RegisterRd != 5'b0) & (EX_MEM_RegisterRd == ID_EX_RegisterRs) )? 2'b10:
					// 2'b01
					( MEM_WB_RegWrite & (MEM_WB_RegisterRd != 5'b0) 
						& ~(EX_MEM_RegWrite & (EX_MEM_RegisterRd != 5'b0) & (EX_MEM_RegisterRd != ID_EX_RegisterRs))
						& (MEM_WB_RegisterRd == ID_EX_RegisterRs) )? 2'b01:
					// 2'b00
					2'b00;

assign ForwardB =	// 2'b10
					( EX_MEM_RegWrite & (EX_MEM_RegisterRd != 5'b0) & (EX_MEM_RegisterRd == ID_EX_RegisterRt) )? 2'b10:
					// 2'b01
					( MEM_WB_RegWrite & (MEM_WB_RegisterRd != 5'b0) 
						& ~(EX_MEM_RegWrite & (EX_MEM_RegisterRd != 5'b0) & (EX_MEM_RegisterRd != ID_EX_RegisterRt))
						& (MEM_WB_RegisterRd == ID_EX_RegisterRt) )? 2'b01: 
					// 2'b00
					2'b00;

endmodule

