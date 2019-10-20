// DESCRIPTION: Verilator: Systemverilog example module
// with interface to switch buttons, LEDs, LCD and register display

parameter NINSTR_BITS = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32, NBITS_LCD = 64;
module top(input  logic clk_2,
           input  logic [NBITS_TOP-1:0] SWI,
           output logic [NBITS_TOP-1:0] LED,
           output logic [NBITS_TOP-1:0] SEG,
           output logic [NBITS_LCD-1:0] lcd_a, lcd_b,
           output logic [NINSTR_BITS-1:0] lcd_instruction,
           output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
             lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
           output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite);

           
  //máquina de dois estados simples 
  enum logic [1:0] {A, B} state;
  logic reset;
  logic [2:0] contador;
  
  always_comb begin
    reset <= SWI[7];
  end

  always_ff@(posedge clk_2) begin
    if (reset) begin
      state <= A;
      contador <= 0;
    end

    else begin
      unique case (state)
        A: if (contador == 3) begin
          state <= B;
          contador <= 0;
          end
          else begin
            state <= A;
            contador <= contador + 1;
          end
        B: if (contador == 2) begin
          state <= A;
          contador <= 0;
          end
          else begin
            state <= B;
            contador <= contador + 1;
          end
      endcase
    end
    
  end

  always_comb begin
    LED[7] <= clk_2;
    LED[0] <= state == A;
    LED[1] <= state == B;
  end

endmodule
