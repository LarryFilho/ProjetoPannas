library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MPU_teste2 is
    port(
        ce_n, we_n, oe_n  : in std_logic;
        intr             : out std_logic;
        address          : in std_logic_vector(15 downto 0);
        data             : inout signed(15 downto 0)
    );
end MPU_teste2;

architecture logica of MPU_teste2 is
    type matriz is array (0 to 15) of signed(15 downto 0);
    signal A, B, C, M : matriz;
	 
	 type tipo_estado is (load, preparado);
    signal estado : tipo_estado := load;
	 signal load_A, load_B : boolean := false;

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

begin

	process (ce_n, we_n, oe_n, address, load_A, load_B)
		begin
			if ce_n = '0' then
				
				if we_n = '0' then
					
					case address is
						
						when "0000000000000000" =>
							A <= vetor_para_matriz(data);
							load_A <= true;
							  
						when "0000000000000001"	=>
							B <= vetor_para_matriz(data);
							load_B <= true;
							  
						when "0000000000000010" =>
							C <= vetor_para_matriz(data);
											
						when "0000000000000100" =>
								for i in 0 to 15 loop
									M(i) <= (others => data(0));
								end loop;
								data <= matriz_para_vetor(M);

						when "0000000000000101" =>
								for i in 0 to 15 loop
									if (i mod 5) = 0 then
										M(i) <= (others => '1');
									else
										M(i) <= (others => '0');
									end if;
								end loop;
								data <= matriz_para_vetor(M);
								
						when others =>
                       null;
								
					end case;	
						
					if load_A and load_B then
                   estado <= preparado;
					end if;
						
				end if;
				
				if estado = preparado then
					
					if oe_n = '0' then
					
						case address is
								
							when "0000000000000000" =>
									for i in 0 to 15 loop
										C(i) <= A(i) + B(i);
									end loop;
									data <= matriz_para_vetor(C);

							when "0000000000000001" =>
									for i in 0 to 15 loop
										C(i) <= A(i) - B(i);
									end loop;
									data <= matriz_para_vetor(C);

							when others =>
									null;
									
						end case;
				
					end if;
					
				end if;
				
			end if;
		
	end process;
		
end logica;