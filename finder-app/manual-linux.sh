#!/bin/bash

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
#KERNEL_REPO=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi

if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}
    # TODO: Add your kernel build steps here
    cd "$OUTDIR/linux-stable"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper   
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig   
    make -j4 ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE all
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs   
fi


echo "Adding the Image in outdir"
cp "${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image" "${OUTDIR}/Image" 

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir ${OUTDIR}/rootfs
cd ${OUTDIR}/rootfs
mkdir -p bin dev etc home lib lib64 proc sys sbin tmp usr var
mkdir -p usr/bin/ usr/lib usr/sbin
mkdir -p var/log


cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
	git clone git://busybox.net/busybox.git
	#git clone https://github.com/mirror/busybox
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    sudo make distclean
	sudo make defconfig

else
    cd busybox
fi


# TODO: Make and install busybox
#cd ${OUTDIR}/linux-stable
make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
#echo "CONFIG_PREFIX=${OUTDIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}"
#cd ${OUTDIR}/linux-stable
make -j4 CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
cd ${OUTDIR}/rootfs
${CROSS_COMPILE}readelf -a /bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a /bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot)
cp -r "${SYSROOT}"/lib/* lib/
cp -r "${SYSROOT}"/lib64/* lib64/

# TODO: Make device nodes
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/console c 5 1

# TODO: Clean and build the writer utility
cd "$FINDER_APP_DIR"
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp "$FINDER_APP_DIR/writer" "${OUTDIR}/rootfs/home"
cp -f "$FINDER_APP_DIR/finder.sh" "${OUTDIR}/rootfs/home"
sudo chmod 777 "${OUTDIR}/rootfs/home/finder.sh"
cp "$FINDER_APP_DIR/finder-test.sh" "${OUTDIR}/rootfs/home"
mkdir "${OUTDIR}/rootfs/conf" 
mkdir "${OUTDIR}/rootfs/home/conf" 
cp "$FINDER_APP_DIR/conf/username.txt" "${OUTDIR}/rootfs/home/conf"
cp "$FINDER_APP_DIR/conf/assignment.txt" "${OUTDIR}/rootfs/conf"
cp "$FINDER_APP_DIR/autorun-qemu.sh" "${OUTDIR}/rootfs/home/"


# TODO: Chown the root directory
cd "${OUTDIR}/rootfs"
sudo chown -R root *

# TODO: Create initramfs.cpio.gz
#cd "${OUTDIR}/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
gzip -f ${OUTDIR}/initramfs.cpio
echo "Finish"
