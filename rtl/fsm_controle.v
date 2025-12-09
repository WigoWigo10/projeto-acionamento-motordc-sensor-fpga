//==============================================================================
// Modulo:   fsm_controle
// Descricao:
//   Máquina de Estados Finitos (FSM) para controle de acionamento do motor
//   com histerese temporal.
//==============================================================================

module fsm_controle (
    input  wire clk,            // Clock principal
    input  wire reset,          // Reset global
    input  wire tick_1hz,       // Pulso de 1 segundo
    input  wire sensor_sync,    // Sinal do sensor sincronizado

    output reg  motor_on,       // 1 = Liga Motor, 0 = Desliga
    output reg  [4:0] timer_val // Valor para display
);

    // Codificação dos Estados
    localparam IDLE     = 2'd0; // Esperando sensor (Display 00)
    localparam RUN      = 2'd1; // Motor ligado pelo sensor (Display 20)
    localparam COOLDOWN = 2'd2; // Resfriamento (Conta 20..0)

    reg [1:0] estado_atual, proximo_estado;
    
    //--------------------------------------------------------------------------
    // Lógica Sequencial (Memória e Timer)
    //--------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            estado_atual <= IDLE;
            timer_val    <= 5'd0;  // REQUISITO: Display exibe 00 no Reset
        end
        else begin
            estado_atual <= proximo_estado;

            // Gerenciamento do Timer baseado no Estado Atual
            if (estado_atual == IDLE) begin
                timer_val <= 5'd0; // Garante 00 enquanto espera
            end
            else if (estado_atual == RUN) begin
                timer_val <= 5'd20; // Prepara o valor 20 enquanto o motor roda
            end
            else if (estado_atual == COOLDOWN) begin
                // Só decrementa se tiver pulso de 1s e não chegou a 0
                if (tick_1hz && timer_val > 0) begin
                    timer_val <= timer_val - 5'd1;
                end
            end
        end
    end

    //--------------------------------------------------------------------------
    // Lógica Combinacional (Próximo Estado e Saídas)
    //--------------------------------------------------------------------------
    always @(*) begin
        proximo_estado = estado_atual;
        motor_on = 1'b0;

        case (estado_atual)
            IDLE: begin
                motor_on = 1'b0;
                // Se sensor ativar, vai para RUN
                if (sensor_sync) proximo_estado = RUN;
            end

            RUN: begin
                motor_on = 1'b1;
                // Se sensor desativar, inicia o resfriamento
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