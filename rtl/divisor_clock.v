//-----------------------------------------------------------------------------
// Module: divisor_clock
//
// Description:
// Este modulo divide um clock de entrada de 27 MHz para gerar um clock de
// saida de 1 Hz (1 segundo) com 50% de ciclo de trabalho.
// Usado para a temporizacao do resfriamento do motor (Projeto 01).
//-----------------------------------------------------------------------------
module divisor_clock (
    // --- Portas de Entrada ---
    input  wire clk_in,      // Clock de entrada de 27 MHz (Kit FPGA)
    input  wire rst,         // Reset assincrono (ativo em nivel baixo)

    // --- Porta de Saida ---
    output reg  clk_out      // Clock de saida de 1 Hz
);

    // --- Parametros ---
    // Fator de divisao: 27.000.000 / 1 = 27.000.000
    parameter DIVISOR = 27000000;

    // --- Registradores Internos ---
    // O contador precisa ir ate (DIVISOR / 2) - 1, que e 13.499.999.
    // log2(13499999) = ~23.6, portanto, sao necessarios 24 bits.
    reg [23:0] counter = 24'd0; // Inicializacao explicita

    // --- Logica Sequencial ---
    always @(posedge clk_in or negedge rst) begin
        if (!rst) begin
            // Condicao de Reset: zera o contador e a saida.
            counter <= 24'd0;
            clk_out <= 1'b0;
        end
        // A contagem so deve acontecer quando o reset nao estiver ativo.
        else if (counter == (DIVISOR / 2) - 1) begin
            // Atingiu o valor de meio ciclo (13.499.999).
            counter <= 24'd0;       // Zera o contador para um novo ciclo.
            clk_out <= ~clk_out;    // Inverte o sinal do clock de saida (gera a borda).
        end
        else begin
            // Se nao atingiu o limite, apenas incrementa o contador.
            counter <= counter + 24'd1;
        end
    end

endmodule