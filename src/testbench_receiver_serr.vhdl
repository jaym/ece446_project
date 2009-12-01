---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- File          : testbench_receiver_serr.vhdl
-- Creation Date : 13/11/2009
-- Description: 
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

---------------------------------------------------------------------------
Entity testbench_receiver_serr is 
---------------------------------------------------------------------------
end entity;


---------------------------------------------------------------------------
Architecture testbench_receiver_serr_1 of testbench_receiver_serr is
---------------------------------------------------------------------------
    constant T_R : time := 10 ns;
    constant T_T : time := 160 ns;
    signal clk, rdy, ferr : std_logic;
    signal rx_d : std_logic := '1';
    signal data : std_logic_vector(7 downto 0);
begin
    DUT: entity work.receiver
    port map(
        clk   => clk,
        rx_d  => rx_d,
        reset => '0',

        data  => data,
        rdy   => rdy,
        ferr  => ferr
    );

    process
    begin
        clk <= '0';
        wait for T_R/2;
        clk <= '1';
        wait for T_R/2;
    end process;

    process
        variable data_in : std_logic_vector(7 downto 0) := X"AA";
    begin
        rx_d <= '0';
        wait for T_T/4;
        rx_d <= '1';
        wait for T_T;
        assert false
            report "End of Simulation"
            severity failure;
    end process;

        
	
end architecture testbench_receiver_serr_1;

