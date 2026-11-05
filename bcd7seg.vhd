----------------------------------------------------------------------------------
-- Módulo: bcd7seg
-- Descripción: Decodificador de BCD (4 bits) a display de 7 segmentos.
--              Diseñado para los displays de ánodo común (activos en bajo)
--              de la placa Nexys 4 DDR: '0' enciende el segmento, '1' lo apaga.
--              Orden de bits: SEG(6 downto 0) = (g, f, e, d, c, b, a)
--              donde SEG(0)=CA, SEG(1)=CB, SEG(2)=CC, SEG(3)=CD,
--                    SEG(4)=CE, SEG(5)=CF, SEG(6)=CG.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd7seg is
    Port (
        BCD : in  STD_LOGIC_VECTOR(3 downto 0);
        SEG : out STD_LOGIC_VECTOR(6 downto 0)
    );
end bcd7seg;

architecture Behavioral of bcd7seg is
begin

    with BCD select
        SEG <= "1000000" when "0000", -- 0
               "1111001" when "0001", -- 1
               "0100100" when "0010", -- 2
               "0110000" when "0011", -- 3
               "0011001" when "0100", -- 4
               "0010010" when "0101", -- 5
               "0000010" when "0110", -- 6
               "1111000" when "0111", -- 7
               "0000000" when "1000", -- 8
               "0010000" when "1001", -- 9
               "1111111" when others; -- Apagado para valores fuera de rango BCD

end Behavioral;

