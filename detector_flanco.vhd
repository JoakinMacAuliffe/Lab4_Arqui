----------------------------------------------------------------------------------
-- Módulo: detector_flanco
-- Descripción: Sincronizador de doble flip-flop y detector de flanco de subida.
--              Genera un pulso limpio de un solo ciclo de reloj (PULSO) por cada
--              pulsación del botón (ENTRADA), evitando conteos múltiples.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity detector_flanco is
    Port (
        CLK     : in  STD_LOGIC;
        RESET   : in  STD_LOGIC;
        ENTRADA : in  STD_LOGIC;
        PULSO   : out STD_LOGIC
    );
end detector_flanco;

architecture Behavioral of detector_flanco is
    signal sync_ff1        : STD_LOGIC := '0';
    signal evento_actual   : STD_LOGIC := '0';
    signal evento_anterior : STD_LOGIC := '0';
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '1' then
                sync_ff1        <= '0';
                evento_actual   <= '0';
                evento_anterior <= '0';
            else
                -- Doble etapa de sincronización contra metaestabilidad
                sync_ff1        <= ENTRADA;
                evento_actual   <= sync_ff1;
                -- Registro de estado anterior para detección de flanco de subida
                evento_anterior <= evento_actual;
            end if;
        end if;
    end process;

    -- Generación de un pulso de un ciclo en el flanco de subida
    PULSO <= evento_actual and (not evento_anterior);

end Behavioral;

