----------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- Creation Date : 11/11/2009
-- File          : transmitter.vhdl
--
-- Abstract : This module defines the asychronous serial transmitter 
--            circuit. When it is initialized, the circuit will assert 'rdy' 
--            indicating it is ready to accept data for transmission. When
--            start is asserted, the circuit will de-assert the 'rdy' 
--            signal, read the data word off the data input lines, and
--            begin sending the transmission out on the 'tx_d' output line.
--            After sending all bits, the 'rdy' sginal will be assterted.
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE ieee.math_real.all;
library STD;
use std.textio.all;

---------------------------------------------------------------------------
Entity transmitter is 
---------------------------------------------------------------------------
    generic
    (
        TX_SIZE : integer := 8
    );
    port 
    (
        clk   : in std_logic;
        start : in std_logic;
        data  : in std_logic_vector((TX_SIZE -1) downto 0);

        tx_d  : out std_logic;
        rdy   : out std_logic
    );
end entity;

---------------------------------------------------------------------------
Architecture transmitter_1 of transmitter is
---------------------------------------------------------------------------
    constant count_high : unsigned 
           := to_unsigned(TX_SIZE, integer(ceil(log2(real(TX_SIZE * 2)))));

    type t_state is (s_wait, s_start, s_send);

    signal data_register : std_logic_vector((TX_SIZE - 1) downto 0);
    signal s_cur         : t_state := s_wait;
    signal s_nxt         : t_state := s_wait;
    signal count         : unsigned(integer(ceil(log2(real(TX_SIZE)))) downto 0) 
                         := (others => '0');
begin
    process(clk)
    begin
        if(clk'event and clk='1') then
            s_cur <= s_nxt;
            if(s_cur = s_wait) then
                count <= (others => '0');
                data_register <= data;
            elsif(s_cur = s_send) and (count /= count_high) then
                count <= count + 1;
                data_register <= '1' & data_register((TX_SIZE - 1) downto 1);
            end if;
        end if;
    end process;

    process(s_cur, s_nxt, start,count)
    begin
        case s_cur is
            when s_wait =>
                if(start = '1') then
                    s_nxt <= s_start;
                else
                    s_nxt <= s_wait;
                end if;
            when s_start =>
                s_nxt <= s_send;
            when s_send =>
                if(count = count_high) then
                    s_nxt <= s_wait;
                end if;
        end case;
    end process;


    process(s_cur, data_register)
    begin
        case s_cur is
            when s_wait =>
                tx_d <= '1';
                rdy  <= '1';
            when s_start =>
                tx_d <= '0';
                rdy  <= '0';
            when s_send =>
                rdy  <= '0';
                tx_d <= data_register(0);
        end case;
    end process;


end architecture transmitter_1;
