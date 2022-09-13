FROM ubuntu:18.04

COPY build/java_policy /etc
RUN export DEBIAN_FRONTEND=noninteractive && \
    buildDeps='software-properties-common git libtool cmake python-dev python3-pip python-pip libseccomp-dev wget curl' && \
    apt-get update && apt-get install -y gnupg ca-certificates tzdata python python3 python-pkg-resources python3-pkg-resources $buildDeps && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && apt-get update && apt-get install -y gcc-9 g++-9 && \
    rm /usr/bin/gcc /usr/bin/g++ && ln -s /usr/bin/gcc-9 /usr/bin/gcc && ln -s /usr/bin/g++-9 /usr/bin/g++ && \
    add-apt-repository ppa:openjdk-r/ppa && add-apt-repository ppa:longsleep/golang-backports  && \
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get update && apt-get install -y golang-go openjdk-8-jdk nodejs mono-complete && \
    ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    pip3 install -I --no-cache-dir psutil gunicorn flask requests idna && \
    cd /tmp && git clone -b newnew  --depth 1 https://github.com/luyencode/Judger.git && cd Judger && \
    mkdir build && cd build && cmake .. && make && make install && cd ../bindings/Python && python3 setup.py install && \
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /code && \
    useradd -u 12001 compiler && useradd -u 12002 code && useradd -u 12003 spj && usermod -a -G code spj
RUN apt-get update && apt-get install -y wget
RUN wget https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20amd64%20DEB/Lazarus%202.2.2/fpc-laz_3.2.2-210709_amd64.deb && \
    apt install -y ./fpc-laz_3.2.2-210709_amd64.deb && rm -rf fpc-laz_3.2.2-210709_amd64.deb
HEALTHCHECK --interval=5s --retries=3 CMD python3 /code/service.py
ADD server /code
WORKDIR /code
RUN gcc -shared -fPIC -o unbuffer.so unbuffer.c
EXPOSE 8080
ENTRYPOINT /code/entrypoint.sh
