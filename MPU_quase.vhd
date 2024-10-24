library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MPU_quase is
    port(
        ce_n, we_n, oe_n  : in std_logic;
        intr             : out std_logic;
        address          : in std_logic_vector(15 downto 0);
        data             : inout signed(15 downto 0)
    );
end MPU_quase;

architecture logica of MPU_quase is
    type matriz is array (0 to 15) of signed(15 downto 0);
    signal A, B, M : matriz;
    signal C : matriz;

    constant tamanho_memoria: integer := 63;
    type mem1 is array (0 to tamanho_memoria) of std_logic_vector(15 downto 0);
    signal RAM: mem1;

    type tipo_estado is (idle, finalizado, add, sub, fill, identidade, load, load_A_estado, load_B_estado, load_C_estado);
    signal estado: tipo_estado := idle;
	 signal proximo_estado: tipo_estado;

    signal load_A, load_B: boolean := false;

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

    process (ce_n,we_n)
    begin
			if ce_n = '0' then
				
				estado <= proximo_estado;
				
            case estado is
					
					when idle =>
							if vetor_para_inteiro(address) >= 0 and vetor_para_inteiro(address) <= 15 then
                        if we_n = '1' then
										if address = "0000000000000000" then
											proximo_estado <= add;
										elsif address = "0000000000000001" then
											proximo_estado <= sub;
										elsif address = "0000000000000100" then
											proximo_estado <= fill;
										elsif address = "0000000000000101" then
											proximo_estado <= identidade;
										end if;
								end if;
							elsif vetor_para_inteiro(address) >= 16 and vetor_para_inteiro(address) <= 63 then
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

					when fill =>
                  for i in 0 to 15 loop
                     M(i) <= data;
                  end loop;
                  proximo_estado <= finalizado;

               when identidade =>
						for i in 0 to 15 loop
							if (i mod 5) = 0 then
                        M(i) <= (others => '1');
								else
                            M(i) <= (others => '0');
                     end if;
                  end loop;
                  proximo_estado <= finalizado;

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
                        when "0000000000010000" => C(0) <= data;
                        when "0000000000010001" => C(1) <= data;
                        when "0000000000010010" => C(2) <= data;
                        when "0000000000010011" => C(3) <= data;
                        when "0000000000010100" => C(4) <= data;
                        when "0000000000010101" => C(5) <= data;
                        when "0000000000010110" => C(6) <= data;
                        when "0000000000010111" => C(7) <= data;
                        when "0000000000011000" => C(8) <= data;
                        when "0000000000011001" => C(9) <= data;
                        when "0000000000011010" => C(10) <= data;
                        when "0000000000011011" => C(11) <= data;
                        when "0000000000011100" => C(12) <= data;
                        when "0000000000011101" => C(13) <= data;
                        when "0000000000011110" => C(14) <= data;
                        when "0000000000011111" => C(15) <= data;
                        when others => null;
                    end case;
						end if;
						  proximo_estado <= idle;

                when load_A_estado =>
						if estado /= proximo_estado then
                    case address is
                        when "0000000000100000" => A(0) <= data; load_A <= true;
                        when "0000000000100001" => A(1) <= data; load_A <= true;
                        when "0000000000100010" => A(2) <= data; load_A <= true;
                        when "0000000000100011" => A(3) <= data; load_A <= true;
                        when "0000000000100100" => A(4) <= data; load_A <= true;
                        when "0000000000100101" => A(5) <= data; load_A <= true;
                        when "0000000000100110" => A(6) <= data; load_A <= true;
                        when "0000000000100111" => A(7) <= data; load_A <= true;
                        when "0000000000101000" => A(8) <= data; load_A <= true;
                        when "0000000000101001" => A(9) <= data; load_A <= true;
                        when "0000000000101010" => A(10) <= data; load_A <= true;
                        when "0000000000101011" => A(11) <= data; load_A <= true;
                        when "0000000000101100" => A(12) <= data; load_A <= true;
                        when "0000000000101101" => A(13) <= data; load_A <= true;
                        when "0000000000101110" => A(14) <= data; load_A <= true;
                        when "0000000000101111" => A(15) <= data; load_A <= true;
                        when others => null;
                    end case;
						end if;
						  proximo_estado <= idle;

                when load_B_estado =>					
						if estado /= proximo_estado then
                    case address is
                        when "0000000000110000" => B(0) <= data; load_B <= true;
                        when "0000000000110001" => B(1) <= data; load_B <= true;
                        when "0000000000110010" => B(2) <= data; load_B <= true;
                        when "0000000000110011" => B(3) <= data; load_B <= true;
                        when "0000000000110100" => B(4) <= data; load_B <= true;
                        when "0000000000110101" => B(5) <= data; load_B <= true;
                        when "0000000000110110" => B(6) <= data; load_B <= true;
                        when "0000000000110111" => B(7) <= data; load_B <= true;
                        when "0000000000111000" => B(8) <= data; load_B <= true;
                        when "0000000000111001" => B(9) <= data; load_B <= true;
                        when "0000000000111010" => B(10) <= data; load_B <= true;
                        when "0000000000111011" => B(11) <= data; load_B <= true;
                        when "0000000000111100" => B(12) <= data; load_B <= true;
                        when "0000000000111101" => B(13) <= data; load_B <= true;
                        when "0000000000111110" => B(14) <= data; load_B <= true;
                        when "0000000000111111" => B(15) <= data; load_B <= true;
                        when others => null;
                    end case;
						end if;
						  proximo_estado <= idle;

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