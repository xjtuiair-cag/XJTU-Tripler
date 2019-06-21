import numpy as np
import cv2
import os
from ctypes import *

class HpuLib:
    """
    The lib of HPU core.
    """
    def __init__(self, ps_if, ddr_base_addr):
        print('--------------------------------------------------------------------------------')
        print('Initialize the HPU core.')

        # Download HPU core to PL.
        self.ps_if = ps_if
        self.ddr_base_addr = ddr_base_addr

        # Parameters of hardware interface
        self.REG_I_ADDR = 18*16
        self.REG_D_ADDR = 17*16

        self.HPU_CTRL_ADDR = 32
        self.START_CONV_BIT = 0
        self.FETCH_EN_BIT   = 3
        self.I_INDICT_BIT   = 4
        self.D_INDICT_BIT   = 5

        self.REG_DDR_SHARE_TO_PL_W = 48
        self.REG_DDR_SHARE_TO_PL_R = 64

        # configure start address to HPU
        self.ps_if.write(self.REG_DDR_SHARE_TO_PL_W, ddr_base_addr.physical_address)

        self.addr_write2riscv_i = 0
        self.addr_write2riscv_d = 0

        # Base address of FM, weight, and bias on DDR
        self.DDR_WT_BASE_ADDR =  0x00000000
        self.DDR_BS_BASE_ADDR =  0x00300000
        self.DDR_FM_BASE_ADDR =  0x00350000
        self.image_size = 360*640*3

        # Distributions of feature map on DDR
        down_load_txt_image_ext = 0
        if  down_load_txt_image_ext  == 1:
            conv1_len = 80
        else:
            conv1_len = 30

        DDR_CONV1_FM_ADDR       =  self.DDR_FM_BASE_ADDR
        DDR_CONV1_FM_LEN        =  conv1_len
        DDR_CONV1_FM_HEIGHT     =  360
        DDR_B1_1_FM_ADDR        =  DDR_CONV1_FM_ADDR + (DDR_CONV1_FM_LEN << 6)*DDR_CONV1_FM_HEIGHT
        DDR_B1_1_FM_LEN         =  60
        DDR_B1_1_FM_HEIGHT      =  90
        DDR_B2_1_FM_ADDR        =  DDR_B1_1_FM_ADDR + (DDR_B1_1_FM_LEN << 6)*DDR_B1_1_FM_HEIGHT
        DDR_B2_1_FM_LEN         =  160
        DDR_B2_1_FM_HEIGHT      =  45
        DDR_B2_2_FM_ADDR        =  DDR_B2_1_FM_ADDR + (DDR_B2_1_FM_LEN << 6)*DDR_B2_1_FM_HEIGHT
        DDR_B2_2_FM_LEN         =  160
        DDR_B2_2_FM_HEIGHT      =  45
        DDR_B2_3_FM_ADDR        =  DDR_B2_2_FM_ADDR + (DDR_B2_2_FM_LEN << 6)*DDR_B2_2_FM_HEIGHT
        DDR_B2_3_FM_LEN         =  160
        DDR_B2_3_FM_HEIGHT      =  45
        DDR_B3_1_FM_ADDR        =  DDR_B2_3_FM_ADDR + (DDR_B2_3_FM_LEN << 6)*DDR_B2_3_FM_HEIGHT
        DDR_B3_1_FM_LEN         =  160
        DDR_B3_1_FM_HEIGHT      =  45
        DDR_B4_1_FM_ADDR        =  DDR_B3_1_FM_ADDR + (DDR_B3_1_FM_LEN << 6)*DDR_B3_1_FM_HEIGHT
        DDR_B4_1_FM_LEN         =  160
        DDR_B4_1_FM_HEIGHT      =  23
        DDR_B4_2_FM_ADDR        =  DDR_B4_1_FM_ADDR + (DDR_B4_1_FM_LEN << 6)*DDR_B4_1_FM_HEIGHT
        DDR_B4_2_FM_LEN         =  160
        DDR_B4_2_FM_HEIGHT      =  23
        DDR_B4_3_FM_ADDR        =  DDR_B4_2_FM_ADDR + (DDR_B4_2_FM_LEN << 6)*DDR_B4_2_FM_HEIGHT
        DDR_B4_3_FM_LEN         =  160
        DDR_B4_3_FM_HEIGHT      =  23
        DDR_B4_4_FM_ADDR        =  DDR_B4_3_FM_ADDR + (DDR_B4_3_FM_LEN << 6)*DDR_B4_3_FM_HEIGHT
        DDR_B4_4_FM_LEN         =  160
        DDR_B4_4_FM_HEIGHT      =  23
        DDR_B4_5_FM_ADDR        =  DDR_B4_4_FM_ADDR + (DDR_B4_4_FM_LEN << 6)*DDR_B4_4_FM_HEIGHT
        DDR_B4_5_FM_LEN         =  160
        DDR_B4_5_FM_HEIGHT      =  23
        DDR_B4_6_FM_ADDR        =  DDR_B4_5_FM_ADDR + (DDR_B4_5_FM_LEN << 6)*DDR_B4_5_FM_HEIGHT
        DDR_B4_6_FM_LEN         =  160
        DDR_B4_6_FM_HEIGHT      =  23
        DDR_B4_7_FM_ADDR        =  DDR_B4_6_FM_ADDR + (DDR_B4_6_FM_LEN << 6)*DDR_B4_6_FM_HEIGHT
        DDR_B4_7_FM_LEN         =  160
        DDR_B4_7_FM_HEIGHT      =  23
        DDR_B5_1_FM_ADDR        =  DDR_B4_7_FM_ADDR + (DDR_B4_7_FM_LEN << 6)*DDR_B4_7_FM_HEIGHT
        DDR_B5_1_FM_LEN         =  160
        DDR_B5_1_FM_HEIGHT      =  23
        DDR_B6_1_FM_ADDR        =  DDR_B5_1_FM_ADDR + (DDR_B5_1_FM_LEN << 6)*DDR_B5_1_FM_HEIGHT
        DDR_B6_1_FM_LEN         =  160
        DDR_B6_1_FM_HEIGHT      =  12
        DDR_B6_2_FM_ADDR        =  DDR_B6_1_FM_ADDR + (DDR_B6_1_FM_LEN << 6)*DDR_B6_1_FM_HEIGHT
        DDR_B6_2_FM_LEN         =  160
        DDR_B6_2_FM_HEIGHT      =  12
        DDR_B6_3_FM_ADDR        =  DDR_B6_2_FM_ADDR + (DDR_B6_2_FM_LEN << 6)*DDR_B6_2_FM_HEIGHT
        DDR_B6_3_FM_LEN         =  160
        DDR_B6_3_FM_HEIGHT      =  12
        DDR_B6_4_FM_ADDR        =  DDR_B6_3_FM_ADDR + (DDR_B6_3_FM_LEN << 6)*DDR_B6_3_FM_HEIGHT
        DDR_B6_4_FM_LEN         =  160
        DDR_B6_4_FM_HEIGHT      =  12
        DDR_B6_5_FM_ADDR        =  DDR_B6_4_FM_ADDR + (DDR_B6_4_FM_LEN << 6)*DDR_B6_4_FM_HEIGHT
        DDR_B6_5_FM_LEN         =  160
        DDR_B6_5_FM_HEIGHT      =  12
        DDR_B6_6_FM_ADDR        =  DDR_B6_5_FM_ADDR + (DDR_B6_5_FM_LEN << 6)*DDR_B6_5_FM_HEIGHT
        DDR_B6_6_FM_LEN         =  160
        DDR_B6_6_FM_HEIGHT      =  12
        DDR_B6_7_FM_ADDR        =  DDR_B6_6_FM_ADDR + (DDR_B6_6_FM_LEN << 6)*DDR_B6_6_FM_HEIGHT
        DDR_B6_7_FM_LEN         =  160
        DDR_B6_7_FM_HEIGHT      =  12
        DDR_B6_8_FM_ADDR        =  DDR_B6_7_FM_ADDR + (DDR_B6_7_FM_LEN << 6)*DDR_B6_7_FM_HEIGHT
        DDR_B6_8_FM_LEN         =  160
        DDR_B6_8_FM_HEIGHT      =  12
        DDR_B6_9_FM_ADDR        =  DDR_B6_8_FM_ADDR + (DDR_B6_8_FM_LEN << 6)*DDR_B6_8_FM_HEIGHT
        DDR_B6_9_FM_LEN         =  160
        DDR_B6_9_FM_HEIGHT      =  12
        DDR_CONVF_FM_ADDR       = DDR_B6_9_FM_ADDR + (DDR_B6_9_FM_LEN << 6)*DDR_B6_9_FM_HEIGHT
        DDR_CONVF_FM_LEN        = 160
        DDR_CONVF_FM_HEIGHT     = 12
        self.DDR_OUTPUT_FM_ADDR      =  DDR_CONVF_FM_ADDR + (DDR_CONVF_FM_LEN << 6)*DDR_CONVF_FM_HEIGHT
        self.DDR_OUTPUT_FM_LEN       =  18
        self.DDR_OUTPUT_FM_HEIGHT    =  12
        print('[INFO] This Neural Network allocates %f MB space on DDR.' % ((self.DDR_OUTPUT_FM_ADDR + (self.DDR_OUTPUT_FM_LEN << 6)*self.DDR_OUTPUT_FM_HEIGHT)/1024./1024))

        # initialize calculation parameters of last layer in Python
        # set block center(x,y)
        # self.org_xy = np.array([[(15+x*30,16+y*32) for y in range(20)] for x in range(12)])
        self.org_xy = np.array([[(x * (640.0 / 21), y * (360.0 / 13)) for x in range(1, 21)] for y in range(1, 13)])
        # set anchor size
        self.org_wh = np.array( [[229., 137.], [48., 71.], [289., 245.], [185., 134.], [85., 142.], [31., 41.], [197., 191.], [237., 206.], [63., 108.]])

        self.H0 = 12  # height
        self.W_full = 24  # width
        self.Wgroups = 8
        self.Wpergroup = 3
        self.C_full = 48  # channels in ddr
        self.Cgroups = 6
        self.Cpergroup = 8
        self.C = 45  # channels of test.txt
        self.Confid = np.zeros([self.H0, self.W_full, 9])  # make a np to save Confidence
        self.OrgDxywh = np.zeros([self.H0, self.W_full, 36])  # make a np to save dx,dy,dh,dw

        # parameters for calculating last layer in C language
        self.W_VALID = 20
        self.H_VALID = 12
        self.IMG_H = 360
        self.IMG_W = 640
        self.ANCHORS_PER_GRID = 9
        self.ANCHOR_SHAPE = [229., 137., 48., 71., 289., 245.,
                             185., 134., 85., 142., 31., 41.,
                             197., 191., 237., 206., 63., 108.]
        self.anchors = None
        self.lib = None
        self.last_layer_result = None
        self.bbox = None

        self.init_last_layer_calc()

        print('HPU core is initialized successfuly.')


    def write_byte(self, addr, data):
        self.ps_if.write(addr, data)

    def read_byte(self, addr):
        data = self.ps_if.read(addr)
        return data

    def set_reg(self, addr, bitn):
        data = self.read_byte(addr)
        data = ((1 << bitn) & 0xff) | data
        self.write_byte(addr, data)

    def clr_reg(self, addr, bitn):
        data = self.read_byte(addr)
        data = ((~1 << bitn) & 0xff) & data
        self.write_byte(addr, data)

    def read_bit(self, addr, bitn):
        data = self.read_byte(addr)
        data = (data & (1 << bitn))
        return data


    def exchange_postion_hexstr16_w2x32bit(self, hexstr, bus_reg_addr):
        new_hexstr1 = hexstr[0 :8] # first 32 bit
        new_hexstr2 = hexstr[8:16] # second 32 bit
        tmp_str = new_hexstr1

        self.exchange_postion_hexstr8_w32bit(tmp_str,bus_reg_addr)

        tmp_str = new_hexstr2
        self.exchange_postion_hexstr8_w32bit(tmp_str,bus_reg_addr)


    def exchange_postion_hexstr8_w32bit(self, hexstr, bus_reg_addr):
        new_hexstr = hexstr[0:8]
        tmp_str = new_hexstr

        str3 = tmp_str[6:8] + tmp_str[4:6] + tmp_str[2:4] + tmp_str[0:2] # exchage postion
        hex_num = int(str3,16) # str hex  to number hex
        self.ps_if.write(bus_reg_addr,hex_num) # write to bus


    def extend_zeros(self, string , target_lengh): # pad 0 after string
        lengh = len(string)
        new_string = string+(target_lengh-lengh)*'0'
        return new_string


    def write2riscv_i_pad_16384(self):# because the itcm is  [2047:0]64 bit =8B  -> 2048 * 8B = 16384
        for_num = int((16384 - self.addr_write2riscv_i)/4)
        for i in range(for_num):
            self.exchange_postion_hexstr8_w32bit(8*'0',self.REG_I_ADDR)
            self.addr_write2riscv_i = self.addr_write2riscv_i + 4


    def write2riscv_i(self, line):
        if line[0] == '@':
            line_num_az = filter(str.isalnum, line[1:])
            new_line = ''.join(list(line_num_az))
            hex_num_addr = int(new_line,16)
            for_num = int((hex_num_addr - self.addr_write2riscv_i)/4)
            for i in range(for_num):
                self.exchange_postion_hexstr8_w32bit(8*'0',self.REG_I_ADDR)
                self.addr_write2riscv_i = self.addr_write2riscv_i + 4
        else:
            line_num_az = filter(str.isalnum, line)
            new_line = ''.join(list(line_num_az))
            lengh = len(new_line)
            if(lengh == 32):
                tmp_str1 = new_line[0:16]
                tmp_str2 = new_line[16:32]
                self.exchange_postion_hexstr16_w2x32bit(tmp_str1,self.REG_I_ADDR)
                self.exchange_postion_hexstr16_w2x32bit(tmp_str2,self.REG_I_ADDR)
                self.addr_write2riscv_i = self.addr_write2riscv_i + 16

            elif(lengh == 24):
                tmp_str1 = new_line[0:16]
                tmp_str2 = new_line[16:24]
                self.exchange_postion_hexstr16_w2x32bit(tmp_str1, self.REG_I_ADDR)
                self.exchange_postion_hexstr8_w32bit(tmp_str2, self.REG_I_ADDR)
                self.addr_write2riscv_i = self.addr_write2riscv_i + 12

            elif(lengh == 16):
                self.exchange_postion_hexstr16_w2x32bit(new_line, self.REG_I_ADDR)
                self.addr_write2riscv_i = self.addr_write2riscv_i + 8

            elif(lengh == 8):
                self.exchange_postion_hexstr8_w32bit(new_line, self.REG_I_ADDR)
                self.addr_write2riscv_i = self.addr_write2riscv_i + 4

            else:
                print('data lengh do no match! can not write')


    def write2riscv_d_pad_8192(self):# because the dtcm is  [2047:0]32 bit =4B  -> 2048 * 4B
        for_num = int((8192 - self.addr_write2riscv_d)/4)
        for i in range(for_num):
            self.exchange_postion_hexstr8_w32bit(8*'0', self.REG_D_ADDR)
            self.addr_write2riscv_d = self.addr_write2riscv_d + 4


    def write2riscv_d(self, line):
        if line[0] == '@':
            line_num_az = filter(str.isalnum, line[1:])
            new_line = ''.join(list(line_num_az))
            hex_num_addr = int(new_line,16)
            for_num = int((hex_num_addr - self.addr_write2riscv_d)/4)
            for i in range(for_num):
                self.exchange_postion_hexstr8_w32bit(8*'0', self.REG_D_ADDR)
                self.addr_write2riscv_d = self.addr_write2riscv_d + 4
        else:
            line_num_az = filter(str.isalnum, line)
            new_line = ''.join(list(line_num_az))
            lengh = len(new_line)
            if(lengh == 32):
                tmp_str1 = new_line[0:16]
                tmp_str2 = new_line[16:32]
                self.exchange_postion_hexstr16_w2x32bit(tmp_str1, self.REG_D_ADDR)
                self.exchange_postion_hexstr16_w2x32bit(tmp_str2, self.REG_D_ADDR)
                self.addr_write2riscv_d = self.addr_write2riscv_d + 16

            elif(lengh == 24):
                tmp_str1 = new_line[0:16]
                tmp_str2 = new_line[16:24]
                self.exchange_postion_hexstr16_w2x32bit(tmp_str1, self.REG_D_ADDR)
                self.exchange_postion_hexstr8_w32bit(tmp_str2, self.REG_D_ADDR)
                self.addr_write2riscv_d = self.addr_write2riscv_d + 12

            elif(lengh == 16):
                self.exchange_postion_hexstr16_w2x32bit(new_line,self.REG_D_ADDR)
                self.addr_write2riscv_d = self.addr_write2riscv_d + 8

            elif(lengh == 8):
                self.exchange_postion_hexstr8_w32bit(new_line, self.REG_D_ADDR)
                self.addr_write2riscv_d = self.addr_write2riscv_d + 4
            else:
                print('data lengh do no match! can not write')


    def load_weight(self, file_path):
        """
        Load weight data to DDR.
        """
        print('--------------------------------------------------------------------------------')
        print('Start to load weight.')
        count = len(open(file_path, 'rU').readlines())

        file_wt = open(file_path)
        wt_nparray = np.zeros([count, 8], dtype=np.uint8)

        cnt_line = count
        cnt = 0
        print('[INFO] The size of weight is %f MB.' % (cnt_line * 8. /1024/1024))

        while cnt < cnt_line:
            line = file_wt.readline()
            wt_nparray[cnt, 7] = int(line[14:16], 16)
            wt_nparray[cnt, 6] = int(line[12:14], 16)
            wt_nparray[cnt, 5] = int(line[10:12], 16)
            wt_nparray[cnt, 4] = int(line[8:10], 16)
            wt_nparray[cnt, 3] = int(line[6: 8], 16)
            wt_nparray[cnt, 2] = int(line[4: 6], 16)
            wt_nparray[cnt, 1] = int(line[2: 4], 16)
            wt_nparray[cnt, 0] = int(line[0: 2], 16)
            new_s = line[14:16] + line[12:14] + line[10:12] + line[8:10] + line[6:8] + line[4:6] + line[2:4] + line[0:2]
            if not line:
                break
            if cnt % 3184 == 0:
                if cnt == 0:
                    print('[>', end='')
                else:
                    print('>', end='')
            cnt = cnt + 1
        print(']')
        file_wt.close()

        wt_np_f = wt_nparray.flatten()
        wt_len = len(wt_np_f)
        wt_s = self.DDR_WT_BASE_ADDR
        wt_e = self.DDR_WT_BASE_ADDR + wt_len
        self.ddr_base_addr[wt_s : wt_e] = wt_np_f
        print('Weight is loaded successfully.')


    def load_bias(self, file_path):
        """
        Load bias data to DDR.
        """
        print('--------------------------------------------------------------------------------')
        print('Start to load bias.')
        count = len(open(file_path,'rU').readlines())

        file_bs = open(file_path)
        bs_nparray = np.zeros([count,8],dtype=np.uint8)

        cnt_line = count
        cnt = 0
        print('[INFO] The size of bias is %f KB.' % (cnt_line * 8. /1024))

        while cnt < cnt_line:
            line = file_bs.readline()
            bs_nparray[cnt,7] = int(line[14:16],16)
            bs_nparray[cnt,6] = int(line[12:14],16)
            bs_nparray[cnt,5] = int(line[10:12],16)
            bs_nparray[cnt,4] = int(line[8 :10],16)
            bs_nparray[cnt,3] = int(line[6 : 8],16)
            bs_nparray[cnt,2] = int(line[4 : 6],16)
            bs_nparray[cnt,1] = int(line[2 : 4],16)
            bs_nparray[cnt,0] = int(line[0 : 2],16)
            new_s = line[14:16] + line[12:14] + line[10:12] + line[8:10] + line[6:8] + line[4:6] + line[2:4] + line[0:2]
            if not line:
                break
            cnt = cnt+1
        file_bs.close()

        bs_np_f = bs_nparray.flatten()
        bs_len = len(bs_np_f)
        bs_s = self.DDR_BS_BASE_ADDR
        bs_e = self.DDR_BS_BASE_ADDR + bs_len
        self.ddr_base_addr[bs_s:bs_e] = bs_np_f
        print('Bias is loaded successfully.')


    def load_riscv_code_sect(self, file_path):
        """
        Load code sector of RISC-V core to HPU
        :param file_path: file path to RISC-V code
        :return:
        """
        print('--------------------------------------------------------------------------------')
        print('Start to load RISC-V code section.')
        count = len(open(file_path, 'rU').readlines())
        file_i = open(file_path)

        cnt_line = count

        #initialize transfer interfaces
        self.addr_write2riscv_i = 0
        self.ps_if.write(2 * 16, 0x10)  # enable instruction transfer
        cnt = 0
        print('[INFO] The size of RISC-V code section is %f KB.' % (cnt_line * 8. /1024))

        while cnt < cnt_line:
            line = file_i.readline()
            if not line:
                break
            self.write2riscv_i(line)
            cnt = cnt + 1
        file_i.close()
        self.write2riscv_i_pad_16384()
        self.ps_if.write(2 * 16, 0) # restore transfer type
        print('RISC-V code section is loaded successfully.')


    def load_riscv_data_sect(self, file_path):
        """
        Load data sector of RISC-V core to HPU
        :param file_path: file path to RISC-V code
        :return:
        """
        print('--------------------------------------------------------------------------------')
        print('Start to load RISC-V data section.')
        count = len(open(file_path, 'rU').readlines())
        file_d = open(file_path)

        cnt_line = count

        # initialize transfer interface
        self.addr_write2riscv_d = 0
        self.ps_if.write(2 * 16, 0x20)  # enable data transfer
        cnt = 0
        print('[INFO] The size of RISC-V data section is %f KB.' % (cnt_line *8. /1024))

        while cnt < cnt_line:
            line = file_d.readline()
            if not line:
                break
            self.write2riscv_d(line)
            cnt = cnt + 1
        file_d.close()
        self.write2riscv_d_pad_8192()
        self.ps_if.write(2 * 16, 0) # restore tranfer type
        print('RISC-V data section is loaded successfully.')


    def start_hpu(self):
        """
        Start HPU core.
        :return:
        """
        self.clr_reg(self.HPU_CTRL_ADDR, self.START_CONV_BIT)
        self.clr_reg(self.HPU_CTRL_ADDR, self.FETCH_EN_BIT)
        self.set_reg(self.HPU_CTRL_ADDR, self.FETCH_EN_BIT)
        self.read_bit(self.HPU_CTRL_ADDR, self.FETCH_EN_BIT)


    def shufflenet_v2(self, pre_load_image_path, pre_load_image_en='False'):
        """
        Function description: invoke shufflenet V2 operation
        input:
           pre_load_image_path: the path of next image.
           pre_load_image_en: whether enable the function that pre load next image data
                              from SD card, when calculating the current image.
        output:
           {Xmin, Xmax, Ymin, Ymax}: The predicting box of current image.
        """
        # calculate the Convolution layers of shufflenet V2.
        self.set_reg(self.HPU_CTRL_ADDR, self.START_CONV_BIT)
        self.clr_reg(self.HPU_CTRL_ADDR, self.START_CONV_BIT)

        # pre-load the next image if enable
        global bgr_array
        if pre_load_image_en:
            bgr_array = cv2.imread(pre_load_image_path)
        # waiting for the finish signal of current calculation
        self.shufflenet_v2_wait()

        # calculate the last layer of shufflenet V2.
        convf = self.ddr_base_addr[ self.DDR_OUTPUT_FM_ADDR: self.DDR_OUTPUT_FM_ADDR + self.DDR_OUTPUT_FM_LEN * self.DDR_OUTPUT_FM_HEIGHT * 64].copy()
        OrgConvf = convf.reshape(self.H0, self.Wpergroup, self.Cgroups, self.Wgroups, self.Cpergroup)  # cnvert input to a suitable np  ,C=45
        OrgOutConvf = OrgConvf.transpose(0, 3, 1, 2, 4)
        OrgOut = OrgOutConvf.reshape(self.H0, self.W_full, self.C_full)
        Confid = OrgOut[:, 0:20, 0:9]  # set confidence np
        OrgDxywh = OrgOut[:, :, 9:45]  # set (dx,dy,dh,dw) np
        Dxywh = OrgDxywh.reshape(self.H0, self.W_full, 9, 4)  # use Dxywh to represent the (dx,dy,dh,dw) of each anchor

        maxindex = Confid.flatten().argsort()[-1]

        Hindex = maxindex // (20 * 9)
        maxindex -= Hindex * 20 * 9
        Windex = maxindex // 9
        anchorindex = maxindex - Windex * 9

        [Xhwk, Yhwk] = self.org_xy[Hindex, Windex]  # get the center (x,y) of the block weget according to the maxindex
        [Whwk, Hhwk] = self.org_wh[anchorindex]  # get the anchor-size of the anchor we get according to the maxindex
        [dx, dy, dw, dh] = Dxywh[Hindex, Windex, anchorindex,] / 8.  # Divided by a coefficient"4" to get (dx,dy,dw,dh)

        X = Xhwk + Whwk * dx
        Y = Yhwk + Hhwk * dy  # the center(x,y) of the baouning box
        W = Whwk * np.exp(dw) if dw <= 1.0 else Whwk * dw * 2.71828  # the width of the bounding box
        H = Hhwk * np.exp(dh) if dh <= 1.0 else Hhwk * dh * 2.71828  # the hight of the bounding box

        Xmin = max(0, int(X - W / 2))  # Min of the horizontal axis
        Xmax = min(639, int(X + W / 2))  # Max of the horizontal axis
        Ymin = max(0, int(Y - H / 2))  # Min of the vertical axis
        Ymax = min(359, int(Y + H / 2))  # Max of the vertical axis（output should be int)
        return Xmin, Xmax, Ymin, Ymax


    # waiting for the calculation of CONV
    def shufflenet_v2_wait(self):
        while self.ps_if.read(80) == 0x0:
            pass
        self.ps_if.write(80, 0x01)


    # Read input image
    def shufflenet_v2_read_image(self, image_path):
        self.bgr_array = cv2.imread(image_path)
        # self.bgr_array = np.array(Image.open(get_image_path(image_path)).convert('RGB'))


    # Move image to DDR, and start convolution operation
    def shufflenet_v2_start_conv(self):
        # load image to DDR
        self.ddr_base_addr[self.DDR_FM_BASE_ADDR : self.DDR_FM_BASE_ADDR + self.image_size] = self.bgr_array.flatten()
        # calculate the Convolution layers of shufflenet V2.
        self.set_reg(self.HPU_CTRL_ADDR, self.START_CONV_BIT)
        self.clr_reg(self.HPU_CTRL_ADDR, self.START_CONV_BIT)


    # Calcualte prediction box
    def shufflenet_v2_last_layer(self):
        # calculate the last layer of shufflenet V2.
        convf = self.ddr_base_addr[self.DDR_OUTPUT_FM_ADDR : self.DDR_OUTPUT_FM_ADDR + self.DDR_OUTPUT_FM_LEN * self.DDR_OUTPUT_FM_HEIGHT * 64].copy()
        OrgConvf = convf.reshape(self.H0, self.Wpergroup, self.Cgroups, self.Wgroups, self.Cpergroup)  # cnvert input to a suitable np  ,C=45
        OrgOutConvf = OrgConvf.transpose(0, 3, 1, 2, 4)
        OrgOut = OrgOutConvf.reshape(self.H0, self.W_full, self.C_full)
        Confid = OrgOut[:, 0:20, 0:9]  # set confidence np
        OrgDxywh = OrgOut[:, :, 9:45]  # set (dx,dy,dh,dw) np
        Dxywh = OrgDxywh.reshape(self.H0, self.W_full, 9, 4)  # use Dxywh to represent the (dx,dy,dh,dw) of each anchor

        #maxindex = Confid.flatten().argsort()[-1]
        Confid_flt = Confid.flatten()
        max_index_list = np.where(Confid_flt==np.max(Confid_flt))
        maxindex = np.max(max_index_list)

        Hindex = maxindex // (20 * 9)
        maxindex -= Hindex * 20 * 9
        Windex = maxindex // 9
        anchorindex = maxindex - Windex * 9

        [Xhwk, Yhwk] = self.org_xy[Hindex, Windex]  # get the center (x,y) of the block weget according to the maxindex
        [Whwk, Hhwk] = self.org_wh[anchorindex]  # get the anchor-size of the anchor we get according to the maxindex
        [dx, dy, dw, dh] = Dxywh[Hindex, Windex, anchorindex,] / 8.  # Divided by a coefficient"4" to get (dx,dy,dw,dh)

        X = Xhwk + Whwk * dx
        Y = Yhwk + Hhwk * dy  # the center(x,y) of the baouning box
        W = Whwk * np.exp(dw) if dw <= 1.0 else Whwk * dw * 2.71828  # the width of the bounding box
        H = Hhwk * np.exp(dh) if dh <= 1.0 else Hhwk * dh * 2.71828  # the hight of the bounding box

        Xmin = max(0, int(X - W / 2))  # Min of the horizontal axis
        Xmax = min(639, int(X + W / 2))  # Max of the horizontal axis
        Ymin = max(0, int(Y - H / 2))  # Min of the vertical axis
        Ymax = min(359, int(Y + H / 2))  # Max of the vertical axis（output should be int)
        return Xmin, Xmax, Ymin, Ymax


    def prepare_anchors(self, anchor_shape, input_w, input_h, convout_w, convout_h,
                        anchors_per_grid):
        center_x = np.zeros(convout_w, dtype=np.float32)
        center_y = np.zeros(convout_h, dtype=np.float32)
        anchors = np.zeros(convout_h * convout_w * anchors_per_grid * 4, dtype=np.float32)

        for i in range(convout_w):
            center_x[i] = (i + 1) * input_w / (convout_w + 1.0)
        for i in range(convout_h):
            center_y[i] = (i + 1) * input_h / (convout_h + 1.0)

        h_vol = convout_w * anchors_per_grid * 4
        w_vol = anchors_per_grid * 4
        b_vol = 4
        for i in range(convout_h):
            for j in range(convout_w):
                for k in range(anchors_per_grid):
                    anchors[i * h_vol + j * w_vol + k * b_vol] = center_x[j]
                    anchors[i * h_vol + j * w_vol + k * b_vol + 1] = center_y[i]
                    anchors[i * h_vol + j * w_vol + k * b_vol + 2] = anchor_shape[k * 2]
                    anchors[i * h_vol + j * w_vol + k * b_vol + 3] = anchor_shape[k * 2 + 1]

        return anchors


    def init_last_layer_calc(self):
        self.anchors = self.prepare_anchors(self.ANCHOR_SHAPE, self.IMG_W, self.IMG_H, self.W_VALID, self.H_VALID, self.ANCHORS_PER_GRID)
        if not os.path.exists('./libgen_bbox_hpu.so'):
            os.system("gcc -Wall -std=c99 -fPIC -shared -O2 -Wno-unused-result gen_bbox_hpu.c -o libgen_bbox_hpu.so -lm")
        self.lib = CDLL("./libgen_bbox_hpu.so")
        self.lib.gbd_preprocess()
        self.last_layer_result = (c_float * 4)()


    def shufflenet_v2_last_layer_in_c(self):
        feature = self.ddr_base_addr[self.DDR_OUTPUT_FM_ADDR : self.DDR_OUTPUT_FM_ADDR + self.DDR_OUTPUT_FM_LEN * self.DDR_OUTPUT_FM_HEIGHT * 64].copy()
        self.lib.gbd_getbbox( feature.ctypes.data_as(c_void_p),
                              self.anchors.ctypes.data_as(c_void_p),
                              self.last_layer_result )
        Xmin = int(self.last_layer_result[0])
        Xmax = int(self.last_layer_result[1])
        Ymin = int(self.last_layer_result[2])
        Ymax = int(self.last_layer_result[3])
        return Xmin, Xmax, Ymin, Ymax

