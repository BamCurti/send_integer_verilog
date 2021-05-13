`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.05.2021 21:56:15
// Design Name: 
// Module Name: send_integerTB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module send_integerTB();
reg[6:0] data;
reg start;
reg clock;
reg reset;

wire done;
wire busy;
wire tx;

send_integer DUT(
    .i_data(data),
    .i_start(start),
    .reset(reset),
    .clock(clock),
    .o_busy(busy),
    .o_done(done),
    .o_serialTX(tx)
);

always begin #1 clock = ~clock;
end

initial begin
clock = 0;

start = 0;
reset = 1;
data = 8'd81;

#10;
reset = 0;
#10; 
 reset = 1;
 #10;
start = 1;
#6;
start = 0;

while(busy && !done) begin
    #1;
end

#1000000;
$stop();


end

endmodule
