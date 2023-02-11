
# run script in `toolbox`
# https://cloud.google.com/container-optimized-os/docs/how-to/toolbox

apt-get update
apt-get install -y htop psmisc wget strace less tree wget sudo

# https://github.com/iovisor/bcc/blob/master/INSTALL.md
apt-get install -y bpfcc-tools

### linux headers https://serverfault.com/questions/938101/how-do-i-obtain-kernel-headers-on-gke-containeros-image
# maybe not needed - because of the next section
# kversion=v"$(uname -r | sed -E 's/\+*$//')"
# wget "https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/$kversion.tar.gz"
# mkdir kernel
# tar xzf "$kversion.tar.gz" -C kernel
# echo "export BPFTRACE_KERNEL_SOURCE=$PWD/kernel"
### END linux headers


# https://github.com/iovisor/bpftrace/blob/master/INSTALL.md
KERNEL_VERSION="${KERNEL_VERSION:-$(uname -r)}"
# original version has `-vFS=-` but this doesn't work on GKE COS because of the trailing +
kernel_version="$(echo "${KERNEL_VERSION}" | awk -vFS=+ '{ print $1 }')"
major_version="$(echo "${KERNEL_VERSION}" | awk -vFS=. '{ print $1 }')"

apt-get install -y build-essential bc curl flex bison libelf-dev

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


# Install BPF tool
apt-get install -y git
git clone --recurse-submodules https://github.com/libbpf/bpftool.git
cd bpftool/src
make -j$(nproc)
sudo ./bpftool prog


## this doesn't work yet
# root@gke-<NODE_NAME>:~/bpftool/src# strace  ./bpftool prog show
# execve("./bpftool", ["./bpftool", "prog", "show"], 0x7fff531acb40 /* 15 vars */) = 0
# brk(NULL)                               = 0x55718c954000
# access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
# openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
# fstat(3, {st_mode=S_IFREG|0644, st_size=15990, ...}) = 0
# mmap(NULL, 15990, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f173014b000
# close(3)                                = 0
# openat(AT_FDCWD, "/usr/lib/x86_64-linux-gnu/libelf.so.1", O_RDONLY|O_CLOEXEC) = 3
# read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`3\0\0\0\0\0\0"..., 832) = 832
# fstat(3, {st_mode=S_IFREG|0644, st_size=105008, ...}) = 0
# mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f1730149000
# mmap(NULL, 106944, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f173012e000
# mmap(0x7f1730131000, 69632, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7f1730131000
# mmap(0x7f1730142000, 20480, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x14000) = 0x7f1730142000
# mmap(0x7f1730147000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x18000) = 0x7f1730147000
# close(3)                                = 0
# openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libz.so.1", O_RDONLY|O_CLOEXEC) = 3
# read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0203\0\0\0\0\0\0"..., 832) = 832
# fstat(3, {st_mode=S_IFREG|0644, st_size=113088, ...}) = 0
# mmap(NULL, 115088, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f1730111000
# mprotect(0x7f1730114000, 98304, PROT_NONE) = 0
# mmap(0x7f1730114000, 69632, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3000) = 0x7f1730114000
# mmap(0x7f1730125000, 24576, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x14000) = 0x7f1730125000
# mmap(0x7f173012c000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1a000) = 0x7f173012c000
# close(3)                                = 0
# openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
# read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@n\2\0\0\0\0\0"..., 832) = 832
# fstat(3, {st_mode=S_IFREG|0755, st_size=1839792, ...}) = 0
# mmap(NULL, 1852680, PROT_READ, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f172ff4c000
# mprotect(0x7f172ff71000, 1662976, PROT_NONE) = 0
# mmap(0x7f172ff71000, 1355776, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x25000) = 0x7f172ff71000
# mmap(0x7f17300bc000, 303104, PROT_READ, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x170000) = 0x7f17300bc000
# mmap(0x7f1730107000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1ba000) = 0x7f1730107000
# mmap(0x7f173010d000, 13576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f173010d000
# close(3)                                = 0
# mmap(NULL, 12288, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f172ff49000
# arch_prctl(ARCH_SET_FS, 0x7f172ff49740) = 0
# mprotect(0x7f1730107000, 12288, PROT_READ) = 0
# mprotect(0x7f173012c000, 4096, PROT_READ) = 0
# mprotect(0x7f1730147000, 4096, PROT_READ) = 0
# mprotect(0x55718bc07000, 16384, PROT_READ) = 0
# mprotect(0x7f1730179000, 4096, PROT_READ) = 0
# munmap(0x7f173014b000, 15990)           = 0
# bpf(BPF_PROG_GET_NEXT_ID, {start_id=0, next_id=0, open_flags=0}, 12) = -1 EPERM (Operation not permitted)
# write(2, "Error: ", 7Error: )                  = 7
