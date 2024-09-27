-- Practica uno: Uso de registros
-- Elaborado por: González Roldán Geoperi
-- Fecha: 26/09/2024

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY practica_uno IS
    PORT (
        binario : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        seleccion_registro : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        reloj : IN STD_LOGIC;
        reinicio : IN STD_LOGIC;
        control : IN STD_LOGIC;
        leds_binario : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        leds_seleccion_registro : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        display_unidades : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        display_decenas : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        display_centenas : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END practica_uno;

ARCHITECTURE comportamiento OF practica_uno IS
    -- Declaración de los registros
    SIGNAL registro_cero : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL registro_uno : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL registro_dos : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL registro_tres : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL registro_cuatro : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL registro_cinco : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL registro_seis : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL registro_siete : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Declaración de los números decimales para mostrar en los displays
    SIGNAL decimal : INTEGER := 0;
    SIGNAL digito_unidades, digito_decenas, digito_centenas : INTEGER := 0;

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
    PROCESS (reloj, binario, reinicio, control, seleccion_registro)
    BEGIN
        -- Reinicio de todo en bajo
        IF (reinicio = '0') THEN
        
            registro_cero <= "00000000";
            registro_uno <= "00000000";
            registro_dos <= "00000000";
            registro_tres <= "00000000";
            registro_cuatro <= "00000000";
            registro_cinco <= "00000000";
            registro_seis <= "00000000";
            registro_siete <= "00000000";

            display_unidades <= "1111110";
            display_decenas <= "1111110";
            display_centenas <= "1111110";

            decimal <= 0;
            digito_unidades <= 0;
            digito_decenas <= 0;
            digito_centenas <= 0;

            leds_binario <= "00000000";
            leds_seleccion_registro <= "000";

        ELSIF (reloj' event AND reloj = '1') THEN
            CASE control IS
                -- El control permite almacenar
                WHEN '0' =>
                    -- Se muestra en LEDs la entrada
                    leds_binario <= binario;

                    -- Se muestra en LEDs el registro seleccionado
                    leds_seleccion_registro <= seleccion_registro;

                    -- Se almacena el binario en el registro correspondiente (entrada paralela)
                    CASE seleccion_registro IS
                        WHEN "000" =>
                            registro_cero <= binario;
                        WHEN "001" =>
                            registro_uno <= binario;
                        WHEN "010" =>
                            registro_dos <= binario;
                        WHEN "011" =>
                            registro_tres <= binario;
                        WHEN "100" =>
                            registro_cuatro <= binario;
                        WHEN "101" =>
                            registro_cinco <= binario;
                        WHEN "110" =>
                            registro_seis <= binario;
                        WHEN OTHERS =>
                            registro_siete <= binario;
                    END CASE;

                -- El control permite mostrar
                WHEN OTHERS =>
                    -- Se apagan los LEDs de entrada porque no importan
                    leds_binario <= "00000000";

                    -- Se muestra en LEDs el registro seleccionado
                    leds_seleccion_registro <= seleccion_registro;

                    -- Se convierte el registro seleccionado a decimal
                    CASE seleccion_registro IS
                        WHEN "000" =>
                            decimal <= to_integer(unsigned(registro_cero));
                        WHEN "001" =>
                            decimal <= to_integer(unsigned(registro_uno));
                        WHEN "010" =>
                            decimal <= to_integer(unsigned(registro_dos));
                        WHEN "011" =>
                            decimal <= to_integer(unsigned(registro_tres));
                        WHEN "100" =>
                            decimal <= to_integer(unsigned(registro_cuatro));
                        WHEN "101" =>
                            decimal <= to_integer(unsigned(registro_cinco));
                        WHEN "110" =>
                            decimal <= to_integer(unsigned(registro_seis));
                        WHEN OTHERS =>
                            decimal <= to_integer(unsigned(registro_siete));
                    END CASE;

                    -- Se separa en dígitos el decimal
                    digito_unidades <= decimal MOD 10;
                    digito_decenas <= (decimal / 10) MOD 10;
                    digito_centenas <= decimal / 100;

                    -- Se convierte el digito correspondiente a segmentos y se muestra en los displays (salida paralela)
                    display_unidades <= Conversion_Segmentos(digito_unidades);
                    display_decenas <= Conversion_Segmentos(digito_decenas);
                    display_centenas <= Conversion_Segmentos(digito_centenas);
            END CASE;
        END IF;
    END PROCESS;
END comportamiento;
