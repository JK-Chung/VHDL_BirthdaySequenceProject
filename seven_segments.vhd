library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_segments is
    Port (basysClock    :   IN STD_LOGIC;
          sw            :   IN STD_LOGIC_VECTOR(0 to 1);
          led           :   OUT STD_LOGIC_VECTOR(0 to 15);
          seg           :   OUT STD_LOGIC_VECTOR(0 to 7);
          digit_enable  :   OUT STD_LOGIC_VECTOR(0 to 3));   
end seven_segments;

architecture Behavioral of seven_segments is
    type SEGMENTS_DISPLAY is array(natural range 0 to 3) of STD_LOGIC_VECTOR(0 to 7);
    type LED_DISPLAY is array(natural range 0 to 15) of STD_LOGIC_VECTOR(led'low to led'high);
    type TEAMS_BIRTHDAYS is array(natural range<>) of SEGMENTS_DISPLAY;
    type TEAMS_SEQUENCES is array(natural range <>) of LED_DISPLAY;
    
    SIGNAL segment_CLK          :   STD_LOGIC := '0';
    SIGNAL led_CLK              :   STD_LOGIC := '0';
    SIGNAL seg_sequenceNumber   :   STD_LOGIC_VECTOR(1 downto 0) := "00";
    SIGNAL led_sequenceNumber   :   STD_LOGIC_VECTOR(3 downto 0) := "0000";
    
    CONSTANT all_sequences      :   TEAMS_SEQUENCES(0 to 3) :=
        (0 =>   ("1100001111000011","1100011111100011","1000111111110001","0001111001111000",
                 "0011110000111100","0111100000011110","1111000000001111","1110000000000111",
                 "1100000000000011","1000000000000000","0000000000000000","1100000000000011",
                 "0011000000001100","0001100000011000","0000110000110000","1000011001100001"),
         1 =>   ("1000000000000000","1100000000000000","1110000000000000","1111000000000000",
                 "1111100000000000","1111110000000000","1111111000000000","1111111100000000",
                 "1111111110000000","1111111111000000","1111111111100000","1111111111110000",
                 "1111111111111000","1111111111111100","1111111111111110","1111111111111111"),
         2 =>   ("1111111111111111","1111111111111110","1111111111111100","1111111111111000",
                 "1111111111110000","1111111111100000","1111111111000000","1111111110000000",
                 "1111111100000000","1111111000000000","1111111111000000","1111100000000000",
                 "1111000000000000","1110000000000000","1100000000000000","1000000000000000"),
         3 =>   ("1111111111111111","0000000000000000","1111111111111111","0000000000000000",
                 "1111111111111111","0000000000000000","1111111111111111","0000000000000000",
                 "1111111111111111","0000000000000000","1111111111111111","0000000000000000",
                 "1111111111111111","0000000000000000","1111111111111111","0000000000000000"));
         
    CONSTANT all_birthdays  :   TEAMS_BIRTHDAYS(0 to 3) :=
        (0 =>   ("00100101","10011001","00000011","10011111"),
         1 =>   ("00000011","00100101","00000011","00001101"),
         2 =>   ("10011111","10011111","00000011","00000001"),
         3 =>   ("00000000","00000000","00000000","00000000"));
begin   
    segment_CLK_DIVIDE : process (basysClock) is
    variable noOfBasyWaves  :   INTEGER := 0;
    constant maxCount       :   INTEGER := 50000;
    --constant maxCount       :   INTEGER := 32;
    begin
        if rising_edge(basysClock) then
            if noOfBasyWaves < maxCount then
                noOfBasyWaves := noOfBasyWaves + 1;
            else
                noOfBasyWaves := 0;
                segment_CLK <= not segment_CLK;
            end if;
        end if;
    end process;
    
    led_CLK_DIVIDE : process (basysClock) is
    variable noOfBasyWaves_LED  :   INTEGER := 0;
    constant maxCount_LED       :   INTEGER := 6250000;
    --constant maxCount_LED       :   INTEGER := 8;
    begin
        if rising_edge(basysClock) then
            if noOfBasyWaves_LED < maxCount_LED then
                noOfBasyWaves_LED := noOfBasyWaves_LED + 1;
            else
                noOfBasyWaves_LED := 0;
                led_CLK <= not led_CLK;
            end if;
        end if;
    end process;

    increment_segmentSequenceNumber : process(segment_CLK) is
    begin
        if rising_edge(segment_CLK) then
            -- seg_sequenceNumber must be converted to unsigned before undergoing arithmetic
            seg_sequenceNumber <= STD_LOGIC_VECTOR(unsigned(seg_sequenceNumber) + 1);
        end if;
    end process;
    
    increment_ledSequenceNumber : process(led_CLK) is
    begin
        if rising_edge(led_CLK) then
            led_sequenceNumber <= STD_LOGIC_VECTOR(unsigned(led_sequenceNumber) + 1);
        end if;
    end process;
    
    controlDisplayEnables : process(seg_sequenceNumber) is
    begin
        case to_integer(unsigned(seg_sequenceNumber)) is
            when 0 =>
                digit_enable <= "0111";
            when 1 =>
                digit_enable <= "1011";
            when 2 =>
                digit_enable <= "1101";
            when others =>
                digit_enable <= "1110";
        end case;
    end process;
    
    personSelection : process (sw,seg_sequenceNumber,led_sequenceNumber) is 
    VARIABLE selectPerson   :   INTEGER := 0;
    begin
        selectPerson := to_integer(unsigned(sw));

        seg <= all_birthdays(selectPerson)(to_integer(unsigned(seg_sequenceNumber)));
        led <= all_sequences(selectPerson)(to_integer(unsigned(led_sequenceNumber)));
    end process;
    
end Behavioral;
