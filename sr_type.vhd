----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.03.2018 13:42:16
-- Design Name: 
-- Module Name: sr_type - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sr_type is
    Port (  S, R, en : in std_logic;
            Q : out std_logic );
end sr_type;

architecture Behavioral of sr_type is

begin

    process (en) is
    variable Qtemp : std_logic := '0';
    begin
    
        if rising_edge(en) then
            
            if S = '1' and R = '0' then
                Qtemp := '1';
            elsif S = '0' and R = '1' then
                Qtemp := '0';
            elsif S = '1' and R = '1' then
                Qtemp := not Qtemp;
            end if;
            
        end if;
        
        Q <= Qtemp;
    
    end process;

end Behavioral;
