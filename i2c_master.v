`timescale 1ns / 1ps

module i2c_master #(parameter clkfreq=10)(
    input clk,enable,readwrite,
    inout sda,
    output reg sclk, 
    output reg [8:0] readdata
    );
  reg [15:0] count ;
  reg [7:0]send;
  reg ack,dout;
  reg rw = 1'b0;
  reg [1:0] trig = 2'b00;
  reg [5:0] address = 6'b111001; ////address of slave
  reg [7:0] data = 8'b11001010; ///testing data
  wire [7:0] concatadd;
  reg startbit= 1'b0,stopbit=1'b1;

  initial begin
    sclk = 1'b0;
    ack= 1'b1;
    dout = 1'b1;
    count =16'd0;
    send = 7'd0;
  end
  always @ (posedge clk) begin:clockdivider
    if(count == clkfreq)begin
        sclk <= ~sclk;
        count <= 16'd0;
        end
    else
        count <= count+1;
  end
 //assign startbit = 1'b0;
 assign concatadd = {readwrite,address,startbit};
 
 
 always @ (posedge sclk) begin:datastart    
   ack <= 1'b1;
   if (enable) begin
   dout <= 1'b1;
   
    case(trig)
    2'b00: begin
           
            dout <= concatadd[send];
            send <=send+1;
            
            if (send>=8'd8) begin
            $display ("address  = %b", concatadd);
                 trig <= 2'b01;
                 dout <= 1'bz;
                 rw <=1'b1;
                 send <= 8'd0;
             end
            else
                trig <= 2'b00;
           end
           
    2'b01: begin
            //ack <= sda;
            
            $display("ack = %d",ack);
                if (ack == 1'b0) begin
                   $display ("welsome to data receieveing case");
                   ack <= 1'b1;
                   trig <= 2'b10; 
                end 
                else trig <= 2'b01;
           end
          
          
    2'b10:  begin
            if(readwrite == 1'b0) begin
            dout <= data[send];
            $display ("data  = %b", dout);
            send=send+1;
           if (send==8'd8) begin
                 trig <= 2'b11;
                 //dout <= 1'b1;
                 send <= 8'd0;
             end
            else
                trig <= 2'b10;
           end
          
           else begin 
            readdata[send] <= sda;
            //$display ("data  = %b", dout);
            send = send+1;
             if (send==8'd8) begin
                 trig <= 2'b00;
                 //dout <= 1'b1;
                 send <= 8'd0;
                 dout <= 1'b0;
             end
             else
                trig <= 2'b10;
           
           end
           end
    2'b11: begin
             //ack <= sda;
                if (ack == 1'b0) begin
                   dout<= stopbit;
                   ack <= 1'b1;
                  trig <= 2'b00; 
                   dout<= 1'b1;
                end
                else 
                trig <= 2'b10;
           end 
    default: dout<= 1'b1;
   endcase
   $display("trig =  %b",trig[1:0]);
   end
end

/*always @ (posedge sclk)begin
ack <= sda;
//$display("ack = %d",ack);
end*/

assign sda = (trig == 2'b01 || trig == 2'b11)?1'b1:dout;
//assign sda = dout;

endmodule
