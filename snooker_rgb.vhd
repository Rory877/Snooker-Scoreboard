----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.03.2018 11:29:50
-- Design Name: 
-- Module Name: snooker_rgb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity snooker_rgb is

    Port (  CLK100MHZ : in std_logic;
            colour : in std_logic_vector (2 downto 0);
            LED16_R, LED16_G, LED16_B : out std_logic);
            
end snooker_rgb;

architecture Behavioral of snooker_rgb is

    signal CLK1KHZ : std_logic := '0';

begin

    clk_divide : process (CLK100MHZ) is
    
        variable clk_max : unsigned (17 downto 0) := to_unsigned(50000, 18);
        variable clk_count : unsigned (17 downto 0) := to_unsigned(0, 18);
    
    begin
    
        if rising_edge(CLK100MHZ) then
            if clk_count >= clk_max then
                CLK1KHZ <= not CLK1KHZ;
            else
                clk_count := clk_count + 1;
            end if;
        end if;
    
    end process;
    
    
    set_rgb : process (colour, CLK1KHZ) is
    
        variable r, g, b : unsigned (7 downto 0) := to_unsigned(0, 8);
        variable rgb_count : unsigned (7 downto 0) := to_unsigned(0, 8);
    
    begin
    
        case colour is
            when "000" =>                   --White
                r := to_unsigned(80, 8);
                g := to_unsigned(80, 8);
                b := to_unsigned(80, 8);
            when "001" =>                   --Red
                r := to_unsigned(127, 8);
                g := to_unsigned(0, 8);
                b := to_unsigned(0, 8);
            when "010" =>                   --Yellow
                r := to_unsigned(127, 8);
                g := to_unsigned(80, 8);
                b := to_unsigned(0, 8);
            when "011" =>                   --Green
                r := to_unsigned(0, 8);
                g := to_unsigned(127, 8);
                b := to_unsigned(0, 8);
            when "100" =>                   --Brown
                r := to_unsigned(255, 8);
                g := to_unsigned(80, 8);
                b := to_unsigned(0, 8);
            when "101" =>                   --Blue
                r := to_unsigned(0, 8);
                g := to_unsigned(0, 8);
                b := to_unsigned(127, 8);
            when "110" =>                   --Pink
                r := to_unsigned(255, 8);
                g := to_unsigned(21, 8);
                b := to_unsigned(147, 8);
            when "111" =>                   --Black
                r := to_unsigned(1, 8);
                g := to_unsigned(1, 8);
                b := to_unsigned(1, 8);
        end case;
        
        if rising_edge (CLK1KHZ) then
    
            if rgb_count <= r then
                LED16_R <= '1';
            else
                LED16_R <= '0';
            end if;
            
            if rgb_count <= g then
                LED16_G <= '1';
            else 
                LED16_G <= '0';
            end if;
            
            if rgb_count <= b then
                LED16_B <= '1';
            else
                LED16_B <= '0';
            end if;
            
            rgb_count := rgb_count + 1;
            
        end if;
    
    end process;

end Behavioral;
