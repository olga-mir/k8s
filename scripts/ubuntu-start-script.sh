#!/bin/bash

sudo apt-get update -y

# gvisor
curl -fsSL https://gvisor.dev/archive.key | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64,arm64] https://storage.googleapis.com/gvisor/releases release main"

# https://falco.org/docs/getting-started/installation/
curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | sudo apt-key add -
sudo echo "deb https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list

# trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
sudo echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list

sudo apt-get -y update
sudo apt-get -y install git make golang-go wget apt-transport-https gnupg lsb-release linux-headers-$(uname -r) falco trivy docker-compose apparmor-utils ca-certificates gnupg-agent software-properties-common runsc

## # install docker from https://get.docker.com (doesn't include docker-compose)
## curl -fsSL https://get.docker.com -o get-docker.sh
## sudo sh ./get-docker.sh
## rm ./get-docker.sh

rm -rf /home/ubuntu/docker-bench-security
cd /home/ubuntu && git clone https://github.com/docker/docker-bench-security.git

# Configure containerd runtime
cp /etc/containerd/config-kops.toml /home/ubuntu/containerd-config-kops-backup.toml
cat > /etc/containerd/config-kops.toml << "EOF"
version = 2

[plugins]

  [plugins."io.containerd.grpc.v1.cri"]

    [plugins."io.containerd.grpc.v1.cri".containerd]

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = false

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc]
          runtime_type = "io.containerd.runsc.v1"

  [plugins."io.containerd.runtime.v1.linux"]
    shim_debug = true
EOF

systemctl daemon-reload
systemctl restart containerd

cat > /etc/apparmor.d/usr.sbin.nginx << "EOF"
#include <tunables/global>

profile k8s-apparmor-nginx flags=(attach_disconnected) {
  #include <abstractions/base>
  #include <abstractions/nameservice>
  #include <abstractions/openssl>

  capability dac_override,

  /etc/nginx/conf.d/ r,
  /etc/nginx/mime.types r,
  /etc/nginx/modules-enabled/ r,
  /etc/nginx/nginx.conf r,
  /etc/nginx/sites-available/default r,
  /etc/nginx/sites-enabled/ r,
  /usr/sbin/nginx mr,
  /usr/share/nginx/modules-available/mod-http-image-filter.conf r,
  /usr/share/nginx/modules-available/mod-http-xslt-filter.conf r,
  /usr/share/nginx/modules-available/mod-mail.conf r,
  /usr/share/nginx/modules-available/mod-stream.conf r,
  /var/log/nginx/access.log w,
  /var/log/nginx/error.log w,

}
EOF
