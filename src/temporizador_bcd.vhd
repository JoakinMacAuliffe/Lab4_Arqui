----------------------------------------------------------------------------------
-- Módulo: temporizador_bcd
-- Descripción: Contador regresivo en formato BCD de dos dígitos (00 a 99).
--              - Inicia en un valor configurable (por defecto 25 segundos).
--              - Permite iniciar/pausar con START_PAUSE.
--              - Disminuye una unidad cada vez que TICK_1S = '1' cuando está activo.
--              - Maneja transiciones BCD (ej. 10 -> 09).
--              - Se detiene automáticamente al llegar a 00 y activa ALARMA.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity temporizador_bcd is
    Generic (
        INIT_DEC : integer range 0 to 9 := 2; -- Decenas iniciales (por defecto 2)
        INIT_UNI : integer range 0 to 9 := 5  -- Unidades iniciales (por defecto 5)
    );
    Port (
        CLK          : in  STD_LOGIC;
        RESET        : in  STD_LOGIC;
        RESET_TIEMPO : in  STD_LOGIC;
        START_PAUSE  : in  STD_LOGIC;
        TICK_1S      : in  STD_LOGIC;
        DEC_TIEMPO   : out STD_LOGIC_VECTOR(3 downto 0);
        UNI_TIEMPO   : out STD_LOGIC_VECTOR(3 downto 0);
        RUNNING      : out STD_LOGIC;
        ALARMA       : out STD_LOGIC
    );
end temporizador_bcd;

architecture Behavioral of temporizador_bcd is
    signal dec_reg     : unsigned(3 downto 0) := to_unsigned(INIT_DEC, 4);
    signal uni_reg     : unsigned(3 downto 0) := to_unsigned(INIT_UNI, 4);
    signal running_reg : STD_LOGIC := '0';
    signal alarma_reg  : STD_LOGIC := '0';
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Reinicio general o reinicio específico de tiempo
            if RESET = '1' or RESET_TIEMPO = '1' then
                dec_reg     <= to_unsigned(INIT_DEC, 4);
                uni_reg     <= to_unsigned(INIT_UNI, 4);
                running_reg <= '0';
                alarma_reg  <= '0';
            else
                -- Control de inicio y pausa (alterna estado si el tiempo no es 00)
                if START_PAUSE = '1' then
                    if not (dec_reg = 0 and uni_reg = 0) then
                        running_reg <= not running_reg;
                    else
                        running_reg <= '0';
                    end if;
                -- Conteo regresivo sincronizado con TICK_1S
                elsif running_reg = '1' and TICK_1S = '1' then
                    if dec_reg = 0 and uni_reg = 0 then
                        -- Ya se encuentra en 00: se detiene y mantiene la alarma
                        running_reg <= '0';
                        alarma_reg  <= '1';
                    elsif dec_reg = 0 and uni_reg = 1 then
                        -- Transición final 01 -> 00: llega a cero, se detiene y activa alarma
                        dec_reg     <= to_unsigned(0, 4);
                        uni_reg     <= to_unsigned(0, 4);
                        running_reg <= '0';
                        alarma_reg  <= '1';
                    elsif uni_reg = 0 then
                        -- Transición de decena (ej. 20 -> 19, 10 -> 09)
                        dec_reg <= dec_reg - 1;
                        uni_reg <= to_unsigned(9, 4);
                    else
                        -- Decremento normal de unidades
                        uni_reg <= uni_reg - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    DEC_TIEMPO <= std_logic_vector(dec_reg);
    UNI_TIEMPO <= std_logic_vector(uni_reg);
    RUNNING    <= running_reg;
    ALARMA     <= alarma_reg;

end Behavioral;

