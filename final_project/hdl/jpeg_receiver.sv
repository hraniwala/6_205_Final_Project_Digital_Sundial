module jpeg_receiver(
    input wire clk_in,
    input wire rst_in,
    input wire data_valid_in,
    input wire [7:0] byte_in,
    input wire complete_in,
    output logic [31:0] data_out,
    output logic [3:0] strb_out,
    output logic data_valid_out
);

logic [1:0] data_counter;
logic [3:0] counter_out;
logic [2:0] output_counter;
typedef enum {IDLE = 0, BUILDING = 1, OUTPUTTING = 2} current_state;
current_state state;

always_comb begin
    case(data_counter)
        default: counter_out = 4'b1000;
        2'b01: counter_out = 4'b1100;
        2'b10: counter_out = 4'b1110;
        2'b11: counter_out = 4'b1111;
    endcase
end

always_ff @(posedge clk_in) begin
    if (rst_in) begin
        data_counter <= 2'b0;
        data_out <= 32'b0;
        data_valid_out <= 1'b0;
        output_counter <= 3'b0;
    end else begin
        case (state)
            IDLE: begin
                data_valid_out <= 1'b0;
                if (data_valid_in && complete_in) begin
                    state <= OUTPUTTING;
                    data_out[31:24] <= byte_in;
                    data_counter <= data_counter + 1;
                end else if (data_valid_in) begin
                    state <= BUILDING;
                    data_out[31:24] <= byte_in;
                    data_counter <= data_counter + 1;                    
                end else begin
                    state <= IDLE;
                end
            end
            BUILDING: begin
                if (data_valid_in) begin
                    case (data_counter)
                        default: begin
                            data_out[31:24] <= byte_in; // shouldn't ever happen
                            data_counter <= data_counter + 1;
                            if (complete_in) begin
                                state <= OUTPUTTING;
                            end else begin
                                state <= BUILDING;
                            end
                        end
                        2'b01: begin
                            data_out[23:16] <= byte_in;
                            data_counter <= data_counter + 1;
                            if (complete_in) begin
                                state <= OUTPUTTING;
                            end else begin
                                state <= BUILDING;
                            end
                        end
                        2'b10: begin
                            data_out[15:8] <= byte_in;
                            data_counter <= data_counter + 1;
                            if (complete_in) begin
                                state <= OUTPUTTING;
                            end else begin
                                state <= BUILDING;
                            end
                        end
                        2'b11: begin 
                            data_out[7:0] <= byte_in;
                            state <= OUTPUTTING;
                        end
                    endcase
                end else begin
                    state <= BUILDING;
                end
            end
            OUTPUTTING: begin
                strb_out <= counter_out;
                data_valid_out <= 1'b1;
                if (output_counter <= 2'b11) begin
                    output_counter <= output_counter + 1;
                    state <= OUTPUTTING;
                end else begin
                    output_counter <= 3'b0;
                    state <= IDLE;
                end
            end
        endcase
    end

end

endmodule