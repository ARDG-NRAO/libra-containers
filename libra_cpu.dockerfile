# syntax=docker/dockerfile:1
FROM docker://rockylinux:8 as base
ADD readline.pc /
LABEL Author pjaganna@nrao.edu
LABEL Version v0.0.1
ENV PATH=/libra/apps/src/:/libra/dependencies/linux_64b/bin/:/libra/dependencies/linux_64b/sbin/:$PATH
ENV LD_LIBRARY_PATH=/libra/apps/src/RoadRunner/:/libra/dependencies/linux_64b/lib/:$LD_LIBRARY_PATH
ENV LIBRA_PATH=/libra
RUN yum -y update
RUN yum -y install epel-release
#RUN dnf install -y yum-plugins-core
RUN dnf config-manager --set-enabled powertools
RUN dnf -y install git cmake gcc-c++ gcc-gfortran ccache flex bison tar curl bzip2 make
RUN dnf -y install {gtest,readline,ncurses,blas,lapack,cfitsio,fftw,wcslib,gsl,eigen3,openmpi,python38}-devel
RUN mv /readline.pc /usr/lib64/pkgconfig/
RUN cd /
RUN git clone --branch nohpg https://roadrunner-deploy:NF63isCrbsxu5LhqjdDy@gitlab.nrao.edu/sbhatnag/libra.git
RUN cd $LIBRA_PATH
RUN make -f /libra/makefile.docker allclone
RUN make -f /libra/makefile.docker allbuild
WORKDIR "/"
#ENTRYPOINT ["/libra/apps/install/roadrunner"]
COPY start.sh /
ENTRYPOINT ["/bin/bash","/start.sh"]