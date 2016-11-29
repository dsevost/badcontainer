FROM fedora:20

RUN \
    yum --releasever=20 --disablerepo='*' --enablerepo=fedora downgrade -y openssl-libs-1.0.1e-30.fc20.x86_64 \
    && yum --releasever=20 --disablerepo='*' --enablerepo=fedora install -y httpd mod_ssl \
    && yum clean all

RUN \
    sed -ci.bak1 '\
        s|CustomLog.*|CustomLog /tmp/access.log combuned| ;\
        s|ErrorLog.*|ErrorLog /tmp/error.log| ; \
        s|Listen.*|Listen 8080| ; \
        ' /etc/httpd/conf/httpd.conf ; \
    sed -ci.bak1 '\
        s|CustomLog.*|CustomLog /tmp/ssl-request.log \\| ;\
        s|ErrorLog.*|ErrorLog /tmp/ssl-error.log| ; \
        s|Listen.*|Listen 8443 https| ; \
        s|TransferLog.*|TransferLog /tmp/ssl-access.log| ;\
        ' /etc/httpd/conf.d/ssl.conf ; \
    openssl \
        req \
            -x509 \
            -nodes \
            -days 3650 \
             -newkey rsa:2048 \
             -keyout /etc/pki/tls/private/localhost.key \
             -out /etc/pki/tls/certs/localhost.crt \
             -subj "/C=RU/ST=Moscow/L=Moscow/O=RHT-RU/CN=localhost" ; \
    chmod a+r /etc/pki/tls/private/localhost.key /etc/pki/tls/certs/localhost.crt ; \
    chmod 777 /run/httpd

USER apache

CMD [ \
    "/usr/sbin/httpd", \
        "-DFOREGROUND", \
        "-C", "ServerName localhost" \
    ]
