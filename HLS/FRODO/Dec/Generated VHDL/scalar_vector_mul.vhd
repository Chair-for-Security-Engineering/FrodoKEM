-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and OpenCL
-- Version: 2020.1
-- Copyright (C) 1986-2020 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity scalar_vector_mul is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    output_vec_address0 : OUT STD_LOGIC_VECTOR (9 downto 0);
    output_vec_ce0 : OUT STD_LOGIC;
    output_vec_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
    output_vec_address1 : OUT STD_LOGIC_VECTOR (9 downto 0);
    output_vec_ce1 : OUT STD_LOGIC;
    output_vec_we1 : OUT STD_LOGIC;
    output_vec_d1 : OUT STD_LOGIC_VECTOR (15 downto 0);
    input_vec_address0 : OUT STD_LOGIC_VECTOR (9 downto 0);
    input_vec_ce0 : OUT STD_LOGIC;
    input_vec_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
    scalar : IN STD_LOGIC_VECTOR (15 downto 0);
    n : IN STD_LOGIC_VECTOR (9 downto 0);
    index : IN STD_LOGIC_VECTOR (9 downto 0);
    E_address0 : OUT STD_LOGIC_VECTOR (9 downto 0);
    E_ce0 : OUT STD_LOGIC;
    E_q0 : IN STD_LOGIC_VECTOR (15 downto 0) );
end;


architecture behav of scalar_vector_mul is 
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';
    constant ap_ST_fsm_state1 : STD_LOGIC_VECTOR (2 downto 0) := "001";
    constant ap_ST_fsm_pp0_stage0 : STD_LOGIC_VECTOR (2 downto 0) := "010";
    constant ap_ST_fsm_state6 : STD_LOGIC_VECTOR (2 downto 0) := "100";
    constant ap_const_boolean_1 : BOOLEAN := true;
    constant ap_const_lv32_0 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_boolean_0 : BOOLEAN := false;
    constant ap_const_lv1_0 : STD_LOGIC_VECTOR (0 downto 0) := "0";
    constant ap_const_lv1_1 : STD_LOGIC_VECTOR (0 downto 0) := "1";
    constant ap_const_lv10_0 : STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
    constant ap_const_lv16_0 : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
    constant ap_const_lv10_1 : STD_LOGIC_VECTOR (9 downto 0) := "0000000001";
    constant ap_const_lv32_2 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010";

    signal ap_CS_fsm : STD_LOGIC_VECTOR (2 downto 0) := "001";
    attribute fsm_encoding : string;
    attribute fsm_encoding of ap_CS_fsm : signal is "none";
    signal ap_CS_fsm_state1 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state1 : signal is "none";
    signal i_0_reg_122 : STD_LOGIC_VECTOR (9 downto 0);
    signal icmp_ln420_fu_144_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln420_reg_212 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln416_fu_150_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln416_reg_216 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_CS_fsm_pp0_stage0 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_pp0_stage0 : signal is "none";
    signal ap_block_state2_pp0_stage0_iter0 : BOOLEAN;
    signal ap_block_state3_pp0_stage0_iter1 : BOOLEAN;
    signal ap_block_state4_pp0_stage0_iter2 : BOOLEAN;
    signal ap_block_state5_pp0_stage0_iter3 : BOOLEAN;
    signal ap_block_pp0_stage0_11001 : BOOLEAN;
    signal icmp_ln416_reg_216_pp0_iter1_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal icmp_ln416_reg_216_pp0_iter2_reg : STD_LOGIC_VECTOR (0 downto 0);
    signal i_fu_155_p2 : STD_LOGIC_VECTOR (9 downto 0);
    signal ap_enable_reg_pp0_iter0 : STD_LOGIC := '0';
    signal output_vec_addr_reg_235 : STD_LOGIC_VECTOR (9 downto 0);
    signal output_vec_addr_reg_235_pp0_iter1_reg : STD_LOGIC_VECTOR (9 downto 0);
    signal output_vec_addr_reg_235_pp0_iter2_reg : STD_LOGIC_VECTOR (9 downto 0);
    signal input_vec_load_reg_246 : STD_LOGIC_VECTOR (15 downto 0);
    signal trunc_ln430_1_fu_177_p1 : STD_LOGIC_VECTOR (14 downto 0);
    signal trunc_ln430_1_reg_251 : STD_LOGIC_VECTOR (14 downto 0);
    signal ap_block_pp0_stage0_subdone : BOOLEAN;
    signal ap_condition_pp0_exit_iter0_state2 : STD_LOGIC;
    signal ap_enable_reg_pp0_iter1 : STD_LOGIC := '0';
    signal ap_enable_reg_pp0_iter2 : STD_LOGIC := '0';
    signal ap_enable_reg_pp0_iter3 : STD_LOGIC := '0';
    signal grp_reg_r_fu_172_ap_return : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_phi_reg_pp0_iter0_e_0_reg_133 : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_phi_reg_pp0_iter1_e_0_reg_133 : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_phi_reg_pp0_iter2_e_0_reg_133 : STD_LOGIC_VECTOR (15 downto 0);
    signal grp_fu_195_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_block_pp0_stage0 : BOOLEAN;
    signal zext_ln421_fu_161_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal zext_ln427_fu_166_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal trunc_ln430_fu_181_p1 : STD_LOGIC_VECTOR (14 downto 0);
    signal add_ln430_fu_185_p2 : STD_LOGIC_VECTOR (14 downto 0);
    signal ap_CS_fsm_state6 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state6 : signal is "none";
    signal ap_NS_fsm : STD_LOGIC_VECTOR (2 downto 0);
    signal ap_idle_pp0 : STD_LOGIC;
    signal ap_enable_pp0 : STD_LOGIC;
    signal ap_condition_84 : BOOLEAN;
    signal ap_condition_137 : BOOLEAN;

    component reg_r IS
    port (
        ap_clk : IN STD_LOGIC;
        ap_rst : IN STD_LOGIC;
        in_r : IN STD_LOGIC_VECTOR (15 downto 0);
        ap_return : OUT STD_LOGIC_VECTOR (15 downto 0) );
    end component;


    component frodo_dec_mac_mulbkb IS
    generic (
        ID : INTEGER;
        NUM_STAGE : INTEGER;
        din0_WIDTH : INTEGER;
        din1_WIDTH : INTEGER;
        din2_WIDTH : INTEGER;
        dout_WIDTH : INTEGER );
    port (
        din0 : IN STD_LOGIC_VECTOR (15 downto 0);
        din1 : IN STD_LOGIC_VECTOR (15 downto 0);
        din2 : IN STD_LOGIC_VECTOR (15 downto 0);
        dout : OUT STD_LOGIC_VECTOR (15 downto 0) );
    end component;



begin
    grp_reg_r_fu_172 : component reg_r
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst,
        in_r => grp_fu_195_p3,
        ap_return => grp_reg_r_fu_172_ap_return);

    frodo_dec_mac_mulbkb_U40 : component frodo_dec_mac_mulbkb
    generic map (
        ID => 1,
        NUM_STAGE => 1,
        din0_WIDTH => 16,
        din1_WIDTH => 16,
        din2_WIDTH => 16,
        dout_WIDTH => 16)
    port map (
        din0 => scalar,
        din1 => input_vec_load_reg_246,
        din2 => ap_phi_reg_pp0_iter2_e_0_reg_133,
        dout => grp_fu_195_p3);





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
                elsif (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                    ap_enable_reg_pp0_iter3 <= ap_const_logic_0;
                end if; 
            end if;
        end if;
    end process;


    ap_phi_reg_pp0_iter1_e_0_reg_133_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_const_boolean_1 = ap_condition_84)) then
                if (((icmp_ln416_fu_150_p2 = ap_const_lv1_0) and (icmp_ln420_reg_212 = ap_const_lv1_0))) then 
                    ap_phi_reg_pp0_iter1_e_0_reg_133 <= ap_const_lv16_0;
                elsif ((ap_const_boolean_1 = ap_const_boolean_1)) then 
                    ap_phi_reg_pp0_iter1_e_0_reg_133 <= ap_phi_reg_pp0_iter0_e_0_reg_133;
                end if;
            end if; 
        end if;
    end process;

    ap_phi_reg_pp0_iter2_e_0_reg_133_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_const_boolean_1 = ap_condition_137)) then
                if (((icmp_ln416_reg_216 = ap_const_lv1_0) and (icmp_ln420_reg_212 = ap_const_lv1_1))) then 
                    ap_phi_reg_pp0_iter2_e_0_reg_133 <= E_q0;
                elsif ((ap_const_boolean_1 = ap_const_boolean_1)) then 
                    ap_phi_reg_pp0_iter2_e_0_reg_133 <= ap_phi_reg_pp0_iter1_e_0_reg_133;
                end if;
            end if; 
        end if;
    end process;

    i_0_reg_122_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln416_fu_150_p2 = ap_const_lv1_0) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then 
                i_0_reg_122 <= i_fu_155_p2;
            elsif (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
                i_0_reg_122 <= ap_const_lv10_0;
            end if; 
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then
                icmp_ln416_reg_216 <= icmp_ln416_fu_150_p2;
                icmp_ln416_reg_216_pp0_iter1_reg <= icmp_ln416_reg_216;
                output_vec_addr_reg_235_pp0_iter1_reg <= output_vec_addr_reg_235;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_const_boolean_0 = ap_block_pp0_stage0_11001)) then
                icmp_ln416_reg_216_pp0_iter2_reg <= icmp_ln416_reg_216_pp0_iter1_reg;
                output_vec_addr_reg_235_pp0_iter2_reg <= output_vec_addr_reg_235_pp0_iter1_reg;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                icmp_ln420_reg_212 <= icmp_ln420_fu_144_p2;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln416_reg_216 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then
                input_vec_load_reg_246 <= input_vec_q0;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (icmp_ln416_fu_150_p2 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then
                output_vec_addr_reg_235 <= zext_ln427_fu_166_p1(10 - 1 downto 0);
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((icmp_ln416_reg_216_pp0_iter1_reg = ap_const_lv1_0) and (ap_const_boolean_0 = ap_block_pp0_stage0_11001))) then
                trunc_ln430_1_reg_251 <= trunc_ln430_1_fu_177_p1;
            end if;
        end if;
    end process;

    ap_NS_fsm_assign_proc : process (ap_start, ap_CS_fsm, ap_CS_fsm_state1, icmp_ln416_fu_150_p2, ap_enable_reg_pp0_iter0, ap_block_pp0_stage0_subdone, ap_enable_reg_pp0_iter1, ap_enable_reg_pp0_iter2, ap_enable_reg_pp0_iter3)
    begin
        case ap_CS_fsm is
            when ap_ST_fsm_state1 => 
                if (((ap_start = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state1))) then
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                else
                    ap_NS_fsm <= ap_ST_fsm_state1;
                end if;
            when ap_ST_fsm_pp0_stage0 => 
                if ((not(((icmp_ln416_fu_150_p2 = ap_const_lv1_1) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone))) and not(((ap_enable_reg_pp0_iter3 = ap_const_logic_1) and (ap_enable_reg_pp0_iter2 = ap_const_logic_0) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone))))) then
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                elsif ((((icmp_ln416_fu_150_p2 = ap_const_lv1_1) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone)) or ((ap_enable_reg_pp0_iter3 = ap_const_logic_1) and (ap_enable_reg_pp0_iter2 = ap_const_logic_0) and (ap_const_boolean_0 = ap_block_pp0_stage0_subdone)))) then
                    ap_NS_fsm <= ap_ST_fsm_state6;
                else
                    ap_NS_fsm <= ap_ST_fsm_pp0_stage0;
                end if;
            when ap_ST_fsm_state6 => 
                ap_NS_fsm <= ap_ST_fsm_state1;
            when others =>  
                ap_NS_fsm <= "XXX";
        end case;
    end process;
    E_address0 <= zext_ln421_fu_161_p1(10 - 1 downto 0);

    E_ce0_assign_proc : process(ap_CS_fsm_pp0_stage0, ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter0)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then 
            E_ce0 <= ap_const_logic_1;
        else 
            E_ce0 <= ap_const_logic_0;
        end if; 
    end process;

    add_ln430_fu_185_p2 <= std_logic_vector(unsigned(trunc_ln430_1_reg_251) + unsigned(trunc_ln430_fu_181_p1));
    ap_CS_fsm_pp0_stage0 <= ap_CS_fsm(1);
    ap_CS_fsm_state1 <= ap_CS_fsm(0);
    ap_CS_fsm_state6 <= ap_CS_fsm(2);
        ap_block_pp0_stage0 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_pp0_stage0_11001 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_pp0_stage0_subdone <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state2_pp0_stage0_iter0 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state3_pp0_stage0_iter1 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state4_pp0_stage0_iter2 <= not((ap_const_boolean_1 = ap_const_boolean_1));
        ap_block_state5_pp0_stage0_iter3 <= not((ap_const_boolean_1 = ap_const_boolean_1));

    ap_condition_137_assign_proc : process(ap_CS_fsm_pp0_stage0, ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter1)
    begin
                ap_condition_137 <= ((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (ap_enable_reg_pp0_iter1 = ap_const_logic_1));
    end process;


    ap_condition_84_assign_proc : process(ap_CS_fsm_pp0_stage0, ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter0)
    begin
                ap_condition_84 <= ((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0));
    end process;


    ap_condition_pp0_exit_iter0_state2_assign_proc : process(icmp_ln416_fu_150_p2)
    begin
        if ((icmp_ln416_fu_150_p2 = ap_const_lv1_1)) then 
            ap_condition_pp0_exit_iter0_state2 <= ap_const_logic_1;
        else 
            ap_condition_pp0_exit_iter0_state2 <= ap_const_logic_0;
        end if; 
    end process;


    ap_done_assign_proc : process(ap_start, ap_CS_fsm_state1, ap_CS_fsm_state6)
    begin
        if (((ap_const_logic_1 = ap_CS_fsm_state6) or ((ap_start = ap_const_logic_0) and (ap_const_logic_1 = ap_CS_fsm_state1)))) then 
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


    ap_idle_pp0_assign_proc : process(ap_enable_reg_pp0_iter0, ap_enable_reg_pp0_iter1, ap_enable_reg_pp0_iter2, ap_enable_reg_pp0_iter3)
    begin
        if (((ap_enable_reg_pp0_iter0 = ap_const_logic_0) and (ap_enable_reg_pp0_iter3 = ap_const_logic_0) and (ap_enable_reg_pp0_iter2 = ap_const_logic_0) and (ap_enable_reg_pp0_iter1 = ap_const_logic_0))) then 
            ap_idle_pp0 <= ap_const_logic_1;
        else 
            ap_idle_pp0 <= ap_const_logic_0;
        end if; 
    end process;

    ap_phi_reg_pp0_iter0_e_0_reg_133 <= "XXXXXXXXXXXXXXXX";

    ap_ready_assign_proc : process(ap_CS_fsm_state6)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state6)) then 
            ap_ready <= ap_const_logic_1;
        else 
            ap_ready <= ap_const_logic_0;
        end if; 
    end process;

    i_fu_155_p2 <= std_logic_vector(unsigned(i_0_reg_122) + unsigned(ap_const_lv10_1));
    icmp_ln416_fu_150_p2 <= "1" when (i_0_reg_122 = n) else "0";
    icmp_ln420_fu_144_p2 <= "1" when (index = ap_const_lv10_0) else "0";
    input_vec_address0 <= zext_ln427_fu_166_p1(10 - 1 downto 0);

    input_vec_ce0_assign_proc : process(ap_CS_fsm_pp0_stage0, ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter0)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter0 = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0))) then 
            input_vec_ce0 <= ap_const_logic_1;
        else 
            input_vec_ce0 <= ap_const_logic_0;
        end if; 
    end process;

    output_vec_address0 <= output_vec_addr_reg_235;
    output_vec_address1 <= output_vec_addr_reg_235_pp0_iter2_reg;

    output_vec_ce0_assign_proc : process(ap_CS_fsm_pp0_stage0, ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter1)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_const_logic_1 = ap_CS_fsm_pp0_stage0) and (ap_enable_reg_pp0_iter1 = ap_const_logic_1))) then 
            output_vec_ce0 <= ap_const_logic_1;
        else 
            output_vec_ce0 <= ap_const_logic_0;
        end if; 
    end process;


    output_vec_ce1_assign_proc : process(ap_block_pp0_stage0_11001, ap_enable_reg_pp0_iter3)
    begin
        if (((ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter3 = ap_const_logic_1))) then 
            output_vec_ce1 <= ap_const_logic_1;
        else 
            output_vec_ce1 <= ap_const_logic_0;
        end if; 
    end process;

    output_vec_d1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(add_ln430_fu_185_p2),16));

    output_vec_we1_assign_proc : process(ap_block_pp0_stage0_11001, icmp_ln416_reg_216_pp0_iter2_reg, ap_enable_reg_pp0_iter3)
    begin
        if (((icmp_ln416_reg_216_pp0_iter2_reg = ap_const_lv1_0) and (ap_const_boolean_0 = ap_block_pp0_stage0_11001) and (ap_enable_reg_pp0_iter3 = ap_const_logic_1))) then 
            output_vec_we1 <= ap_const_logic_1;
        else 
            output_vec_we1 <= ap_const_logic_0;
        end if; 
    end process;

    trunc_ln430_1_fu_177_p1 <= output_vec_q0(15 - 1 downto 0);
    trunc_ln430_fu_181_p1 <= grp_reg_r_fu_172_ap_return(15 - 1 downto 0);
    zext_ln421_fu_161_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(i_0_reg_122),64));
    zext_ln427_fu_166_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(i_0_reg_122),64));
end behav;
