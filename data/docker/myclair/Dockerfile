FROM quay.io/coreos/clair
COPY ca.crt /usr/share/ca-certificates/test/ca.crt
RUN  echo "test/ca.crt" >> /etc/ca-certificates.conf \
     && update-ca-certificates
