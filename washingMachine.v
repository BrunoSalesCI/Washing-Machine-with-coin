module washingMachine(clk,reset,moeda, lid_r, d_lavar, Tempo, molho, enxague, centrifugar, lavar, pausar, break);
 input clk,reset,moeda,lid_r,d_lavar,Tempo;
 output reg molho,enxague,centrifugar,lavar,pausar,break;
 reg[2:0] estado_atual, proximo_estado;
 parameter ESPERA = 3'b000,
           MOLHO = 3'b001,
           LAVAR = 3'b010,
		   ENXAGUE = 3'b011,
           LAVAR2 = 3'b100,
           ENXAGUE2 = 3'b101,
           CENTRIFUGAR = 3'b110,
           PAUSAR = 3'b111;
           

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
         break=0;
         end
else

         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=0;
         pausar=0;
         break=0;
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
         break=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=1;
         enxague=0;
         centrifugar=0;
         lavar=0;
         pausar=0;
         break=0;
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
         break=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=1;
         pausar=0;
         break=0;
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
         break=0;
         end
else if(Tempo==1 && d_lavar==0)

         begin
         proximo_estado=CENTRIFUGAR;
         molho=0;
         enxague=0;
         centrifugar=1;
         lavar=0;
         pausar=0;
         break=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=1;
         centrifugar=0;
         lavar=0;
         pausar=0;
         break=0;
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
         break=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=1;
         pausar=0;
         break=0;
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
         break=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=1;
         centrifugar=0;
         lavar=0;
         pausar=0;
         break=0;
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
         break=0;
         end
else if(Tempo==1)
         begin
         proximo_estado=ESPERA;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=0;
         pausar=0;
         break=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=0;
         centrifugar=1;
         lavar=0;
         pausar=0;
         break=0;
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
         break=0;
         end
else
         begin
         proximo_estado=estado_atual;
         molho=0;
         enxague=0;
         centrifugar=0;
         lavar=0;
         pausar=1;
         break=0;
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
 
 
/*
  assign molho = (estado_atual == MOLHO);
  assign enxague = (estado_atual == ENXAGUE) | (estado_atual == ENXAGUE2);
  assign brake = (estado_atual == PAUSAR);
  assign centrifugar = (estado_atual == CENTRIFUGAR);
  assign lavar = (estado_atual == LAVAR) | (estado_atual == LAVAR2);
*/


endmodule
