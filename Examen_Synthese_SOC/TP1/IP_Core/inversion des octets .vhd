library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity inversion_octets is
    Port (
        data_in  : in  STD_LOGIC_VECTOR(31 downto 0);
        mode     : in  STD_LOGIC; -- 0 : inversion complète
                                  -- 1 : inversion par paires
        data_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end inversion_octets;

architecture combinatoire of inversion_octets is
begin

    process(data_in, mode)
    begin

        if mode = '0' then
            -- [Octet0 | Octet1 | Octet2 | Octet3]
            data_out <= data_in(7 downto 0)   &
                        data_in(15 downto 8)  &
                        data_in(23 downto 16) &
                        data_in(31 downto 24);

        else
            -- [Octet1 | Octet0 | Octet3 | Octet2]
            data_out <= data_in(15 downto 8) &
                        data_in(7 downto 0)  &
                        data_in(31 downto 24)&
                        data_in(23 downto 16);

        end if;

    end process;

end combinatoire;