----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.03.2018 12:37:31
-- Design Name: 
-- Module Name: d_type - Behavioral
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

entity d_type is
    Port (  D, en, rst : in std_logic;
            Q : out std_logic );
end d_type;

architecture Behavioral of d_type is

    signal Qtemp : std_logic := '0';

begin

    process (en, rst) is
    begin
        if rst = '1' then
            Qtemp <= '0';
        elsif en = '1' then
            Qtemp <= D;
        end if;
        
        Q <= Qtemp;
        
    end process;

end Behavioral;
