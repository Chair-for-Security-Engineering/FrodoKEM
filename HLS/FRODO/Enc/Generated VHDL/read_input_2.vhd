-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
-- Version: 2020.1
-- Copyright (C) 1986-2020 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity read_input_2 is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    out_r_req_din : OUT STD_LOGIC;
    out_r_req_full_n : IN STD_LOGIC;
    out_r_req_write : OUT STD_LOGIC;
    out_r_rsp_empty_n : IN STD_LOGIC;
    out_r_rsp_read : OUT STD_LOGIC;
    out_r_address : OUT STD_LOGIC_VECTOR (31 downto 0);
    out_r_datain : IN STD_LOGIC_VECTOR (15 downto 0);
    out_r_dataout : OUT STD_LOGIC_VECTOR (15 downto 0);
    out_r_size : OUT STD_LOGIC_VECTOR (31 downto 0);
    out_offset : IN STD_LOGIC_VECTOR (14 downto 0);
    in_r_address0 : OUT STD_LOGIC_VECTOR (9 downto 0);
    in_r_ce0 : OUT STD_LOGIC;
    in_r_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
    len : IN STD_LOGIC_VECTOR (10 downto 0);
    begin_r : IN STD_LOGIC_VECTOR (0 downto 0) );
end;


architecture behav of read_input_2 is 
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';
    constant ap_ST_fsm_state1 : STD_LOGIC_VECTOR (2 downto 0) := "001";
    constant ap_ST_fsm_pp0_stage0 : STD_LOGIC_VECTOR (2 downto 0) := "010";
    constant ap_ST_fsm_state5 : STD_LOGIC_VECTOR (2 downto 0) := "100";
    constant ap_const_boolean_1 : BOOLEAN := true;
    constant ap_const_lv32_0 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
    constant ap_const_lv1_1 : STD_LOGIC_VECTOR (0 downto 0) := "1";
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_lv1_0 : STD_LOGIC_VECTOR (0 downto 0) := "0";
    constant ap_const_boolean_0 : BOOLEAN := false;
    constant ap_const_lv10_0 : STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
    constant ap_const_lv10_1 : STD_LOGIC_VECTOR (9 downto 0) := "0000000001";
    constant ap_const_lv32_2 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010";

    signal ap_CS_fsm : STD_LOGIC_VECTOR (2 downto 0) := "001";
    attribute fsm_encoding : string;
    attribute fsm_encoding of ap_CS_fsm : signal is "none";
    signal ap_CS_fsm_state1 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state1 : signal is "none";
    signal i_0_reg_92 : STD_LOGIC_VECTOR (9 downto 0);
    signal begin_read_read_fu_54_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal empty_fu_103_p1 : STD_LOGIC_VECTOR (9 downto 0);
    signal empty_reg_147 : STD_LOGIC_VECTOR (9 downto 0);
    signal tmp_1_i32_fu_107_p1 : STD_LOGIC_VECTOR (31 downto 0);
    signal tmp_1_i32_reg_152 : STD_LOGIC_VECTOR (31 downto 0);
    signal out_addr_reg_157 : STD_LOGIC_VECTOR (31 downto 0);
    signal icmp_ln882_fu_121_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln882_reg_162 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_CS_fsm_pp0_stage0 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_pp0_stage0 : signal is "none";
    signal ap_block_state2_pp0_stage0_iter0 : BOOLEAN;
    signal ap_block_state3_pp0_stage0_iter1 : BOOLEAN;
    signal icmp_ln882_reg_162_pp0_iter1_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_block_state4_pp0_stage0_iter2 : BOOLEAN;
    signal ap_enable_reg_pp0_iter2 : STD_LOGIC := '0';
    signal ap_block_pp0_stage0_11001 : BOOLEAN;
    signal i_fu_126_p2 : STD_LOGIC_VECTOR (9 downto 0);
    signal ap_enable_reg_pp0_iter0 : STD_LOGIC := '0';
    signal icmp_ln885_fu_137_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln885_reg_176 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln885_reg_176_pp0_iter1_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal in_load_reg_180 : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_block_pp0_stage0_subdone : BOOLEAN;
    signal ap_condition_pp0_exit_iter0_state2 : STD_LOGIC;
    signal ap_enable_reg_pp0_iter1 : STD_LOGIC := '0';
    signal zext_ln885_fu_132_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal ap_block_pp0_stage0 : BOOLEAN;
    signal sext_ln885_fu_111_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal ap_CS_fsm_state5 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state5 : signal is "none";
    signal ap_NS_fsm : STD_LOGIC_VECTOR (2 downto 0);
    signal ap_idle_pp0 : STD_LOGIC;
    signal ap_enable_pp0 : STD_LOGIC;


begin




    ap_CS_fsm_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_CS_fsm <= ap_ST_fsm_state1;
            else
                ap_CS_fsm <= ap_NS_fsm;
            end if;
        end if;
    end process;


    ap_enable_reg_pp0_iter0_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_enable_reg_pp0_iter0 <= ap_const_logic_0;
            else
                if (((ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (ap_const_logic_1 = ap_condition_pp0_exit_iter0_state2))) then 
                    ap_enable_reg_pp0_iter0 <= ap_const_logic_0;
                elsif (((ap_start = ap_const_logic_1) and (begin_read_read_fu_54_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                    ap_enable_reg_pp0_iter0 <= ap_const_logic_1;
                end if; 
            end if;
        end if;
    end process;


    ap_enable_reg_pp0_iter1_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_enable_reg_pp0_iter1 <= ap_const_logic_0;
            else
                if ((ap_const_boolean_0 = ap_block_pp0_stage0_subdone)) then
                    if ((ap_const_logic_1 = ap_condition_pp0_exit_iter0_state2)) then 
                        ap_enable_reg_pp0_iter1 <= (ap_const_logic_1 xor ap_condition_pp0_exit_iter0_state2);
                    elsif ((ap_const_boolean_1 = ap_const_boolean_1)) then 
                        ap_enable_reg_pp0_iter1 <= ap_enable_reg_pp0_iter0;
                    end if;
                end if; 
            end if;
        end if;
    end process;


    ap_enable_reg_pp0_iter2_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_enable_reg_pp0_iter2 <= ap_const_logic_0;
            else
                if ((ap_const_boolean_0 = ap_block_pp0_stage0_subdone)) then 
                    ap_enable_reg_pp0_iter2 <= ap_enable_reg_pp0_iter1;
                elsif (((ap_start = ap_const_logic_1) and (begin_read_read_fu_54_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                    ap_enable_reg_pp0_iter2 <= ap_const_logic_0;
                end if; 
            end if;
        end if;
    end process;


    i_0_reg_92_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_start = ap_const_logic_1) and (begin_read_read_fu_54_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                i_0_reg_92 <= ap_const_lv10_0;
            elsif (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln882_fu_121_p2 = ap_const_lv1_0) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then 
                i_0_reg_92 <= i_fu_126_p2;
            end if; 
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_start = ap_const_logic_1) and (begin_read_read_fu_54_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                empty_reg_147 <= empty_fu_103_p1;
                out_addr_reg_157 <= sext_ln885_fu_111_p1(32 - 1 downto 0);
                    tmp_1_i32_reg_152(9 downto 0) <= tmp_1_i32_fu_107_p1(9 downto 0);
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then
                icmp_ln882_reg_162 <= icmp_ln882_fu_121_p2;
                icmp_ln882_reg_162_pp0_iter1_reg <= icmp_ln882_reg_162;
                icmp_ln885_reg_176_pp0_iter1_reg <= icmp_ln885_reg_176;
                in_load_reg_180 <= in_r_q0;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln882_fu_121_p2 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then
                icmp_ln885_reg_176 <= icmp_ln885_fu_137_p2;
            end if;
        end if;
    end process;
    tmp_1_i32_reg_152(31 downto 10) <= "0000000000000000000000";

    ap_NS_fsm_assign_proc : process (ap_start, ap_CS_fsm, ap_CS_fsm_state1, begin_read_read_fu_54_p2, icmp_ln882_fu_121_p2, ap_enable_reg_pp0_iter2, ap_enable_reg_pp0_iter0, ap_block_pp0_stage0_subdone, ap_enable_reg_pp0_iter1)
    begin
        case ap_CS_fsm is
            when ap_ST_fsm_state1 => 
                if (((ap_start = ap_const_logic_1) and (begin_read_read_fu_54_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                elsif (((ap_start = ap_const_logic_1) and (begin_read_read_fu_54_p2 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                    ap_NS_fsm <= ap_ST_fsm_state5;
                else
                    ap_NS_fsm <= ap_ST_fsm_state1;
                end if;
            when ap_ST_fsm_pp0_stage0 => 
                if ((not(((ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (icmp_ln882_fu_121_p2 = ap_const_lv1_1) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0))) and not(((ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0))))) then
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                elsif ((((ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (icmp_ln882_fu_121_p2 = ap_const_lv1_1) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0)) or ((ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0)))) then
                    ap_NS_fsm <= ap_ST_fsm_state5;
                else
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                end if;
            when ap_ST_fsm_state5 => 
                ap_NS_fsm <= ap_ST_fsm_state1;
            when others =>  
                ap_NS_fsm <= "XXX";
        end case;
    end process;
    ap_CS_fsm_pp0_stage0 <= ap_CS_fsm(1);
    ap_CS_fsm_state1 <= ap_CS_fsm(0);
    ap_CS_fsm_state5 <= ap_CS_fsm(2);
        ap_block_pp0_stage0 <= not((ap_const_boolean_1 = ap_const_boolean_1));

    ap_block_pp0_stage0_11001_assign_proc : process(out_r_req_full_n, icmp_ln882_reg_162_pp0_iter1_reg, ap_enable_reg_pp0_iter2)
    begin
                ap_block_pp0_stage0_11001 <= ((icmp_ln882_reg_162_pp0_iter1_reg = ap_const_lv1_0) and (out_r_req_full_n = ap_const_logic_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1));
    end process;


    ap_block_pp0_stage0_subdone_assign_proc : process(out_r_req_full_n, icmp_ln882_reg_162_pp0_iter1_reg, ap_enable_reg_pp0_iter2)
    begin
                ap_block_pp0_stage0_subdone <= ((icmp_ln882_reg_162_pp0_iter1_reg = ap_const_lv1_0) and (out_r_req_full_n = ap_const_logic_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1));
    end process;

        ap_block_state2_pp0_stage0_iter0 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state3_pp0_stage0_iter1 <= not((ap_const_boolean_1 = ap_const_boolean_1));

    ap_block_state4_pp0_stage0_iter2_assign_proc : process(out_r_req_full_n, icmp_ln882_reg_162_pp0_iter1_reg)
    begin
                ap_block_state4_pp0_stage0_iter2 <= ((icmp_ln882_reg_162_pp0_iter1_reg = ap_const_lv1_0) and (out_r_req_full_n = ap_const_logic_0));
    end process;


    ap_condition_pp0_exit_iter0_state2_assign_proc : process(icmp_ln882_fu_121_p2)
    begin
        if ((icmp_ln882_fu_121_p2 = ap_const_lv1_1)) then 
            ap_condition_pp0_exit_iter0_state2 <= ap_const_logic_1;
        else 
            ap_condition_pp0_exit_iter0_state2 <= ap_const_logic_0;
        end if; 
    end process;


    ap_done_assign_proc : process(ap_start, ap_CS_fsm_state1, ap_CS_fsm_state5)
    begin
        if (((ap_const_logic_1 = ap_CS_fsm_state5) or ((ap_start = ap_const_logic_0) and (ap_const_logic_1 = ap_CS_fsm_state1)))) then 
            ap_done <= ap_const_logic_1;
        else 
            ap_done <= ap_const_logic_0;
        end if; 
    end process;

    ap_enable_pp0 <= (ap_idle_pp0 xor ap_const_logic_1);

    ap_idle_assign_proc : process(ap_start, ap_CS_fsm_state1)
    begin
        if (((ap_start = ap_const_logic_0) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
            ap_idle <= ap_const_logic_1;
        else 
            ap_idle <= ap_const_logic_0;
        end if; 
    end process;


    ap_idle_pp0_assign_proc : process(ap_enable_reg_pp0_iter2, ap_enable_reg_pp0_iter0, ap_enable_reg_pp0_iter1)
    begin
        if (((ap_enable_reg_pp0_iter0 = ap_const_logic_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_0) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0))) then 
            ap_idle_pp0 <= ap_const_logic_1;
        else 
            ap_idle_pp0 <= ap_const_logic_0;
        end if; 
    end process;


    ap_ready_assign_proc : process(ap_CS_fsm_state5)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state5)) then 
            ap_ready <= ap_const_logic_1;
        else 
            ap_ready <= ap_const_logic_0;
        end if; 
    end process;

    begin_read_read_fu_54_p2 <= begin_r;
    empty_fu_103_p1 <= len(10 - 1 downto 0);
    i_fu_126_p2 <= std_logic_vector(unsigned(i_0_reg_92) + unsigned(ap_const_lv10_1));
    icmp_ln882_fu_121_p2 <= "1" when (i_0_reg_92 = empty_reg_147) else "0";
    icmp_ln885_fu_137_p2 <= "1" when (i_0_reg_92 = ap_const_lv10_0) else "0";
    in_r_address0 <= zext_ln885_fu_132_p1(10 - 1 downto 0);

    in_r_ce0_assign_proc : process(ap_CS_fsm_pp0_stage0, ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter0)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then 
            in_r_ce0 <= ap_const_logic_1;
        else 
            in_r_ce0 <= ap_const_logic_0;
        end if; 
    end process;

    out_r_address <= out_addr_reg_157;
    out_r_dataout <= in_load_reg_180;

    out_r_req_din_assign_proc : process(icmp_ln882_reg_162_pp0_iter1_reg, ap_enable_reg_pp0_iter2, ap_block_pp0_stage0_11001, icmp_ln885_reg_176_pp0_iter1_reg)
    begin
        if ((((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln885_reg_176_pp0_iter1_reg = ap_const_lv1_1) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1)) or ((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln882_reg_162_pp0_iter1_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1)))) then 
            out_r_req_din <= ap_const_logic_1;
        else 
            out_r_req_din <= ap_const_logic_0;
        end if; 
    end process;


    out_r_req_write_assign_proc : process(icmp_ln882_reg_162_pp0_iter1_reg, ap_enable_reg_pp0_iter2, ap_block_pp0_stage0_11001, icmp_ln885_reg_176_pp0_iter1_reg)
    begin
        if ((((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln885_reg_176_pp0_iter1_reg = ap_const_lv1_1) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1)) or ((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln882_reg_162_pp0_iter1_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1)))) then 
            out_r_req_write <= ap_const_logic_1;
        else 
            out_r_req_write <= ap_const_logic_0;
        end if; 
    end process;

    out_r_rsp_read <= ap_const_logic_0;
    out_r_size <= tmp_1_i32_reg_152;
        sext_ln885_fu_111_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(out_offset),64));

    tmp_1_i32_fu_107_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(empty_fu_103_p1),32));
    zext_ln885_fu_132_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(i_0_reg_92),64));
end behav;
