# syntax=docker/dockerfile:1
FROM docker://rockylinux:8 as base
ADD readline.pc /
LABEL Author pjaganna@nrao.edu
LABEL Version v0.0.1
ENV PATH=/libra/apps/src/:/libra/dependencies/linux_64b/bin/:/libra/dependencies/linux_64b/sbin/:$PATH
ENV LD_LIBRARY_PATH=/libra/apps/src/RoadRunner/:/libra/dependencies/linux_64b/lib/:$LD_LIBRARY_PATH
ENV LIBRA_PATH=/libra
RUN yum -y update \
    && yum -y install epel-release
RUN dnf config-manager --set-enabled powertools \
    && dnf -y install git cmake gcc-c++ gcc-gfortran ccache flex bison tar curl bzip2 make \
    && dnf -y install {gtest,readline,ncurses,blas,lapack,cfitsio,fftw,wcslib,gsl,eigen3,openmpi,python38}-devel \
    && mv /readline.pc /usr/lib64/pkgconfig/ && cd / && git clone --branch nohpg https://roadrunner-deploy:NF63isCrbsxu5LhqjdDy@gitlab.nrao.edu/ardg/libra.git && cd $LIBRA_PATH && make -f /libra/makefile.docker allclone
RUN make -f /libra/makefile.docker allbuild \
    && du -sh /libra/apps/build \
    && du -sh /libra/dependencies/build \
    && du -sh /libra/dependencies/src/ \
    && echo "Removing build and source directories to save space" \
    && rm -rf /libra/apps/build rm -rf /libra/dependencies/build rm -rf /libra/dependencies/src 
WORKDIR "/"
#ENTRYPOINT ["/libra/apps/install/roadrunner"]
COPY start.sh /
ENTRYPOINT ["/bin/bash","/start.sh"]