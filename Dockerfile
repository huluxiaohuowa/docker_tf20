FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
LABEL maintainer="4@jach.vip"
LABEL version="1.1.0"

# apps
RUN echo "export CUDA_HOME=\"/usr/local/cuda-10.0/\"" >> /etc/bash.bashrc && \
    echo "export NVIDIA_HOME=\"/usr/local/nvidia/\"" >> /etc/bash.bashrc && \
    echo "export PATH=\$PATH:\$CUDA_HOME/bin" >> /etc/bash.bashrc && \
    echo "export PATH=\$PATH:\$NVIDIA_HOME/bin" >> /etc/bash.bashrc && \
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$CUDA_HOME/lib64:\$NVIDIA_HOME/lib64" >> /etc/bash.bashrc && \
    echo "export LIBRARY_PATH=\$LIBRARY_PATH:\$CUDA_HOME/lib64:\$NVIDIA_HOME/lib64" >> /etc/bash.bashrc && \
    apt-get -y update && apt-get -y upgrade && \
    apt-get install -y htop tmux vim libfontconfig1 libxrender1 openssh-server checkinstall openmpi-bin openmpi-doc libopenmpi-dev graphviz && \
    mkdir -p /var/run/sshd && \
    mkdir -p /root/.ssh && \
    sed -ri 's/session    required     pam_loginuid.so/# session    required     pam_loginuid.so/g' /etc/pam.d/sshd && \
    sed -ri 's/PermitRootLogin  without-password/# PermitRootLogin  without-password/g' /etc/ssh/sshd_config && \
    sed -ri 's/PermitRootLogin prohibit-password/# PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config && \
    echo "PermitRootLogin    yes" >> /etc/ssh/sshd_config && \
    echo "root:woshiroot" | chpasswd && \
    apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "export PATH=\"\$PATH:/opt/conda/bin\"" >> /etc/bash.bashrc && \
    mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    touch /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list



# python packages
RUN /opt/conda/bin/conda install -y -c conda-forge jupyterlab && \
    /opt/conda/bin/conda install -y -c conda-forge matplotlib && \
    /opt/conda/bin/conda install -y -c conda-forge scikit-learn && \
    /opt/conda/bin/conda install -y -c conda-forge scipy && \
    /opt/conda/bin/conda install -y -c rdkit rdkit && \
    /opt/conda/bin/conda install -y pytorch torchvision cudatoolkit=10.0 -c pytorch && \
    /opt/conda/bin/jupyter lab --generate-config  --allow-root && \
    echo "c.NotebookApp.terminado_settings = { \"/bin/bash\": \"foo\" }" >> /root/.jupyter/jupyter_notebook_config.py && \ 
    echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.port =8888 " >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.MappingKernelManager.root_dir = '/root/jupyter'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.notebook_dir = '/root/jupyter'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.allow_remote_access = True" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.token = 'woaixiaohuowa'" >> /root/.jupyter/jupyter_notebook_config.py && \
    /opt/conda/bin/pip install tqdm tf-nightly-gpu-2.0-preview joblib graphviz pydot fire networkx && \
    /opt/conda/bin/pip install dgl adabound tensorboardX torch-scatter torch-sparse torch-cluster torch-spline-conv torch-geometric && \
    /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
    /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
    /opt/conda/bin/conda config --set show_channel_urls yes && \
    /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
    /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/ && \
    /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/ && \
    /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/ && \
    /opt/conda/bin/conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/ && \
    /opt/conda/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    /opt/conda/bin/conda clean -a -y


# entrypoint
RUN touch /entrypoint.sh && \
    echo "#! /bin/bash" >> /entrypoint.sh && \
    echo "/usr/sbin/sshd &" >> /entrypoint.sh && \
    echo "/opt/conda/bin/tensorboard --logdir=/root/jupyter/tensorboard" &>> /entrypoint.sh && \
    echo "/opt/conda/bin/jupyter lab --allow-root" >> /entrypoint.sh && \
    chmod 755 /entrypoint.sh

EXPOSE 8888 22 6006 
CMD ["/entrypoint.sh"]