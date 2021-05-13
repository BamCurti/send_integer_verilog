`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2021 18:50:36
// Design Name: 
// Module Name: send_integer
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

module send_integer(
    input[6:0] i_data,
    input i_start,
    input reset,
    input clock,
    output reg o_busy,
    output reg o_done,
    output reg o_serialTX
);

localparam IDLE = 0;
localparam SENDING_START = 1;
localparam SENDING_CHAR = 2;
localparam MIDDLE = 3;
localparam DONE = 4;

localparam ROUND = 0;
localparam UNIT = 1;
localparam DECIMAL = 2;
localparam ENTER = 3;

reg [1:0] r_char_selector;
reg [2:0] rCurrentState, rNextState;

reg[7: 0] r_entero;
reg[7: 0] r_decena;
reg[7: 0] r_salto = 10;
reg[7: 0] r_retorno = 13;

reg uart_start;
reg uart_busy;
reg uart_done;

reg[7: 0] uart_data;

always @ (posedge i_start) begin //asignación tanto de entero como de decena
    r_decena <= (i_data / 10) + 48; //+48 por el codigo ascii
    r_entero <= (i_data % 10) + 48; //+48 por el codigo ascii
end

uartTX send(  
    .i_clk(clock),
    .i_rst(reset),
    .i_data(uart_data),
    .i_startTX(uart_start),
    .o_busy(uart_busy),
    .o_done(uart_done),
    .o_serialTX(o_serialTX)
    );
    

always @ (posedge clock or negedge reset) begin
    if(!reset) begin rNextState <= IDLE;
    end
    else begin rCurrentState <= rNextState;
    end
end

always @ (*) begin
    if(!reset) begin
        rNextState <= IDLE;
    end
    else begin 
        case(rCurrentState)
        IDLE: begin
            if(i_start) begin rNextState <= SENDING_START;
            end
            else begin rNextState <= IDLE;
            end
        end
        SENDING_START: begin
            if(uart_busy) begin rNextState <= SENDING_CHAR;
            end
        end
        SENDING_CHAR: begin
            if(uart_done && !uart_busy) begin 
                if(r_char_selector == 2'b11) begin rNextState <= DONE; 
                end 
                else begin rNextState <= MIDDLE;
                end
            end
        end
        MIDDLE: begin
            if(uart_busy) begin rNextState <= SENDING_CHAR;
            end
        end
        DONE: begin
            if(r_char_selector == 2'b0) begin rNextState <= IDLE;
            end
        end
        default: begin
            rNextState <= IDLE;
        end
        
        endcase       
    end
end

always @(posedge clock or negedge reset or posedge uart_done or negedge uart_busy) begin
    if(!reset) begin
        o_serialTX = 1'b1;
        o_busy = 1'b0;
        o_done = 1'b0;
        uart_start = 1'b0;
        uart_data = 8'b1;
        r_char_selector = 1'b0;
    end
    else begin
        case(rCurrentState)
        IDLE: begin
        o_busy = 1'b0;
        o_done = 1'b0;
        uart_data = 8'b1;
        r_char_selector = 1'b0;
        end
        SENDING_START: begin
            uart_start = 1'b1;
            uart_data = r_retorno;
            o_busy = 1;
        end
        SENDING_CHAR: begin
            if(!uart_busy && uart_done) begin uart_data = 1'b0;
            end     
        end
        MIDDLE: begin
            r_char_selector = r_char_selector + 1;
            uart_start = 1'b1;
                      
            case(r_char_selector)
                ROUND: begin uart_data <= r_retorno;
                end
                DECIMAL: begin uart_data <= r_decena;
                end
                UNIT: begin uart_data <= r_entero;
                end
                ENTER: begin uart_data <= r_salto;
                end     
            endcase
            
            uart_start = 1'b1;
        end
        DONE: begin
            uart_start = 1'b0;
            r_char_selector = 2'b0;
            o_done = 1; 
        end
        endcase
    
    end
end

endmodule
