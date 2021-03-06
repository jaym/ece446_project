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
        reset : in  std_logic;

        data  : out std_logic_vector((TX_SIZE -1) downto 0);
        rdy   : out std_logic;
        ferr  : out std_logic
    );
end entity;

---------------------------------------------------------------------------
Architecture receiver_1 of receiver is
---------------------------------------------------------------------------
     --constant count_08 : unsigned 
           --:= to_unsigned(7, integer(ceil(log2(real(TX_SIZE * 2)))));
     --constant count_16 : unsigned 
           --:= to_unsigned(15, integer(ceil(log2(real(TX_SIZE * 2)))));

    type t_state is (s_wait, s_start, s_receive, s_done, s_err);

    signal dr      : std_logic_vector((TX_SIZE - 1) downto 0); --current dr
    signal dr_next : std_logic_vector((TX_SIZE - 1) downto 0); --next state dr

    --state registers
    signal s_cur         : t_state := s_wait;
    signal s_nxt         : t_state := s_wait;

    --counter registers: Used to sample
    signal c_cur         : unsigned(integer(ceil(log2(real(TX_SIZE)))) downto 0) 
                         := (others => '0');
    signal c_nxt         : unsigned(integer(ceil(log2(real(TX_SIZE)))) downto 0) 
                         := (others => '0');

    --bit_count registers: Used to keep track of number of received bits
    signal bc_cur         : unsigned(integer(ceil(log2(real(TX_SIZE)))) downto 0) 
                          := (others => '0');
    signal bc_nxt         : unsigned(integer(ceil(log2(real(TX_SIZE)))) downto 0) 
                          := (others => '0');

begin
    process(clk)
    begin
        if(clk'event and clk='1') then
            if(reset = '1') then -- Sync Reset
                s_cur  <= s_wait;
                -- Reset Counters
                c_cur  <= (others => '0');
                bc_cur <= (others => '0');
                dr     <= (others => '0');
            else
                --update current state
                s_cur <= s_nxt;
                c_cur <= c_nxt;
                bc_cur <= bc_nxt;
                dr <= dr_next;
            end if;
        end if;
    end process;

    --next state logic
    process(s_cur, s_nxt, bc_cur, c_cur, dr, rx_d)
    begin
        case s_cur is
            when s_wait =>
                if(rx_d = '0') then
                    --found start bit
                    s_nxt <= s_start;
                    dr_next <= (others => '0');
                else
                    --do nothing
                    s_nxt <= s_cur;
                    bc_nxt <= (others => '0');
                    c_nxt <= (others => '0');
                    dr_next <= dr;
                end if;
            when s_start =>
                if(c_cur = 7) then
                --sample in the middle
                    if(rx_d = '1') then
                        --most likely noise...search for start bit
                        s_nxt <= s_wait;
                    else
                        --start bit sampled, start receiving data
                        s_nxt <= s_receive;
                        bc_nxt <= (others => '0');
                        c_nxt <= (others => '0');
                        dr_next <= rx_d & dr(7 downto 1);
                    end if;
                  else
                    c_nxt <= c_cur + 1;
                end if;
                
            when s_receive =>
                if(c_cur = 15) then
                    --Sample the middle
                    bc_nxt <= bc_cur + 1; --update bit count
                    dr_next <= rx_d & dr(7 downto 1);
                    c_nxt <= (others => '0');
                    if(bc_cur = TX_SIZE -1) then
                        --All bits received
                        s_nxt <= s_done;
                    else 
                        --Need more bits
                        s_nxt <= s_cur;
                    end if;
                else
                    c_nxt <= c_cur + 1;
                end if;

            when s_done =>
                if(c_cur = 15) then
                    --Sample stop bit
                    if(rx_d = '0') then
                        s_nxt <= s_err;
                    else
                        s_nxt <= s_wait;
                    end if;
                end if;
                c_nxt <= c_cur + 1;
            when s_err =>
                --Error state used to display FERR for 16 clock cycles
                if(c_cur = 15) then
                    s_nxt <= s_wait;
                else
                    c_nxt <= c_cur + 1;
                end if;
        end case;
    end process;

    process(s_cur, dr)
    begin
        case s_cur is
            when s_wait | s_start =>
                rdy <= '1';
                ferr <= '0';
                data <= dr;
            when s_receive | s_done =>
                rdy <= '0';
                ferr <= '0';
                data <= dr;
            when s_err =>
                rdy <= '0';
                ferr <= '1';
                data <= dr;
        end case;
    end process;


end architecture receiver_1;
