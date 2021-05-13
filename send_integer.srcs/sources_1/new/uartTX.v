module uartTX
(
  clk,
  rst,
  startUART,
  dataTX,
  done,
  busy,
  bitTX
);

  parameter CLKCOUNTER = ???;
  parameter NBITS_COUNTER = ???;

  localparam IDLE = 3'b000;
  localparam TX_START = 3'b001;
  localparam TX_DATA = 3'b011;
  localparam TX_STOP = 3'b010;
  localparam DONE = 3'b110;

  input clk;
  input rst;
  input startUART;
  input [7:0] dataTX;
  output reg done;
  output reg busy;
  output reg bitTX;

  reg [7:0] rDataTX;
  reg [2:0] rDataIdx;
  reg [2:0] rCurrentState;
  reg [2:0] rNextState;
  reg [NBITS_COUNTER-1:0] rClkCounter;

  always @ (posedge clk or negedge rst) begin
    if (!rst) begin
      rCurrentState <= IDLE;
    end
    else begin
      rCurrentState <= rNextState;
    end
  end

  always @ ( * ) begin
    case (estado)
      IDLE: begin
        if (startUART) begin
          rNextState = TX_START;
        end
        else begin
          rNextState = IDLE;
        end
      end
      TX_START: begin
        if(rClkCounter < CLKCOUNTER) begin
          rNextState = TX_START;
        end
        else begin
          rNextState = TX_DATA;
        end
      end
      TX_DATA: begin
        if (rDataIdx == 7 && rClkCounter == CLKCOUNTER) begin
          rNextState = TX_STOP;
        end
        else begin
          rNextState = TX_DATA;
        end
      end
      TX_STOP: begin
        if(rClkCounter < CLKCOUNTER) begin
          rNextState = TX_STOP;
        end
        else begin
          rNextState = DONE;
        end
      end
      DONE: begin
        rNextState = IDLE;
      end
      default: begin
        rNextState = IDLE;
      end
    endcase
  end

  always @ (posedge clk or negedge rst) begin
    if(!rst) begin
      done <= 1'b0;
      busy <= 1'b0;
      bitTX <= 1'b1;
      rDataTX <= 8'd0;
      rDataIdx <= 3'd0;
      rClkCounter <= {NBITS_COUNTER{1'b0}};
    end
    else begin
      case (rCurrentState)
        IDLE: begin
          done <= 1'b0;
          busy <= 1'b0;
          bitTX <= 1'b1;
          rDataTX <= 8'd0;
          rDataIdx <= 3'd0;
          rClkCounter <= {NBITS_COUNTER{1'b0}};
        end
        TX_START: begin
          done <= 1'b0;
          busy <= 1'b1;
          bitTX <= 1'b0;
          rDataTX <= dataTX;
          rDataIdx <= 3'd0;
          if (rClkCounter < CLKCOUNTER) begin
            rClkCounter <= rClkCounter + 1'b1;
          end
          else begin
            rClkCounter <= {NBITS_COUNTER{1'b0}};
          end
        end
        TX_DATA: begin
          bitTX <= rDataTX[rDataIdx];
          if (rClkCounter < CLKCOUNTER) begin
            rClkCounter <= rClkCounter + 1'b1;
          end
          else begin
            rClkCounter <= {NBITS_COUNTER{1'b0}};
            rDataIdx <= rDataIdx + 1'b1;
          end
        end
        TX_STOP: begin
          bitTX <= 1'b1;
          if (rClkCounter < CLKCOUNTER) begin
            rClkCounter <= rClkCounter + 1'b1;
          end
          else begin
            rClkCounter <= {NBITS_COUNTER{1'b0}};
          end
          //rNextState <= DONE;
        end
        DONE: begin
          done <= 1'b1;
          busy <= 1'b0;
        end
        default: ;
      endcase
    end
  end

endmodule
