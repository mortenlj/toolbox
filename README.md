# toolbox
A docker image used for debugging kafka and kubernetes related issues

Installs many tools (see the [Earthfile](./Earthfile) or [mise.toml](./mise.toml) for details).

Most notable:
- curl
- [grpcurl](https://github.com/fullstorydev/grpcurl)
- httpie
- jq
- [k9s](https://github.com/derailed/k9s)
- [kafkactl](https://github.com/deviceinsight/kafkactl)
- kubectl
- [kubeseal](https://github.com/bitnami-labs/sealed-secrets)
- [kubespy](https://github.com/pulumi/kubespy)
- [kubetail](https://github.com/johanhaleby/kubetail)
- micro
- mosquitto-clients
- [mycli](https://www.mycli.net)
- nano
- nmap
- openssl
- [pgcli](https://www.pgcli.com)
- postgresql15-client
- postgresql16-client
- postgresql17-client
- redis
- tcpdump
- valkey-cli
- vim
- wget
- [yq](https://github.com/mikefarah/yq)


## Usage

Launch a docker container:

`docker run -ti --rm ghcr.io/mortenlj/toolbox:latest bash`

Launch into a kubernetes cluster:

`kubectl run toolbox --image=ghcr.io/mortenlj/toolbox:latest`

Exec into existing pod in kubernetes cluster:

`kubectl exec -ti toolbox -- bash`

## Building locally

The build on GitHub wants a GITHUB_TOKEN, which is usually not needed locally.
Just put the following in a file called `.secret`:

```
GITHUB_TOKEN=
```

Then build with: `earthly +deploy`
