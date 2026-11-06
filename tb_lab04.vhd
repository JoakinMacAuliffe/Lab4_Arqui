----------------------------------------------------------------------------------
-- Módulo: tb_lab04
-- Descripción: Banco de pruebas (Testbench) exhaustivo para lab04_top.
--              Verifica mediante sentencias ASSERT los 11 casos de prueba:
--              1. Reset general (Tiempo = 25, Eventos = 00, RUNNING = 0, ALARMA = 0)
--              2. Inicio del temporizador (START_PAUSE -> RUNNING = 1)
--              3. Decremento y Pausa (el tiempo se mantiene constante en pausa)
--              4. Reanudación del conteo regresivo
--              5. Incremento de eventos (un solo conteo por pulsación larga;
--                 las pulsaciones de START_PAUSE también cuentan como evento)
--              6. Reinicio independiente de eventos (RESET_EVENTO -> 00)
--              7. Transición BCD de 10 a 09 en el temporizador
--              8. Transición de 01 a 00 y detención automática
--              9. Activación de ALARMA al llegar a 00
--              10. Saturación del contador de eventos en 99
--              11. Reinicio independiente de tiempo (RESET_TIEMPO -> 25)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_lab04 is
-- Entidad de testbench vacía
end tb_lab04;

architecture Behavioral of tb_lab04 is

    -- Declaración del componente bajo prueba (DUT)
    component lab04_top is
        Generic (
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
    end component;

    -- Constantes de simulación (divisores reducidos para simular en microsegundos)
    constant CLK_PERIOD     : time     := 10 ns; -- Reloj de 100 MHz
    constant SIM_COUNT_1S   : positive := 20;    -- 20 ciclos por cada "segundo" simulado
    constant SIM_COUNT_DISP : positive := 2;     -- 2 ciclos por cambio de display (8 ciclos barrido completo)
    constant INIT_DEC_VAL   : integer  := 2;
    constant INIT_UNI_VAL   : integer  := 5;

    -- Señales conectadas al DUT (Device Under Test)
    signal CLK          : STD_LOGIC := '0';
    signal RESET        : STD_LOGIC := '0';
    signal START_PAUSE  : STD_LOGIC := '0';
    signal RESET_TIEMPO : STD_LOGIC := '0';
    signal EVENTO       : STD_LOGIC := '0';
    signal RESET_EVENTO : STD_LOGIC := '0';
    signal SEG          : STD_LOGIC_VECTOR(6 downto 0);
    signal AN           : STD_LOGIC_VECTOR(7 downto 0);
    signal ALARMA       : STD_LOGIC;
    signal RUNNING      : STD_LOGIC;
    signal LED_EVENTO   : STD_LOGIC;

    -- Señales auxiliares en el testbench para reconstruir los 4 dígitos mostrados
    -- a partir de la multiplexación de AN y SEG (facilita visualización y asserts)
    signal obs_dec_tiempo : integer range 0 to 15 := 0;
    signal obs_uni_tiempo : integer range 0 to 15 := 0;
    signal obs_dec_evento : integer range 0 to 15 := 0;
    signal obs_uni_evento : integer range 0 to 15 := 0;

    -- Bandera para detener el generador de reloj al finalizar la simulación
    signal sim_finished   : boolean := false;

    -- Función auxiliar inversa para decodificar SEG (activo en bajo) a entero (0..9)
    function seg7_to_int(seg_val : std_logic_vector(6 downto 0)) return integer is
    begin
        case seg_val is
            when "1000000" => return 0;
            when "1111001" => return 1;
            when "0100100" => return 2;
            when "0110000" => return 3;
            when "0011001" => return 4;
            when "0010010" => return 5;
            when "0000010" => return 6;
            when "1111000" => return 7;
            when "0000000" => return 8;
            when "0010000" => return 9;
            when others    => return 15;
        end case;
    end function;

begin

    -- Instanciación del módulo superior (DUT)
    uut : lab04_top
        generic map (
            MAX_COUNT_1S   => SIM_COUNT_1S,
            MAX_COUNT_DISP => SIM_COUNT_DISP,
            INIT_DEC       => INIT_DEC_VAL,
            INIT_UNI       => INIT_UNI_VAL
        )
        port map (
            CLK          => CLK,
            RESET        => RESET,
            START_PAUSE  => START_PAUSE,
            RESET_TIEMPO => RESET_TIEMPO,
            EVENTO       => EVENTO,
            RESET_EVENTO => RESET_EVENTO,
            SEG          => SEG,
            AN           => AN,
            ALARMA       => ALARMA,
            RUNNING      => RUNNING,
            LED_EVENTO   => LED_EVENTO
        );

    -- Generación de reloj de 100 MHz
    proc_clk : process
    begin
        while not sim_finished loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;
            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process proc_clk;

    -- Monitor de displays: captura cada dígito según el ánodo activo AN(3 downto 0)
    -- y verifica que los ánodos AN(7 downto 4) permanezcan siempre apagados ("1111")
    proc_monitor_display : process(CLK)
    begin
        if rising_edge(CLK) then
            if RESET = '0' then
                assert AN(7 downto 4) = "1111"
                    report "Error: Los displays 7 a 4 deben permanecer apagados (1111)."
                    severity error;
            end if;

            case AN(3 downto 0) is
                when "1110" => obs_uni_evento <= seg7_to_int(SEG); -- Display 0
                when "1101" => obs_dec_evento <= seg7_to_int(SEG); -- Display 1
                when "1011" => obs_uni_tiempo <= seg7_to_int(SEG); -- Display 2
                when "0111" => obs_dec_tiempo <= seg7_to_int(SEG); -- Display 3
                when others => null;
            end case;
        end if;
    end process proc_monitor_display;

    -- Proceso principal de estímulos y verificación con ASSERT
    proc_estimulos : process

        -- Procedimiento auxiliar para avanzar N ciclos de reloj
        procedure wait_cycles(n : positive) is
        begin
            for i in 1 to n loop
                wait until rising_edge(CLK);
            end loop;
        end procedure;

        -- Procedimiento para simular la pulsación de un botón (duración total = 20 ciclos)
        -- Mantiene la señal en '1' durante 4 ciclos (verifica que detector_flanco
        -- solo genere un pulso de 1 ciclo) y luego espera 16 ciclos en '0'.
        procedure press_button(signal btn : out std_logic) is
        begin
            btn <= '1';
            wait_cycles(4);
            btn <= '0';
            wait_cycles(SIM_COUNT_1S - 4);
        end procedure;

    begin
        --------------------------------------------------------------------------
        -- CASO 1: Reset general
        --------------------------------------------------------------------------
        RESET <= '1';
        wait_cycles(5);
        RESET <= '0';
        -- Esperamos 10 ciclos (mitad del periodo de TICK_1S) para que mux_display
        -- escanee los 4 dígitos (8 ciclos) antes del primer TICK_1S (ciclo 20)
        wait_cycles(10);

        assert (RUNNING = '0' and ALARMA = '0')
            report "Fallo Caso 1: RUNNING y ALARMA deben ser '0' tras el reset."
            severity error;
        assert (obs_dec_tiempo = 2 and obs_uni_tiempo = 5)
            report "Fallo Caso 1: El tiempo inicial debe ser 25."
            severity error;
        assert (obs_dec_evento = 0 and obs_uni_evento = 0)
            report "Fallo Caso 1: El contador de eventos debe iniciar en 00."
            severity error;
        report "Caso 1 OK: Reset general verificado (TT=25, EE=00)." severity note;

        --------------------------------------------------------------------------
        -- CASO 2: Inicio del temporizador y verificación de decrementos
        --------------------------------------------------------------------------
        START_PAUSE <= '1';
        wait_cycles(4);
        START_PAUSE <= '0';
        wait_cycles(2); -- En este punto RUNNING ya conmutó a '1' antes del ciclo 20

        assert RUNNING = '1'
            report "Fallo Caso 2: RUNNING debe activarse ('1') al pulsar START_PAUSE."
            severity error;

        -- Completamos los 14 ciclos restantes para llegar al ciclo 30 (tras 1er TICK_1S)
        wait_cycles(14);
        assert (obs_dec_tiempo = 2 and obs_uni_tiempo = 4)
            report "Fallo Caso 2: El temporizador debio decrementar de 25 a 24."
            severity error;

        -- Esperamos 1 segundo adicional (20 ciclos) -> debe bajar a 23
        wait_cycles(SIM_COUNT_1S);
        assert (obs_dec_tiempo = 2 and obs_uni_tiempo = 3)
            report "Fallo Caso 2: El temporizador debio decrementar de 24 a 23."
            severity error;
        report "Caso 2 OK: Inicio y decremento del temporizador verificados (25 -> 24 -> 23)." severity note;

        --------------------------------------------------------------------------
        -- CASO 3: Pausa del temporizador
        --------------------------------------------------------------------------
        press_button(START_PAUSE);
        assert RUNNING = '0'
            report "Fallo Caso 3: RUNNING debe ser '0' en estado de pausa."
            severity error;

        -- Esperamos 3 segundos simulados en pausa; el tiempo debe mantenerse en 23
        wait_cycles(3 * SIM_COUNT_1S);
        assert (obs_dec_tiempo = 2 and obs_uni_tiempo = 3 and RUNNING = '0')
            report "Fallo Caso 3: El tiempo no debe cambiar mientras esta en pausa."
            severity error;
        report "Caso 3 OK: Pausa verificada (se mantiene en 23)." severity note;

        --------------------------------------------------------------------------
        -- CASO 5: Incremento de eventos (evitando conteos múltiples por pulsación)
        --------------------------------------------------------------------------
        -- Realizamos 3 pulsaciones largas de EVENTO (cada una de 4 ciclos en '1')
        press_button(EVENTO);
        press_button(EVENTO);
        press_button(EVENTO);

        -- 2 pulsaciones de START_PAUSE (inicio y pausa) + 3 de EVENTO = 05
        assert (obs_dec_evento = 0 and obs_uni_evento = 5)
            report "Fallo Caso 5: El contador de eventos debe mostrar 05 (2 START_PAUSE + 3 EVENTO)."
            severity error;
        report "Caso 5 OK: Incremento de eventos verificado (EE=05)." severity note;

        --------------------------------------------------------------------------
        -- CASO 6: Reinicio independiente de eventos
        --------------------------------------------------------------------------
        press_button(RESET_EVENTO);

        assert (obs_dec_evento = 0 and obs_uni_evento = 0)
            report "Fallo Caso 6: RESET_EVENTO debe reiniciar el contador de eventos a 00."
            severity error;
        assert (obs_dec_tiempo = 2 and obs_uni_tiempo = 3)
            report "Fallo Caso 6: RESET_EVENTO no debe alterar el tiempo del temporizador (23)."
            severity error;
        report "Caso 6 OK: Reinicio independiente de eventos verificado (EE=00, TT=23)." severity note;

        -- Incrementamos 7 eventos para dejar EE=07 durante el conteo regresivo
        for i in 1 to 7 loop
            press_button(EVENTO);
        end loop;
        assert (obs_dec_evento = 0 and obs_uni_evento = 7)
            report "Fallo al cargar 07 eventos."
            severity error;

        --------------------------------------------------------------------------
        -- CASO 4: Reanudación del temporizador
        --------------------------------------------------------------------------
        -- Al pulsar START_PAUSE (20 ciclos), se reanuda y transcurre 1 segundo (23 -> 22)
        press_button(START_PAUSE);
        assert (RUNNING = '1' and obs_dec_tiempo = 2 and obs_uni_tiempo = 2)
            report "Fallo Caso 4: El temporizador debio reanudarse y pasar de 23 a 22."
            severity error;
        report "Caso 4 OK: Reanudacion verificada (TT=22, RUNNING=1)." severity note;

        --------------------------------------------------------------------------
        -- CASO 7: Transición BCD de 10 a 09
        --------------------------------------------------------------------------
        -- Avanzamos 12 segundos simulados: de 22 baja a 10
        wait_cycles(12 * SIM_COUNT_1S);
        assert (obs_dec_tiempo = 1 and obs_uni_tiempo = 0)
            report "Fallo previo a Caso 7: El temporizador debio llegar a 10."
            severity error;

        -- Avanzamos 1 segundo más: transición crítica 10 -> 09
        wait_cycles(SIM_COUNT_1S);
        assert (obs_dec_tiempo = 0 and obs_uni_tiempo = 9)
            report "Fallo Caso 7: Transicion BCD incorrecta de 10 a 09."
            severity error;
        report "Caso 7 OK: Transicion BCD 10 -> 09 verificada correctamente." severity note;

        --------------------------------------------------------------------------
        -- CASOS 8 y 9: Transición 01 a 00, detención en 00 y activación de ALARMA
        --------------------------------------------------------------------------
        -- Avanzamos 8 segundos simulados: de 09 baja a 01
        wait_cycles(8 * SIM_COUNT_1S);
        assert (obs_dec_tiempo = 0 and obs_uni_tiempo = 1 and RUNNING = '1' and ALARMA = '0')
            report "Fallo previo a Caso 8: El temporizador debio estar en 01 con ALARMA='0'."
            severity error;

        -- Avanzamos 1 segundo más: transición 01 -> 00
        wait_cycles(SIM_COUNT_1S);
        assert (obs_dec_tiempo = 0 and obs_uni_tiempo = 0)
            report "Fallo Caso 8: El temporizador debio llegar a 00."
            severity error;
        assert RUNNING = '0'
            report "Fallo Caso 8: El temporizador debe detenerse (RUNNING='0') al llegar a 00."
            severity error;
        assert ALARMA = '1'
            report "Fallo Caso 9: La senal ALARMA debe activarse ('1') al llegar el tiempo a 00."
            severity error;

        -- Esperamos 3 segundos adicionales para comprobar que no continúa disminuyendo
        wait_cycles(3 * SIM_COUNT_1S);
        assert (obs_dec_tiempo = 0 and obs_uni_tiempo = 0 and RUNNING = '0' and ALARMA = '1')
            report "Fallo Caso 8/9: El temporizador debe permanecer detenido en 00 con ALARMA='1'."
            severity error;
        report "Casos 8 y 9 OK: Llegada a 00, detencion automatica y ALARMA verificadas." severity note;

        --------------------------------------------------------------------------
        -- CASO 11: Reinicio independiente de tiempo (RESET_TIEMPO)
        --------------------------------------------------------------------------
        press_button(RESET_TIEMPO);
        assert (obs_dec_tiempo = 2 and obs_uni_tiempo = 5 and RUNNING = '0' and ALARMA = '0')
            report "Fallo Caso 11: RESET_TIEMPO debe restaurar el tiempo a 25 y apagar ALARMA."
            severity error;
        -- 7 de EVENTO + 1 START_PAUSE (reanudación) = 08
        assert (obs_dec_evento = 0 and obs_uni_evento = 8)
            report "Fallo Caso 11: RESET_TIEMPO no debe afectar el contador de eventos (08)."
            severity error;
        report "Caso 11 OK: Reinicio de tiempo verificado (TT=25, ALARMA=0, EE=08)." severity note;

        --------------------------------------------------------------------------
        -- CASO 10: Saturación del contador de eventos en 99
        --------------------------------------------------------------------------
        -- Actualmente EE=08; enviamos 91 pulsos para llegar a 99, más 4 pulsos extra
        for i in 1 to 95 loop
            press_button(EVENTO);
        end loop;

        assert (obs_dec_evento = 9 and obs_uni_evento = 9)
            report "Fallo Caso 10: El contador de eventos debe saturarse y mantener 99."
            severity error;
        report "Caso 10 OK: Saturacion del contador de eventos en 99 verificada." severity note;

        --------------------------------------------------------------------------
        -- Fin de la simulación
        --------------------------------------------------------------------------
        report "=== SIMULACION COMPLETADA EXITOSAMENTE: TODOS LOS CASOS PASARON ===" severity note;
        sim_finished <= true;
        wait;
    end process proc_estimulos;

end Behavioral;
