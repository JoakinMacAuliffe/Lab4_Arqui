----------------------------------------------------------------------------------
-- Módulo: mux_display
-- Descripción: Multiplexor de 4 displays de 7 segmentos con formato "TT EE":
--              - Display 0 (AN(0)='0'): Unidades de eventos (UNI_EVENTO)
--              - Display 1 (AN(1)='0'): Decenas de eventos (DEC_EVENTO)
--              - Display 2 (AN(2)='0'): Unidades de tiempo (UNI_TIEMPO)
--              - Display 3 (AN(3)='0'): Decenas de tiempo (DEC_TIEMPO)
--              - Displays 4 a 7 (AN(7 downto 4)="1111"): Permanentemente apagados.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_display is
    Port (
        CLK          : in  STD_LOGIC;
        RESET        : in  STD_LOGIC;
        TICK_DISPLAY : in  STD_LOGIC;
        DEC_TIEMPO   : in  STD_LOGIC_VECTOR(3 downto 0);
        UNI_TIEMPO   : in  STD_LOGIC_VECTOR(3 downto 0);
        DEC_EVENTO   : in  STD_LOGIC_VECTOR(3 downto 0);
        UNI_EVENTO   : in  STD_LOGIC_VECTOR(3 downto 0);
        BCD_OUT      : out STD_LOGIC_VECTOR(3 downto 0);
        AN           : out STD_LOGIC_VECTOR(7 downto 0)
    );
end mux_display;

architecture Behavioral of mux_display is
    signal sel_display : unsigned(1 downto 0) := "00";
begin

    -- Contador selector de 2 bits que avanza con cada pulso de TICK_DISPLAY
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                sel_display <= "00";
            elsif TICK_DISPLAY = '1' then
                sel_display <= sel_display + 1;
            end if;
        end if;
    end process;

    -- Selección cíclica del ánodo activo (activo en bajo) y del dígito BCD
    process(sel_display, UNI_EVENTO, DEC_EVENTO, UNI_TIEMPO, DEC_TIEMPO)
    begin
        case sel_display is
            when "00" =>
                AN      <= "11111110"; -- Display 0: Unidades de eventos
                BCD_OUT <= UNI_EVENTO;
            when "01" =>
                AN      <= "11111101"; -- Display 1: Decenas de eventos
                BCD_OUT <= DEC_EVENTO;
            when "10" =>
                AN      <= "11111011"; -- Display 2: Unidades de tiempo
                BCD_OUT <= UNI_TIEMPO;
            when "11" =>
                AN      <= "11110111"; -- Display 3: Decenas de tiempo
                BCD_OUT <= DEC_TIEMPO;
            when others =>
                AN      <= "11111111";
                BCD_OUT <= "0000";
        end case;
    end process;

end Behavioral;

