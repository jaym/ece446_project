---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- Creation Date : 01/12/2009
-- File          : clock_gen.vhdl
--
-- Abstract : 
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

---------------------------------------------------------------------------
Entity clock_gen is 
---------------------------------------------------------------------------
    Port ( 
             clk : in std_logic;
             out_clk1 : out std_logic;
             out_clk10 : out std_logic;
             out_clk16 : out std_logic;
             out_clk160 : out std_logic
         );
end entity;


---------------------------------------------------------------------------
Architecture clock_gen_1 of clock_gen is
---------------------------------------------------------------------------

begin
    process (clk)                -- Start a process.
        variable count0 : integer := 0;       -- Variable declaration.
        variable count1 : integer := 0;       -- Variable declaration.
        variable count2 : integer := 0;       -- Variable declaration.
        variable count3 : integer := 0;       -- Variable declaration.
    begin
        if clk = '1' and clk'event then    -- Rising edge detection.
            count0 := count0 + 1;
            count1 := count1 + 1;
            count2 := count2 + 1;
            count3 := count3 + 1;
                -- Code to create the 16 Hz clock.
            if count1 >=  3125000 then    -- Taken off a 50MHz clock.
                count1 := 0;                -- Reset count for next cycle.
            end if;
            if count1 >= 0 and count1 <= 1562500 then
                out_clk16 <= '1';           
            else
                out_clk16 <= '0';            
            end if;
                -- Code to create the 1 Hz clock.
            if count0 >= 50000000 then    -- Taken off a 50MHz clock.
                count0 := 0;                -- Reset count for next cycle.
            end if;
            if count0 >= 0 and count0 <= 25000000 then
                out_clk1 <= '1';            
            else
                out_clk1 <= '0';           
            end if;
                -- Code to create the 10 Hz clock.
            if count2 >= 5000000 then     -- Taken off a 50MHz clock.
                count2 := 0;                -- Reset count for next cycle.
            end if;
            if count2 >= 0 and count2 <= 2500000 then
                out_clk10 <= '1';           
            else
                out_clk10 <= '0';           
            end if;
                -- Code to create the 160 Hz clock.
            if count3 >=  312500 then    -- Taken off a 50MHz clock.
                count3 := 0;                -- Reset count for next cycle.
            end if;
            if count3 >= 0 and count3 <= 156250 then
                out_clk160 <= '1';           
            else
                out_clk160 <= '0';          
            end if;
        end if;
    end process;

end architecture clock_gen_1;

