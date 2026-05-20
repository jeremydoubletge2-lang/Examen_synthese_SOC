LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY inversion_bus_interface IS
    PORT (
        clk        : IN STD_LOGIC;
        resetn     : IN STD_LOGIC;
        read       : IN STD_LOGIC;
        write      : IN STD_LOGIC;
        chipselect : IN STD_LOGIC;
        writedata  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        byteenable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);  -- 4 octets
        readdata   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_out   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  -- sortie directe
        mode       : IN STD_LOGIC  -- 0 : inversion complète, 1 : inversion par paires
    );
END inversion_bus_interface;

ARCHITECTURE rtl OF inversion_bus_interface IS

    SIGNAL local_byteenable : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL reg_data         : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg_output       : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Déclaration du composant combinatoire d’inversion
    COMPONENT inversion_octets
        PORT (
            data_in  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            mode     : IN STD_LOGIC;
            data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

BEGIN

    -- Composant d’inversion
    U1: inversion_octets
        PORT MAP (
            data_in  => reg_data,
            mode     => mode,
            data_out => reg_output
        );

    -- Gestion du byteenable uniquement quand chipselect et write sont actifs
    WITH (chipselect AND write) SELECT
        local_byteenable <= byteenable WHEN '1',
                             "0000" WHEN OTHERS;

    -- Registre interne avec gestion du byteenable
    process(clk, resetn)
    begin
        if resetn = '0' then
            reg_data <= (others => '0');
        elsif rising_edge(clk) then
            if chipselect = '1' AND write = '1' then
                -- Écriture avec byteenable
                if local_byteenable(0) = '1' then
                    reg_data(7 downto 0) <= writedata(7 downto 0);
                end if;
                if local_byteenable(1) = '1' then
                    reg_data(15 downto 8) <= writedata(15 downto 8);
                end if;
                if local_byteenable(2) = '1' then
                    reg_data(23 downto 16) <= writedata(23 downto 16);
                end if;
                if local_byteenable(3) = '1' then
                    reg_data(31 downto 24) <= writedata(31 downto 24);
                end if;
            end if;
        end if;
    end process;

    -- Lecture
    process(clk)
    begin
        if rising_edge(clk) then
            if chipselect = '1' AND read = '1' then
                readdata <= reg_output;
            end if;
        end if;
    end process;

    -- Sortie directe
    data_out <= reg_output;

END rtl;