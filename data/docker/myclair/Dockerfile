FROM quay.io/coreos/clair:v2.0.1
COPY ca.crt /usr/share/ca-certificates/test/ca.crt
RUN  echo "test/ca.crt" >> /etc/ca-certificates.conf \
     && update-ca-certificates
