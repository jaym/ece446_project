---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- File          : testbench_txrx.vhdl
-- Creation Date : 13/11/2009
-- Description: 
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

---------------------------------------------------------------------------
Entity testbench_txrx is 
---------------------------------------------------------------------------
end entity;


---------------------------------------------------------------------------
Architecture testbench_txrx_1 of testbench_txrx is
---------------------------------------------------------------------------
    constant T_R : time := 10 ns;
    constant T_T : time := 160 ns;
    signal clk_r, clk_t, start, rdy_t, rdy_r, ferr : std_logic;
    signal rx_d : std_logic := '1';
    signal data : std_logic_vector(7 downto 0);
    signal data_in : std_logic_vector(7 downto 0);
begin
    DUT0: entity work.receiver
    port map(
        clk   => clk_r,
        rx_d  => rx_d,

        data  => data,
        rdy   => rdy_r,
        ferr  => ferr
    );

    DUT1: entity work.transmitter
    port map(
        clk   => clk_t,
        start => start,
        data  => data_in,

        tx_d  => rx_d,
        rdy   => rdy_t 
    );


    process
    begin
        clk_r <= '0';
        wait for T_R/2;
        clk_r <= '1';
        wait for T_R/2;
    end process;
    process
    begin
        clk_t <= '0';
        wait for T_T/2;
        clk_t <= '1';
        wait for T_T/2;
    end process;

    process
    begin
        start <= '0';
        data_in <= X"99";
        wait for T_R*2;
        start <= '1';
        assert rdy_t = '1'
            report "rdy_t changed too fast...the following TB will not work"
            severity failure;
        wait until rdy_t = '0';
        wait until rdy_t = '1';
        wait until rdy_r = '1' or ferr ='1';
        assert ferr = '0'
            report "Framing Error...Data will probably be bad"
            severity error;
        assert data = data_in
            report "Data != Data_in"
            severity error;
        assert false
            report "End of Simulation"
            severity failure;
    end process;
	
end architecture testbench_txrx_1;

