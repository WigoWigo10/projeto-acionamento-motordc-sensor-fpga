//==============================================================================
// Modulo:   fsm_controle
// Descricao:
//   Máquina de Estados Finitos (FSM) para controle de acionamento do motor
//   com histerese temporal de desligamento (Cooldown).
//==============================================================================

module fsm_controle (
    input  wire clk,            // Clock principal (50 ou 27 MHz)
    input  wire reset,          // Reset global
    input  wire tick_1hz,       // Pulso de 1 segundo (do divisor)
    input  wire sensor_sync,    // Sinal do sensor ja sincronizado

    output reg  motor_on,       // 1 = Liga Motor, 0 = Desliga
    output reg  [4:0] timer_val // Valor do timer (0 a 20) para display
);

    // Codificação dos Estados
    localparam IDLE     = 2'd0; // Esperando sensor
    localparam RUN      = 2'd1; // Motor ligado pelo sensor
    localparam COOLDOWN = 2'd2; // Resfriamento (20s)

    reg [1:0] estado_atual, proximo_estado;
    
    // Lógica Sequencial de Estado e Temporizador
    always @(posedge clk) begin
        if (reset) begin
            estado_atual <= IDLE;
            timer_val    <= 5'd20; // Valor inicial padrao
        end
        else begin
            estado_atual <= proximo_estado;

            // Gerenciamento do Timer
            if (estado_atual == COOLDOWN && tick_1hz && timer_val > 0) begin
                timer_val <= timer_val - 5'd1;
            end
            else if (estado_atual != COOLDOWN) begin
                timer_val <= 5'd20; // Reset do timer fora do cooldown
            end
        end
    end

    // Lógica Combinacional de Saída e Próximo Estado
    always @(*) begin
        proximo_estado = estado_atual;
        motor_on = 1'b0;

        case (estado_atual)
            IDLE: begin
                motor_on = 1'b0;
                if (sensor_sync) proximo_estado = RUN;
            end

            RUN: begin
                motor_on = 1'b1;
                if (!sensor_sync) proximo_estado = COOLDOWN;
            end

            COOLDOWN: begin
                motor_on = 1'b1; // Motor continua ligado no resfriamento
                
                if (sensor_sync) 
                    proximo_estado = RUN; // Reativou sensor, cancela cooldown
                else if (timer_val == 0) 
                    proximo_estado = IDLE; // Acabou o tempo
            end
            
            default: proximo_estado = IDLE;
        endcase
    end

endmodule