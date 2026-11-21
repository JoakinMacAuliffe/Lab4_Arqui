----------------------------------------------------------------------------------
-- Módulo: generador_ticks
-- Descripción: Divisor de frecuencia a partir del reloj de 100 MHz de la placa
--              Nexys 4 DDR. Genera pulsos de habilitación de un ciclo de reloj:
--              - TICK_1S: pulso cada 1 segundo (100,000,000 ciclos en hardware).
--              - TICK_DISPLAY: pulso para multiplexación de displays (~1 kHz).
--              Incluye genéricos para reducir los divisores durante simulación.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity generador_ticks is
    Generic (
        -- Para síntesis en FPGA (100 MHz): 100_000_000 (1 s) y 100_000 (1 ms)
        -- Para simulación, pueden reducirse desde el testbench o cambiando estos valores
        MAX_COUNT_1S   : positive := 100_000_000;
        MAX_COUNT_DISP : positive := 100_000
    );
    Port (
        CLK          : in  STD_LOGIC;
        RESET        : in  STD_LOGIC;
        TICK_1S      : out STD_LOGIC;
        TICK_DISPLAY : out STD_LOGIC
    );
end generador_ticks;

architecture Behavioral of generador_ticks is
    signal cnt_1s   : natural range 0 to MAX_COUNT_1S - 1   := 0;
    signal cnt_disp : natural range 0 to MAX_COUNT_DISP - 1 := 0;
begin

    -- Proceso para generar TICK_1S (activo durante 1 ciclo cada 1 segundo)
    proc_tick_1s : process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                cnt_1s  <= 0;
                TICK_1S <= '0';
            else
                if cnt_1s = MAX_COUNT_1S - 1 then
                    cnt_1s  <= 0;
                    TICK_1S <= '1';
                else
                    cnt_1s  <= cnt_1s + 1;
                    TICK_1S <= '0';
                end if;
            end if;
        end if;
    end process proc_tick_1s;

    -- Proceso para generar TICK_DISPLAY (activo durante 1 ciclo para refresco de displays)
    proc_tick_display : process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                cnt_disp     <= 0;
                TICK_DISPLAY <= '0';
            else
                if cnt_disp = MAX_COUNT_DISP - 1 then
                    cnt_disp     <= 0;
                    TICK_DISPLAY <= '1';
                else
                    cnt_disp     <= cnt_disp + 1;
                    TICK_DISPLAY <= '0';
                end if;
            end if;
        end if;
    end process proc_tick_display;

end Behavioral;

