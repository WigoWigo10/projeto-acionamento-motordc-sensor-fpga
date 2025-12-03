//==============================================================================
// Module:   maquina_de_estados (Top-Level)
// Descricao:
//   Integração dos módulos de controle, sincronização e interface de usuário.
//==============================================================================

module maquina_de_estados (
    // --- Entradas Físicas (Pinos da FPGA) ---
    input  wire CLOCK_27,      // Clock principal de 27 MHz
    input  wire KEY_RESET,     // Botão KEY0 (Reset ativo em nível baixo)
    input  wire SENSOR_IN,     // Entrada digital do sensor de temperatura (GPIO)

    // --- Saídas Físicas (Pinos da FPGA) ---
    output wire MOTOR_OUT,     // Saída para o driver do Motor (GPIO)
    output wire [6:0] HEX0,    // Display 7-Seg Unidade (Contagem)
    output wire [6:0] HEX1     // Display 7-Seg Dezena (Contagem)
);

    // --- Sinais Internos (Fios de conexão) ---
    wire clk_1hz_wire;         // Pulso de 1 segundo vindo do divisor
    wire sensor_synced_wire;   // Sinal do sensor limpo (sincronizado)
    wire [4:0] timer_value;    // Valor atual do temporizador (0 a 20) vindo da FSM
    wire reset_interno;        // Sinal de reset invertido (para lógica positiva)

    // Inverte o reset (Botões da DE1/DE2 são zero quando pressionados)
    assign reset_interno = ~KEY_RESET; // 0(press) -> 1(reset ativo)


    // --- 1. Instância do Divisor de Clock (Gera base de tempo de 1s) ---
    divisor_clock inst_divisor (
        .clk_in(CLOCK_27),
        .rst(reset_interno),
        .clk_out(clk_1hz_wire)
    );

    // --- 2. Instância do Sincronizador (Proteção contra metaestabilidade) ---
    sincronizador inst_sync (
        .clk(CLOCK_27),
        .signal_in(SENSOR_IN),
        .signal_out(sensor_synced_wire)
    );

    // --- 3. Instância da Máquina de Estados (Cérebro do sistema) ---
    fsm_controle inst_fsm (
        .clk(CLOCK_27),
        .reset(reset_interno),
        .tick_1hz(clk_1hz_wire),
        .sensor_sync(sensor_synced_wire),
        .motor_on(MOTOR_OUT),      // Conecta direto à saída física do motor
        .timer_val(timer_value)    // Envia o valor do tempo para ser decodificado
    );

    // --- 4. Lógica de Exibição ---
    
    reg [3:0] digito_unidade;
    reg [3:0] digito_dezena;

    // Conversor Binário para BCD simples (para valores 0 a 31)
    // Consome muito menos área no chip do que os operadores % e /
    always @(*) begin
        if (timer_value >= 5'd20) begin
            digito_dezena  = 4'd2;
            digito_unidade = timer_value - 5'd20;
        end 
        else if (timer_value >= 5'd10) begin
            digito_dezena  = 4'd1;
            digito_unidade = timer_value - 5'd10;
        end 
        else begin
            digito_dezena  = 4'd0;
            digito_unidade = timer_value[3:0];
        end
    end

    // Decodificador para a Unidade (HEX0)
    decodificador_7seg inst_hex0 (
        .bcd_in(digito_unidade),
        .seg_out(HEX0)
    );

    // Decodificador para a Dezena (HEX1)
    decodificador_7seg inst_hex1 (
        .bcd_in(digito_dezena),
        .seg_out(HEX1)
    );

endmodule