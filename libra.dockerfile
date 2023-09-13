# syntax=docker/dockerfile:1
FROM nvcr.io/nvidia/cuda:12.2.0-devel-rockylinux8 as base
ADD readline.pc /
LABEL Author pjaganna@nrao.edu
LABEL Version v0.0.1
ENV PATH=/libra/apps/src/:/libra/dependencies/linux_64b/bin/:/libra/dependencies/linux_64b/sbin/:$PATH
ENV LD_LIBRARY_PATH=/libra/apps/src/RoadRunner/:/libra/dependencies/linux_64b/lib/:/usr/local/cuda-12.2/compat:$LD_LIBRARY_PATH
ENV LIBRA_PATH=/libra
RUN dnf -y clean all
RUN dnf -y update
RUN dnf -y install epel-release
RUN dnf install -y dnf-plugins-core
RUN dnf config-manager --set-enabled powertools
#RUN dnf update -y
RUN dnf -y install git cmake gcc-c++ gcc-gfortran ccache flex bison tar curl bzip2 make
RUN dnf -y install {gtest,readline,ncurses,blas,lapack,cfitsio,fftw,wcslib,gsl,eigen3,openmpi,python38}-devel
RUN mv /readline.pc /usr/lib64/pkgconfig/
RUN cd /
RUN git clone --branch kokkos4 https://roadrunner-deploy:NF63isCrbsxu5LhqjdDy@gitlab.nrao.edu/sbhatnag/libra.git
RUN cd $LIBRA_PATH
RUN make -f /libra/makefile.docker allclone
RUN make Kokkos_CUDA_ARCH=Kokkos_ARCH_TURING75 -f /libra/makefile.docker allbuild
RUN echo "nvcc --version > /tmp/nvcc_version.txt" >> /tests.sh
RUN echo "echo "nvcc version is $(cat /tmp/nvcc_version.txt)"" >> /tests.sh
RUN echo "nvidia-smi > /tmp/nvidia-smi.txt" >> /tests.sh
RUN echo "echo "nvidia-smi is $(cat /tmp/nvidia-smi.txt)"" >> /tests.sh
RUN echo "exit 0" >> /tests.sh
RUN chmod u+x /tests.sh
WORKDIR "/data"
#ENTRYPOINT ["/libra/apps/install/roadrunner"]
COPY start.sh /
ENTRYPOINT ["/bin/bash","/start.sh"]
