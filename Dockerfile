FROM ubuntu:24.04
WORKDIR /home/dev/github

RUN apt update -y && apt install -y git libx11-dev libxft-dev \
    libxft2-dev build-essential libopengl-dev libglut-dev cmake \
    libxinerama-dev libxcursor-dev \
    ninja-build x11-apps vim
RUN apt install -y xterm bash

RUN git clone https://github.com/janet-lang/janet
RUN git clone https://github.com/janet-lang/spork
RUN git clone https://github.com/rwtolbert/fltk-janet

ENV PATH="/home/dev/janet/bin:/home/dev/janet/lib/janet/bin:$PATH"
ENV PREFIX=/home/dev/janet
RUN cd /home/dev/github/janet && make install
RUN cd /home/dev/github/spork && janet --install .
RUN cd /home/dev/github/fltk-janet && /home/dev/janet/lib/janet/bin/janet-pm install


COPY --chmod=755 <<EOT /entrypoint.sh
#!/usr/bin/env bash
set -e
xterm -fa 'Monospace' -fs 14
EOT
ENTRYPOINT ["/entrypoint.sh"]
