FROM registry.fedoraproject.org/fedora:28 

COPY root /
RUN dnf install -y libinput hostname xorg-x11-drv-libinput xorg-x11-drv-evdev xorg-x11-xinit xorg-x11-server-Xorg xorg-x11-drv-intel i3 vim which findutils procps-ng openssl git which && \
    touch /etc/machine-id && \
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    dnf install -y code libX11-xcb && \
    dnf clean all

ENV APP_ROOT=/opt/app-root UID=1000
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT} USER_NAME=user
COPY user/ ${APP_ROOT}
COPY bin/ ${APP_ROOT}/bin/

RUN useradd -u ${UID} -g 0 -d ${HOME} ${USER_NAME} && \ 
    chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} /etc/passwd && \
    chmod -R g=u ${APP_ROOT} /etc/passwd /etc/machine-id /etc/hostname

USER ${USER_NAME} 
WORKDIR ${APP_ROOT}

ENTRYPOINT [ "uid_entrypoint" ]
CMD run "startx /usr/bin/i3 -- :1" 
