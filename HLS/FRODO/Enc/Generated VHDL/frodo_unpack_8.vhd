-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
-- Version: 2020.1
-- Copyright (C) 1986-2020 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity frodo_unpack_8 is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    out_r_address0 : OUT STD_LOGIC_VECTOR (9 downto 0);
    out_r_ce0 : OUT STD_LOGIC;
    out_r_we0 : OUT STD_LOGIC;
    out_r_d0 : OUT STD_LOGIC_VECTOR (15 downto 0);
    in_r_req_din : OUT STD_LOGIC;
    in_r_req_full_n : IN STD_LOGIC;
    in_r_req_write : OUT STD_LOGIC;
    in_r_rsp_empty_n : IN STD_LOGIC;
    in_r_rsp_read : OUT STD_LOGIC;
    in_r_address : OUT STD_LOGIC_VECTOR (31 downto 0);
    in_r_datain : IN STD_LOGIC_VECTOR (15 downto 0);
    in_r_dataout : OUT STD_LOGIC_VECTOR (15 downto 0);
    in_r_size : OUT STD_LOGIC_VECTOR (31 downto 0);
    in_offset : IN STD_LOGIC_VECTOR (17 downto 0);
    previous_rest : IN STD_LOGIC_VECTOR (15 downto 0);
    rest_len : IN STD_LOGIC_VECTOR (5 downto 0);
    ap_return : OUT STD_LOGIC_VECTOR (15 downto 0) );
end;


architecture behav of frodo_unpack_8 is 
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';
    constant ap_ST_fsm_state1 : STD_LOGIC_VECTOR (2 downto 0) := "001";
    constant ap_ST_fsm_pp0_stage0 : STD_LOGIC_VECTOR (2 downto 0) := "010";
    constant ap_ST_fsm_state8 : STD_LOGIC_VECTOR (2 downto 0) := "100";
    constant ap_const_boolean_1 : BOOLEAN := true;
    constant ap_const_lv32_0 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_lv1_0 : STD_LOGIC_VECTOR (0 downto 0) := "0";
    constant ap_const_lv1_1 : STD_LOGIC_VECTOR (0 downto 0) := "1";
    constant ap_const_boolean_0 : BOOLEAN := false;
    constant ap_const_lv4_0 : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    constant ap_const_lv16_0 : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
    constant ap_const_lv5_10 : STD_LOGIC_VECTOR (4 downto 0) := "10000";
    constant ap_const_lv5_8 : STD_LOGIC_VECTOR (4 downto 0) := "01000";
    constant ap_const_lv4_8 : STD_LOGIC_VECTOR (3 downto 0) := "1000";
    constant ap_const_lv4_1 : STD_LOGIC_VECTOR (3 downto 0) := "0001";
    constant ap_const_lv4_7 : STD_LOGIC_VECTOR (3 downto 0) := "0111";
    constant ap_const_lv32_11 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000010001";
    constant ap_const_lv32_1F : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000011111";
    constant ap_const_lv32_F : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000001111";
    constant ap_const_lv32_10 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000010000";
    constant ap_const_lv5_1 : STD_LOGIC_VECTOR (4 downto 0) := "00001";
    constant ap_const_lv32_2 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010";

    signal ap_CS_fsm : STD_LOGIC_VECTOR (2 downto 0) := "001";
    attribute fsm_encoding : string;
    attribute fsm_encoding of ap_CS_fsm : signal is "none";
    signal ap_CS_fsm_state1 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state1 : signal is "none";
    signal temp_0_reg_129 : STD_LOGIC_VECTOR (31 downto 0);
    signal j_0_reg_139 : STD_LOGIC_VECTOR (4 downto 0);
    signal k_0_reg_149 : STD_LOGIC_VECTOR (3 downto 0);
    signal k_0_reg_149_pp0_iter1_reg : STD_LOGIC_VECTOR (3 downto 0);
    signal ap_CS_fsm_pp0_stage0 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_pp0_stage0 : signal is "none";
    signal ap_block_state2_pp0_stage0_iter0 : BOOLEAN;
    signal ap_block_state3_pp0_stage0_iter1 : BOOLEAN;
    signal ap_block_state4_pp0_stage0_iter2 : BOOLEAN;
    signal icmp_ln152_reg_350 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln152_reg_350_pp0_iter2_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln155_reg_359 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln155_reg_359_pp0_iter2_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln155_reg_336 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_predicate_op38_read_state5 : BOOLEAN;
    signal ap_block_state5_pp0_stage0_iter3 : BOOLEAN;
    signal ap_enable_reg_pp0_iter3 : STD_LOGIC := '0';
    signal ap_block_state6_pp0_stage0_iter4 : BOOLEAN;
    signal ap_block_state7_pp0_stage0_iter5 : BOOLEAN;
    signal ap_block_pp0_stage0_11001 : BOOLEAN;
    signal k_0_reg_149_pp0_iter2_reg : STD_LOGIC_VECTOR (3 downto 0);
    signal k_0_reg_149_pp0_iter3_reg : STD_LOGIC_VECTOR (3 downto 0);
    signal k_0_reg_149_pp0_iter4_reg : STD_LOGIC_VECTOR (3 downto 0);
    signal rest_01_reg_161 : STD_LOGIC_VECTOR (15 downto 0);
    signal temp_fu_183_p3 : STD_LOGIC_VECTOR (31 downto 0);
    signal j_fu_195_p2 : STD_LOGIC_VECTOR (4 downto 0);
    signal icmp_ln155_fu_201_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln155_1_fu_207_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln155_1_reg_340 : STD_LOGIC_VECTOR (0 downto 0);
    signal trunc_ln156_fu_213_p1 : STD_LOGIC_VECTOR (16 downto 0);
    signal trunc_ln156_reg_345 : STD_LOGIC_VECTOR (16 downto 0);
    signal icmp_ln152_fu_217_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln152_reg_350_pp0_iter1_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln152_reg_350_pp0_iter3_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln152_reg_350_pp0_iter4_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal k_fu_223_p2 : STD_LOGIC_VECTOR (3 downto 0);
    signal k_reg_354 : STD_LOGIC_VECTOR (3 downto 0);
    signal ap_enable_reg_pp0_iter0 : STD_LOGIC := '0';
    signal and_ln155_fu_235_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln155_reg_359_pp0_iter1_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal and_ln155_reg_359_pp0_iter3_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal in_addr_reg_363 : STD_LOGIC_VECTOR (31 downto 0);
    signal in_addr_read_reg_369 : STD_LOGIC_VECTOR (15 downto 0);
    signal p_Result_s_reg_374 : STD_LOGIC_VECTOR (14 downto 0);
    signal temp_4_fu_295_p2 : STD_LOGIC_VECTOR (31 downto 0);
    signal temp_4_reg_379 : STD_LOGIC_VECTOR (31 downto 0);
    signal ap_enable_reg_pp0_iter4 : STD_LOGIC := '0';
    signal rest_reg_384 : STD_LOGIC_VECTOR (15 downto 0);
    signal j_1_fu_311_p2 : STD_LOGIC_VECTOR (4 downto 0);
    signal j_1_reg_389 : STD_LOGIC_VECTOR (4 downto 0);
    signal ap_block_pp0_stage0_subdone : BOOLEAN;
    signal ap_condition_pp0_exit_iter0_state2 : STD_LOGIC;
    signal ap_enable_reg_pp0_iter1 : STD_LOGIC := '0';
    signal ap_enable_reg_pp0_iter2 : STD_LOGIC := '0';
    signal ap_enable_reg_pp0_iter5 : STD_LOGIC := '0';
    signal ap_phi_mux_temp_0_phi_fu_132_p4 : STD_LOGIC_VECTOR (31 downto 0);
    signal ap_block_pp0_stage0 : BOOLEAN;
    signal ap_phi_mux_j_0_phi_fu_142_p4 : STD_LOGIC_VECTOR (4 downto 0);
    signal ap_phi_mux_k_0_phi_fu_153_p4 : STD_LOGIC_VECTOR (3 downto 0);
    signal ap_phi_mux_p_Val2_s_phi_fu_176_p4 : STD_LOGIC_VECTOR (31 downto 0);
    signal temp_2_fu_278_p2 : STD_LOGIC_VECTOR (31 downto 0);
    signal ap_phi_reg_pp0_iter4_p_Val2_s_reg_173 : STD_LOGIC_VECTOR (31 downto 0);
    signal zext_ln157_fu_321_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal zext_ln156_2_fu_249_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal trunc_ln150_fu_191_p1 : STD_LOGIC_VECTOR (4 downto 0);
    signal icmp_ln155_2_fu_229_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal zext_ln156_fu_240_p1 : STD_LOGIC_VECTOR (16 downto 0);
    signal add_ln156_fu_244_p2 : STD_LOGIC_VECTOR (16 downto 0);
    signal sub_ln156_fu_262_p2 : STD_LOGIC_VECTOR (4 downto 0);
    signal zext_ln156_1_fu_259_p1 : STD_LOGIC_VECTOR (31 downto 0);
    signal zext_ln156_3_fu_268_p1 : STD_LOGIC_VECTOR (31 downto 0);
    signal shl_ln156_fu_272_p2 : STD_LOGIC_VECTOR (31 downto 0);
    signal ap_CS_fsm_state8 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state8 : signal is "none";
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
                if (((ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (ap_const_logic_1 = ap_condition_pp0_exit_iter0_state2) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone))) then 
                    ap_enable_reg_pp0_iter0 <= ap_const_logic_0;
                elsif (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
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
                end if; 
            end if;
        end if;
    end process;


    ap_enable_reg_pp0_iter3_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_enable_reg_pp0_iter3 <= ap_const_logic_0;
            else
                if ((ap_const_boolean_0 = ap_block_pp0_stage0_subdone)) then 
                    ap_enable_reg_pp0_iter3 <= ap_enable_reg_pp0_iter2;
                end if; 
            end if;
        end if;
    end process;


    ap_enable_reg_pp0_iter4_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_enable_reg_pp0_iter4 <= ap_const_logic_0;
            else
                if ((ap_const_boolean_0 = ap_block_pp0_stage0_subdone)) then 
                    ap_enable_reg_pp0_iter4 <= ap_enable_reg_pp0_iter3;
                end if; 
            end if;
        end if;
    end process;


    ap_enable_reg_pp0_iter5_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_enable_reg_pp0_iter5 <= ap_const_logic_0;
            else
                if ((ap_const_boolean_0 = ap_block_pp0_stage0_subdone)) then 
                    ap_enable_reg_pp0_iter5 <= ap_enable_reg_pp0_iter4;
                elsif (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                    ap_enable_reg_pp0_iter5 <= ap_const_logic_0;
                end if; 
            end if;
        end if;
    end process;


    j_0_reg_139_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln152_reg_350_pp0_iter4_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter5 = ap_const_logic_1))) then 
                j_0_reg_139 <= j_1_reg_389;
            elsif (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                j_0_reg_139 <= j_fu_195_p2;
            end if; 
        end if;
    end process;

    k_0_reg_149_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln152_reg_350 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (ap_enable_reg_pp0_iter1 = ap_const_logic_1))) then 
                k_0_reg_149 <= k_reg_354;
            elsif (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                k_0_reg_149 <= ap_const_lv4_0;
            end if; 
        end if;
    end process;

    temp_0_reg_129_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln152_reg_350_pp0_iter4_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter5 = ap_const_logic_1))) then 
                                temp_0_reg_129(31 downto 15) <= temp_4_reg_379(31 downto 15);
            elsif (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                                temp_0_reg_129(31 downto 15) <= temp_fu_183_p3(31 downto 15);
            end if; 
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln155_reg_336 = ap_const_lv1_0) and (icmp_ln152_fu_217_p2 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then
                and_ln155_reg_359 <= and_ln155_fu_235_p2;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then
                and_ln155_reg_359_pp0_iter1_reg <= and_ln155_reg_359;
                icmp_ln152_reg_350 <= icmp_ln152_fu_217_p2;
                icmp_ln152_reg_350_pp0_iter1_reg <= icmp_ln152_reg_350;
                k_0_reg_149_pp0_iter1_reg <= k_0_reg_149;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_const_boolean_0 = ap_block_pp0_stage0_11001)) then
                and_ln155_reg_359_pp0_iter2_reg <= and_ln155_reg_359_pp0_iter1_reg;
                and_ln155_reg_359_pp0_iter3_reg <= and_ln155_reg_359_pp0_iter2_reg;
                icmp_ln152_reg_350_pp0_iter2_reg <= icmp_ln152_reg_350_pp0_iter1_reg;
                icmp_ln152_reg_350_pp0_iter3_reg <= icmp_ln152_reg_350_pp0_iter2_reg;
                icmp_ln152_reg_350_pp0_iter4_reg <= icmp_ln152_reg_350_pp0_iter3_reg;
                k_0_reg_149_pp0_iter2_reg <= k_0_reg_149_pp0_iter1_reg;
                k_0_reg_149_pp0_iter3_reg <= k_0_reg_149_pp0_iter2_reg;
                k_0_reg_149_pp0_iter4_reg <= k_0_reg_149_pp0_iter3_reg;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                icmp_ln155_1_reg_340 <= icmp_ln155_1_fu_207_p2;
                icmp_ln155_reg_336 <= icmp_ln155_fu_201_p2;
                trunc_ln156_reg_345 <= trunc_ln156_fu_213_p1;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_predicate_op38_read_state5 = ap_const_boolean_1))) then
                in_addr_read_reg_369 <= in_r_datain;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (((icmp_ln155_reg_336 = ap_const_lv1_1) and (icmp_ln152_fu_217_p2 = ap_const_lv1_0)) or ((ap_const_lv1_1 = and_ln155_fu_235_p2) and (icmp_ln152_fu_217_p2 = ap_const_lv1_0))))) then
                    in_addr_reg_363(16 downto 0) <= zext_ln156_2_fu_249_p1(32 - 1 downto 0)(16 downto 0);
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln152_reg_350_pp0_iter3_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter4 = ap_const_logic_1))) then
                j_1_reg_389 <= j_1_fu_311_p2;
                rest_reg_384 <= ap_phi_mux_p_Val2_s_phi_fu_176_p4(16 downto 1);
                    temp_4_reg_379(31 downto 15) <= temp_4_fu_295_p2(31 downto 15);
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1))) then
                k_reg_354 <= k_fu_223_p2;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln152_reg_350_pp0_iter3_reg = ap_const_lv1_0))) then
                p_Result_s_reg_374 <= ap_phi_mux_p_Val2_s_phi_fu_176_p4(31 downto 17);
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln152_reg_350_pp0_iter4_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter5 = ap_const_logic_1))) then
                rest_01_reg_161 <= rest_reg_384;
            end if;
        end if;
    end process;
    temp_0_reg_129(14 downto 0) <= "000000000000000";
    in_addr_reg_363(31 downto 17) <= "000000000000000";
    temp_4_reg_379(14 downto 0) <= "000000000000000";

    ap_NS_fsm_assign_proc : process (ap_start, ap_CS_fsm, ap_CS_fsm_state1, icmp_ln152_fu_217_p2, ap_enable_reg_pp0_iter0, ap_enable_reg_pp0_iter4, ap_block_pp0_stage0_subdone, ap_enable_reg_pp0_iter1, ap_enable_reg_pp0_iter5)
    begin
        case ap_CS_fsm is
            when ap_ST_fsm_state1 => 
                if (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                else
                    ap_NS_fsm <= ap_ST_fsm_state1;
                end if;
            when ap_ST_fsm_pp0_stage0 => 
                if ((not(((icmp_ln152_fu_217_p2 = ap_const_lv1_1) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone))) and not(((ap_enable_reg_pp0_iter5 = ap_const_logic_1) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (ap_enable_reg_pp0_iter4 = ap_const_logic_0))))) then
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                elsif ((((ap_enable_reg_pp0_iter5 = ap_const_logic_1) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (ap_enable_reg_pp0_iter4 = ap_const_logic_0)) or ((icmp_ln152_fu_217_p2 = ap_const_lv1_1) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone)))) then
                    ap_NS_fsm <= ap_ST_fsm_state8;
                else
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                end if;
            when ap_ST_fsm_state8 => 
                ap_NS_fsm <= ap_ST_fsm_state1;
            when others =>  
                ap_NS_fsm <= "XXX";
        end case;
    end process;
    add_ln156_fu_244_p2 <= std_logic_vector(unsigned(zext_ln156_fu_240_p1) + unsigned(trunc_ln156_reg_345));
    and_ln155_fu_235_p2 <= (icmp_ln155_2_fu_229_p2 and icmp_ln155_1_reg_340);
    ap_CS_fsm_pp0_stage0 <= ap_CS_fsm(1);
    ap_CS_fsm_state1 <= ap_CS_fsm(0);
    ap_CS_fsm_state8 <= ap_CS_fsm(2);
        ap_block_pp0_stage0 <= not((ap_const_boolean_1 = ap_const_boolean_1));

    ap_block_pp0_stage0_11001_assign_proc : process(in_r_rsp_empty_n, ap_predicate_op38_read_state5, ap_enable_reg_pp0_iter3)
    begin
                ap_block_pp0_stage0_11001 <= ((in_r_rsp_empty_n = ap_const_logic_0) and (ap_enable_reg_pp0_iter3 = ap_const_logic_1) and (ap_predicate_op38_read_state5 = ap_const_boolean_1));
    end process;


    ap_block_pp0_stage0_subdone_assign_proc : process(in_r_rsp_empty_n, ap_predicate_op38_read_state5, ap_enable_reg_pp0_iter3)
    begin
                ap_block_pp0_stage0_subdone <= ((in_r_rsp_empty_n = ap_const_logic_0) and (ap_enable_reg_pp0_iter3 = ap_const_logic_1) and (ap_predicate_op38_read_state5 = ap_const_boolean_1));
    end process;

        ap_block_state2_pp0_stage0_iter0 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state3_pp0_stage0_iter1 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state4_pp0_stage0_iter2 <= not((ap_const_boolean_1 = ap_const_boolean_1));

    ap_block_state5_pp0_stage0_iter3_assign_proc : process(in_r_rsp_empty_n, ap_predicate_op38_read_state5)
    begin
                ap_block_state5_pp0_stage0_iter3 <= ((in_r_rsp_empty_n = ap_const_logic_0) and (ap_predicate_op38_read_state5 = ap_const_boolean_1));
    end process;

        ap_block_state6_pp0_stage0_iter4 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state7_pp0_stage0_iter5 <= not((ap_const_boolean_1 = ap_const_boolean_1));

    ap_condition_pp0_exit_iter0_state2_assign_proc : process(icmp_ln152_fu_217_p2)
    begin
        if ((icmp_ln152_fu_217_p2 = ap_const_lv1_1)) then 
            ap_condition_pp0_exit_iter0_state2 <= ap_const_logic_1;
        else 
            ap_condition_pp0_exit_iter0_state2 <= ap_const_logic_0;
        end if; 
    end process;


    ap_done_assign_proc : process(ap_start, ap_CS_fsm_state1, ap_CS_fsm_state8)
    begin
        if (((ap_const_logic_1 = ap_CS_fsm_state8) or ((ap_start = ap_const_logic_0) and (ap_const_logic_1 = ap_CS_fsm_state1)))) then 
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


    ap_idle_pp0_assign_proc : process(ap_enable_reg_pp0_iter3, ap_enable_reg_pp0_iter0, ap_enable_reg_pp0_iter4, ap_enable_reg_pp0_iter1, ap_enable_reg_pp0_iter2, ap_enable_reg_pp0_iter5)
    begin
        if (((ap_enable_reg_pp0_iter3 = ap_const_logic_0) and (ap_enable_reg_pp0_iter5 = ap_const_logic_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_0) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0) and (ap_enable_reg_pp0_iter4 = ap_const_logic_0) and (ap_enable_reg_pp0_iter0 = ap_const_logic_0))) then 
            ap_idle_pp0 <= ap_const_logic_1;
        else 
            ap_idle_pp0 <= ap_const_logic_0;
        end if; 
    end process;


    ap_phi_mux_j_0_phi_fu_142_p4_assign_proc : process(j_0_reg_139, icmp_ln152_reg_350_pp0_iter4_reg, j_1_reg_389, ap_enable_reg_pp0_iter5, ap_block_pp0_stage0)
    begin
        if (((icmp_ln152_reg_350_pp0_iter4_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter5 = ap_const_logic_1) and (ap_const_boolean_0 = ap_block_pp0_stage0))) then 
            ap_phi_mux_j_0_phi_fu_142_p4 <= j_1_reg_389;
        else 
            ap_phi_mux_j_0_phi_fu_142_p4 <= j_0_reg_139;
        end if; 
    end process;


    ap_phi_mux_k_0_phi_fu_153_p4_assign_proc : process(k_0_reg_149, ap_CS_fsm_pp0_stage0, icmp_ln152_reg_350, k_reg_354, ap_enable_reg_pp0_iter1, ap_block_pp0_stage0)
    begin
        if (((icmp_ln152_reg_350 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (ap_enable_reg_pp0_iter1 = ap_const_logic_1) and (ap_const_boolean_0 = ap_block_pp0_stage0))) then 
            ap_phi_mux_k_0_phi_fu_153_p4 <= k_reg_354;
        else 
            ap_phi_mux_k_0_phi_fu_153_p4 <= k_0_reg_149;
        end if; 
    end process;


    ap_phi_mux_p_Val2_s_phi_fu_176_p4_assign_proc : process(icmp_ln155_reg_336, icmp_ln152_reg_350_pp0_iter3_reg, and_ln155_reg_359_pp0_iter3_reg, ap_phi_mux_temp_0_phi_fu_132_p4, temp_2_fu_278_p2, ap_phi_reg_pp0_iter4_p_Val2_s_reg_173)
    begin
        if (((icmp_ln155_reg_336 = ap_const_lv1_0) and (ap_const_lv1_0 = and_ln155_reg_359_pp0_iter3_reg) and (icmp_ln152_reg_350_pp0_iter3_reg = ap_const_lv1_0))) then 
            ap_phi_mux_p_Val2_s_phi_fu_176_p4 <= ap_phi_mux_temp_0_phi_fu_132_p4;
        elsif ((((icmp_ln155_reg_336 = ap_const_lv1_1) and (icmp_ln152_reg_350_pp0_iter3_reg = ap_const_lv1_0)) or ((ap_const_lv1_1 = and_ln155_reg_359_pp0_iter3_reg) and (icmp_ln152_reg_350_pp0_iter3_reg = ap_const_lv1_0)))) then 
            ap_phi_mux_p_Val2_s_phi_fu_176_p4 <= temp_2_fu_278_p2;
        else 
            ap_phi_mux_p_Val2_s_phi_fu_176_p4 <= ap_phi_reg_pp0_iter4_p_Val2_s_reg_173;
        end if; 
    end process;


    ap_phi_mux_temp_0_phi_fu_132_p4_assign_proc : process(temp_0_reg_129, icmp_ln152_reg_350_pp0_iter4_reg, temp_4_reg_379, ap_enable_reg_pp0_iter5, ap_block_pp0_stage0)
    begin
        if (((icmp_ln152_reg_350_pp0_iter4_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter5 = ap_const_logic_1) and (ap_const_boolean_0 = ap_block_pp0_stage0))) then 
            ap_phi_mux_temp_0_phi_fu_132_p4 <= temp_4_reg_379;
        else 
            ap_phi_mux_temp_0_phi_fu_132_p4 <= temp_0_reg_129;
        end if; 
    end process;

    ap_phi_reg_pp0_iter4_p_Val2_s_reg_173 <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

    ap_predicate_op38_read_state5_assign_proc : process(icmp_ln152_reg_350_pp0_iter2_reg, and_ln155_reg_359_pp0_iter2_reg, icmp_ln155_reg_336)
    begin
                ap_predicate_op38_read_state5 <= (((icmp_ln155_reg_336 = ap_const_lv1_1) and (icmp_ln152_reg_350_pp0_iter2_reg = ap_const_lv1_0)) or ((ap_const_lv1_1 = and_ln155_reg_359_pp0_iter2_reg) and (icmp_ln152_reg_350_pp0_iter2_reg = ap_const_lv1_0)));
    end process;


    ap_ready_assign_proc : process(ap_CS_fsm_state8)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state8)) then 
            ap_ready <= ap_const_logic_1;
        else 
            ap_ready <= ap_const_logic_0;
        end if; 
    end process;

    ap_return <= rest_01_reg_161;
    icmp_ln152_fu_217_p2 <= "1" when (ap_phi_mux_k_0_phi_fu_153_p4 = ap_const_lv4_8) else "0";
    icmp_ln155_1_fu_207_p2 <= "1" when (trunc_ln150_fu_191_p1 = ap_const_lv5_8) else "0";
    icmp_ln155_2_fu_229_p2 <= "1" when (unsigned(ap_phi_mux_k_0_phi_fu_153_p4) < unsigned(ap_const_lv4_7)) else "0";
    icmp_ln155_fu_201_p2 <= "1" when (trunc_ln150_fu_191_p1 = ap_const_lv5_10) else "0";
    in_r_address <= in_addr_reg_363;
    in_r_dataout <= ap_const_lv16_0;
    in_r_req_din <= ap_const_logic_0;

    in_r_req_write_assign_proc : process(ap_CS_fsm_pp0_stage0, icmp_ln152_reg_350, and_ln155_reg_359, icmp_ln155_reg_336, ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter1)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (ap_enable_reg_pp0_iter1 = ap_const_logic_1) and (((icmp_ln155_reg_336 = ap_const_lv1_1) and (icmp_ln152_reg_350 = ap_const_lv1_0)) or ((ap_const_lv1_1 = and_ln155_reg_359) and (icmp_ln152_reg_350 = ap_const_lv1_0))))) then 
            in_r_req_write <= ap_const_logic_1;
        else 
            in_r_req_write <= ap_const_logic_0;
        end if; 
    end process;


    in_r_rsp_read_assign_proc : process(ap_predicate_op38_read_state5, ap_enable_reg_pp0_iter3, ap_block_pp0_stage0_11001)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter3 = ap_const_logic_1) and (ap_predicate_op38_read_state5 = ap_const_boolean_1))) then 
            in_r_rsp_read <= ap_const_logic_1;
        else 
            in_r_rsp_read <= ap_const_logic_0;
        end if; 
    end process;

    in_r_size <= ap_const_lv32_1;
    j_1_fu_311_p2 <= std_logic_vector(unsigned(ap_const_lv5_1) + unsigned(ap_phi_mux_j_0_phi_fu_142_p4));
    j_fu_195_p2 <= std_logic_vector(signed(ap_const_lv5_10) - signed(trunc_ln150_fu_191_p1));
    k_fu_223_p2 <= std_logic_vector(unsigned(ap_phi_mux_k_0_phi_fu_153_p4) + unsigned(ap_const_lv4_1));
    out_r_address0 <= zext_ln157_fu_321_p1(10 - 1 downto 0);

    out_r_ce0_assign_proc : process(ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter5)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter5 = ap_const_logic_1))) then 
            out_r_ce0 <= ap_const_logic_1;
        else 
            out_r_ce0 <= ap_const_logic_0;
        end if; 
    end process;

    out_r_d0 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(p_Result_s_reg_374),16));

    out_r_we0_assign_proc : process(ap_block_pp0_stage0_11001, icmp_ln152_reg_350_pp0_iter4_reg, ap_enable_reg_pp0_iter5)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln152_reg_350_pp0_iter4_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter5 = ap_const_logic_1))) then 
            out_r_we0 <= ap_const_logic_1;
        else 
            out_r_we0 <= ap_const_logic_0;
        end if; 
    end process;

    shl_ln156_fu_272_p2 <= std_logic_vector(shift_left(unsigned(zext_ln156_1_fu_259_p1),to_integer(unsigned('0' & zext_ln156_3_fu_268_p1(31-1 downto 0)))));
    sub_ln156_fu_262_p2 <= std_logic_vector(signed(ap_const_lv5_10) - signed(ap_phi_mux_j_0_phi_fu_142_p4));
    temp_2_fu_278_p2 <= (shl_ln156_fu_272_p2 or ap_phi_mux_temp_0_phi_fu_132_p4);
    temp_4_fu_295_p2 <= std_logic_vector(shift_left(unsigned(ap_phi_mux_p_Val2_s_phi_fu_176_p4),to_integer(unsigned('0' & ap_const_lv32_F(31-1 downto 0)))));
    temp_fu_183_p3 <= (previous_rest & ap_const_lv16_0);
    trunc_ln150_fu_191_p1 <= rest_len(5 - 1 downto 0);
    trunc_ln156_fu_213_p1 <= in_offset(17 - 1 downto 0);
    zext_ln156_1_fu_259_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(in_addr_read_reg_369),32));
    zext_ln156_2_fu_249_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(add_ln156_fu_244_p2),64));
    zext_ln156_3_fu_268_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(sub_ln156_fu_262_p2),32));
    zext_ln156_fu_240_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(ap_phi_mux_k_0_phi_fu_153_p4),17));
    zext_ln157_fu_321_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(k_0_reg_149_pp0_iter4_reg),64));
end behav;
