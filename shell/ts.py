#########################################################################
#  -*- coding:utf-8 -*-  
#  File Name: ts.py
#  Author: Charles
#########################################################################
# coding:utf-8
import tensorflow as tf
print('tensorflow version:',tf.__version__)  # 查看TensorFlow的版本
print('===================================================')
print('cuda available:',tf.test.is_built_with_cuda()) # 判断CUDA是否可用
print('===================================================')
print(tf.test.is_gpu_available())  # 查看cuda、TensorFlow_GPU和cudnn(选择下载，cuda对深度学习的补充)版本是否对应
print('===================================================')
gpus = tf.config.experimental.list_physical_devices(device_type='GPU') # 查看可用GPU
print(gpus)
import os
#选择使用某一块或多块GPU
#os.environ["CUDA_VISIBLE_DEVICES"] = "0,1"  # =右边"0,1",代表使用标号为0,和1的GPU
os.environ["CUDA_VISIBLE_DEVICES"] = "0"  # =右边"0",代表使用标号为0的GPU
# 查看可用GPU的详细信息
from tensorflow.python.client import device_lib
print(device_lib.list_local_devices())
