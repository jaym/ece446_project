---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- File          : top.vhdl
-- Creation Date : 13/11/2009
-- Description: 
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

---------------------------------------------------------------------------
Entity top is 
---------------------------------------------------------------------------
    port(
            clk : in std_logic;
            start : in std_logic;
            data_in : in std_logic_vector(7 downto 0);
            rx_data : out std_logic_vector(7 downto 0);
            rx_d : in std_logic;
            tx_d : out std_logic;
            rdy_r : out std_logic;
            rx_ferr: out std_logic;
            rdy_t : out std_logic;
            s : in std_logic;
            reset : in std_logic
        );
end entity;


---------------------------------------------------------------------------
Architecture top_1 of top is
---------------------------------------------------------------------------
    signal clk_rx   : std_logic;
    signal clk_tx   : std_logic;
    signal clk_1    : std_logic;
    signal clk_10   : std_logic;
    signal clk_16   : std_logic;
    signal clk_160  : std_logic;
begin
    DUT0: entity work.receiver
    port map(
        clk   => clk_rx,
        rx_d  => rx_d,
        reset => reset,

        data  => rx_data,
        rdy   => rdy_r,
        ferr  => rx_ferr
    );

    DUT1: entity work.transmitter
    port map(
        clk   => clk_tx,
        start => start,
        data  => data_in,
        reset => reset,

        tx_d  => tx_d,
        rdy   => rdy_t 
    );

    CDIV: entity work.clock_gen 
    port map(
        clk => clk,
        out_clk1   => clk_1,
        out_clk10  => clk_10,
        out_clk16  => clk_16,
        out_clk160 => clk_160
    );

    process(s,clk_16,clk_1,clk_10,clk_160)
    begin
        if(s = '0') then
            clk_rx <= clk_16;
            clk_tx <= clk_1;
        else
            clk_rx <= clk_160;
            clk_tx <= clk_10;
        end if;
    end process;

end architecture top_1;

