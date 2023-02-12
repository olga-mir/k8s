
set -x

# run script in `toolbox`
# https://cloud.google.com/container-optimized-os/docs/how-to/toolbox

apt-get update
apt-get install -y htop psmisc wget strace less tree wget curl

# https://github.com/iovisor/bcc/blob/master/INSTALL.md
apt-get install -y bpfcc-tools

# https://github.com/iovisor/bpftrace/blob/master/INSTALL.md
KERNEL_VERSION="${KERNEL_VERSION:-$(uname -r)}"
# original version has `-vFS=-` but this doesn't work on GKE COS because of the trailing +
kernel_version="$(echo "${KERNEL_VERSION}" | awk -vFS=+ '{ print $1 }')"
major_version="$(echo "${KERNEL_VERSION}" | awk -vFS=. '{ print $1 }')"

apt-get install -y build-essential

mkdir -p /usr/src/linux
curl -sL "https://www.kernel.org/pub/linux/kernel/v${major_version}.x/linux-$kernel_version.tar.gz" \
  | tar --strip-components=1 -xzf - -C /usr/src/linux
cd /usr/src/linux
zcat /proc/config.gz > .config
make ARCH=x86 oldconfig
make ARCH=x86 prepare
mkdir -p /lib/modules/$(uname -r)
ln -sf /usr/src/linux /lib/modules/$(uname -r)/source
ln -sf /usr/src/linux /lib/modules/$(uname -r)/build
### end

# make bpftool

cd /usr/src/linux/tools/bpf/bpftool
make


# NOTES


# ++ make ARCH=x86 oldconfig
# requires manual 'y/N'
# IA32 Emulation (IA32_EMULATION) [Y/n/?] y
# x32 ABI for 64-bit mode (X86_X32) [N/y/?] (NEW)

# Auto-detecting system features:
# ...                        libelf: [ on  ]
# ...                          zlib: [ on  ]
# ...                           bpf: [ on  ]

## this still doesn't work even with root, presumably due to seccomp

# root@gke-<NODE_NAME>::/usr/src/linux/tools/bpf/bpftool# strace -e bpf ./bpftool prog show
# root@gke-dev-default-node-pool-938fe3b9-vkzt
# bpf(BPF_PROG_GET_NEXT_ID, {start_id=0, next_id=0, open_flags=0}, 120) = -1 EPERM (Operation not permitted)
# Error: can't get next program: Operation not permitted
# +++ exited with 255 +++
