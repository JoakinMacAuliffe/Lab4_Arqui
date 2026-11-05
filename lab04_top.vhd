----------------------------------------------------------------------------------
-- Módulo: lab04_top
-- Descripción: Módulo superior (Top-Level) del proyecto "Temporizador regresivo
--              y contador de eventos" para la placa FPGA Nexys 4 DDR (XC7A100T).
--              Integra:
--              - generador_ticks
--              - 4 instancias de detector_flanco para los pulsadores de control
--              - temporizador_bcd
--              - contador_eventos
--              - mux_display
--              - bcd7seg
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lab04_top is
    Generic (
        -- Valores por defecto para síntesis en placa (reloj de 100 MHz)
        -- En el testbench se sobreescriben con valores reducidos para simulación rápida
        MAX_COUNT_1S   : positive := 100_000_000;
        MAX_COUNT_DISP : positive := 100_000;
        INIT_DEC       : integer range 0 to 9 := 2;
        INIT_UNI       : integer range 0 to 9 := 5
    );
    Port (
        CLK          : in  STD_LOGIC;
        RESET        : in  STD_LOGIC;
        START_PAUSE  : in  STD_LOGIC;
        RESET_TIEMPO : in  STD_LOGIC;
        EVENTO       : in  STD_LOGIC;
        RESET_EVENTO : in  STD_LOGIC;
        SEG          : out STD_LOGIC_VECTOR(6 downto 0);
        AN           : out STD_LOGIC_VECTOR(7 downto 0);
        ALARMA       : out STD_LOGIC;
        RUNNING      : out STD_LOGIC;
        LED_EVENTO   : out STD_LOGIC
    );
end lab04_top;

architecture Structural of lab04_top is

    -- Declaración de componentes
    component generador_ticks is
        Generic (
            MAX_COUNT_1S   : positive := 100_000_000;
            MAX_COUNT_DISP : positive := 100_000
        );
        Port (
            CLK          : in  STD_LOGIC;
            RESET        : in  STD_LOGIC;
            TICK_1S      : out STD_LOGIC;
            TICK_DISPLAY : out STD_LOGIC
        );
    end component;

    component detector_flanco is
        Port (
            CLK     : in  STD_LOGIC;
            RESET   : in  STD_LOGIC;
            ENTRADA : in  STD_LOGIC;
            PULSO   : out STD_LOGIC
        );
    end component;

    component temporizador_bcd is
        Generic (
            INIT_DEC : integer range 0 to 9 := 2;
            INIT_UNI : integer range 0 to 9 := 5
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
    end component;

    component contador_eventos is
        Port (
            CLK          : in  STD_LOGIC;
            RESET        : in  STD_LOGIC;
            RESET_EVENTO : in  STD_LOGIC;
            EVENTO       : in  STD_LOGIC;
            DEC_EVENTO   : out STD_LOGIC_VECTOR(3 downto 0);
            UNI_EVENTO   : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component mux_display is
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
    end component;

    component bcd7seg is
        Port (
            BCD : in  STD_LOGIC_VECTOR(3 downto 0);
            SEG : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    -- Señales internas de habilitación (ticks)
    signal tick_1s            : STD_LOGIC;
    signal tick_display       : STD_LOGIC;

    -- Pulsos de un ciclo provenientes de los detectores de flanco
    signal pulso_start_pause  : STD_LOGIC;
    signal pulso_reset_tiempo : STD_LOGIC;
    signal pulso_evento       : STD_LOGIC;
    signal pulso_reset_evento : STD_LOGIC;

    -- Dígitos BCD del temporizador y del contador de eventos
    signal dec_tiempo         : STD_LOGIC_VECTOR(3 downto 0);
    signal uni_tiempo         : STD_LOGIC_VECTOR(3 downto 0);
    signal dec_evento         : STD_LOGIC_VECTOR(3 downto 0);
    signal uni_evento         : STD_LOGIC_VECTOR(3 downto 0);

    -- Dígito BCD seleccionado por el multiplexor hacia el decodificador 7 segmentos
    signal bcd_actual         : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- 1. Generador de ticks (1 segundo y refresco de displays)
    u_generador_ticks : generador_ticks
        generic map (
            MAX_COUNT_1S   => MAX_COUNT_1S,
            MAX_COUNT_DISP => MAX_COUNT_DISP
        )
        port map (
            CLK          => CLK,
            RESET        => RESET,
            TICK_1S      => tick_1s,
            TICK_DISPLAY => tick_display
        );

    -- 2. Detectores de flanco para pulsadores de control y eventos
    u_det_start_pause : detector_flanco
        port map (
            CLK     => CLK,
            RESET   => RESET,
            ENTRADA => START_PAUSE,
            PULSO   => pulso_start_pause
        );

    u_det_reset_tiempo : detector_flanco
        port map (
            CLK     => CLK,
            RESET   => RESET,
            ENTRADA => RESET_TIEMPO,
            PULSO   => pulso_reset_tiempo
        );

    u_det_evento : detector_flanco
        port map (
            CLK     => CLK,
            RESET   => RESET,
            ENTRADA => EVENTO,
            PULSO   => pulso_evento
        );

    u_det_reset_evento : detector_flanco
        port map (
            CLK     => CLK,
            RESET   => RESET,
            ENTRADA => RESET_EVENTO,
            PULSO   => pulso_reset_evento
        );

    -- 3. Temporizador regresivo BCD (TT)
    u_temporizador_bcd : temporizador_bcd
        generic map (
            INIT_DEC => INIT_DEC,
            INIT_UNI => INIT_UNI
        )
        port map (
            CLK          => CLK,
            RESET        => RESET,
            RESET_TIEMPO => pulso_reset_tiempo,
            START_PAUSE  => pulso_start_pause,
            TICK_1S      => tick_1s,
            DEC_TIEMPO   => dec_tiempo,
            UNI_TIEMPO   => uni_tiempo,
            RUNNING      => RUNNING,
            ALARMA       => ALARMA
        );

    -- 4. Contador de eventos BCD (EE)
    u_contador_eventos : contador_eventos
        port map (
            CLK          => CLK,
            RESET        => RESET,
            RESET_EVENTO => pulso_reset_evento,
            EVENTO       => pulso_evento,
            DEC_EVENTO   => dec_evento,
            UNI_EVENTO   => uni_evento
        );

    -- 5. Multiplexor de 4 displays (Displays 3-2: Tiempo, Displays 1-0: Eventos)
    u_mux_display : mux_display
        port map (
            CLK          => CLK,
            RESET        => RESET,
            TICK_DISPLAY => tick_display,
            DEC_TIEMPO   => dec_tiempo,
            UNI_TIEMPO   => uni_tiempo,
            DEC_EVENTO   => dec_evento,
            UNI_EVENTO   => uni_evento,
            BCD_OUT      => bcd_actual,
            AN           => AN
        );

    -- 6. Decodificador BCD a 7 segmentos (activo en bajo)
    u_bcd7seg : bcd7seg
        port map (
            BCD => bcd_actual,
            SEG => SEG
        );

    -- Salida indicadora de detección de evento
    LED_EVENTO <= pulso_evento;

end Structural;
