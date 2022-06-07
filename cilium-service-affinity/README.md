# Deploy Cluster and Cilium

```
make deploy
```

# Destroy Cluster and Cilium

```
make destroy
```

# Running demo

```
make demo
```

This demo makes traffic from the netshoot Pod to the services that have local/remote/none service affinity annotation and display number of responses returned from clusters. echoserver Pods running behind those services returns the name of the Node they are running. From that node name, we can determine which cluster they are running. Please see `demo.sh` for more details.

## Example Output

```
Current Cluster: kind-service-affinity2
Making 100 requests to service-affinity=local service
  Number of responses from clusters
    100 kind-service-affinity2
Making 100 requests to service-affinity=remote service
  Number of responses from clusters
    100 kind-service-affinity1
Making 100 requests to service-affinity=none service
  Number of responses from clusters
     48 kind-service-affinity1
     52 kind-service-affinity2
```

## Tested on

```
$ uname -a
Linux xps 5.13.0-44-generic #49~20.04.1-Ubuntu SMP Wed May 18 18:44:28 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
$ kind --version
kind version 0.11.1
$ cilium version
cilium-cli: v0.11.4 compiled with go1.18.1 on linux/amd64
cilium image (default): v1.11.3
cilium image (stable): v1.11.5
cilium image (running): clustermesh-service-affinity
```
