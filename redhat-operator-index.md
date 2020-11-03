# Pruning or looking at index images
This is a helpful utility to see all the operators that can be mirrored, from the bastion system:

1. `curl https://github.com/fullstorydev/grpcurl/releases/download/v1.7.0/grpcurl_1.7.0_linux_x86_64.tar.gz`
2. `tar -xvzf grpcurl_1.7.0_linux_x86_64.tar.gz`
3. `mv grpcurl /usr/local/bin`
3. `podman run --authfile pull-secret-full.json -p50051:50051 -it registry.redhat.io/redhat/redhat-operator-index:v4.6`

## Looking at the Index using grpcurl
Using another terminal window on the bastion system:

1. `grpcurl -plaintext localhost:50051 api.Registry/ListPackages > packages.out`
2. `cat packages.out`
