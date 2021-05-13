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

always @(*) begin #0.5 clock = ~clock;
end

initial begin
start <= 0;
reset <= 1;
data <= 8'b10101100;

#3;

start <= 1;

while(busy && !done) begin
    #1;
end

start <= 0;
data <= 8'b11100011;

#3;

start <= 1;

while(busy && !done) begin
    #1;
end


end

endmodule
