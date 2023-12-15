module tmds_choice (
  input wire [7:0] data_in,
  output logic [8:0] qm_out
  );

  logic[3:0] ones;

  always_comb begin
    ones = 0;
    for (int i=0; i<$bits(data_in); i=i+1) begin
      ones = ones + data_in[i];
    end

    if (ones > 4 || (ones == 4 && data_in[0] ==0)) begin
      qm_out[0] = data_in[0];    
      for (int i=1; i < $bits(data_in); i=i+1) begin
        qm_out[i] = qm_out[i-1]~^data_in[i];
      end
      qm_out[8] = 0;
    end else begin
      qm_out[0] = data_in[0];    
      for (int i=1; i < $bits(data_in); i=i+1) begin
        qm_out[i] = qm_out[i-1]^data_in[i];
      end
      qm_out[8] = 1;
    end
  end
 
endmodule