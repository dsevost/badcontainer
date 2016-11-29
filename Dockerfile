FROM fedora:20

RUN \
    yum --releasever=20 --disablerepo='*' --enablerepo=fedora downgrade -y openssl-libs-1.0.1e-30.fc20.x86_64 \
    && yum --releasever=20 --disablerepo='*' --enablerepo=fedora install -y httpd mod_ssl \
    && yum clean all

CMD [ "/usr/sbin/httpd", "-DFOREGROUND" ]
