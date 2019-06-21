// +FHDR------------------------------------------------------------------------
// Copyright ownership belongs to CAG laboratory, Institute of Artificial
// Intelligence and Robotics, Xi'an Jiaotong University, shall not be used in
// commercial ways without permission.
// -----------------------------------------------------------------------------
// FILE NAME  : main.c
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

c_dlctrl_param g_dlctrl_param = {
    DDR_CONV1_FM_ADDR,
    DDR_WT_BASE_ADDR,
    DDR_BS_BASE_ADDR
};

void main()
{
    // initial interrupt configure
    init_intr();

    // config input/weight/bias base address
    if(PHASE_CONV1_IS_ACTIVE)
        g_dlctrl_param.dlctrl_fm_ddr_base_addr = DDR_CONV1_FM_ADDR;
    else if(PHASE_BLK1_1_IS_ACTIVE)
        g_dlctrl_param.dlctrl_fm_ddr_base_addr = DDR_B1_1_FM_ADDR;
    else if(PHASE_BLK2_1_IS_ACTIVE)
        g_dlctrl_param.dlctrl_fm_ddr_base_addr = DDR_B2_1_FM_ADDR;
    else if(PHASE_BLK3_1_IS_ACTIVE)
        g_dlctrl_param.dlctrl_fm_ddr_base_addr = DDR_B3_1_FM_ADDR;
    else if(PHASE_BLK4_1_IS_ACTIVE)
        g_dlctrl_param.dlctrl_fm_ddr_base_addr = DDR_B4_1_FM_ADDR;
    else if(PHASE_BLK5_1_IS_ACTIVE)
        g_dlctrl_param.dlctrl_fm_ddr_base_addr = DDR_B5_1_FM_ADDR;
    else if(PHASE_BLK6_1_IS_ACTIVE)
        g_dlctrl_param.dlctrl_fm_ddr_base_addr = DDR_B6_1_FM_ADDR;
    else if(PHASE_CONVF_IS_ACTIVE)
        g_dlctrl_param.dlctrl_fm_ddr_base_addr = DDR_CONVF_FM_ADDR;

    dlctrl_set(&g_dlctrl_param);

    while (1)
    {
        // wait for start signal
        while(!intr_stcalc_act);
        intr_stcalc_act = 0;

        // invoke shufflenet
        shufflenet_v2();
        fshflg_ps();
        // upload result
        // ...
    }
}
