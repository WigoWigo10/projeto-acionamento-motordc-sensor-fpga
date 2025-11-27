//-----------------------------------------------------------------------------
// Module: sincronizador
// Descricao: Sincroniza um sinal assincrono (sensor) com o clock do sistema
//            usando dois flip-flops em serie.
//-----------------------------------------------------------------------------
module sincronizador (
    input  wire clk,
    input  wire signal_in,
    output reg  signal_out
);

    reg estagio1;

    always @(posedge clk) begin
        estagio1   <= signal_in;
        signal_out <= estagio1;
    end

endmodule