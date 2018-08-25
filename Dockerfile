FROM fedora:28

COPY root /
RUN dnf install -y vim which findutils procps-ng openssl git which && \
     touch /etc/machine-id && \
     rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    dnf install -y code

ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}
COPY bin/ ${APP_ROOT}/bin/

RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} /etc/passwd && \
    chmod -R g=u ${APP_ROOT} /etc/passwd /etc/machine-id /etc/hostname

USER 1000
WORKDIR ${APP_ROOT}

ENTRYPOINT [ "uid_entrypoint" ]
EXPOSE 8080
CMD run /usr/bin/code -w