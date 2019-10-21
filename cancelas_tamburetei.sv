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

  enum logic [1:0] {cancela_morador_aberta, cancela_morador_fechada} state_cancela_morador;
  enum logic [1:0] {cancela_visitante_aberta, cancela_visitante_fechada} state_cancela_visitante;
  logic reset;
  logic chega_morador;
  logic entrando_morador;
  logic chega_visitante;
  logic entrando_visitante;
  logic alarme;
  logic contador_ciclos_morador;
  logic contador_ciclos_visitante;
  logic clk_3;

  always_comb begin
    reset <= SWI[0];
    chega_morador <= SWI[1];
    entrando_morador <= SWI[2];
    chega_visitante <= SWI[3];
    entrando_visitante <= SWI[4];
  end

  always_ff@(posedge clk_2) begin
    clk_3 = (!clk_3);
  end

  always_ff@(posedge clk_3) begin
    if (reset) begin
      state_cancela_morador <= cancela_morador_fechada;
      state_cancela_visitante <= cancela_visitante_fechada;
      alarme <= 0;
      contador_ciclos_morador <= 0;
      contador_ciclos_visitante <= 0;
    end

    else begin
      unique case (state_cancela_morador)
        cancela_morador_fechada: 
          if (chega_morador) begin
            if (entrando_morador) begin
              state_cancela_morador <= cancela_morador_fechada;
              alarme <= 1;
            end

            else begin
              if (!entrando_visitante) begin
                state_cancela_morador <= cancela_morador_aberta;
              end
              else begin
                state_cancela_morador <= cancela_morador_fechada;
              end
            end
          end

          else begin
            state_cancela_morador <= cancela_morador_fechada;
          end
        
        cancela_morador_aberta:
          if (entrando_morador) begin
            state_cancela_morador <= cancela_morador_aberta;
            contador_ciclos_morador <= contador_ciclos_morador + 1;
            if (contador_ciclos_morador < 1 || contador_ciclos_morador > 3) begin
              state_cancela_morador <= cancela_morador_aberta;
              alarme <= 1;
              contador_ciclos_morador <= 0;
            end
            else begin
              state_cancela_morador <= cancela_morador_aberta;
              contador_ciclos_morador <= contador_ciclos_morador + 1;
            end
          end
          else begin
            state_cancela_morador <= cancela_morador_fechada;
            contador_ciclos_morador <= 0;
          end
      endcase

      unique case (state_cancela_visitante)
        cancela_visitante_fechada: 
          if (chega_visitante) begin
            if (entrando_visitante) begin
              state_cancela_visitante <= cancela_visitante_fechada;
              alarme <= 1;
            end

            else begin
              if (!entrando_morador) begin
                state_cancela_visitante <= cancela_visitante_aberta;
              end
              else begin
                state_cancela_visitante <= cancela_visitante_fechada;
              end
            end
          end

          else begin
            state_cancela_visitante <= cancela_visitante_fechada;
          end
        
        cancela_visitante_aberta:
          if (entrando_visitante) begin
            state_cancela_visitante <= cancela_visitante_aberta;
            contador_ciclos_visitante <= contador_ciclos_visitante + 1;
            if (contador_ciclos_visitante < 1 || contador_ciclos_visitante > 3) begin
              state_cancela_visitante <= cancela_visitante_aberta;
              alarme <= 1;
              contador_ciclos_visitante <= 0;
            end
            else begin
              state_cancela_visitante <= cancela_visitante_aberta;
              contador_ciclos_visitante <= contador_ciclos_visitante + 1;
            end
          end
          else begin
            state_cancela_visitante <= cancela_visitante_fechada;
            contador_ciclos_visitante <= 0;
          end
      endcase
    end
  end

  always_comb begin
    LED[0] <= (state_cancela_morador == cancela_morador_aberta);
    LED[1] <= (state_cancela_visitante == cancela_visitante_aberta);
    LED[2] <= (alarme);
    SEG[7] <= clk_3;
  end

endmodule

