FROM quay.io/coreos/clair
COPY /data/ca.crt /usr/share/ca-certificates/test/ca.crt
RUN    echo "test/ca.crt" >> /etc/ca-certificates.conf
    && echo "192.168.33.12    nexus.test" >> /etc/hosts
    && update-ca-certificates
