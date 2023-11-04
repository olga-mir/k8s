
set -x

# run script in `toolbox`
# https://cloud.google.com/container-optimized-os/docs/how-to/toolbox

apt-get update
apt-get install -y htop psmisc wget strace less tree wget curl

# install other tools
apt install iproute2 -y

# https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md
VERSION="v1.26.0" # check latest version in /releases page
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

cat <<EOF > /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: true
pull-image-on-create: false
EOF
