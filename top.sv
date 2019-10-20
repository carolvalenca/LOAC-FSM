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

  enum logic [1:0] {sem_pulsacao, com_pulsacao} state;
  logic reset;
  logic batida;
  logic contador_ciclos;
  logic alarme;
  
  always_comb begin
    reset <= SWI[7];
    batida <= SWI[0];
  end

  always_ff@(posedge clk_2 or posedge reset) begin
    if (reset) begin
      state <= sem_pulsacao;
      contador_ciclos <= 0;
      alarme <= 0;
    end

    else begin
      unique case (state)
        com_pulsacao: 
          if (!batida) begin
            if (contador_ciclos == 3) begin
              state <= sem_pulsacao;
              contador_ciclos <= contador_ciclos + 1;
            end 
            else begin
              state <= com_pulsacao;
              contador_ciclos <= contador_ciclos + 1;
            end     
          end

          else begin
            if (contador_ciclos < 3) begin
              state <= com_pulsacao;
              alarme <= 1;
              contador_ciclos <= 0;
            end
            else begin
              state <= com_pulsacao;
              contador_ciclos <= 0;
            end
          end
        
        sem_pulsacao:
          if (batida) begin
            state <= com_pulsacao;
            contador_ciclos <= 0;
          end
          else begin
            if (contador_ciclos > 5) begin
              state <= com_pulsacao;
              contador_ciclos <= contador_ciclos + 1;
            end
            else begin
              state <= sem_pulsacao;
              contador_ciclos <= contador_ciclos + 1;
          end
      endcase
    end
    
  end

  always_comb begin
    LED[7] <= clk_2;
    LED[0] <= (state == com_pulsacao);
    LED[1] <= (alarme);
  end

endmodule
