FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04
LABEL maintainer="4@jach.vip"
LABEL version="1.1.22"

# apps
RUN echo "export CUDA_HOME=\"/usr/local/cuda-10.0/\"" >> /etc/bash.bashrc && \
    echo "export NVIDIA_HOME=\"/usr/local/nvidia/\"" >> /etc/bash.bashrc && \
    echo "export PATH=\$PATH:\$CUDA_HOME/bin" >> /etc/bash.bashrc && \
    echo "export PATH=\$PATH:\$NVIDIA_HOME/bin" >> /etc/bash.bashrc && \
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$CUDA_HOME/lib64:\$NVIDIA_HOME/lib64" >> /etc/bash.bashrc && \
    echo "export LIBRARY_PATH=\$LIBRARY_PATH:\$CUDA_HOME/lib64:\$NVIDIA_HOME/lib64" >> /etc/bash.bashrc && \
    echo "shopt -s autocd" >> /etc/bash.bashrc && \
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
    apt-get install -y wget software-properties-common bzip2 ca-certificates curl git libpq-dev && \
    # /usr/bin/chsh -s /usr/bin/fish && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "export PATH=\"\$PATH:/opt/conda/bin\"" >> /etc/bash.bashrc && \
    echo "export NODE_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/" >> /etc/bash.bashrc && \
    mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    touch /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list 

# python packages
RUN /opt/conda/bin/conda install -y python=3.6 
RUN /opt/conda/bin/conda install -y -c conda-forge jupyterlab && \
    /opt/conda/bin/conda install nodejs && \
    /opt/conda/bin/jupyter labextension install @jupyterlab/toc && \
    /opt/conda/bin/jupyter labextension install @telamonian/theme-darcula && \
    /opt/conda/bin/jupyter labextension install @jupyterlab/katex-extension && \
    /opt/conda/bin/conda install -y -c conda-forge matplotlib && \
    /opt/conda/bin/conda install -y -c conda-forge scikit-learn && \
    /opt/conda/bin/conda install -y -c conda-forge scipy && \
    /opt/conda/bin/conda install -y -c rdkit rdkit && \
    /opt/conda/bin/conda install -c conda-forge jupyter_conda && \
    /opt/conda/bin/conda install -y pytorch torchvision cudatoolkit=10.0 -c pytorch && \
    /opt/conda/bin/conda install -y -c openbabel openbabel && \
    /opt/conda/bin/jupyter lab --generate-config  --allow-root && \
    echo "c.NotebookApp.terminado_settings = { \"/bin/bash\": \"foo\" }" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.port =8888 " >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.MappingKernelManager.root_dir = '/root/jupyter'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.notebook_dir = '/root/jupyter'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.allow_remote_access = True" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.token = 'woaixiaohuowa'" >> /root/.jupyter/jupyter_notebook_config.py && \
    /opt/conda/bin/pip install future ipypb jupytext tf-nightly-gpu-2.0-preview joblib graphviz pydot fire molvs networkx  && \
    /opt/conda/bin/pip install nbresuse modin psutil setproctitle jupyterlab_sql jupyter-tensorboard && \
    /opt/conda/bin/pip install psycopg2 pysnooper py3dmol dgl adabound botorch torch-scatter torch-sparse torch-cluster torch-spline-conv torch-geometric && \
    /opt/conda/bin/jupyter labextension install @krassowski/jupyterlab_go_to_definition @enlznep/jupyterlab_shell_file jupyterlab-python-file && \
    /opt/conda/bin/jupyter labextension install jupyterlab-jupytext jupyterlab_vim jupyterlab_tensorboard jupyterlab_toastify jupyterlab_conda && \
    /opt/conda/bin/jupyter labextension install @jupyterlab/statusbar jupyterlab-topbar-extension jupyterlab-system-monitor jupyterlab-topbar-text && \
    /opt/conda/bin/jupyter serverextension enable jupyterlab_sql --py --sys-prefix && \
    /opt/conda/bin/jupyter serverextension enable --py nbresuse && \
    /opt/conda/bin/jupyter lab build && \
    curl -L -s https://raw.githubusercontent.com/jach4/docker_tf20/master/.condarc -o /root/.condarc && \
    /opt/conda/bin/conda config --set show_channel_urls yes && \
    /opt/conda/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    # hhhh e3fp 
    # /opt/conda/bin/pip install e3fp && \
    /opt/conda/bin/conda clean -a -y


# entrypoint
RUN /usr/bin/git clone https://github.com/DamnWidget/anaconda.git /root/anaconda 
RUN echo "set number" >> /etc/vim/vimrc && \
    echo "set -o vi" >> /etc/bash.bashrc && \
    touch /root/mylayout && \
    touch /root/.tmux.conf && \
    echo "selectp -t 0" >> /root/mylayout && \
    echo "splitw -h -p 50" >> /root/mylayout && \
    echo "selectp -t 0" >> /root/mylayout &&\
    echo "bind D source-file /root/mylayout" >> /root/.tmux.conf && \
    touch /entrypoint.sh && \
    echo "#! /bin/bash" >> /entrypoint.sh && \
    echo "export SHELL=/bin/bash" >> /entrypoint.sh && \
    echo "/usr/sbin/sshd &" >> /entrypoint.sh && \
    # echo "/opt/conda/bin/tensorboard --logdir=/root/jupyter/tensorboard &" >> /entrypoint.sh && \
    echo "/opt/conda/bin/python /root/anaconda/anaconda_server/minserver.py 9999 &" >> /entrypoint.sh &&\
    echo "/opt/conda/bin/jupyter lab --allow-root" >> /entrypoint.sh && \
    chmod 755 /entrypoint.sh

EXPOSE 8888 22 9999
CMD ["/entrypoint.sh"]