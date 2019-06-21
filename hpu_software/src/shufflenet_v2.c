// +FHDR------------------------------------------------------------------------
// Copyright ownership belongs to CAG laboratory, Institute of Artificial
// Intelligence and Robotics, Xi'an Jiaotong University, shall not be used in
// commercial ways without permission.
// -----------------------------------------------------------------------------
// FILE NAME  : shufflenet_v2.c
// DEPARTMENT : CAG of IAIR
// AUTHOR     : XXXX
// AUTHOR'S EMAIL :XXXX@mail.xjtu.edu.cn
// -----------------------------------------------------------------------------
// Ver 1.0  2019--01--01 initial version.
// -----------------------------------------------------------------------------

#include "../inc/global.h"
#include "../inc/hpu_api.h"
#include "../inc/intr.h"
#include "../inc/shufflenet_v2.h"

// Matrix register assignment
int fm_layer0_table_addr[8] = {0x03540354, 0x00000000, 0x00aa00aa, 0x01540154, 0x02000200, 0x02aa02aa, 0x03540354, 0x00000000};
int fm_layer1_table_addr[8] = {0x07540754, 0x04000400, 0x04aa04aa, 0x05540554, 0x06000600, 0x06aa06aa, 0x07540754, 0x04000400};
int fm_layer2_table_addr[5] = {0x09540954, 0x08000800, 0x08aa08aa, 0x09540954, 0x08000800};
int fm_layer3_table_addr[5] = {0x0b540b54, 0x0a000a00, 0x0aaa0aaa, 0x0b540b54, 0x0a000a00};
int fm_layer4_table_addr[5] = {0x0d540d54, 0x0c000c00, 0x0caa0caa, 0x0d540d54, 0x0c000c00};
int fm_layer5_table_addr[5] = {0x0f540f54, 0x0e000e00, 0x0eaa0eaa, 0x0f540f54, 0x0e000e00};

int fm_conv0_table_addr[7] = {0x08000800, 0x00000000, 0x02000200, 0x04000400, 0x06000600, 0x08000800, 0x00000000};
int fm_conv1_table_addr[4] = {0x0c000c00, 0x0a000a00, 0x0c000c00, 0x0a000a00};
int fm_conv2_table_addr = 0x0e000e00;

int fm_cmdstream0_table_addr[5] = {0x04000400, 0x00000000, 0x02000200, 0x04000400, 0x00000000};
int fm_cmdstream1_table_addr[5] = {0x0a000a00, 0x06000600, 0x08000800, 0x0a000a00, 0x06000600};

// global control variables
int ldmr_en = 0;
int ldmr_busy = 0;
int ldmr_line = 0;
int ldmr_index = 1;

int calc_en = 0;
int calc_busy = 0;
int calc_line = 0;
int calc_ifm_index = 1;
int calc_ofm_index = 1;

int conv_en = 0;
int conv_busy = 0;
int conv_line = 0;
int conv_ifm_index = 1;
int conv_ofm_index = 1;

int dwc_en = 0;
int dwc_busy = 0;
int dwc_line = 0;
int dwc_ifm_index = 1;
int dwc_ofm_index = 1;

int svmr_en = 0;
int svmr_busy = 0;
int svmr_line = 0;
int svmr_index = 1;

// shufflenet V2 parameters
pc_ldmr_param wt_dwc_param;
pc_ldmr_param wt_conv_param;
pc_ldmr_param bias_dwc_param;
pc_ldmr_param bias_conv_param;
pc_ldmr_param ifm_param;
pc_svmr_param ofm_param;
pc_conv_param conv_param;
pc_dwcalc_param pool1_param;
pc_conv_param right_a_param;
pc_dwcalc_param right_b_param;
pc_conv_param right_c_param;
pc_dwcalc_param left_b_param;
pc_conv_param left_c_param;
pc_dtrans_param left_dt_param;
pc_ftrans_param ftrans_param;
pc_dtrans_param dtrans_param;

int conv_ch64;
int conv_fm_height;
int pool_fm_height;
int conv_pad_width;
int pool_width;
int conv_lb_pad_width;
int conv_rb_pad_width;
int conv_lb_fm_width;
int conv_rb_fm_width;
int conv_ifm_offset;

// variables
// pc_ldmr_param wt_conv_param;
// pc_ldmr_param bias_conv_param
// pc_ldmr_param ifm_param;
// pc_conv_param conv_param;
// pc_dwcalc_param pool1_param;
// pc_dtrans_param dt_param;
// pc_svmr_param ofm_param;
// int conv_fm_height;
// int conv_pad_width;
// int pool_width;
void conv1_pool1()
{
    int i;
    // save the svmr/ldmr parameters
    int ldmr_ddr_addr = ifm_param->ddr_addr;
    int svmr_ddr_addr = ofm_param->ddr_addr;

    // initialize the index parameters
    ldmr_index = 1;
    conv_line = 0;
    conv_ifm_index = 1;

    // initialize weight and bias data
    // load weight data
    ldmr_set(wt_conv_param);
    ldmr_start();
    while(!ldmr_check());

    // load bias data
    ldmr_set(bias_conv_param);
    ldmr_start();
    while(!ldmr_check());

    // generated instruction stream
    // ==================================================================
    // load ifm 0/1/2
    // ==================================================================
    ifm_param->mr_addr = fm_conv0_table_addr[1];
    ifm_param->reoder_en = 1;
    ldmr_set(ifm_param);
    ldmr_start();

    ifm_param->mr_addr = fm_conv0_table_addr[2];
    ifm_param->ddr_addr += (ifm_param->trans_len << 6);
    ldmr_set(ifm_param);
    while(!ldmr_check());
    ldmr_start();

    ifm_param->mr_addr = fm_conv0_table_addr[3];
    ifm_param->ddr_addr += (ifm_param->trans_len << 6);
    ldmr_set(ifm_param);
    while(!ldmr_check());
    ldmr_start();

    // configure param of ldmr
    ldmr_index = 4;
    ifm_param->mr_addr = fm_conv0_table_addr[4];
    ifm_param->ddr_addr += (ifm_param->trans_len << 6);
    ldmr_set(ifm_param);

    // confiture param of conv1
    conv_ifm_index = 2;
    conv_param->ifm_addr0 = fm_conv0_table_addr[1];
    conv_param->ifm_addr1 = fm_conv0_table_addr[2];
    conv_param->ifm_addr2 = fm_conv0_table_addr[3];
    conv_param->ofm_addr = fm_conv1_table_addr[1];
    conv_set(conv_param);

    // configure param of pool1
    pool1_param->ifm_addr0 = fm_conv1_table_addr[1];
    pool1_param->ifm_addr1 = fm_conv1_table_addr[2];
    pool1_param->ofm_addr = fm_conv2_table_addr;
    dwcalc_set(pool1_param);

    // configure param of svmr
    ofm_param->mr_addr = fm_conv2_table_addr;
    svmr_set(ofm_param);
    while(!ldmr_check());

    // ==================================================================
    // loop
    // ==================================================================
    for(conv_line = 0; conv_line < conv_fm_height; conv_line += 4)
    {
        // ==================================================================
        // Phase 0: pool 
        // ==================================================================
        if(conv_line != 0)
        {
            dwcalc_start();
        }

        // ==================================================================
        // Phase 0: load ifm [conv_line + 3]
        // ==================================================================
        if(conv_line+3 < conv_fm_height)
        {
            ldmr_start();
            // prepare params for next ldmr
            ldmr_index++;
            if(ldmr_index > 5) ldmr_index -= 5;
            ifm_param->mr_addr = fm_conv0_table_addr[ldmr_index];
            ifm_param->ddr_addr += (ifm_param->trans_len << 6);
            ldmr_set(ifm_param);
        }

        // ==================================================================
        // Phase 0: conv [conv_line]
        // ==================================================================
        conv_start();
        // prepare params for next conv
        conv_ifm_index += 2;
        if(conv_ifm_index > 5) conv_ifm_index -= 5;
        conv_param->ifm_addr0 = fm_conv0_table_addr[conv_ifm_index-1];
        conv_param->ifm_addr1 = fm_conv0_table_addr[conv_ifm_index];
        conv_param->ifm_addr2 = fm_conv0_table_addr[conv_ifm_index+1];
        if(conv_line+5 > conv_fm_height)
            conv_param->ifm_addr2 = 0x3e003e00;
        conv_param->ofm_addr = fm_conv1_table_addr[2];
        conv_set(conv_param);

        if(conv_line+3 < conv_fm_height)
        {
            while(!ldmr_check());
        }
        // ==================================================================
        // Phase 1: load ifm [conv_line + 4]
        // ==================================================================
        if(conv_line+4 < conv_fm_height)
        {
            ldmr_start();
            // prepare params for next ldmr
            ldmr_index++;
            if(ldmr_index > 5) ldmr_index -= 5;
            ifm_param->mr_addr = fm_conv0_table_addr[ldmr_index];
            ifm_param->ddr_addr += (ifm_param->trans_len << 6);
            ldmr_set(ifm_param);
        }

        if(conv_line != 0)
        {
            while(!intr_dwcalc_act);
            intr_dwcalc_act = 0;
        }
        while(!intr_conv_act);
        intr_conv_act = 0;
        if(conv_line+4 < conv_fm_height)
        {
            while(!ldmr_check());
        }

        // ==================================================================
        // Phase 2: save 
        // ==================================================================
        if(conv_line != 0)
        {
            svmr_start();
        }

        // ==================================================================
        // Phase 2: load ifm [conv_line + 5]
        // ==================================================================
        if(conv_line+5 < conv_fm_height)
        {
            ldmr_start();
        }

        // ==================================================================
        // Phase 2: conv [conv_line + 2]
        // ==================================================================
        conv_start();
        // set conv parameters for next command
        if(conv_line != 0)
        {
            ofm_param->ddr_addr += (ofm_param->trans_len << 6);
            svmr_set(ofm_param);
        }
        // set ldmr params for next command
        if(conv_line+5 < conv_fm_height)
        {
            ldmr_index++;
            if(ldmr_index > 5) ldmr_index -= 5;
            ifm_param->mr_addr = fm_conv0_table_addr[ldmr_index];
            ifm_param->ddr_addr += (ifm_param->trans_len << 6);
            ldmr_set(ifm_param);
        }

        if(conv_line+5 < conv_fm_height)
        {
            while(!ldmr_check());
        }

        // ==================================================================
        // Phase 3: load ifm [conv_line + 6]
        // ==================================================================
        if(conv_line+6 < conv_fm_height)
        {
            ldmr_start();
            ldmr_index++;
            if(ldmr_index > 5) ldmr_index -= 5;
            ifm_param->mr_addr = fm_conv0_table_addr[ldmr_index];
            ifm_param->ddr_addr += (ifm_param->trans_len << 6);
            ldmr_set(ifm_param);
        }

        // prepare conv params for next conv
        conv_ifm_index += 2;
        if(conv_ifm_index > 5) conv_ifm_index -= 5;
        conv_param->ifm_addr0 = fm_conv0_table_addr[conv_ifm_index-1];
        conv_param->ifm_addr1 = fm_conv0_table_addr[conv_ifm_index];
        conv_param->ifm_addr2 = fm_conv0_table_addr[conv_ifm_index+1];
        conv_param->ofm_addr = fm_conv1_table_addr[1];
        conv_set(conv_param);

        if(conv_line != 0)
        {
            while(!svmr_check());
        }
        while(!intr_conv_act);
        intr_conv_act = 0;
        if(conv_line+6 < conv_fm_height)
        {
            while(!ldmr_check());
        }
    }

    // ==================================================================
    // pool last line
    // ==================================================================
    dwcalc_start();
    while(!intr_dwcalc_act);
    intr_dwcalc_act = 0;

    // ==================================================================
    // svmr last line
    // ==================================================================
    svmr_start();
    while(!svmr_check());

    // restore svmr/ldmr parameters
    ifm_param->reoder_en = 0;
    ifm_param->ddr_addr = ldmr_ddr_addr;
    ofm_param->ddr_addr = svmr_ddr_addr;
}

// variables
// pc_ldmr_param wt_dwc_param;
// pc_ldmr_param wt_conv_param;
// pc_ldmr_param bias_dwc_param;
// pc_ldmr_param bias_conv_param;
// pc_ldmr_param ifm_param;
// pc_conv_param right_a_param;
// pc_dwcalc_param right_b_param;
// pc_dtrans_param right_b_dt_param;
// pc_conv_param right_c_param;
// pc_dwcalc_param left_b_param;
// pc_dtrans_param left_b_dt_param;
// pc_conv_param left_c_param;
// pc_svmr_param ofm_param;
// int conv_fm_height;
// int conv_ch64;
// int conv_lb_pad_width;
// int conv_rb_pad_width;
// int conv_lb_fm_width;
// int conv_rb_fm_width;
void interlayer_conv_a()
{
    // save the svmr/ldmr parameters
    int ldmr_ddr_addr = ifm_param->ddr_addr;
    int svmr_ddr_addr = ofm_param->ddr_addr;
    int wt_ddr_addr = wt_conv_param->ddr_addr;
    int wt_mr_addr = wt_conv_param->mr_addr;

    // calc_phase: 0=ra[i] 1=ra[i+1] 2=rb[i] 3=rc[i]&lb[i] 4=lc[i], where i is current line num.
    int calc_phase = 0;
    int score_board[5] = {1, 1, 2, 3, 1};
    int ldmr_finish = 0;
    int i;
    // int last_ldmr_index = 0;

    // initialize variables
    ldmr_en = 0;
    ldmr_busy = 0;
    ldmr_line = 0;
    ldmr_index = 1;

    calc_en = 0;
    calc_busy = 0;
    calc_line = 0;
    calc_ifm_index = 1;
    calc_ofm_index = 1;

    svmr_en = 0;
    svmr_busy = 0;
    svmr_line = 0;
    svmr_index = 1;

    // set the initial parameters of methods

    // load weight data
    ldmr_set(wt_dwc_param);
    ldmr_start();
    while(!ldmr_check());

    if(conv_ch64)
    {
        for(i=0; i<8; i++)
        {
            ldmr_set(wt_conv_param);
            ldmr_start();
            wt_conv_param->ddr_addr += (wt_conv_param->trans_len << 6);
            wt_conv_param->mr_addr += 0x02000200;
            while(!ldmr_check());
        }
    }
    else
    {
        ldmr_set(wt_conv_param);
        ldmr_start();
        while(!ldmr_check());
    }

    // load bias data
    ldmr_set(bias_dwc_param);
    ldmr_start();
    while(!ldmr_check());

    ldmr_set(bias_conv_param);
    ldmr_start();
    while(!ldmr_check());

    // initialize ldmr
    ifm_param->mr_addr = fm_layer0_table_addr[1]; // + conv_lb_pad_width;
    ldmr_set(ifm_param);
    // initialize svmr
    ofm_param->mr_addr = fm_layer5_table_addr[1];
    svmr_set(ofm_param);
    // initialize conv
    right_a_param->ifm_addr0 = fm_layer0_table_addr[1]; // + conv_lb_pad_width;
    right_a_param->ofm_addr = fm_layer1_table_addr[1]; // + conv_rb_pad_width;
    conv_set(right_a_param);

    // Processing first row if no top padding
    if((conv_fm_height & 0x1) == 0)
    {
        // load 1st row
        ldmr_start();
        // set parameters for next command
        ldmr_index++;
        ifm_param->mr_addr = fm_layer0_table_addr[2];
        ifm_param->ddr_addr += (ifm_param->trans_len << 6);
        ldmr_set(ifm_param);
        while(!ldmr_check());
        ldmr_line++;
        // calc ra
        conv_start();
        // set parameters for next command
        right_a_param->ifm_addr0 = fm_layer0_table_addr[2]; // + conv_lb_pad_width;
        right_a_param->ofm_addr = fm_layer1_table_addr[2]; // + conv_rb_pad_width;
        conv_set(right_a_param);
        calc_ifm_index++;
        while(!intr_conv_act);
        intr_conv_act = 0;
        calc_line++;
        svmr_line++;
    }

    while(1)
    {
        // =====
        // Process 1: load 1 line of feature map
        if(ldmr_check())
        {
            ldmr_line++;
            ldmr_busy = 0;
            if(ldmr_line == conv_fm_height)
                ldmr_finish = 1;
            // // data transfer
            // left_b_dt_param->src_addr = fm_layer0_table_addr[last_ldmr_index] + conv_lb_fm_width;
            // left_b_dt_param->dest_addr = fm_layer0_table_addr[last_ldmr_index];
            // dtrans_set(left_b_dt_param);
            // dtrans_start();
            // while(!dtrans_check());
        }
        if((ldmr_line < calc_line + 5) && (ldmr_line < conv_fm_height))
        {
            ldmr_en = !ldmr_busy;
        }
        if(ldmr_en)
        {
            ldmr_busy = 1;
            ldmr_en = 0;
            ldmr_start();

            // set parameters for next command
            // last_ldmr_index = ldmr_index;
            ldmr_index++;
            if(ldmr_index > 6) ldmr_index -= 6;
            ifm_param->mr_addr = fm_layer0_table_addr[ldmr_index]; // + conv_lb_pad_width;
            ifm_param->ddr_addr += (ifm_param->trans_len << 6);
            ldmr_set(ifm_param);
        }

        // =====
        // Process 2: calculate feature map
        if( (!(score_board[calc_phase] & 0x00000001) || intr_conv_act)
        &&  (!(score_board[calc_phase] & 0x00000002) || intr_dwcalc_act) )
        {
            if(score_board[calc_phase] & 0x00000001)
            {
                intr_conv_act = 0;
            }
            if(score_board[calc_phase] & 0x00000002)
            {
                intr_dwcalc_act = 0;
            }
            if(calc_phase == 4)
            {
                calc_phase = 0;
                calc_line += 2;
            }
            else
            {
                calc_phase++;
            }
            calc_busy = 0;
        }
        if((calc_line < ldmr_line - 1 || ldmr_finish) && (calc_line < svmr_line + 4) && (calc_line < conv_fm_height))
        {
            calc_en = !calc_busy;
        }
        if(calc_en)
        {
            calc_busy = 1;
            calc_en = 0;
            if(calc_phase == 0)
            {
                conv_start();
                // set parameters for next command
                right_a_param->ifm_addr0 = fm_layer0_table_addr[calc_ifm_index+1]; // + conv_lb_pad_width;
                right_a_param->ofm_addr = fm_layer1_table_addr[calc_ifm_index+1]; // + conv_rb_pad_width;

                conv_set(right_a_param);
            }
            else if(calc_phase == 1)
            {
                conv_start();
                // set parameters for next command
                right_b_param->ifm_addr0 = fm_layer1_table_addr[calc_ifm_index-1];
                right_b_param->ifm_addr1 = fm_layer1_table_addr[calc_ifm_index];
                right_b_param->ifm_addr2 = fm_layer1_table_addr[calc_ifm_index+1];
                if(calc_line == 0)
                {
                    right_b_param->ifm_addr0 = 0x00003e00;
                }
                if(calc_line >= conv_fm_height -1)
                {
                    right_b_param->ifm_addr2 = 0x00003e00;
                }
                right_b_param->ofm_addr = fm_layer2_table_addr[0];
                // right_b_param->ofm_addr = fm_layer2_table_addr[0];
                dwcalc_set(right_b_param);
            }
            else if(calc_phase == 2)
            {
                // // data transfer
                // right_b_dt_param->src_addr = right_b_param->ifm_addr1 + conv_rb_fm_width;
                // right_b_dt_param->dest_addr = right_b_param->ifm_addr1;
                // dtrans_set(right_b_dt_param);
                // dtrans_start();
                // while(!dtrans_check());

                // right_b_dt_param->src_addr = right_b_param->ifm_addr2 + conv_rb_fm_width;
                // right_b_dt_param->dest_addr = right_b_param->ifm_addr2;
                // dtrans_set(right_b_dt_param);
                // dtrans_start();
                // while(!dtrans_check());

                dwcalc_start();
                // set parameters for next command
                right_c_param->ifm_addr0 = fm_layer2_table_addr[0];
                right_c_param->ofm_addr = fm_layer5_table_addr[calc_ofm_index];
                conv_set(right_c_param);
                left_b_param->ifm_addr0 = fm_layer0_table_addr[calc_ifm_index-1];
                left_b_param->ifm_addr1 = fm_layer0_table_addr[calc_ifm_index];
                left_b_param->ifm_addr2 = fm_layer0_table_addr[calc_ifm_index+1];
                if(calc_line == 0)
                {
                    left_b_param->ifm_addr0 = 0x00003e00;
                }
                if(calc_line >= conv_fm_height - 1)
                {
                    left_b_param->ifm_addr2 = 0x00003e00;
                }
                left_b_param->ofm_addr = fm_layer3_table_addr[0];
                // left_b_param->ofm_addr = fm_layer3_table_addr[0];
                dwcalc_set(left_b_param);
            }
            else if(calc_phase == 3)
            {
                conv_start();
                dwcalc_start();
                // set parameters for next command
                left_c_param->ifm_addr0 = fm_layer3_table_addr[0];
                left_c_param->ofm_addr = fm_layer5_table_addr[calc_ofm_index];
                conv_set(left_c_param);
            }
            else if(calc_phase == 4)
            {
                conv_start();
                // set parameters for next command
                calc_ifm_index += 2;
                if(calc_ifm_index > 6) calc_ifm_index -= 6;
                calc_ofm_index++;
                if(calc_ofm_index > 3) calc_ofm_index -= 3;
                right_a_param->ifm_addr0 = fm_layer0_table_addr[calc_ifm_index]; // + conv_lb_pad_width;
                right_a_param->ofm_addr = fm_layer1_table_addr[calc_ifm_index]; // + conv_rb_pad_width;
                conv_set(right_a_param);
            }
        }

        // =====
        // Process 3: save 1 line of output feature map
        if(svmr_check())
        {
            svmr_line += 2;
            if(svmr_line >= conv_fm_height)
            {
                break;
            }
            svmr_busy = 0;
        }
        if(svmr_line < calc_line)
        {
            svmr_en = !svmr_busy;
        }
        if(svmr_en)
        {
            svmr_busy = 1;
            svmr_en = 0;
            svmr_start();
            // set parameters for next command
            svmr_index++;
            if(svmr_index > 3) svmr_index -= 3;
            ofm_param->mr_addr = fm_layer5_table_addr[svmr_index];
            ofm_param->ddr_addr += (ofm_param->trans_len<<6);
            svmr_set(ofm_param);
        }
    }
    // restore svmr/ldmr parameters
    ifm_param->ddr_addr = ldmr_ddr_addr;
    ofm_param->ddr_addr = svmr_ddr_addr;
    wt_conv_param->ddr_addr = wt_ddr_addr;
    wt_conv_param->mr_addr = wt_mr_addr;
}

// variables
// pc_ldmr_param wt_dwc_param;
// pc_ldmr_param wt_conv_param;
// pc_ldmr_param bias_dwc_param;
// pc_ldmr_param bias_conv_param;
// pc_ldmr_param ifm_param;
// pc_conv_param right_a_param;
// pc_dwcalc_param right_b_param;
// pc_conv_param right_c_param;
// pc_dtrans_param left_dt_param;
// pc_svmr_param ofm_param;
// int conv_fm_height;
// int conv_ifm_offset;
// int conv_ch64;
void interlayer_conv_b()
{
    int i;
    // save the svmr/ldmr parameters
    int ldmr_ddr_addr = ifm_param->ddr_addr;
    int svmr_ddr_addr = ofm_param->ddr_addr;
    int wt_ddr_addr = wt_conv_param->ddr_addr;
    int wt_mr_addr = wt_conv_param->mr_addr;

    calc_line = 0;
    calc_ifm_index = 1;
    calc_ofm_index = 1;

    // initilize weight and bias
    // load weight data
    ldmr_set(wt_dwc_param);
    ldmr_start();

    if(conv_ch64)
    {
        for(i=0; i<8; i++)
        {
            ldmr_set(wt_conv_param);
            while(!ldmr_check());
            ldmr_start();
            wt_conv_param->ddr_addr += (wt_conv_param->trans_len << 6);
            wt_conv_param->mr_addr += 0x02000200;
        }
    }
    else
    {
        ldmr_set(wt_conv_param);
        while(!ldmr_check());
        ldmr_start();
    }

    // load bias data
    ldmr_set(bias_dwc_param);
    while(!ldmr_check());
    ldmr_start();

    ldmr_set(bias_conv_param);
    while(!ldmr_check());
    ldmr_start();

    // generated instruction stream
    // ==================================================================
    // load ifm 0
    // ==================================================================
    ifm_param->mr_addr = fm_cmdstream0_table_addr[1];
    ldmr_set(ifm_param);
    while(!ldmr_check());
    ldmr_start();

    // ==================================================================
    // calc right a and load ifm 1
    // ==================================================================
    ifm_param->ddr_addr += (ifm_param->trans_len << 6);
    ifm_param->mr_addr = fm_cmdstream0_table_addr[2];
    ldmr_set(ifm_param);

    right_a_param->ifm_addr0 = fm_cmdstream0_table_addr[1] + conv_ifm_offset;
    right_a_param->ofm_addr = fm_cmdstream1_table_addr[1];
    conv_set(right_a_param);

    while(!ldmr_check());
    ldmr_start();
    conv_start();

    // ==================================================================
    // calc right a
    // ==================================================================
    right_a_param->ifm_addr0 = fm_cmdstream0_table_addr[2] + conv_ifm_offset;
    right_a_param->ofm_addr = fm_cmdstream1_table_addr[2];
    conv_set(right_a_param);

    while(!ldmr_check());
    while(!intr_conv_act);
    intr_conv_act = 0;
    conv_start();

    // set parameters to load ifm [line+2] and calc right b
    ifm_param->ddr_addr += (ifm_param->trans_len << 6);
    ifm_param->mr_addr = fm_cmdstream0_table_addr[3];
    ldmr_set(ifm_param);

    right_b_param->ifm_addr0 = 0x3e003e00;
    right_b_param->ifm_addr1 = fm_cmdstream1_table_addr[1];
    right_b_param->ifm_addr2 = fm_cmdstream1_table_addr[2];
    dwcalc_set(right_b_param);

    while(!intr_conv_act);
    intr_conv_act = 0;
    calc_ifm_index = 3;
    calc_ofm_index = 1;

    for(calc_line = 0; calc_line < conv_fm_height; calc_line++)
    {
        // ==================================================================
        // load ifm [line+2] and calc right b [line]
        // ==================================================================
        if(calc_line < conv_fm_height-2)
            ldmr_start();
        dwcalc_start();

        // ==================================================================
        // calc right c [line]
        // ==================================================================
        conv_set(right_c_param);

        while(!intr_dwcalc_act);
        intr_dwcalc_act = 0;
        if(calc_line < conv_fm_height-2)
            while(!ldmr_check());
        conv_start();

        // ==================================================================
        // trans data [line]
        // ==================================================================
        left_dt_param->src_addr = fm_cmdstream0_table_addr[calc_ofm_index];
        dtrans_set(left_dt_param);

        while(!intr_conv_act);
        intr_conv_act = 0;
        dtrans_start();

        // ==================================================================
        // calc right a [line+2] and save [line]
        // ==================================================================
        right_a_param->ifm_addr0 = fm_cmdstream0_table_addr[calc_ifm_index] + conv_ifm_offset;
        right_a_param->ofm_addr = fm_cmdstream1_table_addr[calc_ifm_index];
        conv_set(right_a_param);

        svmr_set(ofm_param);
        ofm_param->ddr_addr += (ofm_param->trans_len << 6);

        while(!dtrans_check());
        if(calc_line < conv_fm_height-2)
            conv_start();
        svmr_start();

        // prepare parameters of next command
        calc_ifm_index++;
        if(calc_ifm_index > 3) calc_ifm_index = 1;
        ifm_param->ddr_addr += (ifm_param->trans_len << 6);
        ifm_param->mr_addr = fm_cmdstream0_table_addr[calc_ifm_index];
        ldmr_set(ifm_param);

        calc_ofm_index++;
        if(calc_ofm_index > 3) calc_ofm_index = 1;
        right_b_param->ifm_addr0 = fm_cmdstream1_table_addr[calc_ofm_index-1];
        right_b_param->ifm_addr1 = fm_cmdstream1_table_addr[calc_ofm_index];
        right_b_param->ifm_addr2 = fm_cmdstream1_table_addr[calc_ofm_index+1];
        if(calc_line == conv_fm_height-2) right_b_param->ifm_addr2 = 0x3e003e00;
        dwcalc_set(right_b_param);

        while(!svmr_check());
        if(calc_line < conv_fm_height-2)
        {
            while(!intr_conv_act);
            intr_conv_act = 0;
        }
    }
    // restore svmr/ldmr parameters
    ifm_param->ddr_addr = ldmr_ddr_addr;
    ofm_param->ddr_addr = svmr_ddr_addr;
    wt_conv_param->ddr_addr = wt_ddr_addr;
    wt_conv_param->mr_addr = wt_mr_addr;
}

// transform data format from ch8 to ch64
// pc_ldmr_param ifm_param;
// pc_svmr_param ofm_param;
// pc_ftrans_param ftrans_param;
// int conv_fm_height;
void trans_fmt()
{
    int i;
    // save the svmr/ldmr parameters
    int ldmr_ddr_addr = ifm_param->ddr_addr;
    int svmr_ddr_addr = ofm_param->ddr_addr;

    for(i = 0; i < conv_fm_height; i++)
    {
        // ldmr line
        ldmr_set(ifm_param);
        ldmr_start();
        ifm_param->ddr_addr += (ifm_param->trans_len << 6);
        while(!ldmr_check());

        // format translation
        ftrans_set(ftrans_param);
        ftrans_start();
        while(!ftrans_check());

        // svmr line
        svmr_set(ofm_param);
        svmr_start();
        ofm_param->ddr_addr += (ofm_param->trans_len << 6);
        while(!svmr_check());
    }
    // restore svmr/ldmr parameters
    ifm_param->ddr_addr = ldmr_ddr_addr;
    ofm_param->ddr_addr = svmr_ddr_addr;
}

// wt_conv_param = &g_convf_wt;
// bias_conv_param = &g_convf_bias;
// ifm_param = &g_convf_ifm;
// ofm_param = &g_convf_ofm;
// dtrans_param = &g_convf_dt;
// ftrans_param = &g_convf_ft;
// conv_param = &g_convf;
// conv_fm_height = g_convf_fm_height;
void convf()
{
    // save the svmr/ldmr parameters
    int ldmr_ddr_addr = ifm_param->ddr_addr;
    int svmr_ddr_addr = ofm_param->ddr_addr;

    calc_line = 0;
    calc_ifm_index = 1;

    // initilize weight, bias, and partial feature map
    // load weight data
    ldmr_set(wt_conv_param);
    ldmr_start();
    while(!ldmr_check());

    // load bias data
    ldmr_set(bias_conv_param);
    ldmr_start();
    while(!ldmr_check());

    // set width 20-24 of feature map as zeros
    dtrans_set(dtrans_param);
    dtrans_start();
    while(!dtrans_check());

    // load 1st line of feature map
    // load width 0-20 of feature map
    ldmr_set(ifm_param);
    ldmr_start();
    while(!ldmr_check());

    // transform the format of feature map, from ch64 mode to ch8 mode
    ftrans_param->dest_addr = fm_cmdstream1_table_addr[1];
    ftrans_set(ftrans_param);
    ftrans_start();
    while(!ftrans_check());

    // initialize parameters

    for(calc_line = 0; calc_line < conv_fm_height; calc_line++)
    {
        // load feature map
        if(calc_line < conv_fm_height-1)
        {
            // load 1 line of feature map
            ifm_param->ddr_addr += (ifm_param->trans_len << 6);
            ldmr_set(ifm_param);
            ldmr_start();
            while(!ldmr_check());

            // transform the format of feature map, from ch64 mode to ch8 mode
            ftrans_param->dest_addr = fm_cmdstream1_table_addr[calc_ifm_index+1]; // calc_ifm_index+1
            ftrans_set(ftrans_param);
            ftrans_start();
            while(!ftrans_check());
        }

        // make 3x3 convolution
        conv_param->ifm_addr0 = fm_cmdstream1_table_addr[calc_ifm_index-1];
        conv_param->ifm_addr1 = fm_cmdstream1_table_addr[calc_ifm_index];
        conv_param->ifm_addr2 = fm_cmdstream1_table_addr[calc_ifm_index+1];
        if(calc_line == 0) conv_param->ifm_addr0 = 0x3e003e00;
        if(calc_line == conv_fm_height-1) conv_param->ifm_addr2 = 0x3e003e00;
        conv_set(conv_param);
        conv_start();
        while(!intr_conv_act);
        intr_conv_act = 0;

        // save 1 line of feature map to ddr
        svmr_set(ofm_param);
        ofm_param->ddr_addr += (ofm_param->trans_len << 6);
        svmr_start();
        while(!svmr_check());

        // set next command
        calc_ifm_index++;
        if(calc_ifm_index>3) calc_ifm_index -= 3;
    }

    // restore the svmr/ldmr parameters
    ifm_param->ddr_addr = ldmr_ddr_addr;
    ofm_param->ddr_addr = svmr_ddr_addr;
}

void shufflenet_v2()
{
    int i;

    conv_ch64 = 0;
    if(PHASE_CONV1_IS_ACTIVE)
    {
        // CONV1 and Pool1
        wt_conv_param = &g_conv1_wt;
        bias_conv_param = &g_conv1_bias;
        ifm_param = &g_conv1_ifm;
        conv_param = &g_conv1;
        pool1_param = &g_pool1;
        ofm_param = &g_conv1_ofm;
        conv_fm_height = g_conv1_fm_height;
        conv1_pool1();
    }

    if(PHASE_BLK1_1_IS_ACTIVE)
    {
        // Blk1_1
        wt_dwc_param = &g_blk1_1_dwc_wt;
        wt_conv_param = &g_blk1_1_conv_wt;
        bias_dwc_param = &g_blk1_1_dwc_bias;
        bias_conv_param = &g_blk1_1_conv_bias;
        ifm_param = &g_blk1_1_ifm;
        ofm_param = &g_blk1_1_ofm;
        right_a_param = &g_blk1_1_ra;
        right_b_param = &g_blk1_1_rb;
        right_c_param = &g_blk1_1_rc;
        left_b_param = &g_blk1_1_lb;
        left_c_param = &g_blk1_1_lc;
        conv_fm_height = g_blk1_1_fm_height;
        interlayer_conv_a();
    }

    if(PHASE_BLK2_1_IS_ACTIVE)
    {
        // Blk2_x
        for(i=0; i<3; i++)
        {
            wt_dwc_param = &g_blk2_x_dwc_wt[i];
            wt_conv_param = &g_blk2_x_conv_wt[i];
            bias_dwc_param = &g_blk2_x_dwc_bias[i];
            bias_conv_param = &g_blk2_x_conv_bias[i];
            ifm_param = &g_blk2_x_ifm[i];
            ofm_param = &g_blk2_x_ofm[i];
            right_a_param = &g_blk2_x_ra[i];
            right_b_param = &g_blk2_x_rb[i];
            right_c_param = &g_blk2_x_rc[i];
            left_dt_param = &g_blk2_x_dt;
            conv_fm_height = g_blk2_x_fm_height;
            conv_ifm_offset = g_blk2_x_ifm_offset;
            interlayer_conv_b();
        }
    }

    if(PHASE_BLK3_1_IS_ACTIVE)
    {
        // Blk3_1
        wt_dwc_param = &g_blk3_1_dwc_wt;
        wt_conv_param = &g_blk3_1_conv_wt;
        bias_dwc_param = &g_blk3_1_dwc_bias;
        bias_conv_param = &g_blk3_1_conv_bias;
        ifm_param = &g_blk3_1_ifm;
        ofm_param = &g_blk3_1_ofm;
        right_a_param = &g_blk3_1_ra;
        right_b_param = &g_blk3_1_rb;
        right_c_param = &g_blk3_1_rc;
        left_b_param = &g_blk3_1_lb;
        left_c_param = &g_blk3_1_lc;
        conv_fm_height = g_blk3_1_fm_height;
        interlayer_conv_a();
    }

    if(PHASE_BLK4_1_IS_ACTIVE)
    {
        // Blk4_x
        for(i=0; i<7; i++)
        {
            wt_dwc_param = &g_blk4_x_dwc_wt[i];
            wt_conv_param = &g_blk4_x_conv_wt[i];
            bias_dwc_param = &g_blk4_x_dwc_bias[i];
            bias_conv_param = &g_blk4_x_conv_bias[i];
            ifm_param = &g_blk4_x_ifm[i];
            ofm_param = &g_blk4_x_ofm[i];
            right_a_param = &g_blk4_x_ra[i];
            right_b_param = &g_blk4_x_rb[i];
            right_c_param = &g_blk4_x_rc[i];
            left_dt_param = &g_blk4_x_dt;
            conv_fm_height = g_blk4_x_fm_height;
            conv_ifm_offset = g_blk4_x_ifm_offset;
            interlayer_conv_b();
        }
    }

    conv_ch64 = 1;
    if(PHASE_BLK5_1_IS_ACTIVE)
    {
        // transform data format from ch8 to ch64
        ifm_param = &g_fmtrans_ifm;
        ofm_param = &g_fmtrans_ofm;
        ftrans_param = &g_fmtrans;
        conv_fm_height = g_fmtrans_fm_height;
        trans_fmt();

        // Blk5_1
        wt_dwc_param = &g_blk5_1_dwc_wt;
        wt_conv_param = &g_blk5_1_conv_wt;
        bias_dwc_param = &g_blk5_1_dwc_bias;
        bias_conv_param = &g_blk5_1_conv_bias;
        ifm_param = &g_blk5_1_ifm;
        ofm_param = &g_blk5_1_ofm;
        right_a_param = &g_blk5_1_ra;
        right_b_param = &g_blk5_1_rb;
        right_c_param = &g_blk5_1_rc;
        left_b_param = &g_blk5_1_lb;
        left_c_param = &g_blk5_1_lc;
        conv_fm_height = g_blk5_1_fm_height;
        interlayer_conv_a();
    }

    if(PHASE_BLK6_1_IS_ACTIVE)
    {
        // Blk6_x
        for(i=0; i<9; i++)
        {
            wt_dwc_param = &g_blk6_x_dwc_wt[i];
            wt_conv_param = &g_blk6_x_conv_wt[i];
            bias_dwc_param = &g_blk6_x_dwc_bias[i];
            bias_conv_param = &g_blk6_x_conv_bias[i];
            ifm_param = &g_blk6_x_ifm[i];
            ofm_param = &g_blk6_x_ofm[i];
            right_a_param = &g_blk6_x_ra[i];
            right_b_param = &g_blk6_x_rb[i];
            right_c_param = &g_blk6_x_rc[i];
            left_dt_param = &g_blk6_x_dt;
            conv_fm_height = g_blk6_x_fm_height;
            conv_ifm_offset = g_blk6_x_ifm_offset;
            interlayer_conv_b();
        }
    }

    if(PHASE_CONVF_IS_ACTIVE)
    {
        // CONVF
        // 1st step: transform data format from ch64 to ch8
        // 2nd step: make conv preds operation
        wt_conv_param = &g_convf_wt;
        bias_conv_param = &g_convf_bias;
        ifm_param = &g_convf_ifm;
        ofm_param = &g_convf_ofm;
        dtrans_param = &g_convf_dt;
        ftrans_param = &g_convf_ft;
        conv_param = &g_convf;
        conv_fm_height = g_convf_fm_height;
        convf();
    }

    // upload calculation result from DDR to PS
    c_uplctrl_param g_upl_param = {DDR_B1_1_FM_ADDR, DDR_B1_1_FM_LEN*DDR_B1_1_FM_HEIGHT};
    uplctrl_set(&g_upl_param);
    uplctrl_start();
}
