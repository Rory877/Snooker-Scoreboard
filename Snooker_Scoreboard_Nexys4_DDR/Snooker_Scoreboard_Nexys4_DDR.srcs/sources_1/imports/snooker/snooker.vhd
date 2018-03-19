----------------------------------------------------------------------------------
-- Company: Strathclyde University
-- Engineers:
-- 
-- Create Date: 24.2.2017 09:30:14
-- Design Name: 
-- Module Name: 
-- Project Name: Snooker Scoreboard
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
  port (    CLK100MHZ : in std_logic;                                       --Internal 100MHZ clock from the Nexsys4 board
               colour : in UNSIGNED(2 downto 0);                            --3 bit colour activated by 3 switches
         pot, endTurn : in std_logic;                                       --Pot and End Turn buttons
                reset : in std_logic;                                       --Reset button
                  
                  seg : out STD_LOGIC_VECTOR(0 to 6);                       --Segments on the LCD
                   AN : out STD_LOGIC_VECTOR(7 downto 0);                   --Anodes for each digit, activated one at a time with seg to flash through each digit faster than noticable (looks constant)
                  LED : out STD_LOGIC_VECTOR(1 downto 0);                   --Teo leds to display current player
            LED16_R, LED16_B, LED16_G : out std_logic                       --Three RGB LEDs
            );
end entity seven_segment;

-------------------------------
-- architecture body --
-------------------------------
architecture arch of seven_segment is

    -------------
    -- signals --
    -------------
    signal counter : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');       --Counter is used to set each digit on the LCD in incremental order
    signal r_anodes : STD_LOGIC_VECTOR(7 downto 0);                         --This enables the anode of each digit on the LCD, each digit is triggered sequentially using counter
    
    type player_score is array (1 downto 0) of unsigned(7 downto 0);
    signal playerScore : player_score := (others => "0");                   --This stores the players' index 0 is the first player, index 1 is the second player
    signal intScore0 : NATURAL range 0 to 150;                              --Stores the players' scores as natural for displaying on the LCD
    signal intScore1 : NATURAL range 0 to 150;
    
    signal currentPlayer : unsigned(0 downto 0) := "0";                     --Stores the current player, 0 is first player, 1 is second player
    
    signal CLK10KHZ : std_logic := '0';                                     --This is the divided clock (frequency of 10kHz)

    constant zero : STD_LOGIC_VECTOR(6 downto 0) := "0000001";              --These are values used to display the necessary characters on the LCD
    constant one : STD_LOGIC_VECTOR(6 downto 0) := "1001111";               --They are accessed as the more readable one, two, three etc instead of a string of binary numbers
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
    
    type display is array (7 downto 0) of STD_LOGIC_VECTOR(6 downto 0);     --An array to store the characters of each digit on the display
    signal sevenSegment : display;
                     
    signal ballOn : std_logic_vector(7 downto 0) := "00000010";             --Determines if each colour is on, 1 is on, 0 is off. Index 0 is white, 1 is red, 2 is yellow
    
    signal turnLatch : std_logic := '0';                                    --Various outputs from d type flip flops which reset the score and change the current
    signal rstLatch : std_logic := '0';
    signal debounceCount : unsigned (15 downto 0) := (others=>'0');         --Counter to prevent switch bouncing
    
    component d_type                                                        --D type flip flop used to synchronise inputs for reseting score and changing player
        Port (  D, en, rst : in std_logic;
                Q : out std_logic);
    end component;


begin

    endTurnFF : d_type port map (D => endTurn, en => CLK10KHZ, rst => '0', Q => turnLatch);     --Flip flops for synchronising reset score and change player
    scorerstFF : d_type port map (D => reset, en => CLK10KHZ, rst => '0', Q => rstLatch);
    
    AN <= r_anodes;                                                                             --Sets the anode outputs on the board with the signal r_anodes;
    
  -------------------------------  
  -----clock divider process-----
  -------------------------------
  clk_divide : process (CLK100MHZ) is
  
  variable count_10khz : unsigned(11 downto 0) := to_unsigned(0,12);                            --Counter variable required to count up to 5000
  variable max_count_10kHz : unsigned (11 downto 0) := to_unsigned(4999, 12);                   --Max count to achieve 10kHz
  
  begin
    
    if rising_edge(CLK100MHZ) then
      
      if count_10kHz < max_count_10kHz then                                                     --Checks if a max count has been reached
        count_10kHz := count_10kHz + 1;                                                         --If not increment counter
      else
        count_10kHz := to_unsigned(0,12);                                                       --If so reset count to zero and toggle clock signal
        CLK10KHZ <= not CLK10KHZ;
      end if;
      
    end if;
    
  end process;


  
  ------------------------------------
  -----Main scoring functionality-----
  ------------------------------------
  score : process (pot, turnLatch, CLK10KHZ) is
  
  begin
  
    if rstLatch = '1' then                              --If reset score button is pressed then reset both players' score
      playerScore(0) <= to_unsigned(0, 8);
      playerScore(1) <= to_unsigned(0, 8);
  
    elsif turnLatch = '1' then                          --If end turn button is pressed
        if debounceCount < to_unsigned(50000, 16) then          --Ensure button is held for a while
            debounceCount <= debounceCount + 1;
        else
            currentPlayer <= currentPlayer + 1;         --If count is reached change player and reset the count
            debounceCount <= to_unsigned(0, 16);
        end if;
  
    elsif rising_edge(pot) then             --Main scoring logic, runs when pot button is pressed

            if ballOn(to_integer(colour)) = '1' then                    --Checks if the colour of ball potted is on from the ballOn array
                playerScore(to_integer(currentPlayer)) <= playerScore(to_integer(currentPlayer)) + colour;      --Adds score to the current player
                if colour = "001" then
                    ballOn <= "11111110";               --Sets the appropriate balls to on
                else 
                    ballOn <= "00000010";
                end if;
            else
                playerScore(to_integer(not currentPlayer)) <= playerScore(to_integer(not currentPlayer)) + colour;      --Adds score to the other player if incorrect ball is potted
                currentPlayer <= currentPlayer + 1;                                                                     --And changes the current player
                ballOn <= "00000010";
            end if;

    end if;
  
    intScore0 <= to_integer(playerScore(0));        --For converting the score to deciaml to
    intScore1 <= to_integer(playerScore(1));        --display on seven segment LCD
  
  end process;
   
   
   
   -----------------------------
   -- Decimal Score Converter --
   -----------------------------
    decimal_score_converter : process(intScore0, intScore1) is      --When a score is updated, convert to decimal 
        
        variable hun0 : natural := intScore0/100;                   --Finds the hundredths, tenths and units of both scores
        variable rem_hand0 :natural := intScore0 rem 100;
        variable ten0 : natural := rem_hand0/10;
        variable rem_tens0 :natural :=rem_hand0 rem 10;
        variable unit0 : natural := rem_tens0;
        
        variable hun1 : natural := intScore1/100;                   --hun0 is hundredths for player 1, ten1 is tenths for player 2 etc.
        variable rem_hand1 :natural :=intScore1 rem 100;
        variable ten1 : natural := rem_hand1/10;
        variable rem_tens1 :natural :=rem_hand1 rem 10;
        variable unit1 : natural := rem_tens1;
    
    begin
    
        case hun0 is                                                --Sets the array holding each digit on the LCD for each player and digit
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
    
    
    
    -----------------------
    -- Anode Incrementer --
    -----------------------
    anode_incrementer : process (CLK10KHZ) is                         --Increments counter to run through each anode and set the appropriate character
        variable coun : unsigned(2 downto 0) := "000";
    begin
       
        if rising_edge(CLK10KHZ) then
            coun := coun + 1;
        end if;    
            
           counter <= std_logic_vector(coun);
       
    end process;
   
      
      
    --------------------------------------
    -- Seven Segment Display Controller --
    --------------------------------------
    Seven_seg_disply : process(counter) is
          
    begin  
       
        case counter is
            when "000" => r_anodes <= "11111110"; -- AN 0                       --Activates each anode individually
            when "001" => r_anodes <= "11111101"; -- AN 1                       --Active low (0 is on)
            when "010" => r_anodes <= "11111011"; -- AN 2
            when "011" => r_anodes <= "11110111"; -- AN 3
            when "100" => r_anodes <= "11101111"; -- AN 4
            when "101" => r_anodes <= "11011111"; -- AN 5
            when "110" => r_anodes <= "10111111"; -- AN 6
            when "111" => r_anodes <= "01111111"; -- AN 7
      
            when others => r_anodes <= "11111111"; -- nothing
        end case;

        case r_anodes is                                                        --For each anode activate the appropriate character
            when "11111110" => 
                seg <= sevenSegment(7);     -- Eighth Segment
            when "11111101" => 
                seg <= sevenSegment(6);     -- Seventh Segment
            when "11111011" => 
                seg <= sevenSegment(5);     -- Sixth Segment
            when "11110111" => 
                seg <= s;                   -- Fifth Segment
            when "11101111" => 
                seg <= sevenSegment(3);     -- Fourth Segment
            when "11011111" => 
                seg <= sevenSegment(2);     -- Third Segment
            when "10111111" => 
                seg <= sevenSegment(1);     --Second Segment
            when "01111111" => 
                seg <= f;                   --First Segment
                          
            when others => seg <= "1111111"; -- nothing
        end case;
                  
          
    end process;
      
      
      
    ----------------------------
    -- Display Current Player --
    ----------------------------
    displayPlayer : process(currentPlayer) is
    begin
    
        case currentPlayer is                                   --Controls two LEDs to display the current player
            when "0" => LED <= "10";
            when "1" => LED <= "01";
            when others => LED <= "00";
        end case;
                
    end process;
    
    
    
    --------------------
    -- RGB Controller --
    --------------------
    RGB_ball_colour : process (colour, CLK10KHZ) is                 --Displays the current ball colour selected with rgb LED
        
        variable r, g, b : unsigned (7 downto 0) := to_unsigned(0, 8);
        variable rgb_count : unsigned (7 downto 0) := to_unsigned(0, 8);
        
    begin
        
        case colour is                                              --For each colour set the appropriate rgb values
            when "000" =>                   --White
                r := to_unsigned(40, 8);
                g := to_unsigned(40, 8);
                b := to_unsigned(40, 8);
            when "001" =>                   --Red
                r := to_unsigned(40, 8);
                g := to_unsigned(0, 8);
                b := to_unsigned(0, 8);
            when "010" =>                   --Yellow
                r := to_unsigned(40, 8);
                g := to_unsigned(20, 8);
                b := to_unsigned(0, 8);
            when "011" =>                   --Green
                r := to_unsigned(0, 8);
                g := to_unsigned(40, 8);
                b := to_unsigned(0, 8);
            when "100" =>                   --Brown (orange)
                r := to_unsigned(40, 8);
                g := to_unsigned(5, 8);
                b := to_unsigned(0, 8);
            when "101" =>                   --Blue
                r := to_unsigned(0, 8);
                g := to_unsigned(0, 8);
                b := to_unsigned(40, 8);
            when "110" =>                   --Pink
                r := to_unsigned(200, 8);
                g := to_unsigned(20, 8);
                b := to_unsigned(100, 8);
            when "111" =>                   --Black (dim white)
                r := to_unsigned(1, 8);
                g := to_unsigned(1, 8);
                b := to_unsigned(1, 8);
        end case;
            
            if rising_edge (CLK10KHZ) then              --Activates each colour LED for a fraction of 255 count/255
        
                if rgb_count <= r then                  --Active until the r, g or b value is exceeded by the counter
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
                
                rgb_count := rgb_count + 1;             --Increment the counter
                
            end if;
        
        end process;
    

                 
end arch;