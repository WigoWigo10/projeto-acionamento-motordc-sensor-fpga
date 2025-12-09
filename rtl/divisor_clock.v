//==============================================================================
// Modulo:   divisor_clock
// Descricao:
//   Divisor de frequência parametrizável. Gera um pulso de enable (strobe)
//   com largura de 1 ciclo de clock na frequência de saída desejada.
//==============================================================================

module divisor_clock (
    input  wire clk_in,
    input  wire rst,
    output reg  clk_out
);

    // Configuração para 1 Hz com clock de entrada de 27 MHz
    // Para Simulação: Utilizar valor reduzido (ex: 4)
    parameter DIVISOR = 27000000; 

    reg [24:0] counter;

    always @(posedge clk_in) begin
        if (rst) begin
            counter <= 25'd0;
            clk_out <= 1'b0;
        end
        else begin
            if (counter == DIVISOR - 1) begin
                counter <= 25'd0;
                clk_out <= 1'b1; // Strobe
            end
            else begin
                counter <= counter + 25'd1;
                clk_out <= 1'b0;
            end
        end
    end

endmodule