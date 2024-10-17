module par_to_ser #(parameter N = 8)(
    //parallel side
  input logic [N-1:0] par_data,
  input logic clk,rstn,
  input logic par_valid,
  output logic par_ready,
    //serial side
    output logic ser_data,ser_valid,
    input logic ser_ready
);

enum {Rx = 0,Tx = 1} state ,state_next;//Define states
logic [N-1:0] shift_reg;
  logic [$clog2(N):0] count;

//Next state decorder
always_comb 
unique case(state)
Rx: state_next = par_valid ? Tx :Rx; 
Tx: state_next = count==7 & ser_ready ? Rx : Tx;

endcase
/*
always_comb begin 
if(Rx) begin 
    if(par_valid) state_next = Tx ;
    else state_next = state ;
end
if(Tx) begin 
    if(count==7 & ) state_next = Tx ;
end

end 
*/

//state sequencer
always_ff @(posedge clk or negedge rstn)
state <= !rstn ? Rx : state_next ;    

//output decorder
assign ser_data = shift_reg[0];
assign par_ready = (state == Rx) ;
assign ser_valid = (state == Tx) ;

always_ff @(posedge clk or negedge rstn)begin 
    if (!rstn) count <= '0;
  else unique case(state)
        Rx : begin
            shift_reg <= par_data ;
            count <= 0 ;
        end

    Tx : if(ser_ready) begin 
            shift_reg <= shift_reg >>1 ;
            count <= count + 1'd1;
        end
    endcase
end 
endmodule