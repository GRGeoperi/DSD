-- Practica uno: Uso de maquinas de estado, contadores y memorias
-- Elaborado por: González Roldán Geoperi y Pérez Olivares Julio
-- Fecha: 28/09/2024

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY proyecto_dos IS
    PORT (
        reloj : IN STD_LOGIC;
        reinicio : IN STD_LOGIC;
        confirmacion_ajuste : IN STD_LOGIC;
        ajuste_horas : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        ajuste_minutos : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        display_horas_decenas : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        display_horas_unidades : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        display_minutos_decenas : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        display_minutos_unidades : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        display_segundos_decenas : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        display_segundos_unidades : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        led_segundero : OUT STD_LOGIC;
        led_alarma_cero : OUT STD_LOGIC;
        led_alarma_uno : OUT STD_LOGIC;
        led_alarma_dos : OUT STD_LOGIC;
        led_alarma_tres : OUT STD_LOGIC;
        led_alarma_cuatro : OUT STD_LOGIC;
        led_alarma_cinco : OUT STD_LOGIC;
        led_alarma_seis : OUT STD_LOGIC;
        led_alarma_siete : OUT STD_LOGIC;
        led_alarma_ocho : OUT STD_LOGIC;
        led_alarma_nueve : OUT STD_LOGIC;
        cargar_datos_FL : IN STD_LOGIC;
        FL_ADDR : OUT STD_LOGIC_VECTOR(22 DOWNTO 0); -- bus de direccion de memoria
        FL_DQ : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- bus de datos de la memoria
        FL_CE_N : OUT STD_LOGIC; -- chip enable
        FL_OE_N : OUT STD_LOGIC; -- output enable
        FL_RY : IN STD_LOGIC; -- indicador de ocupado
        FL_WE_N : OUT STD_LOGIC; -- habilitacion de escritura
        FL_RST_N : OUT STD_LOGIC; -- reset de memoria
        FL_WP_N : OUT STD_LOGIC -- proteccion contra escritura
    );
END proyecto_dos;

ARCHITECTURE Behavioral OF proyecto_dos IS
    -- Declaración de los registros para los segundos, minutos y horas
    SIGNAL segundos : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
    SIGNAL minutos : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
    SIGNAL horas : STD_LOGIC_VECTOR (4 DOWNTO 0) := "00000";

    -- Declaración del contador para generar el delay de 1Hz
    SIGNAL contador : INTEGER := 0;
    CONSTANT cuenta_maxima : INTEGER := 50000000;

    -- Declaración de la máquina de estados
    TYPE estado IS (espera, cuenta_segundos, cuenta_minutos, cuenta_horas, ajuste, alarma);
    SIGNAL estado_presente, estado_siguiente : estado := espera;

    -- Declaración de los números decimales para mostrar en los displays
    SIGNAL decimal_segundos : INTEGER := 0;
    SIGNAL decimal_minutos : INTEGER := 0;
    SIGNAL decimal_horas : INTEGER := 0;

    -- Declaración de los dígitos para mostrar los segundos
    SIGNAL digito_segundos_decenas : INTEGER := 0;
    SIGNAL digito_segundos_unidades : INTEGER := 0;

    -- Declaración de los dígitos para mostrar los minutos
    SIGNAL digito_minutos_decenas : INTEGER := 0;
    SIGNAL digito_minutos_unidades : INTEGER := 0;

    -- Declaración de los dígitos para mostrar las horas
    SIGNAL digito_horas_decenas : INTEGER := 0;
    SIGNAL digito_horas_unidades : INTEGER := 0;

    -- Declaración de la señal para el LED
    SIGNAL senial_led : STD_LOGIC := '0';

    -- Declaración de las constantes para la dirección de la memoria
    CONSTANT direccion_hora : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    CONSTANT direccion_minuto : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";

    -- Declaración de las señales para almacenar la hora y el minuto de la alarma
    SIGNAL hora_almacenada : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL minuto_almacenado : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";

    --Función para convertir un dígito a segmentos
    FUNCTION Conversion_Segmentos(DIGITO : INTEGER) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE DIGITO IS
            WHEN 0 => RETURN "0000001";
            WHEN 1 => RETURN "1001111";
            WHEN 2 => RETURN "0010010";
            WHEN 3 => RETURN "0000110";
            WHEN 4 => RETURN "1001100";
            WHEN 5 => RETURN "0100100";
            WHEN 6 => RETURN "0100000";
            WHEN 7 => RETURN "0001111";
            WHEN 8 => RETURN "0000000";
            WHEN 9 => RETURN "0000100";
            WHEN OTHERS => RETURN "1111110";
        END CASE;
    END FUNCTION;

BEGIN
    led_segundero <= senial_led;
    PROCESS (reloj, reinicio)
    BEGIN
        -- Reinicio de todo el reloj en bajo
        IF reinicio = '0' THEN
            segundos <= "000000";
            minutos <= "000000";
            horas <= "00000";
            estado_presente <= espera;
            contador <= 0;
            senial_led <= '0';
        ELSIF rising_edge(reloj) THEN
            -- Si el contador llega a la cuenta máxima, se cambia de estado
            IF contador = cuenta_maxima - 1 THEN
                contador <= 0;
                estado_presente <= estado_siguiente;
                -- Se cambia la señal del LED
                senial_led <= NOT senial_led;
                CASE estado_presente IS
                    WHEN espera =>
                        estado_siguiente <= cuenta_segundos;
                    WHEN cuenta_segundos =>
                        -- Si se confirma el ajuste, se cambia a su estado
                        IF (confirmacion_ajuste = '1' AND cargar_datos_FL = '0') THEN
                            estado_siguiente <= ajuste;
                        -- Si se carga la alarma, se cambia a su estado
                        ELSIF (cargar_datos_FL = '1' AND confirmacion_ajuste = '0') THEN
                            estado_siguiente <= alarma;
                        ELSE
                            -- Si los segundos llegan a 59, se cambia al estado de minutos
                            IF segundos = "111011" THEN
                                segundos <= "000000";
                                estado_siguiente <= cuenta_minutos;
                            -- Si no, se incrementa en 1 y se mantiene en el mismo estado
                            ELSE
                                segundos <= segundos + 1;
                                estado_siguiente <= cuenta_segundos;
                            END IF;
                        END IF;
                    WHEN cuenta_minutos =>
                        -- Si los minutos llegan a 59, se cambia al estado de horas
                        IF minutos = "111011" THEN
                            minutos <= "000000";
                            estado_siguiente <= cuenta_horas;
                        -- Si no, se incrementa en 1 y se mantiene en el mismo estado
                        ELSE
                            minutos <= minutos + 1;
                            estado_siguiente <= cuenta_segundos;
                        END IF;
                    WHEN cuenta_horas =>
                        -- Si las horas llegan a 23, se reinician a 0
                        IF horas = "10111" THEN
                            horas <= "00000";
                        -- Si no, se incrementa en 1
                        ELSE
                            horas <= horas + 1;
                        END IF;
                        -- Se cambia al estado de segundos
                        estado_siguiente <= cuenta_segundos;
                    WHEN ajuste =>
                        -- Si se desactiva la confirmación, se cambia al estado de espera
                        IF confirmacion_ajuste = '0' THEN
                            estado_siguiente <= espera;
                        -- Si no, se ajustan las horas y minutos a su correspondiente entrada
                        ELSE
                            horas <= ajuste_horas;
                            minutos <= ajuste_minutos;
                            segundos <= "000000";
                            estado_siguiente <= ajuste;
                        END IF;
                    WHEN alarma =>
                        -- Si se desactiva la carga de datos, se cambia al estado de espera
                        IF cargar_datos_FL = '0' THEN
                            estado_siguiente <= espera;
                        ELSE
                            -- Si la memoria está ocupada, se accede a la dirección correspondiente
                            -- y se almacena la hora y el minuto que están en la FLASH
                            IF FL_RY = '0' THEN
                                FL_ADDR <= STD_LOGIC_VECTOR("0000000000000000000" & direccion_hora);
                                FL_CE_N <= '0';
                                FL_OE_N <= '0';
                                FL_WE_N <= '1';
                                hora_almacenada <= FL_DQ;
                                FL_ADDR <= STD_LOGIC_VECTOR("0000000000000000000" & direccion_minuto);
                                FL_CE_N <= '0';
                                FL_OE_N <= '0';
                                FL_WE_N <= '1';
                                minuto_almacenado <= FL_DQ;
                                estado_siguiente <= alarma;
                            ELSE
                                FL_CE_N <= '1';
                                FL_OE_N <= '1';
                            END IF;
                        END IF;
                END CASE;
            ELSE
                contador <= contador + 1;
            END IF;
            -- Si las horas y minutos coinciden con la hora actual, se activan los LEDs
            IF (horas = hora_almacenada AND minutos = minuto_almacenado) THEN
                led_alarma_cero <= '1';
                led_alarma_uno <= '1';
                led_alarma_dos <= '1';
                led_alarma_tres <= '1';
                led_alarma_cuatro <= '1';
                led_alarma_cinco <= '1';
                led_alarma_seis <= '1';
                led_alarma_siete <= '1';
                led_alarma_ocho <= '1';
                led_alarma_nueve <= '1';
            ELSE
                led_alarma_cero <= '0';
                led_alarma_uno <= '0';
                led_alarma_dos <= '0';
                led_alarma_tres <= '0';
                led_alarma_cuatro <= '0';
                led_alarma_cinco <= '0';
                led_alarma_seis <= '0';
                led_alarma_siete <= '0';
                led_alarma_ocho <= '0';
                led_alarma_nueve <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Se convierte el valor binario de los segundos, minutos y horas a decimal
    decimal_segundos <= to_integer(unsigned(segundos));
    decimal_minutos <= to_integer(unsigned(minutos));
    decimal_horas <= to_integer(unsigned(horas));

    -- Se separa en dígitos el decimal de segundos
    digito_segundos_unidades <= decimal_segundos MOD 10;
    digito_segundos_decenas <= (decimal_segundos / 10) MOD 10;

    -- Se separa en dígitos el decimal de minutos
    digito_minutos_unidades <= decimal_minutos MOD 10;
    digito_minutos_decenas <= (decimal_minutos / 10) MOD 10;

    -- Se separa en dígitos el decimal de horas
    digito_horas_unidades <= decimal_horas MOD 10;
    digito_horas_decenas <= (decimal_horas / 10) MOD 10;

    -- Se convierten los dígitos a segmentos y se muestra en los displays
    display_segundos_unidades <= Conversion_Segmentos(digito_segundos_unidades);
    display_segundos_decenas <= Conversion_Segmentos(digito_segundos_decenas);
    display_minutos_unidades <= Conversion_Segmentos(digito_minutos_unidades);
    display_minutos_decenas <= Conversion_Segmentos(digito_minutos_decenas);
    display_horas_unidades <= Conversion_Segmentos(digito_horas_unidades);
    display_horas_decenas <= Conversion_Segmentos(digito_horas_decenas);
END Behavioral;
