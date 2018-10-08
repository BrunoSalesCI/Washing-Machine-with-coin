module washingMachine(clk,reset,moeda, lid_r, d_lavar, Tempo, molho, enxague, centrifugar, lavar, pausar, parada, botao_50cent, botao_1real);
 input clk,reset,moeda,lid_r,d_lavar,Tempo;
 output reg molho,enxague,centrifugar,lavar,pausar,parada;
 reg [2:0] count;
 
 reg[2:0] estado_atual, proximo_estado;
 parameter ESPERA = 3'b000,
           MOLHO = 3'b001,
           LAVAR = 3'b010,
		   ENXAGUE = 3'b011,
           LAVAR2 = 3'b100,
           ENXAGUE2 = 3'b101,
           CENTRIFUGAR = 3'b110,
           PAUSAR = 3'b111;
           



/*always @(posedge botao_50cent or posedge botao_1real or negedge reset)
begin
	if(~reset)
		count <= 0;
	else if(botao_50cent == 1)
		count = count + 1;
	if(botao_1real == 1)
		count = count + 2;
end
*/

// ATRIBUIÇÃO DE ESTADO - PARTE COMBINACIONAL

always @(estado_atual or moeda or d_lavar or lid_r or Tempo)
begin
   case (estado_atual)
    ESPERA:
	if(moeda==1)
         begin
         proximo_estado=MOLHO;
         molho=1;
         enxague=0;
         centrifugar=0;
         lavar=0;
         pausar=0;
         parada=0;
         end
else

         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=0;
         pausar=0;
         parada=0;
         end

MOLHO:
if(Tempo==1)													//T = Espera pelo tempo

         begin
         proximo_estado=LAVAR;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=1;
         pausar=0;
         parada=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=1;
         enxague=0;
         centrifugar=0;
         lavar=0;
         pausar=0;
         parada=0;
          end
LAVAR:
if(Tempo==1)

         begin
         proximo_estado=ENXAGUE;
         molho=0;
         enxague=1;
         centrifugar=0;
         lavar=0;
         pausar=0;
         parada=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=1;
         pausar=0;
         parada=0;
         end
ENXAGUE2:
if(Tempo==1 && d_lavar==1)

         begin
         proximo_estado=LAVAR2;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=1;
         pausar=0;
         parada=0;
         end
else if(Tempo==1 && d_lavar==0)

         begin
         proximo_estado=CENTRIFUGAR;
         molho=0;
         enxague=0;
         centrifugar=1;
         lavar=0;
         pausar=0;
         parada=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=1;
         centrifugar=0;
         lavar=0;
         pausar=0;
         parada=0;
         end
LAVAR2:
if(Tempo==1)

         begin
         proximo_estado=ENXAGUE2;
         molho=0;
         enxague=1;
         centrifugar=0;
         lavar=0;
         pausar=0;
         parada=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=1;
         pausar=0;
         parada=0;
         end

ENXAGUE:
if(Tempo==1)
         begin
         proximo_estado=CENTRIFUGAR;
         molho=0;
         enxague=0;
         centrifugar=1;
         lavar=0;
         pausar=0;
         parada=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=1;
         centrifugar=0;
         lavar=0;
         pausar=0;
         parada=0;
         end
CENTRIFUGAR:
if(Tempo==0 && lid_r==1)
         begin
         proximo_estado=PAUSAR;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=0;
         pausar=1;
         parada=0;
         end
else if(Tempo==1)
         begin
         proximo_estado=ESPERA;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=0;
         pausar=0;
         parada=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=0;
         centrifugar=1;
         lavar=0;
         pausar=0;
         parada=0;
         end
PAUSAR:
if(lid_r==0)
         begin
         proximo_estado=CENTRIFUGAR;
         molho=0;
         enxague=0;
         centrifugar=1;
         lavar=0;
         pausar=0;
         parada=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=0;
         pausar=1;
         parada=0;
         end
		 default: proximo_estado=ESPERA;
		 endcase
	end


always @(posedge clk or negedge reset)			// ATRIBUIÇÃO DE FUNÇÃO - PARTE SEQUENCIAL
begin
   if (~reset)
     estado_atual <= ESPERA;
    else
     estado_atual <= proximo_estado;
 end
 

endmodule
