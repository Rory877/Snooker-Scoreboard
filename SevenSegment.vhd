----------------------------------------------------------------------------------
-- Company: Strathclyde University
-- Engineers:
-- 
-- Create Date: 24.2.2017 09:30:14
-- Design Name: 
-- Module Name: comb_logic - Behavioral
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



-------------------------------
-- library declarations --
-------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-------------------------------
-- entity declaration --
-------------------------------
entity seven_segment is
  port (       clk_in : in std_logic;
               colour : in UNSIGNED(2 downto 0);
                  pot : in std_logic;
              endTurn : in std_logic;
                  
                 seg  : out STD_LOGIC_VECTOR(0 to 6);
                  AN  : out STD_LOGIC_VECTOR(7 downto 0);
                  LED : out STD_LOGIC_VECTOR(1 downto 0)
                 
            );
end entity seven_segment;

-------------------------------
-- architecture body --
-------------------------------
architecture arch of seven_segment is

-- constants 
-- ( *** make sure to comment one of these out depending on whether you are simulating or implementing! ***)
constant max_count : integer :=5000 ;    -- must count to this number to divide clock frequency from 100MHz to 8Hz.
--constant max_count : integer := 5;           -- for simulation only (easier to check output!)

    --signals
    signal counter : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal r_anodes : STD_LOGIC_VECTOR(7 downto 0);
    signal score0 : UNSIGNED(7 downto 0);
    signal score1 : UNSIGNED(7 downto 0);
    signal intScore0 : NATURAL range 0 to 150;
    signal intScore1 : NATURAL range 0 to 150;
    signal currentPlayer : unsigned(0 downto 0) := "0";
    signal clk : std_logic;                         -- this is the divided clock (i.e. frequency of 8Hz)

    constant zero : STD_LOGIC_VECTOR(6 downto 0) := "0000001";
    constant one : STD_LOGIC_VECTOR(6 downto 0) := "1001111";
    constant two : STD_LOGIC_VECTOR(6 downto 0) := "0010010";
    constant three : STD_LOGIC_VECTOR(6 downto 0) := "0000110";
    constant four : STD_LOGIC_VECTOR(6 downto 0) := "1001100";
    constant five : STD_LOGIC_VECTOR(6 downto 0) := "0100100";
    constant six : STD_LOGIC_VECTOR(6 downto 0) := "0100000";
    constant seven : STD_LOGIC_VECTOR(6 downto 0) := "0001111";
    constant eight : STD_LOGIC_VECTOR(6 downto 0) := "0000000";
    constant nine : STD_LOGIC_VECTOR(6 downto 0) := "0001100";
    constant f : STD_LOGIC_VECTOR(6 downto 0) := "0111000";
    constant s : STD_LOGIC_VECTOR(6 downto 0) := "0100100";
     constant blank : STD_LOGIC_VECTOR(6 downto 0) := "1111111";
    type display is array (7 downto 0) of STD_LOGIC_VECTOR(6 downto 0);
    signal sevenSegment : display;
    
    type activation is array (7 downto 0) of std_logic;
    signal ballOn : activation := "00000010";
    
    signal turnLatch : std_logic := '0';
    signal rstTurn : std_logic := '0';
    signal playerLatch : std_logic := '0';
    signal playerS : std_logic := '0';
    signal playerR : std_logic := '0';
    
    component d_type
        Port (  D, en, rst : in std_logic;
                Q : out std_logic);
    end component;
    
    component dbounce
        Port (  A, clk : in std_logic;
                Qout : out std_logic);
    end component;

begin

    --endTurnFF : d_type port map (D => endTurn, en => clk_in, rst => rstTurn, Q => turnLatch);
    endTurn_dbounce : dbounce port map (A => endTurn, clk => clk, Qout => turnLatch);
    
    AN <= r_anodes;
  
    sevenSegment(0) <= f;
    --sevenSegment(1) <= zero;
    --sevenSegment(2) <= zero;
    --sevenSegment(3) <= zero;
    sevenSegment(4) <= s;
    --sevenSegment(5) <= zero;
    --sevenSegment(6) <= zero;
    --sevenSegment(7) <= zero;
    
    
  -------------------------------  
  -----clock divider process-----
  -------------------------------
  clk_divide : process (clk_in) is
  
  variable count : unsigned(25 downto 0):= to_unsigned(0,26);   -- required to count up to 500000!
  variable clk_int : std_logic := '0';                          -- this is a clock internal to the process
  
  begin
    
    if rising_edge(clk_in) then
      
      if count < max_count-1 then     -- highest value count should reach is 6,249,999.
        count := count + 1;           -- increment counter
      else
        count := to_unsigned(0,26);   -- reset count to zero
        clk_int := not clk_int;       -- invert clock variable every time counter resets
      end if;
      
      clk <= clk_int;                 -- assign clock variable to internal clock signal
      
    end if;
    
  end process;
  
  
  ------------------------------------
  -----Toggles the current player-----
  ------------------------------------
  --buttonLatch : process(clk) is
  --begin
    
    --if rising_edge(clk) then
        --if turnLatch = '1' then
            --currentPlayer <= currentPlayer + 1;
        --end if;
    --end if;
    
  --end process;
  
  
  ------------------------------------
  -----Main scoring functionality-----
  ------------------------------------
  score : process (pot, clk) is
  
  begin
  
    if turnLatch = '1' then
        currentPlayer <= currentPlayer + 1;
        --turnLatch <= '0';
  
    elsif rising_edge(pot) then

        case currentPlayer is
    
        when "0" =>
            if ballOn(to_integer(colour)) = '1' then    --Checks if the colour of ball potted is on from the ballOn array
                score0 <= score0 + colour;
                if colour = "001" then
                    ballOn <= "11111110";
                else 
                    ballOn <= "00000010";
                end if;
            else
                score1 <= score1 + colour;
                currentPlayer <= currentPlayer + 1;
                ballOn <= "00000010";
            end if;
        when "1" =>
            if ballOn(to_integer(colour)) = '1' then
                score1 <= score1 + colour;
                if colour = "001" then
                    ballOn <= "11111110";
                else
                    ballOn <= "00000010";
                end if;
            else
                score0 <= score0 + colour;
                currentPlayer <= currentPlayer + 1;
                ballOn <= "00000010";
            end if;
            
        end case;

    end if;
  
    intScore0 <= to_integer(score0);
    intScore1 <= to_integer(score1);
  
  end process;
  
  

  
  
  -- sequence generator process - to be completed
  ------------------------------------------------
 clk_counter : process (clk) is

    variable coun : unsigned(2 downto 0) := "000";
 
    begin
    
        if rising_edge(clk) then
   
            coun := coun + 1;--          

        end if;    
         
        counter <= std_logic_vector(coun);
    
 end process;
   
   
    updateScore : process(intScore0, intScore1) is
        
        variable hun0 : natural := intScore0/100;
        variable rem_hand0 :natural := intScore0 rem 100;
        variable ten0 : natural := rem_hand0/10;
        variable rem_tens0 :natural :=rem_hand0 rem 10;
        variable unit0 : natural := rem_tens0;
        
        variable hun1 : natural := intScore1/100;
        variable rem_hand1 :natural :=intScore1 rem 100;
        variable ten1 : natural := rem_hand1/10;
        variable rem_tens1 :natural :=rem_hand1 rem 10;
        variable unit1 : natural := rem_tens1;
    
    begin
    
        case hun0 is
            when 0 => sevenSegment(1) <= zero;
            when 1 => sevenSegment(1) <= one;
            when 2 => sevenSegment(1) <= two;
            when 3 => sevenSegment(1) <= three;
            when 4 => sevenSegment(1) <= four;
            when 5 => sevenSegment(1) <= five;
            when 6 => sevenSegment(1) <= six;
            when 7 => sevenSegment(1) <= seven;
            when 8 => sevenSegment(1) <= eight;
            when 9 => sevenSegment(1) <= nine;
            when others=>sevenSegment(1)<= zero;
        end case;
        
        case ten0 is
            when 0 => sevenSegment(2) <= zero;
            when 1 => sevenSegment(2) <= one;
            when 2 => sevenSegment(2) <= two;
            when 3 => sevenSegment(2) <= three;
            when 4 => sevenSegment(2) <= four;
            when 5 => sevenSegment(2) <= five;
            when 6 => sevenSegment(2) <= six;
            when 7 => sevenSegment(2) <= seven;
            when 8 => sevenSegment(2) <= eight;
            when 9 => sevenSegment(2) <= nine;
            when others=>sevenSegment(2)<= zero;
        end case;
        
        case unit0 is
            when 0 => sevenSegment(3) <= zero;
            when 1 => sevenSegment(3) <= one;
            when 2 => sevenSegment(3) <= two;
            when 3 => sevenSegment(3) <= three;
            when 4 => sevenSegment(3) <= four;
            when 5 => sevenSegment(3) <= five;
            when 6 => sevenSegment(3) <= six;
            when 7 => sevenSegment(3) <= seven;
            when 8 => sevenSegment(3) <= eight;
            when 9 => sevenSegment(3) <= nine;
            when others=>sevenSegment(3)<= zero;
        end case;
        
        case hun1 is
            when 0 => sevenSegment(5) <= zero;
            when 1 => sevenSegment(5) <= one;
            when 2 => sevenSegment(5) <= two;
            when 3 => sevenSegment(5) <= three;
            when 4 => sevenSegment(5) <= four;
            when 5 => sevenSegment(5) <= five;
            when 6 => sevenSegment(5) <= six;
            when 7 => sevenSegment(5) <= seven;
            when 8 => sevenSegment(5) <= eight;
            when 9 => sevenSegment(5) <= nine;
            when others=>sevenSegment(5)<= zero;
        end case;
        
        case ten1 is
            when 0 => sevenSegment(6) <= zero;
            when 1 => sevenSegment(6) <= one;
            when 2 => sevenSegment(6) <= two;
            when 3 => sevenSegment(6) <= three;
            when 4 => sevenSegment(6) <= four;
            when 5 => sevenSegment(6) <= five;
            when 6 => sevenSegment(6) <= six;
            when 7 => sevenSegment(6) <= seven;
            when 8 => sevenSegment(6) <= eight;
            when 9 => sevenSegment(6) <= nine;
            when others=>sevenSegment(6)<= zero;
        end case;
        
        case unit1 is
            when 0 => sevenSegment(7) <= zero;
            when 1 => sevenSegment(7) <= one;
            when 2 => sevenSegment(7) <= two;
            when 3 => sevenSegment(7) <= three;
            when 4 => sevenSegment(7) <= four;
            when 5 => sevenSegment(7) <= five;
            when 6 => sevenSegment(7) <= six;
            when 7 => sevenSegment(7) <= seven;
            when 8 => sevenSegment(7) <= eight;
            when 9 => sevenSegment(7) <= nine;
            when others=>sevenSegment(7)<= zero;
        end case;
    
    end process;
   
      
    Seven_seg_disply : process(counter) is
          
    begin  
       
        case counter(2 downto 0) is
            when "000" => r_anodes <= "11111110"; -- AN 0
            when "001" => r_anodes <= "11111101"; -- AN 1
            when "010" => r_anodes <= "11111011"; -- AN 2
            when "011" => r_anodes <= "11110111"; -- AN 3
            when "100" => r_anodes <= "11101111"; -- AN 4
            when "101" => r_anodes <= "11011111"; -- AN 5
            when "110" => r_anodes <= "10111111"; -- AN 6
            when "111" => r_anodes <= "01111111"; -- AN 7
      
            when others => r_anodes <= "11111111"; -- nothing
        end case;
      
        -- Set segments correctly based on the signal 
        case r_anodes is
            when "11111110" => 
                seg <= sevenSegment(7); -- F
            when "11111101" => 
                seg <= sevenSegment(6);--0
            when "11111011" => 
                seg <= sevenSegment(5); -- 0
            when "11110111" => 
                seg <= sevenSegment(4);--0
            when "11101111" => 
                seg <= sevenSegment(3);--S
            when "11011111" => 
                seg <= sevenSegment(2);--0
            when "10111111" => 
                seg <= sevenSegment(1); -- 0
            when "01111111" => 
                seg <= sevenSegment(0); --0                       
                          
            when others => seg <= "1111111"; -- nothing
        end case;
                  
          
    end process;
      
      
    displayPlayer : process(currentPlayer) is
    begin
    
        case currentPlayer is
            when "0" => LED <= "10";
            when "1" => LED <= "01";
            when others => LED <= "00";
        end case;
                
    end process;

                 
end arch;