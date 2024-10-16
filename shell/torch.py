#########################################################################
#  -*- coding:utf-8 -*-  
#  File Name: torch.py
#  Author: Charles
#########################################################################
import torch
flag = torch.cuda.is_available()

if flag:
   print("CUDA可使用")
else:
   print("CUDA不可用")

ngpu= 1
# Decide which device we want to run on
device = torch.device("cuda:0" if (torch.cuda.is_available() and ngpu > 0) else "cpu")
print("torch版本 ",torch.__version__)
print("cuda版本 ",torch.version.cuda)
print("驱动为：",device)
print("GPU型号： ",torch.cuda.get_device_name(0))
