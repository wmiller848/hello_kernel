FROM fedora:latest

RUN yum -y update
RUN yum -y install isl-devel cloog-devel gmp-devel gmpc-devel mpfr-devel
RUN yum -y install gcc make texinfo
RUN yum -y install wget tar

ENV PREFIX=/opt/cross
ENV TARGET=i686-elf
ENV PATH=$PATH:$PREFIX/bin

WORKDIR /opt/src

RUN wget http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.gz
RUN tar -xf binutils-2.25.tar.gz
RUN wget http://www.netgull.com/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.gz
RUN tar -xf gcc-4.9.2.tar.gz

WORKDIR /opt/src/build-binutils
RUN ../binutils-2.25/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
RUN make
RUN make install

RUN yum -y install gmp gmpc mpfr

WORKDIR /opt/src/build-gcc
RUN ../gcc-4.9.2/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
RUN make all-gcc
RUN make all-target-libgcc
RUN make install-gcc
RUN make install-target-libgcc
