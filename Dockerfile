FROM envoyproxy/envoy:v1.14.1
COPY envoy.yaml /etc/envoy/envoy.yaml
COPY qrl.pb /tmp/envoy/qrl.pb
