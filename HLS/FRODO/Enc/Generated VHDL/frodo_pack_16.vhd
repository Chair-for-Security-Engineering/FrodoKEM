-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
-- Version: 2020.1
-- Copyright (C) 1986-2020 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity frodo_pack_16 is
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
    in_r_address0 : OUT STD_LOGIC_VECTOR (9 downto 0);
    in_r_ce0 : OUT STD_LOGIC;
    in_r_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
    in_r_address1 : OUT STD_LOGIC_VECTOR (9 downto 0);
    in_r_ce1 : OUT STD_LOGIC;
    in_r_q1 : IN STD_LOGIC_VECTOR (15 downto 0);
    inlen : IN STD_LOGIC_VECTOR (9 downto 0);
    begin_r : IN STD_LOGIC_VECTOR (0 downto 0) );
end;


architecture behav of frodo_pack_16 is 
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';
    constant ap_ST_fsm_state1 : STD_LOGIC_VECTOR (3 downto 0) := "0001";
    constant ap_ST_fsm_state2 : STD_LOGIC_VECTOR (3 downto 0) := "0010";
    constant ap_ST_fsm_pp0_stage0 : STD_LOGIC_VECTOR (3 downto 0) := "0100";
    constant ap_ST_fsm_state6 : STD_LOGIC_VECTOR (3 downto 0) := "1000";
    constant ap_const_boolean_1 : BOOLEAN := true;
    constant ap_const_lv32_0 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_lv1_1 : STD_LOGIC_VECTOR (0 downto 0) := "1";
    constant ap_const_lv1_0 : STD_LOGIC_VECTOR (0 downto 0) := "0";
    constant ap_const_lv32_2 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010";
    constant ap_const_boolean_0 : BOOLEAN := false;
    constant ap_const_lv32_3 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000011";
    constant ap_const_lv16_0 : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
    constant ap_const_lv5_E : STD_LOGIC_VECTOR (4 downto 0) := "01110";
    constant ap_const_lv4_0 : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    constant ap_const_lv16_1 : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000001";
    constant ap_const_lv16_4 : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000100";
    constant ap_const_lv20_1 : STD_LOGIC_VECTOR (19 downto 0) := "00000000000000000001";
    constant ap_const_lv4_F : STD_LOGIC_VECTOR (3 downto 0) := "1111";
    constant ap_const_lv4_1 : STD_LOGIC_VECTOR (3 downto 0) := "0001";
    constant ap_const_lv5_F : STD_LOGIC_VECTOR (4 downto 0) := "01111";
    constant ap_const_lv16_FFFF : STD_LOGIC_VECTOR (15 downto 0) := "1111111111111111";
    constant ap_const_lv5_1 : STD_LOGIC_VECTOR (4 downto 0) := "00001";
    constant ap_const_lv5_1F : STD_LOGIC_VECTOR (4 downto 0) := "11111";
    constant ap_const_lv16_FFF0 : STD_LOGIC_VECTOR (15 downto 0) := "1111111111110000";

    signal ap_CS_fsm : STD_LOGIC_VECTOR (3 downto 0) := "0001";
    attribute fsm_encoding : string;
    attribute fsm_encoding of ap_CS_fsm : signal is "none";
    signal ap_CS_fsm_state1 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state1 : signal is "none";
    signal k_0_reg_152 : STD_LOGIC_VECTOR (4 downto 0);
    signal j_0_reg_164 : STD_LOGIC_VECTOR (3 downto 0);
    signal begin_read_read_fu_80_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal inlen_cast_fu_175_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal icmp_ln74_fu_179_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_CS_fsm_state2 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state2 : signal is "none";
    signal i_fu_185_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal i_reg_378 : STD_LOGIC_VECTOR (15 downto 0);
    signal sub_ln82_fu_197_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal sub_ln82_reg_383 : STD_LOGIC_VECTOR (15 downto 0);
    signal zext_ln83_fu_217_p1 : STD_LOGIC_VECTOR (20 downto 0);
    signal zext_ln83_reg_388 : STD_LOGIC_VECTOR (20 downto 0);
    signal icmp_ln78_fu_225_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln78_reg_393 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_CS_fsm_pp0_stage0 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_pp0_stage0 : signal is "none";
    signal ap_block_state3_pp0_stage0_iter0 : BOOLEAN;
    signal ap_block_state4_pp0_stage0_iter1 : BOOLEAN;
    signal ap_block_state5_pp0_stage0_iter2 : BOOLEAN;
    signal ap_block_pp0_stage0_11001 : BOOLEAN;
    signal icmp_ln78_reg_393_pp0_iter1_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal j_fu_231_p2 : STD_LOGIC_VECTOR (3 downto 0);
    signal ap_enable_reg_pp0_iter0 : STD_LOGIC := '0';
    signal index_fu_237_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal index_reg_402 : STD_LOGIC_VECTOR (15 downto 0);
    signal index_reg_402_pp0_iter1_reg : STD_LOGIC_VECTOR (15 downto 0);
    signal temp_fu_343_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal temp_reg_417 : STD_LOGIC_VECTOR (15 downto 0);
    signal k_fu_349_p2 : STD_LOGIC_VECTOR (4 downto 0);
    signal k_reg_422 : STD_LOGIC_VECTOR (4 downto 0);
    signal ap_enable_reg_pp0_iter1 : STD_LOGIC := '0';
    signal add_ln87_fu_359_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_CS_fsm_state6 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state6 : signal is "none";
    signal ap_block_pp0_stage0_subdone : BOOLEAN;
    signal ap_condition_pp0_exit_iter0_state3 : STD_LOGIC;
    signal ap_enable_reg_pp0_iter2 : STD_LOGIC := '0';
    signal p_0_reg_130 : STD_LOGIC_VECTOR (15 downto 0);
    signal i_0_reg_140 : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_phi_mux_k_0_phi_fu_156_p4 : STD_LOGIC_VECTOR (4 downto 0);
    signal ap_block_pp0_stage0 : BOOLEAN;
    signal zext_ln83_2_fu_254_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal zext_ln83_5_fu_264_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal zext_ln84_fu_355_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal shl_ln82_fu_191_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal shl_ln1_fu_203_p3 : STD_LOGIC_VECTOR (19 downto 0);
    signal or_ln83_fu_211_p2 : STD_LOGIC_VECTOR (19 downto 0);
    signal zext_ln78_fu_221_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal add_ln_fu_246_p3 : STD_LOGIC_VECTOR (19 downto 0);
    signal zext_ln83_1_fu_242_p1 : STD_LOGIC_VECTOR (20 downto 0);
    signal add_ln83_fu_259_p2 : STD_LOGIC_VECTOR (20 downto 0);
    signal sub_ln83_fu_273_p2 : STD_LOGIC_VECTOR (4 downto 0);
    signal zext_ln83_3_fu_279_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal lshr_ln83_fu_283_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal trunc_ln83_fu_269_p1 : STD_LOGIC_VECTOR (3 downto 0);
    signal xor_ln83_fu_295_p2 : STD_LOGIC_VECTOR (3 downto 0);
    signal p_Result_s_fu_289_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal zext_ln83_4_fu_301_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal add_ln83_1_fu_311_p2 : STD_LOGIC_VECTOR (4 downto 0);
    signal zext_ln83_6_fu_317_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal zext_ln83_7_fu_321_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal lshr_ln83_1_fu_325_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal lshr_ln83_2_fu_331_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal shl_ln83_fu_305_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal p_Result_5_fu_337_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_NS_fsm : STD_LOGIC_VECTOR (3 downto 0);
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
                if (((ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (ap_const_logic_1 = ap_condition_pp0_exit_iter0_state3) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone))) then 
                    ap_enable_reg_pp0_iter0 <= ap_const_logic_0;
                elsif (((icmp_ln74_fu_179_p2 = ap_const_lv1_0) and (begin_read_read_fu_80_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
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
                    if ((ap_const_logic_1 = ap_condition_pp0_exit_iter0_state3)) then 
                        ap_enable_reg_pp0_iter1 <= (ap_const_logic_1 xor ap_condition_pp0_exit_iter0_state3);
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
                elsif (((icmp_ln74_fu_179_p2 = ap_const_lv1_0) and (begin_read_read_fu_80_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
                    ap_enable_reg_pp0_iter2 <= ap_const_logic_0;
                end if; 
            end if;
        end if;
    end process;


    i_0_reg_140_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_start = ap_const_logic_1) and (begin_read_read_fu_80_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                i_0_reg_140 <= ap_const_lv16_0;
            elsif ((ap_const_logic_1 = ap_CS_fsm_state6)) then 
                i_0_reg_140 <= i_reg_378;
            end if; 
        end if;
    end process;

    j_0_reg_164_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln78_fu_225_p2 = ap_const_lv1_0) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then 
                j_0_reg_164 <= j_fu_231_p2;
            elsif (((icmp_ln74_fu_179_p2 = ap_const_lv1_0) and (begin_read_read_fu_80_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
                j_0_reg_164 <= ap_const_lv4_0;
            end if; 
        end if;
    end process;

    k_0_reg_152_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln78_reg_393_pp0_iter1_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1))) then 
                k_0_reg_152 <= k_reg_422;
            elsif (((icmp_ln74_fu_179_p2 = ap_const_lv1_0) and (begin_read_read_fu_80_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
                k_0_reg_152 <= ap_const_lv5_E;
            end if; 
        end if;
    end process;

    p_0_reg_130_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_start = ap_const_logic_1) and (begin_read_read_fu_80_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                p_0_reg_130 <= inlen_cast_fu_175_p1;
            elsif ((ap_const_logic_1 = ap_CS_fsm_state6)) then 
                p_0_reg_130 <= add_ln87_fu_359_p2;
            end if; 
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((begin_read_read_fu_80_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then
                i_reg_378 <= i_fu_185_p2;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then
                icmp_ln78_reg_393 <= icmp_ln78_fu_225_p2;
                icmp_ln78_reg_393_pp0_iter1_reg <= icmp_ln78_reg_393;
                index_reg_402_pp0_iter1_reg <= index_reg_402;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln78_fu_225_p2 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then
                index_reg_402 <= index_fu_237_p2;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln78_reg_393 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (ap_enable_reg_pp0_iter1 = ap_const_logic_1))) then
                k_reg_422 <= k_fu_349_p2;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((icmp_ln74_fu_179_p2 = ap_const_lv1_0) and (begin_read_read_fu_80_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then
                sub_ln82_reg_383 <= sub_ln82_fu_197_p2;
                    zext_ln83_reg_388(19 downto 4) <= zext_ln83_fu_217_p1(19 downto 4);
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln78_reg_393 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then
                temp_reg_417 <= temp_fu_343_p2;
            end if;
        end if;
    end process;
    zext_ln83_reg_388(3 downto 0) <= "0001";
    zext_ln83_reg_388(20) <= '0';

    ap_NS_fsm_assign_proc : process (ap_start, ap_CS_fsm, ap_CS_fsm_state1, begin_read_read_fu_80_p2, icmp_ln74_fu_179_p2, ap_CS_fsm_state2, icmp_ln78_fu_225_p2, ap_enable_reg_pp0_iter0, ap_enable_reg_pp0_iter1, ap_block_pp0_stage0_subdone, ap_enable_reg_pp0_iter2)
    begin
        case ap_CS_fsm is
            when ap_ST_fsm_state1 => 
                if (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                    ap_NS_fsm <= ap_ST_fsm_state2;
                else
                    ap_NS_fsm <= ap_ST_fsm_state1;
                end if;
            when ap_ST_fsm_state2 => 
                if (((ap_const_logic_1 = ap_CS_fsm_state2) and ((icmp_ln74_fu_179_p2 = ap_const_lv1_1) or (begin_read_read_fu_80_p2 = ap_const_lv1_0)))) then
                    ap_NS_fsm <= ap_ST_fsm_state1;
                else
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                end if;
            when ap_ST_fsm_pp0_stage0 => 
                if ((not(((icmp_ln78_fu_225_p2 = ap_const_lv1_1) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0))) and not(((ap_enable_reg_pp0_iter2 = ap_const_logic_1) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0))))) then
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                elsif ((((icmp_ln78_fu_225_p2 = ap_const_lv1_1) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0)) or ((ap_enable_reg_pp0_iter2 = ap_const_logic_1) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0)))) then
                    ap_NS_fsm <= ap_ST_fsm_state6;
                else
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                end if;
            when ap_ST_fsm_state6 => 
                ap_NS_fsm <= ap_ST_fsm_state2;
            when others =>  
                ap_NS_fsm <= "XXXX";
        end case;
    end process;
    add_ln83_1_fu_311_p2 <= std_logic_vector(unsigned(ap_const_lv5_1) + unsigned(ap_phi_mux_k_0_phi_fu_156_p4));
    add_ln83_fu_259_p2 <= std_logic_vector(unsigned(zext_ln83_reg_388) + unsigned(zext_ln83_1_fu_242_p1));
    add_ln87_fu_359_p2 <= std_logic_vector(unsigned(p_0_reg_130) + unsigned(ap_const_lv16_FFF0));
    add_ln_fu_246_p3 <= (i_0_reg_140 & j_0_reg_164);
    ap_CS_fsm_pp0_stage0 <= ap_CS_fsm(2);
    ap_CS_fsm_state1 <= ap_CS_fsm(0);
    ap_CS_fsm_state2 <= ap_CS_fsm(1);
    ap_CS_fsm_state6 <= ap_CS_fsm(3);
        ap_block_pp0_stage0 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_pp0_stage0_11001 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_pp0_stage0_subdone <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state3_pp0_stage0_iter0 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state4_pp0_stage0_iter1 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state5_pp0_stage0_iter2 <= not((ap_const_boolean_1 = ap_const_boolean_1));

    ap_condition_pp0_exit_iter0_state3_assign_proc : process(icmp_ln78_fu_225_p2)
    begin
        if ((icmp_ln78_fu_225_p2 = ap_const_lv1_1)) then 
            ap_condition_pp0_exit_iter0_state3 <= ap_const_logic_1;
        else 
            ap_condition_pp0_exit_iter0_state3 <= ap_const_logic_0;
        end if; 
    end process;


    ap_done_assign_proc : process(ap_start, ap_CS_fsm_state1, begin_read_read_fu_80_p2, icmp_ln74_fu_179_p2, ap_CS_fsm_state2)
    begin
        if ((((ap_const_logic_1 = ap_CS_fsm_state2) and ((icmp_ln74_fu_179_p2 = ap_const_lv1_1) or (begin_read_read_fu_80_p2 = ap_const_lv1_0))) or ((ap_start = ap_const_logic_0) and (ap_const_logic_1 = ap_CS_fsm_state1)))) then 
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


    ap_idle_pp0_assign_proc : process(ap_enable_reg_pp0_iter0, ap_enable_reg_pp0_iter1, ap_enable_reg_pp0_iter2)
    begin
        if (((ap_enable_reg_pp0_iter0 = ap_const_logic_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_0) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0))) then 
            ap_idle_pp0 <= ap_const_logic_1;
        else 
            ap_idle_pp0 <= ap_const_logic_0;
        end if; 
    end process;


    ap_phi_mux_k_0_phi_fu_156_p4_assign_proc : process(k_0_reg_152, icmp_ln78_reg_393_pp0_iter1_reg, k_reg_422, ap_enable_reg_pp0_iter2, ap_block_pp0_stage0)
    begin
        if (((icmp_ln78_reg_393_pp0_iter1_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1) and (ap_const_boolean_0 = ap_block_pp0_stage0))) then 
            ap_phi_mux_k_0_phi_fu_156_p4 <= k_reg_422;
        else 
            ap_phi_mux_k_0_phi_fu_156_p4 <= k_0_reg_152;
        end if; 
    end process;


    ap_ready_assign_proc : process(begin_read_read_fu_80_p2, icmp_ln74_fu_179_p2, ap_CS_fsm_state2)
    begin
        if (((ap_const_logic_1 = ap_CS_fsm_state2) and ((icmp_ln74_fu_179_p2 = ap_const_lv1_1) or (begin_read_read_fu_80_p2 = ap_const_lv1_0)))) then 
            ap_ready <= ap_const_logic_1;
        else 
            ap_ready <= ap_const_logic_0;
        end if; 
    end process;

    begin_read_read_fu_80_p2 <= begin_r;
    i_fu_185_p2 <= std_logic_vector(unsigned(i_0_reg_140) + unsigned(ap_const_lv16_1));
    icmp_ln74_fu_179_p2 <= "1" when (p_0_reg_130 = ap_const_lv16_0) else "0";
    icmp_ln78_fu_225_p2 <= "1" when (j_0_reg_164 = ap_const_lv4_F) else "0";
    in_r_address0 <= zext_ln83_2_fu_254_p1(10 - 1 downto 0);
    in_r_address1 <= zext_ln83_5_fu_264_p1(10 - 1 downto 0);

    in_r_ce0_assign_proc : process(ap_CS_fsm_pp0_stage0, ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter0)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then 
            in_r_ce0 <= ap_const_logic_1;
        else 
            in_r_ce0 <= ap_const_logic_0;
        end if; 
    end process;


    in_r_ce1_assign_proc : process(ap_CS_fsm_pp0_stage0, ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter0)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then 
            in_r_ce1 <= ap_const_logic_1;
        else 
            in_r_ce1 <= ap_const_logic_0;
        end if; 
    end process;

    index_fu_237_p2 <= std_logic_vector(unsigned(sub_ln82_reg_383) + unsigned(zext_ln78_fu_221_p1));
    inlen_cast_fu_175_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(inlen),16));
    j_fu_231_p2 <= std_logic_vector(unsigned(j_0_reg_164) + unsigned(ap_const_lv4_1));
    k_fu_349_p2 <= std_logic_vector(signed(ap_const_lv5_1F) + signed(ap_phi_mux_k_0_phi_fu_156_p4));
    lshr_ln83_1_fu_325_p2 <= std_logic_vector(shift_right(unsigned(in_r_q1),to_integer(unsigned('0' & zext_ln83_6_fu_317_p1(16-1 downto 0)))));
    lshr_ln83_2_fu_331_p2 <= std_logic_vector(shift_right(unsigned(ap_const_lv16_FFFF),to_integer(unsigned('0' & zext_ln83_7_fu_321_p1(16-1 downto 0)))));
    lshr_ln83_fu_283_p2 <= std_logic_vector(shift_right(unsigned(ap_const_lv16_FFFF),to_integer(unsigned('0' & zext_ln83_3_fu_279_p1(16-1 downto 0)))));
    or_ln83_fu_211_p2 <= (shl_ln1_fu_203_p3 or ap_const_lv20_1);
    out_r_address0 <= zext_ln84_fu_355_p1(10 - 1 downto 0);

    out_r_ce0_assign_proc : process(ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter2)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1))) then 
            out_r_ce0 <= ap_const_logic_1;
        else 
            out_r_ce0 <= ap_const_logic_0;
        end if; 
    end process;

    out_r_d0 <= temp_reg_417;

    out_r_we0_assign_proc : process(ap_block_pp0_stage0_11001, icmp_ln78_reg_393_pp0_iter1_reg, ap_enable_reg_pp0_iter2)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln78_reg_393_pp0_iter1_reg = ap_const_lv1_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_1))) then 
            out_r_we0 <= ap_const_logic_1;
        else 
            out_r_we0 <= ap_const_logic_0;
        end if; 
    end process;

    p_Result_5_fu_337_p2 <= (lshr_ln83_2_fu_331_p2 and lshr_ln83_1_fu_325_p2);
    p_Result_s_fu_289_p2 <= (lshr_ln83_fu_283_p2 and in_r_q0);
    shl_ln1_fu_203_p3 <= (i_0_reg_140 & ap_const_lv4_0);
    shl_ln82_fu_191_p2 <= std_logic_vector(shift_left(unsigned(i_0_reg_140),to_integer(unsigned('0' & ap_const_lv16_4(16-1 downto 0)))));
    shl_ln83_fu_305_p2 <= std_logic_vector(shift_left(unsigned(p_Result_s_fu_289_p2),to_integer(unsigned('0' & zext_ln83_4_fu_301_p1(16-1 downto 0)))));
    sub_ln82_fu_197_p2 <= std_logic_vector(unsigned(shl_ln82_fu_191_p2) - unsigned(i_0_reg_140));
    sub_ln83_fu_273_p2 <= std_logic_vector(unsigned(ap_const_lv5_F) - unsigned(ap_phi_mux_k_0_phi_fu_156_p4));
    temp_fu_343_p2 <= (shl_ln83_fu_305_p2 or p_Result_5_fu_337_p2);
    trunc_ln83_fu_269_p1 <= ap_phi_mux_k_0_phi_fu_156_p4(4 - 1 downto 0);
    xor_ln83_fu_295_p2 <= (trunc_ln83_fu_269_p1 xor ap_const_lv4_F);
    zext_ln78_fu_221_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(j_0_reg_164),16));
    zext_ln83_1_fu_242_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(j_0_reg_164),21));
    zext_ln83_2_fu_254_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(add_ln_fu_246_p3),64));
    zext_ln83_3_fu_279_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(sub_ln83_fu_273_p2),16));
    zext_ln83_4_fu_301_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(xor_ln83_fu_295_p2),16));
    zext_ln83_5_fu_264_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(add_ln83_fu_259_p2),64));
    zext_ln83_6_fu_317_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(ap_phi_mux_k_0_phi_fu_156_p4),16));
    zext_ln83_7_fu_321_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(add_ln83_1_fu_311_p2),16));
    zext_ln83_fu_217_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(or_ln83_fu_211_p2),21));
    zext_ln84_fu_355_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(index_reg_402_pp0_iter1_reg),64));
end behav;