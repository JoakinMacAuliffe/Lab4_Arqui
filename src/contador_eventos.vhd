----------------------------------------------------------------------------------
-- Módulo: contador_eventos
-- Descripción: Contador ascendente BCD de dos dígitos (00 a 99).
--              - Inicia en 00.
--              - Incrementa una unidad por cada pulso en EVENTO.
--              - Al alcanzar 99, mantiene su valor (saturación) hasta ser reiniciado.
--              - Permite reinicio general (RESET) o independiente (RESET_EVENTO).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador_eventos is
    Port (
        CLK          : in  STD_LOGIC;
        RESET        : in  STD_LOGIC;
        RESET_EVENTO : in  STD_LOGIC;
        EVENTO       : in  STD_LOGIC;
        DEC_EVENTO   : out STD_LOGIC_VECTOR(3 downto 0);
        UNI_EVENTO   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end contador_eventos;

architecture Behavioral of contador_eventos is
    signal dec_reg : unsigned(3 downto 0) := (others => '0');
    signal uni_reg : unsigned(3 downto 0) := (others => '0');
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' or RESET_EVENTO = '1' then
                dec_reg <= (others => '0');
                uni_reg <= (others => '0');
            elsif EVENTO = '1' then
                if dec_reg = 9 and uni_reg = 9 then
                    -- Saturación en 99: mantiene el valor máximo
                    dec_reg <= to_unsigned(9, 4);
                    uni_reg <= to_unsigned(9, 4);
                elsif uni_reg = 9 then
                    -- Acarreo BCD a las decenas (ej. 09 -> 10)
                    uni_reg <= to_unsigned(0, 4);
                    dec_reg <= dec_reg + 1;
                else
                    -- Incremento normal de unidades
                    uni_reg <= uni_reg + 1;
                end if;
            end if;
        end if;
    end process;

    DEC_EVENTO <= std_logic_vector(dec_reg);
    UNI_EVENTO <= std_logic_vector(uni_reg);

end Behavioral;

