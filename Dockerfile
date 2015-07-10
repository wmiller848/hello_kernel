FROM fedora:latest

RUN yum -y update
RUN yum -y install isl isl-devel cloog cloog-devel gmp gmp-devel gmpc-devel libmpc libmpc-devel mpfr mpfr-devel
RUN yum -y install glibc-devel glibc-headers glibc-static cpp
RUN yum -y install gcc gcc-c++ make texinfo
RUN yum -y install xorriso grub2 grub2-tools
RUN yum -y install wget tar git mercurial

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

WORKDIR /opt/src/build-gcc
RUN ../gcc-4.9.2/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
RUN make all-gcc
RUN make all-target-libgcc
RUN make install-gcc
RUN make install-target-libgcc

WORKDIR /opt
RUN wget https://static.rust-lang.org/rustup.sh
RUN chmod +x ./rustup.sh
RUN ./rustup.sh --help
RUN ./rustup.sh --verbose --yes --channel=nightly --disable-sudo

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

WORKDIR /opt
RUN git clone https://github.com/rust-lang/rust
WORKDIR /opt/rust
RUN git checkout e6a9be10bc1b178dc0b23c505fc8f17e925cabb2

WORKDIR /opt
RUN mkdir libcore-i686-unknown-linux-gnu
RUN rustc -C opt-level=2 -Z no-landing-pads --target=i686-unknown-linux-gnu -g rust/src/libcore/lib.rs --out-dir=libcore-i686-unknown-linux-gnu

ADD ./src /opt/hello_kernel

WORKDIR /opt/hello_kernel

RUN cat install.sh | bash

RUN mkdir -p isodir/boot/grub
RUN cp hello_kernel.bin isodir/boot/hello_kernel.bin
RUN cp grub.cfg isodir/boot/grub/grub.cfg
RUN grub2-mkrescue -o hello_kernel.iso isodir
