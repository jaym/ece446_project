----------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- Creation Date : 11/11/2009
-- File          : receiver.vhdl
--
-- Abstract : The 'rdy' signal is asserted when a data word has been
--            received, and the 'ferr' signal is asserted only when a
--            framming error occurred in the data reception. Both the 'rdy'
--            and 'ferr' signals should hold their values until the start 
--            bit of the next data transmission is observed.
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE ieee.math_real.all;
library STD;
use std.textio.all;

---------------------------------------------------------------------------
Entity receiver is 
---------------------------------------------------------------------------
    generic
    (
        TX_SIZE : integer := 8
    );
    port 
    (
        clk   : in  std_logic;
        rx_d  : in  std_logic;

        data  : out std_logic_vector((TX_SIZE -1) downto 0);
        rdy   : out std_logic;
        ferr  : out std_logic
    );
end entity;

---------------------------------------------------------------------------
Architecture receiver_1 of receiver is
---------------------------------------------------------------------------
     constant count_08 : unsigned 
           := to_unsigned(7, integer(ceil(log2(real(TX_SIZE * 2)))));
     constant count_16 : unsigned 
           := to_unsigned(15, integer(ceil(log2(real(TX_SIZE * 2)))));

    type t_state is (s_wait, s_start, s_receive, s_done);

    signal data_register : std_logic_vector((TX_SIZE - 1) downto 0);
    signal s_cur         : t_state := s_wait;
    signal s_nxt         : t_state := s_wait;
    signal counter       : unsigned(integer(ceil(log2(real(TX_SIZE)))) downto 0) 
                         := (others => '0');
    signal bit_count     : unsigned(integer(ceil(log2(real(TX_SIZE)))) downto 0) 
                         := (others => '0');
begin
    process(clk)
    begin
        if(clk'event and clk='1') then
            s_cur <= s_nxt;
            if(s_cur = s_wait) then
                counter <= (others => '0');
                data_register <= data;
                bit_count <= (others => '0'); 
                data_register <= (others => '0');
            elsif(s_cur = s_start) then
                data_register <= rxd & data_register((TX_SIZE -1) downto 0);
            elsif(s_cur = s_receive) and (count = count_16) then
                counter <= (others => '0');
                bit_count <= bit_count + 1;
                data_register <= rx_d & data_register((TX_SIZE -1) downto 0);
            elsif(s_cur = s_receive and (count /= count_16) then
                counter <= counter + 1;
            end if;
        end if;
    end process;

    process(s_cur, s_nxt, bit_count, counter, data_register)
    begin
        case s_cur is
            when s_wait =>
                if(rx_d = '0') then
                    s_nxt <= s_start;
                end if;
            when s_start =>
                if(data_register /= (others => 0)) then
                    s_nxt <= s_wait;
                else
                    s_nxt <= s_receive;
                end if;
            when s_receive =>
                if(bit_count = count_08) then
                    s_nxt <= s_done;
                end if;
            when s_done =>
                if(counter = count_16) then
                    s_nxt <= s_wait;
                end if;
        end case;

    end process;

end architecture receiver_1;
