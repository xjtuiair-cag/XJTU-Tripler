import numpy as np

itcm = []
dtcm = []
dtype = 'unknown'

with open('./output/hpu.hex', 'rt') as infile:
    for line in infile:
        # judge data type
        if line[0] == '@':
            addr = int(line[1 : ], 16)
            if addr >= 0x00200000:
                dtype = 'unknown'
            elif addr >= 0x00000000 and addr < 0x00100000:
                dtype = 'code'
                tmp = ("%08x\n") % (addr - 0x00000000)
                itcm.append('@' + tmp)
            elif addr >= 0x00100000 and addr < 0x00200000:
                dtype = 'data'
                tmp = ("%08x\n") % (addr - 0x00100000)
                dtcm.append('@' + tmp)
        else:
            if dtype == 'code':
                itcm.append(line)
            elif dtype == 'data':
                dtcm.append(line)

with open('./output/1_itcm.verilog', 'wt') as outfile:
    for line in itcm:
        outfile.write(line)

with open('./output/1_dtcm.verilog', 'wt') as outfile:
    for line in dtcm:
        outfile.write(line)

print("Transform is finished.")
