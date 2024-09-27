-- Practica uno: Uso de registros
-- Elaborado por: González Roldán Geoperi
-- Fecha: 25/09/2024

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY practica_uno IS
    PORT (
        binario : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        seleccion : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        reloj : IN STD_LOGIC;
        reinicio : IN STD_LOGIC;
        control : IN STD_LOGIC;
        leds_binario : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        leds_seleccion : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        display_unidades : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        display_decenas : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        display_centenas : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END practica_uno;

ARCHITECTURE comportamiento OF practica_uno IS
    -- Declaración de un solo registro
    SIGNAL registro : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Declaración del índice de desplazamiento para el guardado de bits
    SIGNAL indice_desplazamiento : INTEGER RANGE 0 TO 7 := 0;

    -- Declaración del índice de display para mostrar en orden
    -- las unidades, decenas y centenas
    SIGNAL indice_display : INTEGER RANGE 0 TO 2 := 0;

    -- Declaración de los números decimales para mostrar en los displays
    SIGNAL decimal : INTEGER := 0;
    SIGNAL digito_unidades, digito_decenas, digito_centenas : INTEGER := 0;

    -- Función para convertir un dígito a segmentos
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
    PROCESS (reloj, binario, reinicio, control, seleccion)
    BEGIN
        -- Reinicio de todo en bajo
        IF (reinicio = '0') THEN

            registro <= "00000000";

            display_unidades <= "1111110";
            display_decenas <= "1111110";
            display_centenas <= "1111110";

            indice_desplazamiento <= 0;
            indice_display <= 0;

            decimal <= 0;
            digito_unidades <= 0;
            digito_decenas <= 0;
            digito_centenas <= 0;

            leds_binario <= "00000000";
            leds_seleccion <= "000";

        ELSIF (reloj' event AND reloj = '1') THEN
            CASE seleccion IS
                -- Entrada serie, salida serie
                WHEN "001" =>
                    leds_seleccion <= "001";
                    CASE control IS
                            -- El control permite almacenar
                        WHEN '0' =>
                            -- Se muestra en LEDs la entrada
                            leds_binario <= binario;

                            -- Se almacena el bit de entrada en el registro de acuerdo al índice
                            registro(indice_desplazamiento) <= binario(indice_desplazamiento);

                            -- Se actualizael índice
                            IF indice_desplazamiento = 7 THEN
                                indice_desplazamiento <= 0;
                            ELSE
                                indice_desplazamiento <= indice_desplazamiento + 1;
                            END IF;

                            -- El control permite mostrar
                        WHEN OTHERS =>
                            -- Convertir registro binario a decimal
                            decimal <= to_integer(unsigned(registro));

                            -- Separar en dígitos
                            digito_unidades <= decimal MOD 10;
                            digito_decenas <= (decimal / 10) MOD 10;
                            digito_centenas <= decimal / 100;

                            -- Mostrar en los displays uno tras otro con la diferencia de un ciclo de reloj
                            CASE indice_display IS
                                WHEN 0 =>
                                    display_unidades <= Conversion_Segmentos(digito_unidades);
                                    indice_display <= 1;
                                WHEN 1 =>
                                    display_decenas <= Conversion_Segmentos(digito_decenas);
                                    indice_display <= 2;
                                WHEN 2 =>
                                    display_centenas <= Conversion_Segmentos(digito_centenas);
                                    indice_display <= 0;
                            END CASE;
                    END CASE;
                    
                -- Entrada serie, salida paralelo
                WHEN "010" =>
                    leds_seleccion <= "010";
                    CASE control IS
                            -- El control permite almacenar
                        WHEN '0' =>
                            -- Se muestra en LEDs la entrada
                            leds_binario <= binario;

                            -- Se almacena el bit de entrada en el registro de acuerdo al índice
                            registro(indice_desplazamiento) <= binario(indice_desplazamiento);

                            -- Se actualiza el índice
                            IF indice_desplazamiento = 7 THEN
                                indice_desplazamiento <= 0;
                            ELSE
                                indice_desplazamiento <= indice_desplazamiento + 1;
                            END IF;

                            -- El control permite mostrar
                        WHEN OTHERS =>
                            -- Convertir registro binario a decimal
                            decimal <= to_integer(unsigned(registro));

                            -- Separar en dígitos
                            digito_unidades <= decimal MOD 10;
                            digito_decenas <= (decimal / 10) MOD 10;
                            digito_centenas <= decimal / 100;

                            -- Mostrar en displays
                            display_unidades <= Conversion_Segmentos(digito_unidades);
                            display_decenas <= Conversion_Segmentos(digito_decenas);
                            display_centenas <= Conversion_Segmentos(digito_centenas);
                    END CASE;

                -- Entrada paralelo, salida serie
                WHEN "011" =>
                    leds_seleccion <= "011";
                    CASE control IS
                            -- El control permite almacenar
                        WHEN '0' =>
                            -- Se muestra en LEDs la entrada
                            leds_binario <= binario;

                            -- Se almacena el binario en el registro
                            registro <= binario;

                            -- El control permite mostrar
                        WHEN OTHERS =>
                            -- Convertir registro binario a decimal
                            decimal <= to_integer(unsigned(registro));

                            -- Separar en dígitos
                            digito_unidades <= decimal MOD 10;
                            digito_decenas <= (decimal / 10) MOD 10;
                            digito_centenas <= decimal / 100;

                            -- Mostrar en los displays uno tras otro con la diferencia de un ciclo de reloj
                            CASE indice_display IS
                                WHEN 0 =>
                                    display_unidades <= Conversion_Segmentos(digito_unidades);
                                    indice_display <= 1;
                                WHEN 1 =>
                                    display_decenas <= Conversion_Segmentos(digito_decenas);
                                    indice_display <= 2;
                                WHEN 2 =>
                                    display_centenas <= Conversion_Segmentos(digito_centenas);
                                    indice_display <= 0;
                            END CASE;
                    END CASE;

                -- Entrada paralelo, salida paralelo
                WHEN "100" =>
                    leds_seleccion <= "100";
                    CASE control IS
                            -- El control permite almacenar
                        WHEN '0' =>
                            -- Se muestra en LEDs la entrada
                            leds_binario <= binario;

                            -- Se almacena el binario en el registro
                            registro <= binario;

                            -- El control permite mostrar
                        WHEN OTHERS =>
                            -- Convertir registro binario a decimal
                            decimal <= to_integer(unsigned(registro));

                            -- Separar en dígitos
                            digito_unidades <= decimal MOD 10;
                            digito_decenas <= (decimal / 10) MOD 10;
                            digito_centenas <= decimal / 100;

                            -- Mostrar en displays
                            display_unidades <= Conversion_Segmentos(digito_unidades);
                            display_decenas <= Conversion_Segmentos(digito_decenas);
                            display_centenas <= Conversion_Segmentos(digito_centenas);
                    END CASE;

                -- Barrel Shifter
                WHEN "101" =>
                    leds_seleccion <= "101";
                    CASE control IS
                        WHEN '0' =>
                            -- Se muestra en LEDs la entrada
                            leds_binario <= binario;
                            registro <= binario;
                        WHEN OTHERS =>
                            -- Desplazar a la derecha
                            registro(0) <= registro(1);
                            registro(1) <= registro(2);
                            registro(2) <= registro(3);
                            registro(3) <= registro(4);
                            registro(4) <= registro(5);
                            registro(5) <= registro(6);
                            registro(6) <= registro(7);
                            registro(7) <= registro(0);
                    END CASE;
                    -- Convertir registro binario a decimal
                    decimal <= to_integer(unsigned(registro));

                    -- Separar en dígitos
                    digito_unidades <= decimal MOD 10;
                    digito_decenas <= (decimal / 10) MOD 10;
                    digito_centenas <= decimal / 100;

                    -- Mostrar en displays
                    display_unidades <= Conversion_Segmentos(digito_unidades);
                    display_decenas <= Conversion_Segmentos(digito_decenas);
                    display_centenas <= Conversion_Segmentos(digito_centenas);

                -- Si la selección de registro no es válida, se reinicia todo
                WHEN OTHERS =>
                    leds_seleccion <= "000";

                    registro <= "00000000";

                    display_unidades <= "1111110";
                    display_decenas <= "1111110";
                    display_centenas <= "1111110";

                    indice_desplazamiento <= 0;
                    indice_display <= 0;

                    decimal <= 0;
                    digito_unidades <= 0;
                    digito_decenas <= 0;
                    digito_centenas <= 0;
            END CASE;
        END IF;
    END PROCESS;
END comportamiento;
