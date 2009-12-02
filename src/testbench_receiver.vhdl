---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- File          : testbench_receiver.vhdl
-- Creation Date : 13/11/2009
-- Description: 
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

---------------------------------------------------------------------------
Entity testbench_receiver is 
---------------------------------------------------------------------------
end entity;


---------------------------------------------------------------------------
Architecture testbench_receiver_1 of testbench_receiver is
---------------------------------------------------------------------------
    constant T_R : time := 10 ns;
    constant T_T : time := 160 ns;
    signal clk, rdy, ferr : std_logic;
    signal sclk : std_logic;
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
    begin
        sclk <= '0';
        wait for T_T/2;
        sclk <= '1';
        wait for T_T/2;
    end process;

    process
        variable data_in : std_logic_vector(7 downto 0) := X"A4";
    begin
        rx_d <= '1';
        wait for T_T;
        rx_d <= '0';
        wait for T_T;
        for i in 0 to 7 loop
            rx_d <= data_in(i);
            wait for T_T;
        end loop;
        rx_d <= '1';
        wait until rdy = '1' or ferr='1';
        assert data = X"A4"
            report "Incorrectly Received"
            severity error;
        assert ferr = '0'
            report "FERR != 0"
            severity error;
        wait for T_T;
        assert false
            report "End of Simulation"
            severity failure;
    end process;

        
	
end architecture testbench_receiver_1;

