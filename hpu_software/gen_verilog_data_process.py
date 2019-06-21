import numpy as np

itcm = []
dtcm = []
dtype = 'unknown'
add_zero_itcm_onece = 1
add_zero_dtcm_onece = 1
total_line_num = 0
total_num =0
#send packet number
packet_number = 640
#64 bit width
byte_str = "0000000000000000\n"
with open('./output/hpu.hex', 'rt') as infile:
    for line in infile:
        # judge data type
        # for i in range(len(dtcm)):
        #     total_num = total_num + len(dtcm[i])/2
        if line[0] == '@':
            addr = int(line[1 : ], 16)
            if addr < 0x80000000:
                dtype = 'unknown'
            elif addr >= 0x80000000 and addr < 0x90000000:
                dtype = 'code'
                #tmp = ("%08x\n") % ((addr - 0x80000000))
                #itcm.append('@' + tmp)
            elif addr >= 0x90000000:
                dtype = 'data'
                if ((addr - 0x90000000) > 0) :
                    print((total_num))
                    for i in range((addr - 0x90000000-total_num)):
                         dtcm.append("00")
                         total_num = total_num + 1
                #tmp = ("%08x\n") % ((addr - 0x90000000))
                #dtcm.append('@' +l tmp)
        else:
            line = line.replace(' ','')
            line = line.replace('\n','')
            line = line.replace('\r','')
            line = line.replace('\r\n', '')
            # line = line.strip('\n')
            #line = line.replace('\n','')
            #line = list(line)
            #for i in range(len(line)):
            #    if (i == 16 ) and len(line) >17 :
            #           line.insert(i,'\n')
            #line = "".join(line)
            if dtype == 'code':                        
                itcm.append(line)
            elif dtype == 'data':
                dtcm.append(line)
                total_num = total_num + (len(line) / 2)

with open('./output/1_itcm.verilog', 'wt') as outfile:
    itcm1 = "".join(itcm)
    itcm2 = itcm1.replace('\r\n', '')
    for i in range(len(itcm2)):
        if i % 16 == 0 and i != 0:
            outfile.write("\n")
            outfile.write(itcm2[i])
        else:
            outfile.write(itcm2[i])
with open('./output/1_itcm.verilog', 'r') as outfile:
    total_line_num = len(outfile.readlines())
    print(total_line_num)
with open('./output/1_itcm.verilog', 'a') as outfile:
    if (total_line_num % packet_number) < packet_number :
        outfile.write("\n")
        for i in range(packet_number-(total_line_num % packet_number)):
            outfile.write(byte_str)

with open('./output/1_dtcm.verilog', 'wt') as outfile:
    dtcm1 = "".join(dtcm)
    dtcm2 = dtcm1.replace('\r\n','')
    for i in range(len(dtcm2)):
        if i%16 == 0 and i != 0 :
            outfile.write("\n")
            outfile.write(dtcm2[i])
        else :
            outfile.write(dtcm2[i])
with open('./output/1_dtcm.verilog', 'r') as outfile:
    total_line_num = len(outfile.readlines())
    print(total_line_num)
with open('./output/1_dtcm.verilog', 'a') as outfile:
    if (total_line_num % packet_number)< packet_number :
        outfile.write("\n")
        for i in range(packet_number-(total_line_num % packet_number)):
            outfile.write(byte_str)

print("Transform is finished.")
