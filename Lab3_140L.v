// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //           
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
//
// Author: Cristina Ahamad
// Github: CristinaAhamad

module Lab3_140L (
		  input wire 	    rst, // reset signal (active high)
		  input wire 	    clk, // global clock
		  input wire oneSecStrb,  	    
		  input 	    bu_rx_data_rdy, // data from the uart ready
		  input [7:0] 	    bu_rx_data, // data from the uart
		  output wire 	    L3_tx_data_rdy, // data to the alarm display
		  output wire [7:0] L3_tx_data,     // data to the alarm display
		  output [4:0] 	    L3_led,
		  output reg [6:0] 	    L3_segment1, // 1's seconds
		  output reg [6:0] 	    L3_segment2, // 10's seconds
		  output reg [6:0] 	    L3_segment3, // 1's minutes
		  output reg [6:0] 	    L3_segment4, // 10's minutes

		  output [3:0] 	    di_Mtens,
		  output [3:0] 	    di_Mones,
		  output [3:0] 	    di_Stens,
		  output wire [3:0] di_Sones,
		  output [3:0] 	    di_AMtens,
		  output [3:0] 	    di_AMones,
		  output [3:0] 	    di_AStens,
		  output [3:0] 	    di_ASones
		  );
		  
		wire [6:0] segSO;
		wire [6:0] segST;
		wire [6:0] segMO;
		wire [6:0] segMT;
		
		wire did_alarmMatch, dicRun;
		
		wire dicLdMtens, dicLdMones, dicLdStens, dicLdSones, dicLdAMtens, dicLdAMones, 
			dicLdAStens, dicLdASones, dicAlarmIdle, dicAlarmArmed, dicAlarmTrig;
		
		dictrl dictrl(.dicLdMtens(dicLdMtens), .dicLdMones(dicLdMones), .dicLdStens(dicLdStens), 
						.dicLdSones(dicLdSones), .dicLdAMtens(dicLdAMtens), .dicLdAMones(dicLdAMones), 
						.dicLdAStens(dicLdAStens), .dicLdASones(dicLdASones), .dicRun(dicRun), 
						.dicAlarmIdle(dicAlarmIdle), .dicAlarmArmed(dicAlarmArmed), .dicAlarmTrig(dicAlarmTrig),
						.did_alarmMatch(did_alarmMatch), .bu_rx_data_rdy(bu_rx_data), .bu_rx_data(bu_rx_data),
						.rst(rst), .clk(clk));

		didp didp(.di_Mtens(di_Mtens[3:0]), .di_Mones(di_Mones[3:0]), 
					.di_Stens(di_Stens[3:0]), .di_Sones(di_Sones[3:0]), 
					.di_AMtens(di_AMtens[3:0]), .di_AMones(di_AMones[3:0]), 
					.di_AStens(di_AStens[3:0]), .di_ASones(di_ASones[3:0]),
					.did_alarmMatch(did_alarmMatch), .L3_led(L3_led), 
					.bu_rx_data(bu_rx_data), 
					.dicLdMtens(dicLdMtens), .dicLdMones(dicLdMones), 
					.dicLdStens(dicLdStens), .dicLdSones(dicLdSones),
					.dicLdAMtens(dicLdAMtens), .dicLdAMones(dicLdAMones),
					.dicLdAStens(dicLdAStens), .dicLdASones(dicLdASones),
					.dicRun(dicRun), .oneSecStrb(oneSecStrb), 
					.rst(rst), .clk(clk));
					
		bcd2segment bcdSO(.segment(segSO), .num(di_Sones), .enable(1'b1));
		bcd2segment bcdST(.segment(segST), .num(di_Stens), .enable(1'b1));
		bcd2segment bcdMO(.segment(segMO), .num(di_Mones), .enable(1'b1));
		bcd2segment bcdMT(.segment(segMT), .num(di_Mtens), .enable(1'b1));
				
		always@(*) begin	
			L3_segment1[6:0] = segSO;
			L3_segment2[6:0] = segST;
			L3_segment3[6:0] = segMO;
			L3_segment4[6:0] = segMT;
		end 

endmodule // Lab3_140L



//
//
// sample interface for clock datpath
//
module didp (
	     output [3:0] di_Mtens, // current 10's minutes
	     output [3:0] di_Mones, // current 1's minutes
	     output [3:0] di_Stens, // current 10's second
	     output [3:0] di_Sones, // current 1's second

	     output [3:0] di_AMtens, // current alarm 10's minutes
	     output [3:0] di_AMones, // current alarm 1's minutes
	     output [3:0] di_AStens, // current alarm 10's second
	     output [3:0] di_ASones, // current alarm 1's second

	     output wire  did_alarmMatch, // one cydie alarm match (raw signal, unqualified)

	     output [4:0] L3_led,

	     input [7:0]  bu_rx_data,
	     input 	  dicLdMtens, // load 10's minute
	     input 	  dicLdMones, // load 1's minute
	     input 	  dicLdStens, // load 10's second
	     input 	  dicLdSones, // load 1's second
	     
	     input 	  dicLdAMtens, // load alarm 10's minute
	     input 	  dicLdAMones, // load alarm 1's minute
	     input 	  dicLdAStens, // load alarm 10's second
	     input 	  dicLdASones, // load alarm 1's second
	     input 	  dicRun, //clock should run 	  
	     input 	  oneSecStrb, // one cycle strobe
	     input 	  rst,
	     input 	  clk 	  
	     );
	
	//reset registers
	reg rstSO;
	reg rstST;
	reg rstMO;
	reg rstMT;

	//value checks for reset
	always@(*) begin
		rstSO = di_Sones == 4'b1001;
		rstST = (di_Stens == 4'b0101) & rstSO;
		rstMO = (di_Mones == 4'b1001) & rstST;
		rstMT = (di_Mtens == 4'b0101) & rstMO;
	end
	
	//counter 
	countrce countSO(.q(di_Sones), .d(bu_rx_data[3:0]), .ld(dicLdSones), 
							.ce(dicRun & oneSecStrb), 
							.rst(rst | rstSO), .clk(clk));
	countrce countST(.q(di_Stens), .d(bu_rx_data[3:0]), .ld(dicLdStens), 
							.ce(dicLdStens | rstSO), 
							.rst(rst | rstST), .clk(clk));	
	countrce countMO(.q(di_Mones), .d(bu_rx_data[3:0]), .ld(dicLdMones), 
							.ce(dicLdMones | rstST), 
							.rst(rst | rstMO), .clk(clk));				
	countrce countMT(.q(di_Mtens), .d(bu_rx_data[3:0]), .ld(dicLdMtens), 
							.ce(dicLdMtens | rstMO), 
							.rst(rst | rstMT), .clk(clk));
   
	//register for alarm
	regrce #(.WIDTH(4)) regSO(.q(di_ASones), .d(bu_rx_data[3:0]), 
					.ce(dicLdASones), 
					.rst(rst), .clk(clk));
	regrce #(.WIDTH(4)) regST(.q(di_AStens), .d(bu_rx_data[3:0]), 
				   .ce(dicLdAStens), 
					.rst(rst), .clk(clk));
	regrce #(.WIDTH(4)) regMO(.q(di_AMones), .d(bu_rx_data[3:0]), 
					.ce(dicLdAMones), 
					.rst(rst), .clk(clk));
	regrce #(.WIDTH(4)) regMT(.q(di_AMtens), .d(bu_rx_data[3:0]), 
					.ce(dicLdAMtens), 
					.rst(rst), .clk(clk));
	
	//check if alarm should go off
	assign did_alarmMatch = ((di_ASones == di_Sones) 
									& (di_AStens == di_Stens) 
									& (di_AMones == di_Mones)
									& (di_AMtens == di_Mtens));
endmodule




//
//
// sample interface for clock control
//
module dictrl(
	      output 	  dicLdMtens, // load the 10's minutes
	      output 	  dicLdMones, // load the 1's minutes
	      output 	  dicLdStens, // load the 10's seconds
	      output 	  dicLdSones, // load the 1's seconds
	      output 	  dicLdAMtens, // load the alarm 10's minutes
	      output 	  dicLdAMones, // load the alarm 1's minutes
	      output 	  dicLdAStens, // load the alarm 10's seconds
	      output 	  dicLdASones, // load the alarm 1's seconds
	      output 	  dicRun, // clock should run

	      output wire dicAlarmIdle, // alarm is off
	      output wire dicAlarmArmed, // alarm is armed
	      output wire dicAlarmTrig, // alarm is triggered

	      input       did_alarmMatch, // raw alarm match

              input 	  bu_rx_data_rdy, // new data from uart rdy
              input [7:0] bu_rx_data, // new data from uart
              input 	  rst,
	      input 	  clk
	      );
			
			assign dicRun = 1'b1;
			
			//initialize for time and alarm
			localparam start=4'b0000, lalarm=4'b0001, ltime=4'b0010, laMT=4'b0011, laMO=4'b0100,
							laST=4'b0101, laSO=4'b0110, ltMT=4'b0111, ltMO=4'b1000, ltST=4'b1001,
							ltSO=4'b1010;
			
			reg [3:0] currState = start;
			reg [3:0] nextState;
			
			//initialize for alarm trigger
			localparam off=4'b0000, armed=4'b0001, triggered=4'b0010;
			
			reg [3:0] aCurrState;
			reg [3:0] aNextState;
			
			wire deEsc, deNum, deNum0to5, deCr, deAS, deLA, deLL, deLN;
			
			//temps for output
			reg Mtens, Mones, Stens, Sones, AMtens, AMones, AStens, ASones;
			reg idle, arm, trig;
			
			//assign output to temp registers
			assign dicLdMtens = Mtens;
			assign dicLdMones = Mones;
			assign dicLdStens = Stens;
			assign dicLdSones = Sones;
				
			assign dicLdAMtens = AMtens;
			assign dicLdAMones = AMones;
			assign dicLdAStens = AStens;
			assign dicLdASones = ASones;
				
			assign dicAlarmIdle = idle;
			assign dicAlarmArmed = arm;
			assign dicAlarmTrig = trig;
			
			//call decodeKeys to determine user input
			decodeKeys decode(.de_esc(deEsc), .de_num(deNum), .de_num0to5(deNum0to5), 
							.de_cr(deCr), .de_atSign(deAS), .de_littleA(deLA),
							.de_littleL(deLL), .de_littleN(deLN), .charData(bu_rx_data), 
							.charDataValid(bu_rx_data_rdy));
			
			/*Load time and alarm FSM*/
			//next state logic
			always@(*)begin
				case (currState)
					//if start load time or alarm, stay at start
					start :
						if(deLA & bu_rx_data_rdy)
							nextState = lalarm;
						else if(deLL & bu_rx_data_rdy)
							nextState = ltime;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;
							
					//input AMtens or stay in load alarm state
					lalarm :
						if(deNum0to5 & bu_rx_data_rdy)
							nextState = laMT;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;

					//input AMones or stay in load alarm state
					laMT :
						if(deNum & bu_rx_data_rdy)
							nextState = laMO;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;
					
					//input AStens or stay in load alarm state
					laMO :
						if(deNum0to5 & bu_rx_data_rdy)
							nextState = laST;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;
					
					//input ASOnes or stay in load alarm state
					laST :
						if(deNum0to5 & bu_rx_data_rdy) 
							nextState = laSO;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;
						
					//accept alarm
					laSO :
						if(deCr & bu_rx_data_rdy) 
							nextState = start;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;
							
					//load Mtens or stay in load time state
					ltime :
						if(deNum0to5 & bu_rx_data_rdy)
							nextState = ltMT;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;
					
					//load Mnes or stay in load time state
					ltMT :
						if(deNum & bu_rx_data_rdy)
							nextState = ltMO;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;
					
					//load Stens or stay in load time state
					ltMO :
						if(deNum0to5 & bu_rx_data_rdy)
							nextState = ltST;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;
					
					//load Sones or stay in load time state
					ltST :
						if(deNum & bu_rx_data_rdy)
							nextState = ltSO;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;
					
					//accept time
					ltSO :
						if(deCr & bu_rx_data_rdy)
							nextState = start;
						else if(deEsc & bu_rx_data_rdy)
							nextState = start;
						else
							nextState = currState;
							
					//default case
					default : 
						nextState = start;
				endcase
			end
			
			//output logic
			always@(*) begin
				case (currState)
					//default to 0000
					start : begin
						Mtens = 1'b0;
						Mones = 1'b0;
						Stens = 1'b0;
						Sones = 1'b0;
						AMtens = 1'b0;
						AMones = 1'b0;
						AStens = 1'b0;
						ASones = 1'b0;
					end
					
					lalarm : begin
						AMtens = 1'b0;
						AMones = 1'b0;
						AStens = 1'b0;
						ASones = 1'b0;
					end
						
					ltime : begin
						Mtens = 1'b0;
						Mones = 1'b0;
						Stens = 1'b0;
						Sones = 1'b0;
					end
					
					//load alarm input
					laMT :
						AMtens = 1'b1;
						
					laMO :
						AMones = 1'b1;
						
					laST :
						AStens = 1'b1;
					
					laSO :
						ASones = 1'b1;
						
					//load time input
					ltMT :
						Mtens = 1'b1;
						
					ltMO :
						Mones = 1'b1;
					
					ltST : 
						Stens = 1'b1;
						
					ltSO :
						Sones = 1'b1;
					
					//default load
					default : begin
						Mtens = 1'b0;
						Mones = 1'b0;
						Stens = 1'b0;
						Sones = 1'b0;
						AMtens = 1'b0;
						AMones = 1'b0;
						AStens = 1'b0;
						ASones = 1'b0;
					end
						
				endcase
			end
			
			
			//sequential logic
			always@(posedge clk) begin
				if(rst)
					currState <= start;
				else
					currState <= nextState;
			end
			
			
			
			/*FSM for alarm*/
			//next state logic
			always@(*) begin
				case (aCurrState)
					off:
						if(deAS & bu_rx_data_rdy)
							aNextState = arm;
							
					armed:
						if(deAS & bu_rx_data_rdy)
							aNextState = off;
						else if(did_alarmMatch)
							aNextState = triggered;
							
					triggered:
						if(deAS & bu_rx_data_rdy)
							aNextState = off;
							
					default: 
						aNextState = off;
				endcase
			end
			
			//ouput logic
			always@(*) begin
				case (aCurrState)
					off: begin
						idle = 1'b1;
						arm = 1'b0;
						trig = 1'b0;
					end
						
					armed: begin
						arm = 1'b1;
						idle = 1'b0;
						trig = 1'b0;
					end
					
					triggered: begin
						trig = 1'b1;
						arm = 1'b0;
						idle = 1'b0;
					end
						
					default: begin
						idle = 1'b1;
						arm = 1'b0;
						trig = 1'b0;
					end
					
				endcase
			end
			
			
			//sequential logic
			always@(posedge clk) begin
				if(rst)
					aCurrState <= off;
				else
					aCurrState <= aNextState;
			end
   
endmodule

