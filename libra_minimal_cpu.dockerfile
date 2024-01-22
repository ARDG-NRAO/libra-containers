# Build stage
FROM docker://rockylinux:8 as build
ADD readline.pc /
ENV LIBRA_PATH=/libra
RUN yum -y update \
    && yum -y install epel-release \
    && dnf config-manager --set-enabled powertools \
    && dnf -y install git cmake gcc-c++ gcc-gfortran ccache flex bison tar curl bzip2 make \
    && dnf -y install {gtest,readline,ncurses,blas,lapack,cfitsio,fftw,wcslib,gsl,eigen3,openmpi,python38}-devel \
    && mv /readline.pc /usr/lib64/pkgconfig/ \
    && cd / \
    && git clone --branch nohpg https://github.com/ARDG-NRAO/LibRA.git libra\
    && cd $LIBRA_PATH \
    && make -f /libra/makefile.libra allclone \
    && make -f /libra/makefile.libra allbuild

# Final stage
ENV PATH=/libra/apps/src/:/libra/dependencies/linux_64b/bin/:/libra/dependencies/linux_64b/sbin/:$PATH
ENV LD_LIBRARY_PATH=/libra/apps/src/RoadRunner/:/libra/dependencies/linux_64b/lib/:$LD_LIBRARY_PATH
COPY --from=build /libra/apps/build /libra/apps/build
COPY --from=build /libra/dependencies/build /libra/dependencies/build
COPY --from=build /libra/dependencies/src/ /libra/dependencies/src/
COPY start.sh /
ENTRYPOINT ["/bin/bash","/start.sh"]