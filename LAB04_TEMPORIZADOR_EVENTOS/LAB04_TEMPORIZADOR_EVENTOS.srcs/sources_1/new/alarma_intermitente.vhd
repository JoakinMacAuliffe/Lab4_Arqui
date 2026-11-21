----------------------------------------------------------------------------------
-- Módulo: alarma_intermitente
-- Descripción: Actividad adicional - Alarma intermitente.
--              Convierte la alarma fija del temporizador (ALARMA_IN) en una señal
--              que parpadea (ALARMA_OUT) mientras el tiempo está agotado.
--              - Mientras ALARMA_IN = '0': la salida está apagada y el contador
--                se mantiene en 0 (fase inicial "encendido").
--              - Mientras ALARMA_IN = '1': la salida alterna entre encendido y
--                apagado cada MAX_COUNT_BLINK ciclos de reloj.
--              Con 100 MHz y MAX_COUNT_BLINK = 25_000_000, cada fase dura 0,25 s,
--              es decir, el LED parpadea a 2 Hz.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity alarma_intermitente is
    Generic (
        -- Ciclos de reloj que dura cada fase (encendido / apagado)
        MAX_COUNT_BLINK : positive := 25_000_000
    );
    Port (
        CLK        : in  STD_LOGIC;
        RESET      : in  STD_LOGIC;
        ALARMA_IN  : in  STD_LOGIC;
        ALARMA_OUT : out STD_LOGIC
    );
end alarma_intermitente;


architecture Behavioral of alarma_intermitente is
    signal cnt_blink : natural range 0 to MAX_COUNT_BLINK - 1 := 0;
    signal blink     : STD_LOGIC := '1';
begin


    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' or ALARMA_IN = '0' then
                -- Sin alarma: contador detenido y fase lista para empezar encendida
                cnt_blink <= 0;
                blink     <= '1';
            elsif cnt_blink = MAX_COUNT_BLINK - 1 then
                -- Fin de la fase actual: se invierte el estado del LED
                cnt_blink <= 0;
                blink     <= not blink;
            else
                cnt_blink <= cnt_blink + 1;
            end if;
        end if;
    end process;


    -- El LED solo puede encenderse cuando la alarma está activa
    ALARMA_OUT <= ALARMA_IN and blink;


end Behavioral;