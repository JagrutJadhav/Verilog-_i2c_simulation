`timescale 1ns / 1ps

module i2c_tb();
reg clk=1'b0,enable=1'b0,readwrite=1'b0;
wire sda;
wire sclk;
wire [8:0] readdata;


           
 reg [5:0] address = 6'b111001;
 reg [6:0] addressreg;
 reg [2:0] trigg = 2'b00;
 reg startbit= 1'b0,stopbit=1'b1,rw,ack;
 reg [15:0] count=16'd0; 
initial ack = 1'b1;
always #10 clk =~clk;
i2c_master #(10) i2c(.clk(clk),
            .enable(enable),
            .readwrite(readwrite),
            .sda(sda),.sclk(sclk),
            .readdata(readdata));
always @ (posedge sclk)begin
enable <= 1'b1;
ack <= 1'b1;
case (trigg)
2'b00 : begin   
         if (sda == startbit)
            trigg <= 2'b01;  
        end
2'b01 : begin 
         addressreg[count] <= sda; 
         //$display("%b",sda);
            if (count >= 16'd7 ) begin
                //count = count+1;
                count <= 16'd0;
                $display ("address = %b and read/write =%b ",addressreg[5:0],addressreg[6]);
                    if(addressreg[5:0] == address) begin
                        ack <= 1'b0;
                        $display("entered in ack");
                        rw <= addressreg[6];
                        //sda <= ack;
                        trigg <= 2'b10;
                    end
                    else trigg <= 2'b00;   
                
               end
            else
                count <= count+1;

        end
        
2'b10 : $display ("");
        
 endcase
end

 assign sda = (ack==0) ? 1'b0:1'bz ;
endmodule

