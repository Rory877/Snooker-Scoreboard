----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.03.2018 14:40:17
-- Design Name: 
-- Module Name: dbounce - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dbounce is

    Port (  A, clk : in std_logic;
            Qout : out std_logic );
            
end dbounce;

architecture Behavioral of dbounce is

    signal Aout, Qin, Qtemp : std_logic;

    component d_type
        Port (  D, en, rst : in std_logic;
                Q : out std_logic);
    end component;

begin

    flipflopA : d_type port map (D => A, en => clk, rst => '0', Q => Aout);
    flipflopQ : d_type port map (D => Qin, en => clk, rst => '0', Q => Qout);
    
    process (clk) is
    
    variable count : unsigned (19 downto 0) := (others => '0');
    variable output : std_logic := '0';
    
    begin
    
        if count > 100 then
            Qtemp <= '1';
            count := (others => '0');
        elsif Aout = '1' then
            Qtemp <= '0';
            count := count + 1;
        else
            Qtemp <= '0';
            count := (others => '0');
        end if;
        
        Qin <= Qtemp;
    
    end process;

end Behavioral;
