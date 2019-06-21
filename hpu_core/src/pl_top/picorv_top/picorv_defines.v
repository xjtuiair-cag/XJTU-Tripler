  // The ITCM size is 2^addr_width bytes, and ITCM is 8bits wide (1 bytes)

`define PICORV_ITCM_RAM_DW      8 // data width: 8 bit = 1 Byte
`define PICORV_ITCM_RAM_WW      32 // word width: 32 bit
`define PICORV_ITCM_RAM_AW      16 // RAM Size: 2^16 = 64K
`define PICORV_ITCM_RAM_SZ      1024*64 // Size: 2^16 = 64K Byte
`define PICORV_ITCM_RAM_MW      4

`define PICORV_DTCM_RAM_DW      8
`define PICORV_DTCM_RAM_WW      32
`define PICORV_DTCM_RAM_AW      16
`define PICORV_DTCM_RAM_SZ      1024*64
`define PICORV_DTCM_RAM_MW      4

`define PROGADDR_RESET          32'h0000_0000
`define PROGADDR_IRQ            32'h0000_0100
`define ITCM_START              32'h0000_0000 // 1MB
`define DTCM_START              32'h0010_0000
`define DPU_MAP_START           32'h2000_0000