library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE WORK.conexao.all;
use IEEE.NUMERIC_STD.ALL;

entity MPU_final is
    port(
        ce_n, we_n, oe_n  : in std_logic;
        intr             : out std_logic;
        address          : in reg16;
        data             : inout reg16
    );
end MPU_final;

architecture logica of MPU_final is
    type matriz is array (0 to 15) of signed(15 downto 0);
    signal A, B, C : matriz;
	 signal result_32 : signed(31 downto 0) := (others => '0');
	 signal index: integer range 0 to 15 := 0;

    constant tamanho_memoria: integer := 63;
    type mem1 is array (0 to tamanho_memoria) of std_logic_vector(15 downto 0);

    type tipo_estado is (idle, finalizado, add, sub, fill_A, fill_B, fill_C, identidade_A, identidade_B, identidade_C, load, load_A_estado, load_B_estado, load_C_estado, mul_estado, mul_calc, mul_result, mac_estado);
    signal estado: tipo_estado := idle;
	 signal proximo_estado: tipo_estado;

    signal load_A, load_B: boolean := false;
	 signal mac: boolean := false; 

    function matriz_para_vetor(m : matriz) return signed is
        variable vet : signed(15 downto 0);
    begin
        for i in 0 to 15 loop
            vet(i) := m(i)(0);
        end loop;
        return vet;
    end function;

    function vetor_para_matriz(v : signed) return matriz is
        variable m : matriz;
    begin
        for i in 0 to 15 loop
            m(i) := (others => v(i));
        end loop;
        return m;
    end function;

    function vetor_para_inteiro(v : std_logic_vector) return integer is
        variable b : integer;
    begin
        b := to_integer(signed(v));
        return b;
    end function;

begin

    process (ce_n, we_n)
    begin
			if ce_n = '0' then
				
				estado <= proximo_estado;
				
            case estado is
					
					when idle =>
							mac <= false;
							if vetor_para_inteiro(address) >= 0 and vetor_para_inteiro(address) <= 15 then
                        if we_n = '1' then
										elsif address = "0000000000000000" then
											proximo_estado <= add;
										elsif address = "000000000000001" then
											proximo_estado <= sub;
										elsif address = "0000000000000101" then
											proximo_estado <= mul_estado;
										elsif address = "0000000000000110" then
											proximo_estado <= mac_estado;		
								end if;
								
								if we_n = '0' then
										elsif address = "0000000000000010" then
											proximo_estado <= fill_A;
										elsif address = "0000000000000011" then
											proximo_estado <= fill_B;
										elsif address = "0000000000000100" then
											proximo_estado <= fill_C;
										elsif address = "0000000000000111" then
											proximo_estado <= identidade_A;
										elsif address = "0000000000001000" then
											proximo_estado <= identidade_B;
										elsif address = "0000000000001001" then
											proximo_estado <= identidade_C;
								end if;
								
							elsif vetor_para_inteiro(address) >= 16 and vetor_para_inteiro(address) <= 63 then -- linhas 16 a 63
                        if we_n = '0' then
                            proximo_estado <= load;
                        end if;
							end if;

					when add =>
						for i in 0 to 15 loop
							C(i) <= A(i) + B(i);
                  end loop;
                  proximo_estado <= finalizado;

					when sub =>
						for i in 0 to 15 loop
							C(i) <= A(i) - B(i);
                  end loop;
                  proximo_estado <= finalizado;

					when fill_A =>
					   if estado /= proximo_estado then
							for i in 0 to 15 loop
								A(i) <= signed(data);
							end loop;
						end if;
                  proximo_estado <= idle;
						
					when fill_B =>
						if estado /= proximo_estado then
							for i in 0 to 15 loop
								B(i) <= signed(data);
							end loop;
						end if;
                  proximo_estado <= idle;
						
					when fill_C =>
						if estado /= proximo_estado then
							for i in 0 to 15 loop
								C(i) <= signed(data);
							end loop;
						end if;
                  proximo_estado <= idle;

               when identidade_A =>
						if estado /= proximo_estado then
							for i in 0 to 15 loop
								if (i mod 5) = 0 then
									A(i) <= signed(data);
									else
										 A(i) <= (others => '0');
								end if;
							end loop;
						end if;
                  proximo_estado <= idle;
						
					when identidade_B =>
						if estado /= proximo_estado then
							for i in 0 to 15 loop
								if (i mod 5) = 0 then
									B(i) <= signed(data);
									else
										 B(i) <= (others => '0');
								end if;
							end loop;
						end if;
                  proximo_estado <= idle;
					
					when identidade_C =>
						if estado /= proximo_estado then
							for i in 0 to 15 loop
								if (i mod 5) = 0 then
									C(i) <= signed(data);
									else
										 C(i) <= (others => '0');
								end if;
							end loop;
						end if;
                  proximo_estado <= idle;
					

					when load =>
							if vetor_para_inteiro(address) >= 16 and vetor_para_inteiro(address) <= 31 then
                        proximo_estado <= load_C_estado;
							elsif vetor_para_inteiro(address) >= 32 and vetor_para_inteiro(address) <= 47 then
                        proximo_estado <= load_A_estado;
							elsif vetor_para_inteiro(address) >= 48 and vetor_para_inteiro(address) <= 63 then
                        proximo_estado <= load_B_estado;
							end if;

					when load_C_estado =>
						if estado /= proximo_estado then
							case address is
                        when "0000000000010000" => C(0) <= signed(data);
                        when "0000000000010001" => C(1) <= signed(data);
                        when "0000000000010010" => C(2) <= signed(data);
                        when "0000000000010011" => C(3) <= signed(data);
                        when "0000000000010100" => C(4) <= signed(data);
                        when "0000000000010101" => C(5) <= signed(data);
                        when "0000000000010110" => C(6) <= signed(data);
                        when "0000000000010111" => C(7) <= signed(data);
                        when "0000000000011000" => C(8) <= signed(data);
                        when "0000000000011001" => C(9) <= signed(data);
                        when "0000000000011010" => C(10) <= signed(data);
                        when "0000000000011011" => C(11) <= signed(data);
                        when "0000000000011100" => C(12) <= signed(data);
                        when "0000000000011101" => C(13) <= signed(data);
                        when "0000000000011110" => C(14) <= signed(data);
                        when "0000000000011111" => C(15) <= signed(data);
                        when others => null;
                    end case;
						end if;
						  proximo_estado <= idle;

                when load_A_estado =>
						if estado /= proximo_estado then
                    case address is
                        when "0000000000100000" => A(0) <= signed(data); load_A <= true;
                        when "0000000000100001" => A(1) <= signed(data); load_A <= true;
                        when "0000000000100010" => A(2) <= signed(data); load_A <= true;
                        when "0000000000100011" => A(3) <= signed(data); load_A <= true;
                        when "0000000000100100" => A(4) <= signed(data); load_A <= true;
                        when "0000000000100101" => A(5) <= signed(data); load_A <= true;
                        when "0000000000100110" => A(6) <= signed(data); load_A <= true;
                        when "0000000000100111" => A(7) <= signed(data); load_A <= true;
                        when "0000000000101000" => A(8) <= signed(data); load_A <= true;
                        when "0000000000101001" => A(9) <= signed(data); load_A <= true;
                        when "0000000000101010" => A(10) <= signed(data); load_A <= true;
                        when "0000000000101011" => A(11) <= signed(data); load_A <= true;
                        when "0000000000101100" => A(12) <= signed(data); load_A <= true;
                        when "0000000000101101" => A(13) <= signed(data); load_A <= true;
                        when "0000000000101110" => A(14) <= signed(data); load_A <= true;
                        when "0000000000101111" => A(15) <= signed(data); load_A <= true;
                        when others => null;
                    end case;
						end if;
						  proximo_estado <= idle;

                when load_B_estado =>					
						if estado /= proximo_estado then
                    case address is
                        when "0000000000110000" => B(0) <= signed(data); load_B <= true;
                        when "0000000000110001" => B(1) <= signed(data); load_B <= true;
                        when "0000000000110010" => B(2) <= signed(data); load_B <= true;
                        when "0000000000110011" => B(3) <= signed(data); load_B <= true;
                        when "0000000000110100" => B(4) <= signed(data); load_B <= true;
                        when "0000000000110101" => B(5) <= signed(data); load_B <= true;
                        when "0000000000110110" => B(6) <= signed(data); load_B <= true;
                        when "0000000000110111" => B(7) <= signed(data); load_B <= true;
                        when "0000000000111000" => B(8) <= signed(data); load_B <= true;
                        when "0000000000111001" => B(9) <= signed(data); load_B <= true;
                        when "0000000000111010" => B(10) <= signed(data); load_B <= true;
                        when "0000000000111011" => B(11) <= signed(data); load_B <= true;
                        when "0000000000111100" => B(12) <= signed(data); load_B <= true;
                        when "0000000000111101" => B(13) <= signed(data); load_B <= true;
                        when "0000000000111110" => B(14) <= signed(data); load_B <= true;
                        when "0000000000111111" => B(15) <= signed(data); load_B <= true;
                        when others => null;
                    end case;
						end if;
						  proximo_estado <= idle;
						  
					 when mul_estado =>	
						  proximo_estado <= mul_calc;
					 
					 when mul_calc =>
						  if estado /= proximo_estado then
							  case index is
									 when 0 =>
										  result_32 <= (A(0) * B(0)) + (A(1) * B(4)) + (A(2) * B(8)) + (A(3) * B(12));
									 when 1 =>
										  result_32 <= (A(0) * B(1)) + (A(1) * B(5)) + (A(2) * B(9)) + (A(3) * B(13));
									 when 2 =>
										  result_32 <= (A(0) * B(2)) + (A(1) * B(6)) + (A(2) * B(10)) + (A(3) * B(14));
									 when 3 =>
										  result_32 <= (A(0) * B(3)) + (A(1) * B(7)) + (A(2) * B(11)) + (A(3) * B(15));
									 when 4 =>
										  result_32 <= (A(4) * B(0)) + (A(5) * B(4)) + (A(6) * B(8)) + (A(7) * B(12));
									 when 5 =>
										  result_32 <= (A(4) * B(1)) + (A(5) * B(5)) + (A(6) * B(9)) + (A(7) * B(13));
									 when 6 =>
										  result_32 <= (A(4) * B(2)) + (A(5) * B(6)) + (A(6) * B(10)) + (A(7) * B(14));
									 when 7 =>
										  result_32 <= (A(4) * B(3)) + (A(5) * B(7)) + (A(6) * B(11)) + (A(7) * B(15));
									 when 8 =>
										  result_32 <= (A(8) * B(0)) + (A(9) * B(4)) + (A(10) * B(8)) + (A(11) * B(12));
									 when 9 =>
										  result_32 <= (A(8) * B(1)) + (A(9) * B(5)) + (A(10) * B(9)) + (A(11) * B(13));
									 when 10 =>
										  result_32 <= (A(8) * B(2)) + (A(9) * B(6)) + (A(10) * B(10)) + (A(11) * B(14));
									 when 11 =>
										  result_32 <= (A(8) * B(3)) + (A(9) * B(7)) + (A(10) * B(11)) + (A(11) * B(15));
									 when 12 =>
										  result_32 <= (A(12) * B(0)) + (A(13) * B(4)) + (A(14) * B(8)) + (A(15) * B(12));
									 when 13 =>
										  result_32 <= (A(12) * B(1)) + (A(13) * B(5)) + (A(14) * B(9)) + (A(15) * B(13));
									 when 14 =>
										  result_32 <= (A(12) * B(2)) + (A(13) * B(6)) + (A(14) * B(10)) + (A(15) * B(14));
									 when 15 =>
										  result_32 <= (A(12) * B(3)) + (A(13) * B(7)) + (A(14) * B(11)) + (A(15) * B(15));
									 when others =>
										  result_32 <= (others => '0'); 
							  end case;
						  end if;
						  proximo_estado <= mul_result;
					 
					 when mul_result =>
						  if mac = true then
								C(index) <= C(index) + result_32(15 downto 0);
						  else
								C(index) <= result_32(15 downto 0);
						  end if;
						  
						  if index = 15 then
								proximo_estado <= idle;
						  else
								index <= index + 1;
								proximo_estado <= mul_calc;
						  end if;
					 
					 when mac_estado =>
						  mac <= true;
						  proximo_estado <= mul_calc;
						  
                when finalizado =>
						  proximo_estado <= idle;

                when others =>
                    null;
            end case;
        end if;
    end process;

    process (estado)
    begin
        case estado is
            when idle =>
                intr <= '1';
            when finalizado =>
                intr <= '0';
            when others =>
                null;
        end case;
    end process;

end logica;