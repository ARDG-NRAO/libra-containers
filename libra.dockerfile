# syntax=docker/dockerfile:1
FROM nvcr.io/nvidia/cuda:12.2.0-devel-rockylinux8 as base
WORKDIR "/data"
ADD readline.pc /data/
LABEL Author pjaganna@nrao.edu
LABEL Version v0.0.1

# Build stage
FROM base as build
ENV PATH=/libra/apps/src/:/libra/dependencies/linux_64b/bin/:/libra/dependencies/linux_64b/sbin/:$PATH
ENV LD_LIBRARY_PATH=/libra/apps/src/RoadRunner/:/libra/dependencies/linux_64b/lib/:/usr/local/cuda-12.2/compat:$LD_LIBRARY_PATH
ENV LIBRA_PATH=/libra
RUN dnf -y clean all \
    && dnf -y install epel-release \
    && dnf install -y dnf-plugins-core \
    && dnf config-manager --set-enabled powertools \
    && dnf -y install git cmake gcc-c++ gcc-gfortran ccache flex bison tar curl bzip2 make \
    && dnf -y install {gtest,readline,ncurses,blas,lapack,cfitsio,fftw,wcslib,gsl,eigen3,openmpi,python38}-devel \
    && mv /data/readline.pc /usr/lib64/pkgconfig/ \
    && cd /data/ \
    && git clone https://github.com/ARDG-NRAO/LibRA.git libra\
    && cd libra \
    && make -f makefile.docker allclone \
    && make Kokkos_CUDA_ARCH=Kokkos_ARCH_VOLTA70 -f makefile.libra allbuild

# Final stage
FROM base
ENV PATH=/libra/apps/src/:/libra/dependencies/linux_64b/bin/:/libra/dependencies/linux_64b/sbin/:$PATH
ENV LD_LIBRARY_PATH=/libra/apps/src/RoadRunner/:/libra/dependencies/linux_64b/lib/:/usr/local/cuda-12.2/compat:$LD_LIBRARY_PATH
ENV LIBRA_PATH=/libra
COPY --from=build /data/libra/apps/install/roadrunner /data/libra/apps/install/roadrunner
COPY start.sh /data/
RUN echo "nvcc --version > /tmp/nvcc_version.txt" >> /tests.sh \
    && echo "echo "nvcc version is $(cat /tmp/nvcc_version.txt)"" >> /tests.sh \
    && echo "nvidia-smi > /tmp/nvidia-smi.txt" >> /tests.sh \
    && echo "echo "nvidia-smi is $(cat /tmp/nvidia-smi.txt)"" >> /tests.sh \
    && echo "exit 0" >> /tests.sh \
    && chmod u+x /tests.sh
ENTRYPOINT ["/bin/bash","/data/start.sh"]