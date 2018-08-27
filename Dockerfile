FROM registry.fedoraproject.org/fedora:28 

COPY root /
RUN dnf install -y hostname systemd-udev xorg-x11-drv-evdev xorg-x11-xinit xorg-x11-server-Xorg xorg-x11-drv-intel i3 vim which findutils procps-ng openssl git which && \
    touch /etc/machine-id && \
    rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    dnf install -y code libX11-xcb && \
    dnf clean all

ENV APP_ROOT=/opt/app-root UID=1000 container=oci
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT} USER_NAME=user
COPY user/ ${APP_ROOT}
COPY bin/ ${APP_ROOT}/bin/

STOPSIGNAL SIGRTMIN+3

RUN useradd -u ${UID} -g 0 -d ${HOME} ${USER_NAME} && \ 
    chown -R ${USER_NAME}:0 ${APP_ROOT} && \
    chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} /etc/passwd && \
    chmod -R g=u ${APP_ROOT} /etc/passwd /etc/machine-id /etc/hostname

RUN MASK_JOBS="sys-fs-fuse-connections.mount getty.target systemd-initctl.socket systemd-logind.service" && \
    systemctl mask ${MASK_JOBS} && \
    for i in ${MASK_JOBS}; do find /usr/lib/systemd/ -iname $i | grep ".wants" | xargs rm -f; done && \
    rm -f /etc/fstab && \
    systemctl set-default multi-user.target

USER ${USER_NAME} 
WORKDIR ${APP_ROOT}

#CMD [ "/sbin/init" ]

#ENTRYPOINT [ "uid_entrypoint" ]
CMD [ "uid_entrypoint" ] 
