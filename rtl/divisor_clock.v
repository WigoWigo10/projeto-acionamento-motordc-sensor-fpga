//-----------------------------------------------------------------------------
// Module: divisor_clock (Versao Strobe/Pulso)
// Descricao: Gera um pulso de 1 ciclo de clock (strobe) a cada 1 segundo.
//            Ideal para habilitar logica em FSMs sincronas.
//-----------------------------------------------------------------------------
module divisor_clock (
    input  wire clk_in,
    input  wire rst,
    output reg  clk_out // Agora e um strobe (pulso curto), nao onda quadrada
);

    // PARA SIMULACAO: Mude este valor para 4
    // PARA GRAVACAO: Mude este valor para 27000000
    parameter DIVISOR = 4; 

    reg [24:0] counter;

    // Mudança 1: Lista de sensibilidade apenas no Clock (Reset Síncrono)
    always @(posedge clk_in) begin
        // Mudança 2: Verifica se rst é 1 (Active High)
        if (rst) begin
            counter <= 25'd0;
            clk_out <= 1'b0;
        end
        else begin
            if (counter == DIVISOR - 1) begin
                counter <= 25'd0;
                clk_out <= 1'b1; // Gera o pulso de enable
            end
            else begin
                counter <= counter + 25'd1;
                clk_out <= 1'b0;
            end
        end
    end

endmodule