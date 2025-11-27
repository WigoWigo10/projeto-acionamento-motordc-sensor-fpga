//==============================================================================
// Modulo:   sincronizador
// Descricao:
//   Sincronizador de sinal de entrada de duplo estágio para mitigação de
//   metaestabilidade em domínios de clock assíncronos.
//==============================================================================

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