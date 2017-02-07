----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:52:28 11/06/2016 
-- Design Name: 
-- Module Name:    processamento - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.Numeric_Std.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity processamento is
Port ( clock : in  STD_LOGIC;
		 reset : in  STD_LOGIC;
		 op : in STD_LOGIC_VECTOR(1 DOWNTO 0);
		 imagemIn : in STD_LOGIC_VECTOR(7 DOWNTO 0);
		 imagemOut : out STD_LOGIC_VECTOR(7 DOWNTO 0)
	   );
end processamento;

architecture Behavioral of processamento is
	--CONSTANTE DO TAMANHO DA IMAGEM
	constant TAMANHODAIMAGEM : INTEGER := 256;
	constant INICIOLINHA : INTEGER := 0;
	constant FIMLINHA : INTEGER := 15;

	--VARIAVEIS PARA USAR A MEMORIA PRINCIPAL
	signal we : STD_LOGIC := '0'; --Sinal
	signal dataIn : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal address : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal dataOut : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	--ESTADOS PARA OS OPERADORES MORFOLOGICOS
	type state_type IS (s0, s1, s2, s3, s4);
	signal state : state_type; 
	
	
	--VARIAVEIS DAS MEMORIAS DOS OPERADORES MORFOLOGICOS	
	
	--VARIAVEIRS DE EROSAO
	signal weErosao : STD_LOGIC := '0';
	signal addressErosao : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	signal dataInErosao : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal dataOutErosao : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	--VARIAVEIS DE DILATACAO
	signal weDilatacao : STD_LOGIC := '0';
	signal addressDilatacao : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	signal dataInDilatacao : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal dataOutDilatacao : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	--VARIAVEIS DE GRADIENTE
	signal weGradiente : STD_LOGIC := '0';
	signal addressGradiente : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	signal dataInGradiente : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal dataOutGradiente : STD_LOGIC_VECTOR(7 DOWNTO 0);
	

begin
	--INSTANCIACAO DA MEMORIA PRINCIPAL
	RAM: entity work.memoria port map(clock, we, address, dataIn, dataOut);
	
	--INSTANCIACAO DA MEMORIA PARA OS OPERADORES MORFOLOGICOS
	EROSAO: entity work.memoria port map(clock, weErosao, addressErosao, dataInErosao, dataOutErosao);
	DILATACAO: entity work.memoria port map(clock, weDilatacao, addressDilatacao, dataInDilatacao, dataOutDilatacao);
	GRADIENTE: entity work.memoria port map(clock, weGradiente, addressGradiente, dataInGradiente, dataOutGradiente);

	process(clock,reset,op,imagemIn)
		variable posicaoMemoria, opComparacao, colunaImagem : INTEGER := 0;
		variable pAtual, pProximo, pAnterior : STD_LOGIC_VECTOR(7 DOWNTO 0);
	begin
		if reset = '1' then --SE O RESET ESTIVER LIGADO
			state <= s0; --INICIA NO ESTADO S0
			we <= '1'; --COLOCA A MEMORIA PRINCIPAL PARA SALVAR
		end if;
		
		case state is
			when s0 => --S0: GRAVA IMAGEM NA MEMORIA PRINCIPAL
				if posicaoMemoria < TAMANHODAIMAGEM then --SE NAO CHEGOU NO FIM DA IMAGEM
					if falling_edge(clock) then --QUANDO O CLOCK FOR 0
						dataIn <= imagemIn; --LE A IMAGEM E PASSA PARA O DATAIN DA MEM PRINCIPAL
						address <= std_logic_vector(to_unsigned(posicaoMemoria, address'length)); --PASSA O ENDERECO
						posicaoMemoria := posicaoMemoria + 1; --VAI PARA A PROXIMA POSICAO
					end if;	--QUANDO O CLOCK FOR 1, EH SALVO NA MEMORIA
				else --SE CHEGOU NO FIM DA IMAGEM
					if falling_edge(clock) then --QUANDO O CLOCK FOR 0
						we <= '0'; --COLOCA A MEMORIA PRINCIPAL PARA LEITURA
						posicaoMemoria := 0; --ZERA O CONTADOR DE POSICAO
						address <= (others => '0'); --COLOCA O ENDERECO NA PRIMEIRA POSICAO
						case op is --LE O OPERADOR
							when "00" => state <= s1; --SE O OP FOR 00 FAZ A EROSAO
							when "01" => state <= s2; --SE FOR 01 FAZ A DILATACAO
							when "10" => state <= s1; --SE FOR 10 FAZ O GRADIENTE (PASSA POR TODOS OS ESTADOS)
							when others => 			  --SE DIGITOU QUALQUER OUTRA COISA NAO FAZ NADA
						end case;						
					end if;	
				end if;	
			
			when s1 => --S1: OPERADOR DE EROSAO (VIZINHOS < POSICAO LIDA)
				if posicaoMemoria < TAMANHODAIMAGEM then --SE NAO CHEGOU AO FIM DA IMAGEM
					weErosao <= '1'; --COLOCA A MEMORIA DE EROSAO PARA SALVAR
					if falling_edge(clock) then --QUANDO O CLOCK ESTIVER EM 0
						if opComparacao = 0 then --SE O OPERADOR ESTA EM 0
							pAtual := dataOut; --PASSA O VALOR DA MEM PRINCIPAL PARA A VAR QUE SERA COMPARADA COM O VIZINHO
							opComparacao := opComparacao + 1; --ADICIONA +1 NO OP
						elsif	opComparacao = 1 then --SE O OP ESTA EM 1
							pProximo := dataOut; --PASSA O VALOR DO VIZINHO 
							opComparacao := opComparacao + 1; --ADICIONA +1 NO OP
						else --SE O OP NAO FOR 0 OU 1
							dataInErosao <= pAtual; --PASSA O RESULTADO DAS COMPARACOES 
							addressErosao <= std_logic_vector(to_unsigned(posicaoMemoria, address'length)); --LE O ENDERECO
							posicaoMemoria := posicaoMemoria + 1; --ADICIONA +1 PARA IR PARA A PROXIMA POSICAO
							opComparacao := 0; --ZERA O OP PARA INICIAR A PROXIMA COMPARACAO
							colunaImagem := colunaImagem + 1; --ADICIONA +1 NO CONTADOR DE COLUNA
							if	 colunaImagem > FIMLINHA then
								colunaImagem := 0; --ZERA O CONTADOR DE COLUNAS
							end if;
							pAnterior := pAtual; --SALVA NA O RESULTADO COMO VIZINHO ANTERIOR
						end if;	
					else --QUANDO O CLOCK ESTIVER EM 1 (O ESTADO S1 TEM INICIO COM O CLOCK EM 1)
						address <= std_logic_vector(to_unsigned(posicaoMemoria+1, address'length)); --PASSA O PROXIMO ENDERECO DA MEM PRINCIPAL 
						if opComparacao = 2 then --SE O OPERADOR ESTA EM 2, FAZ A COMPARACAO
							if colunaImagem = INICIOLINHA then --SE A VAR ESTIVER NA PRIMEIRA COLUNA
								if pProximo < pAtual then --VERIFICA COM O PROXIMO VIZINHO APENAS
									pAtual := pProximo; --SE O VIZINHO FOR MENOR PASSA O RESULTADO PARA A VAR 
								end if;
							elsif colunaImagem = FIMLINHA then --SE A VAR ESTIVER NA ULTIMA COLUNA
								if pAnterior < pAtual then --VERIFICA COM O VIZINHO ANTERIOR APENAS
									pAtual := pAnterior; --SE O VIZINHO FOR MENOR PASSA O RESULTADO PARA A VAR
								end if;	
							else --SE A VAR ESTIVER ENTRA A PRIMEIRA COLUNA E A ULTIMA
								if pAnterior < pAtual then --VERIFICA SE O VIZINHO ANTERIOR EH MENOR
									pAtual := pAnterior; --SE FOR PASSA O VALOR PARA A VAR
								end if; --INDEPENDENTE DO RESULTADO ANTERIOR EH FEITO A COMPARACAO COM O PROXIMO VIZINHO
								if pProximo < pAtual then --VERIFICA SE O PROXIMO VIZINHO EH MENOR
									pAtual := pProximo; --SE FOR PASSA O VALOR PARA A VAR
								end if;							
							end if;	
							opComparacao := opComparacao + 1; --ADICIONA +1 NO OP PARA SALVAR O RESULTADO
						end if;						
					end if;	
				else	
					if falling_edge(clock) then --QUANDO O CLOCK FOR 0
						weErosao <= '0'; --COLOCA A MEMORIA DA EROSAO PARA LEITURA
						posicaoMemoria := 0; --ZERA O CONTADOR DE POSICAO
						address <= (others => '0'); --COLOCA O ENDERECO NA PRIMEIRA POSICAO
						addressErosao <= (others => '0'); --COLOCA O ENDERECO DA EROSAO NA PRIMEIRA POSICAO
						case op is --LE O OPERADOR
							when "00" => state <= s4; --SE O OP FOR 00 FAZ A GRAVACAO NA MEMORIA 
							when "10" => state <= s2; --SE FOR 10 FAZ A DILATACAO
							when others => 			  --SE DIGITOU QUALQUER OUTRA COISA NAO FAZ NADA
						end case;						
					end if;
				end if;
				
			when s2 => --S2: OPERADOR DE DILATACAO (VIZINHOS > POSICAO LIDA)
				if posicaoMemoria < TAMANHODAIMAGEM then --SE NAO CHEGOU AO FIM DA IMAGEM
					weDilatacao <= '1'; --COLOCA A MEMORIA DE DILATACAO PARA SALVAR
					if falling_edge(clock) then --QUANDO O CLOCK ESTIVER EM 0
						if opComparacao = 0 then --SE O OPERADOR ESTA EM 0
							pAtual := dataOut; --PASSA O VALOR DA MEM PRINCIPAL PARA A VAR QUE SERA COMPARADA COM O VIZINHO
							opComparacao := opComparacao + 1; --ADICIONA +1 NO OP
						elsif	opComparacao = 1 then --SE O OP ESTA EM 1
							pProximo := dataOut; --PASSA O VALOR DO VIZINHO 
							opComparacao := opComparacao + 1; --ADICIONA +1 NO OP
						else --SE O OP NAO FOR 0 OU 1
							dataInDilatacao <= pAtual; --PASSA O RESULTADO DAS COMPARACOES 
							addressDilatacao <= std_logic_vector(to_unsigned(posicaoMemoria, address'length)); --LE O ENDERECO
							posicaoMemoria := posicaoMemoria + 1; --ADICIONA +1 PARA IR PARA A PROXIMA POSICAO
							opComparacao := 0; --ZERA O OP PARA INICIAR A PROXIMA COMPARACAO
							colunaImagem := colunaImagem + 1; --ADICIONA +1 NO CONTADOR DE COLUNA
							if	 colunaImagem > FIMLINHA then
								colunaImagem := 0; --ZERA O CONTADOR DE COLUNAS
							end if;
							pAnterior := pAtual; --SALVA NA O RESULTADO COMO VIZINHO ANTERIOR
						end if;	
					else --QUANDO O CLOCK ESTIVER EM 1 (O ESTADO S1 TEM INICIO COM O CLOCK EM 1)
						address <= std_logic_vector(to_unsigned(posicaoMemoria+1, address'length)); --PASSA O PROXIMO ENDERECO DA MEM PRINCIPAL 
						if opComparacao = 2 then --SE O OPERADOR ESTA EM 2, FAZ A COMPARACAO
							if colunaImagem = INICIOLINHA then --SE A VAR ESTIVER NA PRIMEIRA COLUNA
								if pProximo > pAtual then --VERIFICA COM O PROXIMO VIZINHO APENAS
									pAtual := pProximo; --SE O VIZINHO FOR MAIOR PASSA O RESULTADO PARA A VAR 
								end if;
							elsif colunaImagem = FIMLINHA then --SE A VAR ESTIVER NA ULTIMA COLUNA
								if pAnterior > pAtual then --VERIFICA COM O VIZINHO ANTERIOR APENAS
									pAtual := pAnterior; --SE O VIZINHO FOR MAIOR PASSA O RESULTADO PARA A VAR
								end if;	
							else --SE A VAR ESTIVER ENTRA A PRIMEIRA COLUNA E A ULTIMA
								if pAnterior > pAtual then --VERIFICA SE O VIZINHO ANTERIOR EH MAIOR
									pAtual := pAnterior; --SE FOR PASSA O VALOR PARA A VAR
								end if; --INDEPENDENTE DO RESULTADO ANTERIOR EH FEITO A COMPARACAO COM O PROXIMO VIZINHO
								if pProximo > pAtual then --VERIFICA SE O PROXIMO VIZINHO EH MAIOR
									pAtual := pProximo; --SE FOR PASSA O VALOR PARA A VAR
								end if;							
							end if;	
							opComparacao := opComparacao + 1; --ADICIONA +1 NO OP PARA SALVAR O RESULTADO
						end if;						
					end if;	
				else	
					if falling_edge(clock) then --QUANDO O CLOCK FOR 0
						weDilatacao <= '0'; --COLOCA A MEMORIA DA DILATACAO PARA LEITURA
						posicaoMemoria := 0; --ZERA O CONTADOR DE POSICAO
						address <= (others => '0'); --COLOCA O ENDERECO NA PRIMEIRA POSICAO
						addressDilatacao <= (others => '0'); --COLOCA O ENDERECO DA DILATACAO NA PRIMEIRA POSICAO
						case op is --LE O OPERADOR
							when "01" => state <= s4; --SE O OP FOR 01 FAZ A GRAVACAO NA MEMORIA 
							when "10" => state <= s3; --SE FOR 10 FAZ O GRADIENTE
							when others => 			  --SE DIGITOU QUALQUER OUTRA COISA NAO FAZ NADA
						end case;						
					end if;
				end if;
				
			when s3 => --S3: OPERADOR DE GRADIENTE (DILATACAO - EROSAO)
				if posicaoMemoria < TAMANHODAIMAGEM then --SE NAO CHEGOU AO FIM DA IMAGEM
					weGradiente <= '1';
					if falling_edge(clock) then
						dataInGradiente <= dataOutDilatacao - dataOutErosao; --PASSA O RESULTADO DAS COMPARACOES 
						addressGradiente <= std_logic_vector(to_unsigned(posicaoMemoria, address'length)); --LE O ENDERECO
						posicaoMemoria := posicaoMemoria + 1; --ADICIONA +1 PARA IR PARA A PROXIMA POSICAO
					else
						addressErosao <= std_logic_vector(to_unsigned(posicaoMemoria+1, address'length)); --PASSA O PROXIMO ENDERECO DA MEM DA EROSAO 
						addressDilatacao <= std_logic_vector(to_unsigned(posicaoMemoria+1, address'length)); --PASSA O PROXIMO ENDERECO DA MEM DA DILATACAO 
					end if;
				else
					if falling_edge(clock) then --QUANDO O CLOCK FOR 0
						weGradiente <= '0'; --COLOCA A MEMORIA DO GRADIENTE PARA LEITURA
						posicaoMemoria := 0; --ZERA O CONTADOR DE POSICAO
						addressGradiente <= (others => '0'); --COLOCA O ENDERECO DA DILATACAO NA PRIMEIRA POSICAO
						state <= s4; --PASSA PARA O ESTADO DA GRAVACAO NA MEMORIA 					
					end if;
				end if;
				
			when s4 => --S4: GRAVACAO DOS RESULTADOS NA MEMORIA
				if posicaoMemoria < TAMANHODAIMAGEM then --SE NAO CHEGOU AO FIM DA IMAGEM
					we <= '1'; --COLOCA A MEMORIA PRINCIPAL PARA SALVAR
					if falling_edge(clock) then --QUANDO O CLOCK FOR 0
						case op is --LE O OPERADOR
							when "00" => dataIn <= dataOutErosao; --SE O OP FOR 00 LE O DATAOUT DA EROSAO
							when "01" => dataIn <= dataOutDilatacao; --SE FOR 01 LE O DATAOUT DA DILATACAO
							when "10" => dataIn <= dataOutGradiente; --SE FOR 10 LE O DATAOUT DO GRADIENTE
							when others => 			  --SE DIGITOU QUALQUER OUTRA COISA NAO FAZ NADA
						end case;
						address <= std_logic_vector(to_unsigned(posicaoMemoria, address'length)); --PASSA O ENDERECO
						posicaoMemoria := posicaoMemoria + 1; --VAI PARA A PROXIMA POSICAO
					else
						case op is --LE O OPERADOR
							when "00" => addressErosao <= std_logic_vector(to_unsigned(posicaoMemoria+1, address'length)); --SE O OP FOR 00 LE A MEM DA EROSAO
							when "01" => addressDilatacao <= std_logic_vector(to_unsigned(posicaoMemoria+1, address'length)); --SE FOR 01 LE A MEMO DA DILATACAO
							when "10" => addressGradiente <= std_logic_vector(to_unsigned(posicaoMemoria+1, address'length)); --SE FOR 10 LE A MEMO DO GRADIENTE
							when others => 			  --SE DIGITOU QUALQUER OUTRA COISA NAO FAZ NADA
						end case;						
					end if;
				end if;
				
		end case;
	end process;
	
end Behavioral;

