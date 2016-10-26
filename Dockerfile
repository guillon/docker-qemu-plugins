FROM guillon/qemu-dev:v0.1

#
# Image containing executable QEMU with plugins and arm/aarch64 sysroots.
#
# Ref to README.md file
#

MAINTAINER Christophe Guillon <christophe.guillon@st.com>

# Install arm/aarch64 sysroots
RUN cd /opt && \
    wget -q -O sysroot-arm.tar.xz https://releases.linaro.org/components/toolchain/binaries/5.3-2016.02/arm-linux-gnueabihf/sysroot-linaro-glibc-gcc5.3-2016.02-arm-linux-gnueabihf.tar.xz && \
    tar xvJf sysroot-arm.tar.xz && \
    rm -f sysroot-arm.tar.xz

RUN cd /opt && \
    wget -q -O sysroot-aarch64.tar.xz https://releases.linaro.org/components/toolchain/binaries/5.3-2016.02/aarch64-linux-gnu/sysroot-linaro-glibc-gcc5.3-2016.02-aarch64-linux-gnu.tar.xz && \
    tar xvJf sysroot-aarch64.tar.xz && \
    rm -f sysroot-aarch64.tar.xz

# QEMU build and install
RUN wget -q -O qemu-plugins.zip https://github.com/guillon/qemu-plugins/archive/v2.6.0-2.zip && \
    unzip qemu-plugins.zip && \
    rm -f qemu-plugins.zip && \
    mv qemu-plugins-* qemu-plugins && \
    cd qemu-plugins && \
    ./configure --disable-werror --enable-capstone --enable-tcg-plugin \
    --target-list=x86_64-linux-user,arm-linux-user,aarch64-linux-user,arm-softmmu,aarch64-softmmu && \
    make -j 4 && make install && \
    cd .. && rm -rf qemu-plugins

# Install local files for reference
COPY README.md Dockerfile /dockerfiles/guillon/qemu-plugins/
