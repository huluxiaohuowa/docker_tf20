FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
LABEL maintainer="4@jach.vip"
LABEL version="0.0.2"

#  update
RUN apt-get -y update
RUN apt-get -y upgrade

# ssh and other softwares
RUN apt-get install -y htop tmux vim
RUN apt-get install -y libfontconfig1 libxrender1
RUN apt-get install -y openssh-server
RUN apt-get install -y checkinstall openmpi-bin openmpi-doc libopenmpi-dev
RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh
RUN sed -ri 's/session    required     pam_loginuid.so/# session    required     pam_loginuid.so/g' /etc/pam.d/sshd
RUN sed -ri 's/PermitRootLogin  without-password/# PermitRootLogin  without-password/g' /etc/ssh/sshd_config
RUN sed -ri 's/PermitRootLogin prohibit-password/# PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
RUN echo "PermitRootLogin    yes" >> /etc/ssh/sshd_config

# sources.list
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
RUN touch /etc/apt/sources.list
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list


# root password
RUN echo "root:woshiroot" | chpasswd

# # libxrender
# RUN apt-get install -y libfontconfig1 libxrender1




# miniconda3
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN echo "export PATH=\"\$PATH:/opt/conda/bin\"" >> /etc/bash.bashrc

# nccl
RUN wget --quiet https://od.lk/d/MzdfMjQzODc4N18/nccl-repo-ubuntu1604-2.3.7-ga-cuda10.0_1-1_amd64.deb -O ~/nccl.deb \
    && dpkg -i ~/nccl.deb

#cuda
RUN echo "export CUDA_HOME=\"/usr/local/cuda-10.0/\"" >> /etc/bash.bashrc
RUN echo "export NVIDIA_HOME=\"/usr/local/nvidia/\"" >> /etc/bash.bashrc
RUN echo "export PATH=\$PATH:\$CUDA_HOME/bin" >> /etc/bash.bashrc
RUN echo "export PATH=\$PATH:\$NVIDIA_HOME/bin" >> /etc/bash.bashrc
RUN echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$CUDA_HOME/lib64:\$NVIDIA_HOME/lib64" >> /etc/bash.bashrc
RUN echo "export LIBRARY_PATH=\$LIBRARY_PATH:\$CUDA_HOME/lib64:\$NVIDIA_HOME/lib64" >> /etc/bash.bashrc
# RUN apt-get -y install libcupti-dev


# jupyter and other packages
RUN /opt/conda/bin/conda install -y python=3.6
RUN /opt/conda/bin/conda install -y -c conda-forge jupyterlab
RUN /opt/conda/bin/conda install -y -c conda-forge matplotlib
RUN /opt/conda/bin/conda install -y -c conda-forge scikit-learn
RUN /opt/conda/bin/conda install -y -c conda-forge scipy



# RUN mkdir -p /root/jupyter/tensorboard
RUN /opt/conda/bin/jupyter lab --generate-config  --allow-root
RUN echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py
# RUN echo "c.NotebookApp.password = 'sha1:fbc4098e99ca:30ee6637f61c1c23395795e64a6e405e056cc326'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.port =8888 " >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.MappingKernelManager.root_dir = '/root/jupyter'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.notebook_dir = '/root/jupyter'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.allow_remote_access = True" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.token = 'woaixiaohuowa'" >> /root/.jupyter/jupyter_notebook_config.py

# rdkit
RUN /opt/conda/bin/conda install -y -c rdkit rdkit 

#  deep learning
# RUN /opt/conda/bin/conda install -y pytorch torchvision cuda100 -c pytorch
# RUN /opt/conda/bin/pip install mxnet-cu100
RUN /opt/conda/bin/pip install tf-nightly-gpu-2.0-preview


# conda and pip source
RUN /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
RUN /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
RUN /opt/conda/bin/conda config --set show_channel_urls yes
RUN /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
RUN /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
RUN /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
RUN /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/
RUN /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
RUN /opt/conda/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple



# clean conda caches
RUN /opt/conda/bin/conda clean -a -y

# entrypoint
RUN touch /entrypoint.sh
RUN echo "#! /bin/bash" >> /entrypoint.sh
RUN echo "/usr/sbin/sshd &" >> /entrypoint.sh
RUN echo "/opt/conda/bin/jupyter lab --allow-root \"\$@\" &" >> /entrypoint.sh
RUN echo "/opt/conda/bin/tensorboard --logdir=/root/jupyter/tensorboard" >> /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 8888 22 6006 
CMD ["/entrypoint.sh"]