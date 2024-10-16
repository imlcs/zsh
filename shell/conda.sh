#########################################################################
# File Name: conda.sh
# Author: Charles
# Created Time: 2024-10-16 10:30:05
#########################################################################

#!/bin/bash
set -e
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash

### create env
# conda create -n py39 python=3.9
