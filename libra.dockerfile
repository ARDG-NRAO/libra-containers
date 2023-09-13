# syntax=docker/dockerfile:1
FROM nvcr.io/nvidia/cuda:12.2.0-devel-rockylinux8 as base
WORKDIR "/data"
ADD readline.pc /data/
LABEL Author pjaganna@nrao.edu
LABEL Version v0.0.1
ENV PATH=/libra/apps/src/:/libra/dependencies/linux_64b/bin/:/libra/dependencies/linux_64b/sbin/:$PATH
ENV LD_LIBRARY_PATH=/libra/apps/src/RoadRunner/:/libra/dependencies/linux_64b/lib/:/usr/local/cuda-12.2/compat:$LD_LIBRARY_PATH
ENV LIBRA_PATH=/libra
RUN dnf -y clean all
#RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/Rocky-*
#RUN sed -i 's|#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=http://dl.rockylinux.org/vault/rocky|g' /etc/yum.repos.d/Rocky-*
#RUN echo "nameserver 8.8.8.8" >> /etc/resolv.conf && dnf -y install epel-release
#RUN cat /etc/resolv.conf
RUN dnf -y install epel-release
RUN dnf install -y dnf-plugins-core
RUN dnf config-manager --set-enabled powertools
#RUN dnf update -y
RUN dnf -y install git cmake gcc-c++ gcc-gfortran ccache flex bison tar curl bzip2 make
RUN dnf -y install {gtest,readline,ncurses,blas,lapack,cfitsio,fftw,wcslib,gsl,eigen3,openmpi,python38}-devel
RUN mv /data/readline.pc /usr/lib64/pkgconfig/
RUN cd /data/
RUN git clone --branch kokkos4 https://roadrunner-deploy:NF63isCrbsxu5LhqjdDy@gitlab.nrao.edu/sbhatnag/libra.git && cd libra && make -f makefile.docker allclone && make Kokkos_CUDA_ARCH=Kokkos_ARCH_VOLTA70 -f makefile.docker allbuild
RUN echo "nvcc --version > /tmp/nvcc_version.txt" >> /tests.sh
RUN echo "echo "nvcc version is $(cat /tmp/nvcc_version.txt)"" >> /tests.sh
RUN echo "nvidia-smi > /tmp/nvidia-smi.txt" >> /tests.sh
RUN echo "echo "nvidia-smi is $(cat /tmp/nvidia-smi.txt)"" >> /tests.sh
RUN echo "exit 0" >> /tests.sh
RUN chmod u+x /tests.sh
#ENTRYPOINT ["/data/libra/apps/install/roadrunner"]
COPY start.sh /data/
ENTRYPOINT ["/bin/bash","/data/start.sh"]

