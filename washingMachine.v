module washing_Machine(
		input CLOCK_27,  //Clock
		output reg [3:0] LEDG,		//bomba_agua = 1000, modo_agitar = 0100, modo_centrifugar = 0001, modo_girar = 0010
		output reg [6:0] HEX6,
		output reg [6:0] HEX4,
		output reg [6:0] HEX7,
		output reg [6:0] HEX5,
		output reg [6:0] HEX3,
		output reg [6:0] HEX2,
		output reg [6:0] HEX0,
		output reg GPIO,
		input wire [1:0] SW, //controle de modos
		output reg [17:0] LEDR);  //usado para teste e visualizaÃ§Ã£o do contador que controla
																	  //o contador que muda de estado

	initial HEX6 = 7'b1111111;
	initial HEX4 = 7'b1111111;
	integer contador = 0;	//contador que gerencia os estados
	integer jaContou;	//variavel que assegura que o contador nÃ£o incrementa varias vezes por conta da velocidade do clock
	reg flag = 0;		//flag para zerar o contador
	
	reg [23:0] cnt;									//cnt Ã© um contador que funciona como prescaler
	always @(posedge CLOCK_27) cnt <= cnt+24'h1;
	wire cntovf = &cnt;

						//Dando Set no contador baseado no clock interno
	reg [3:0] UNI;		//UNI eh um contador que conta de 0 a 9
	always @(posedge CLOCK_27) begin		
		if(cntovf) UNI = (UNI==4'h9 ? 4'h0 : UNI+4'h1);	//incrementa o uni ou zera se seu valor for 9
	end													//essa variaÃ§Ã£o acontece num tempo prÃ³ximo de 1 segundo
	


	reg [1:0] modo; 	//variavel que guarda o modo da maquina de lavar
	
	parameter modo_espera = 0, limpeza_padrao = 1, limpeza_rapida = 2;	 //modos
	
	always @ (posedge CLOCK_27) begin	//selecao de modo
		case (SW[1:0])
			2'b00:
			begin
				HEX3 = 7'b1000110;
				HEX2 = 7'b1000111;								//CL2 NO DISPLAY
				HEX0 = 7'b0100100;
				HEX7 = 7'b0010010;								//SIMPLES (S) NO DISPLAY
				HEX5 = 7'b1000110;								//COMPLETO (C) NO DISPLAY
				LEDR = 18'b000000000000000000;
				modo <= modo_espera;	//maquina em espera
			end
			2'b01: 
			begin
				HEX3 = 7'b1000110;
				HEX2 = 7'b1000111;								//CL2 NO DISPLAY
				HEX0 = 7'b0100100;
				HEX7 = 7'b0010010;
				HEX5 = 7'b1000110;
				modo <= limpeza_padrao;		//ciclo completo
			end
			2'b10: 
			begin
				HEX3 = 7'b1000110;
				HEX2 = 7'b1000111;								//CL2 NO DISPLAY
				HEX0 = 7'b0100100;
				HEX7 = 7'b0010010;
				HEX5 = 7'b1000110;
				modo <= limpeza_rapida;		//ciclo simplificado
			end
			2'b11:						//caso de erro
			begin
				HEX3 = 7'b1000110;
				HEX2 = 7'b1000111;								//CL2 NO DISPLAY
				HEX0 = 7'b0100100;
				HEX7 = 7'b1111111;
				HEX5 = 7'b1111111;
				LEDR = 18'b111111111111111111;	//sinal de erro que indica que os dois modos nÃo podem estar ativos ao mesmo tempo
				modo <= modo_espera;
			end
		endcase
	end
	
	initial GPIO = 1'b0;
	
	always@ (posedge CLOCK_27) begin //controle do contador que gerencia os estados
		if(UNI == 4'h0)				//zera o jaContou quando UNI chega em 0 para o contador ir para a prÃ³xima etapa
			jaContou = 0;

		if (UNI == 4'h9 && ((SW == 2'b01) || (SW == 2'b10)) && jaContou == 0) begin		//incrementa o contador
			contador = contador + 1;
			jaContou = 1;
		end

		if (SW == 2'b00)	//se os dois switchs estiverem desligados, o contador que gerencia os estados nÃ£o incrementa
			contador = 0;

	end
	
	
	always @ (posedge CLOCK_27) begin 	//funcionalidade
		case (modo)
			modo_espera:
			begin
				HEX4 = 7'b1111111;
				HEX6 = 7'b1111111; 	// PARTE PARA TESTAR
				LEDG = 4'b0000;
			end
							//contador:
			limpeza_padrao:	//espera = 0, encher = 1, agitar = 2, tempo = 3, agitar2 = 4, esvaziar = 5, centrifugar = 6, fim = 7
			begin
				//espera >> encher
				if(contador == 1) begin											//ENCHER
					GPIO <= 1'b0;
					HEX4 = 7'b0000110;
					LEDG = 4'b1000;
				end
				
				//enchendo >> modo agitar
				if (contador == 2) begin										//AGITAR
					GPIO <= 1'b1;
					HEX4 = 7'b0001000;
					LEDG = 4'b0100;	
				end

				//agitar >> tempo
				if (contador == 3) begin										//PAUSA, MOLHO
					GPIO <= 1'b0;
					HEX4 = 7'b0001100;
					LEDG = 4'b0010;
				end

				//tempo >> agitar2
				if (contador == 4) begin										//AGITAR 2
					GPIO <= 1'b1;
					HEX4 = 7'b0001000;
					LEDG = 4'b0100;
				
				end

				//agitar2 >> esvaziar
				if (contador == 5) begin
					GPIO <= 1'b0;
					HEX4 = 7'b0100001;											//DRENAR
					LEDG = 4'b0000;
				end

				//esvaziar >> centrifugar
				if (contador == 6) begin
					GPIO <= 1'b1;
					HEX4 = 7'b1000110;											//CENTRIFUGAR
					LEDG = 4'b0001;
				end

				//centrifugar >> fim
				if (contador == 7) begin
					GPIO <= 1'b0;
					HEX4 = 7'b0001110;											//FIM		
					LEDG = 4'b1111;
				end

			end
							//contador:
			limpeza_rapida:	//espera = 0, encher = 1, agitar = 2, esvaziar = 3, centrifugar = 4, fim = 5

				
				begin	
					//espera >> encher
					if(contador == 1) begin
						GPIO <= 1'b0;
						HEX6 = 7'b0000110;										//ENCHER
						LEDG = 4'b1000;
					end

					//enchendo >> modo agitar
					if (contador == 2) begin
						GPIO <= 1'b1;
						HEX6 = 7'b0001000;										//AGITAR
						LEDG = 4'b0100;
					end

					//agitar >> esvaziar
					if (contador == 3) begin
						GPIO <= 1'b0;
						HEX6 = 7'b0100001;									//DRENAR
						LEDG = 4'b0000;
					end
					
					//esvaziar >> centrifugar
					if (contador == 4) begin
						GPIO <= 1'b1;
						HEX6 = 7'b1000110;										//CENTRIFUGAR
						LEDG = 4'b0001;
					end

					//centrifugar >> fim
					if (contador == 5) begin
						GPIO <= 1'b0;
						HEX6 = 7'b0001110;										//FIM
						LEDG = 4'b1111;
					end

				end
		endcase
	end
endmodule
