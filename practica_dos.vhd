LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY practica_uno IS
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
        led : OUT STD_LOGIC
    );
END practica_uno;

ARCHITECTURE Behavioral OF practica_uno IS
    SIGNAL segundos : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
    SIGNAL minutos : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000";
    SIGNAL horas : STD_LOGIC_VECTOR (4 DOWNTO 0) := "00000";

    -- Declaración del contador para generar el delay de 1Hz
    SIGNAL contador : INTEGER := 0;
    CONSTANT MAX_COUNT : INTEGER := 50000000;

    TYPE estado IS (espera, cuenta_segundos, cuenta_minutos, cuenta_horas, ajuste);
    SIGNAL estado_presente, estado_siguiente : estado := espera;

    -- Declaración de los números decimales para mostrar en los displays
    SIGNAL decimal_segundos : INTEGER := 0;
    SIGNAL decimal_minutos : INTEGER := 0;
    SIGNAL decimal_horas : INTEGER := 0;

    -- Declaración de los dígitos para mostrar los segundos
    SIGNAL digito_segundos_decenas: INTEGER := 0;
    SIGNAL digito_segundos_unidades: INTEGER := 0;

    -- Declaración de los dígitos para mostrar los minutos
    SIGNAL digito_minutos_decenas: INTEGER := 0;
    SIGNAL digito_minutos_unidades: INTEGER := 0;

    -- Declaración de los dígitos para mostrar las horas
    SIGNAL digito_horas_decenas: INTEGER := 0;
    SIGNAL digito_horas_unidades: INTEGER := 0;

    -- Declaración de la señal para el LED
    SIGNAL senial_led : STD_LOGIC := '0';

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
    led <= senial_led;

    PROCESS (reloj, reinicio)
    BEGIN
        IF reinicio = '0' THEN
            segundos <= "000000";
            minutos <= "000000";
            horas <= "00000";
            estado_presente <= espera;
            contador <= 0;
            senial_led <= '0';
        ELSIF rising_edge(reloj) THEN
            IF contador = MAX_COUNT - 1 THEN
                contador <= 0;
                estado_presente <= estado_siguiente;
                senial_led <= NOT senial_led;
                CASE estado_presente IS
                    WHEN espera =>
                        IF confirmacion_ajuste = '1' THEN
                            estado_siguiente <= ajuste;
                        ELSE
                            estado_siguiente <= cuenta_segundos;
                        END IF;
                    WHEN cuenta_segundos =>
                        IF segundos = "111011" THEN
                            segundos <= "000000";
                            estado_siguiente <= cuenta_minutos;
                        ELSE
                            segundos <= segundos + 1;
                            estado_siguiente <= cuenta_segundos;
                        END IF;
                    WHEN cuenta_minutos =>
                        IF minutos = "111011" THEN
                            minutos <= "000000";
                            estado_siguiente <= cuenta_horas;
                        ELSE
                            minutos <= minutos + 1;
                            estado_siguiente <= cuenta_segundos;
                        END IF;
                    WHEN cuenta_horas =>
                        IF horas = "10111" THEN
                            horas <= "00000";
                        ELSE
                            horas <= horas + 1;
                        END IF;
                        estado_siguiente <= cuenta_segundos;
                    WHEN ajuste =>
                        IF confirmacion_ajuste = '0' THEN
                            estado_siguiente <= espera;
                        ELSE
                            horas <= ajuste_horas;
                            minutos <= ajuste_minutos;
                            segundos <= "000000";
                            estado_siguiente <= ajuste;
                        END IF;
                END CASE;
            ELSE
                contador <= contador + 1;
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
