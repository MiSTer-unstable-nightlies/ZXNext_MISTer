
-- PS2 Keymap
-- Copyright 2020 Fabio Belavenuto
--
-- This file is part of the ZX Spectrum Next Project
-- <https://gitlab.com/SpectrumNext/ZX_Spectrum_Next_FPGA/tree/master/cores>
--
-- The ZX Spectrum Next FPGA source code is free software: you can 
-- redistribute it and/or modify it under the terms of the GNU General 
-- Public License as published by the Free Software Foundation, either 
-- version 3 of the License, or (at your option) any later version.
--
-- The ZX Spectrum Next FPGA source code is distributed in the hope 
-- that it will be useful, but WITHOUT ANY WARRANTY; without even the 
-- implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE.  See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with the ZX Spectrum Next FPGA source code.  If not, see 
-- <https://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keymaps is
   port (
      clock_i     : in  std_logic;
      addr_wr_i   : in  std_logic_vector(8 downto 0);
      data_i      : in  std_logic_vector(8 downto 0);
      we_i        : in  std_logic;
      addr_rd_i   : in  std_logic_vector(8 downto 0);
      data_o      : out std_logic_vector(8 downto 0)
   );
end entity;

architecture Behavior of keymaps is

-- Speccy keymaps
-- col  0    1    2    3    4     5          6
-- row ------------------------------------------
--  0 | CAPS Z    X    C    V   EXTEND      UP
--  1 | A    S    D    F    G  CAPS LOCK   GRAPH  
--  2 | Q    W    E    R    T  TRUE VID   INV VID
--  3 | 1    2    3    4    5   BREAK      EDIT
--  4 | 0    9    8    7    6     ;          "
--  5 | P    O    I    U    Y     ,          .
--  6 | RET  L    K    J    H   DELETE     RIGHT
--  7 | SPC  SYM  M    N    B    LEFT      DOWN

   type ram_t is array (0 to 511) of std_logic_vector(8 downto 0);
   -- keycode set 2 us keyboard
   signal ram_q : ram_t := (
   --
   -- Format:
   --
   -- CASE 1 - Keypress
   --
   -- bit 8    = 0 (reserved)
   -- bit 7    = SYMBOL  \  must not be
   -- bit 6    = CAPS    /  "11"
   -- bits 5-3 = row
   -- bits 2-0 = col (only 0-6) 7 = no action
   --
   -- CASE 2 - Function Key
   --
   -- bit 8    = 0 (reserved)
   -- bit 7    = 1
   -- bit 6    = 1
   -- bits 5-3 = 0 (reserved)
   -- bits 2-0 = function key 8:1
   --            F1 = hard reset
   --            F2 = toggle scandoubler, hdmi reset
   --            F3 = toggle 50Hz / 60Hz display
   --            F4 = soft reset
   --            F5 = (temporary) expansion bus on
   --            F6 = (temporary) expansion bus off
   --            F7 = change scanline weight
   --            F8 = change cpu speed
   
   -- U.S. PS/2 ASSIGNMENTS
   --
   --    Left / Right Shift = CAPS SHIFT
   --    Left / Right Ctl   = SYM SHIFT
   --    Left Alt           = EXTEND
   --    Right Alt          = GRAPH
   --    ;",. mapped to appropriate keys
   --    Arrows             = ARROW KEYS
   --    Caps lock          = CAPS LOCK
   --    Backspace          = DELETE
   --    Esc                = BREAK
   --    `~                 = EDIT (to left of 1)
   --    Tab                = TRUE VIDEO
   --    \                  = INV VIDEO (right side of same row as tab)
   --
   --    F3  = 50 / 60 Hz toggle
   --    F4  = soft reset
   --    F8  = cpu speed
   --    F9  = reserved (multiface nmi)
   --    F10 = reserved (divmmc nmi)
   --    F11 = expansion bus on
   --    F12 = expansion bus off
   --
   --    PAUSE/BREAK = reserved (reset ps2 module)
   
   -- Table of ps2 scan codes https://techdocs.altium.com/display/FPGA/PS2+Keyboard+Scan+Codes

--                    F9                        F5           F3           F1           F2           F12
        "000000111", "000000111", "000000111", "000000111", "011000010", "000000111", "000000111", "011000101",   -- 00..07
--                    F10          F8           F6           F4           Tab          ` ~
        "000000111", "000000111", "011000111", "000000111", "011000011", "000010101", "000011110", "000000111",   -- 08..0F
--                    LAlt         LShft                     LCtrl        Q            1 !
        "000000111", "000000101", "001000111", "000000111", "010000111", "000010000", "000011000", "000000111",   -- 10..17
--                                 Z            S            A            W            2 @
        "000000111", "000000111", "000000001", "000001001", "000001000", "000010001", "000011001", "000000111",   -- 18..1F
--                    C            X            D            E            4 $          3 #
        "000000111", "000000011", "000000010", "000001010", "000010010", "000011011", "000011010", "000000111",   -- 20..27
--                    Space        V            F            T            R            5 %
        "000000111", "000111000", "000000100", "000001011", "000010100", "000010011", "000011100", "000000111",   -- 28..2F
--                    N            B            H            G            Y            6 ¨
        "000000111", "000111011", "000111100", "000110100", "000001100", "000101100", "000100100", "000000111",   -- 30..37
--                                 M            J            U            7 &          8 *
        "000000111", "000000111", "000111010", "000110011", "000101011", "000100011", "000100010", "000000111",   -- 38..3F
--                    , <          K            I            O            0 )          9 (
        "000000111", "000101101", "000110010", "000101010", "000101001", "000100000", "000100001", "000000111",   -- 40..47
--                    . >          / ?          L            ; :          P            - _
        "000000111", "000101110", "010000100", "000110001", "000100101", "000101000", "010110011", "000000111",   -- 48..4F
--                                 ' "                       [ {          = +
        "000000111", "000000111", "000100110", "000000111", "000000111", "010110001", "000000111", "000000111",   -- 50..57
--       CapsLock     R Shift      Enter        ] }                       \ |
        "000001101", "001000111", "000110000", "000000111", "000000111", "000010110", "000000111", "000000111",   -- 58..5F
--                                                                                     BackSpace
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000110101", "000000111",   -- 60..67
--                    [1]                       [4]          [7]
        "000000111", "000011000", "000000111", "000011011", "000100011", "000000111", "000000111", "000000111",   -- 68..6F
--       [0]          [.]          [2]          [5]          [6]          [8]          Esc          NumLock
        "000100000", "000101110", "000011001", "000011100", "000100100", "000100010", "000011101", "000000111",   -- 70..77
--       F11          [+]          [3]          [-]          [*]          [9]          ScrLk
        "011000100", "010110010", "000011010", "010110011", "010111100", "000100001", "000000111", "000000111",   -- 78..7F
--                                              F7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 80..87
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 88..8F
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 90..97
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 98..9F
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- A0..A7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- A8..AF
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- B0..B7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- B8..BF
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- C0..C7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- C8..CF
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- D0..D7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- D8..DF
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- E0..E7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- E8..EF
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- F0..F7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- F8..FF

   -- Extended

--
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 00..07
--
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 08..0F
--                    RAlt         PrtSc                     RCtrl
        "000000111", "000001110", "000000111", "000000111", "010000111", "000000111", "000000111", "000000111",   -- 10..17
--                                                                                                  LWin
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 18..1F
--                                                                                                  RWin
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 20..27
--                                                                                                  Menu
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 28..2F
--                                                                                                  Power
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 30..37
--                                                                                                  Sleep
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 38..3F
--
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 40..47
--                                 [/]
        "000000111", "000000111", "010000100", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 48..4F
--
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 50..57
--                                 [Enter]                                             Wake
        "000000111", "000000111", "000110000", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 58..5F
--
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 60..67
--                    End                       Left         Home
        "000000111", "000000111", "000000111", "000111101", "000000111", "000000111", "000000111", "000000111",   -- 68..6F
--       Ins          Delete       Down                      Right        Up
        "000000111", "000000111", "000111110", "000000111", "000110110", "000000110", "000000111", "000000111",   -- 70..77
--                                 PDown                                  PUp
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 78..7F
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 80..87
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 88..8F
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 90..97
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- 98..9F
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- A0..A7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- A8..AF
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- B0..B7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- B8..BF
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- C0..C7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- C8..CF
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- D0..D7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- D8..DF
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- E0..E7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- E8..EF
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111",   -- F0..F7
        "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111", "000000111"    -- F8..FF
   );
begin

   process (clock_i)
   begin
      if rising_edge(clock_i) then
         if we_i = '1' then
            ram_q(to_integer(unsigned(addr_wr_i))) <= data_i;
         end if;
         data_o <= ram_q(to_integer(unsigned(addr_rd_i)));
      end if;
   end process;

end architecture;
