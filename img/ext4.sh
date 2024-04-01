RANDDIR=../tools/randdir
MKDOUBLEDIRS=../tools/mkdoubledirs
MKFILEPATTERN=../tools/mkfilepattern
DIRTOTEST=../tools/dirtotest.py
MKSAMEHASH=../tools/mksamehash
MKDIRRANGE=../tools/mkdirrange

MKFS_XFS="sudo mkfs.xfs"
XFS_MIN_DISK_SIZE="302MiB"
XFS_MKFS_OPTS="-q -i maxpct=0"
XFS_MOUNT_OPTS="-t xfs"

MKFS_EXT2="sudo mkfs.ext2"
MKFS_EXT4="sudo mkfs.ext4"
EXT_HASH_SEED="01234567-abcd-abcd-abcd-001122334455"
EXT_MKFS_OPTS="-q"

MKFS_FAT="sudo mkfs.fat"
FAT_MOUNT_OPTS="umask=111,dmask=000"

MKFS_EXFAT="sudo mkfs.exfat"

QCOW2_OPTS="compat=v3,compression_type=zlib,encryption=off,extended_l2=off,preallocation=off"
NBD_DEV=/dev/nbd0   # FIXME
SGDISK="sgdisk --align-end --disk-guid=abcdefff-0123-4554-3210-ffeeddccbbaa"

ext4_s05k.qcow2 () {
    local img=$FUNCNAME
    local img_raw=$(basename $img .qcow2).raw

    fallocate -l 5GiB $img_raw
    $SGDISK --clear --new=0:0:0 $img_raw > /dev/null
    sudo losetup -P $LOOP_DEV $img_raw
    local p1="$LOOP_DEV"

    $MKFS_EXT4 -N 1200000 $p1
    debugfs -w -R "set_super_value hash_seed $EXT_HASH_SEED" $p1 > /dev/null
    sudo mount $p1 $TEMP_DIR
    sudo chown $USER $TEMP_DIR -R
#
    mkdir $TEMP_DIR/dir_a
    $MKDIRRANGE $TEMP_DIR/dir_a 0 3  0 1
#
    mkdir $TEMP_DIR/dir_b
    $MKDIRRANGE $TEMP_DIR/dir_b 0 10  0 1


    # $RANDDIR $TEMP_DIR 1000 8 255 65536

    mkdir $TEMP_DIR/dir_c
    $MKDIRRANGE $TEMP_DIR/dir_c 0 100  0 1
#
    mkdir $TEMP_DIR/dir_d
    $MKDIRRANGE $TEMP_DIR/dir_d 0 1000  0 1
#
    mkdir $TEMP_DIR/dir_e
    $MKDIRRANGE $TEMP_DIR/dir_e 0 10000  0 1
# #
#     mkdir $TEMP_DIR/dir_f
#     $MKDIRRANGE $TEMP_DIR/dir_f 0 100000  0 1
# #
#     mkdir $TEMP_DIR/dir_g
#     $MKDIRRANGE $TEMP_DIR/dir_g 0 1000000  0 1
#
    sudo umount $TEMP_DIR
    sudo losetup -d $LOOP_DEV

    qemu-img convert -O qcow2 -o $QCOW2_OPTS $img_raw $img
    rm $img_raw
}

ext2_s05k.qcow2 () {
    local img=$FUNCNAME
    local img_raw=$(basename $img .qcow2).raw

    fallocate -l 5GiB $img_raw
    $SGDISK --clear --new=0:0:0 $img_raw > /dev/null
    sudo losetup -P $LOOP_DEV $img_raw
    local p1="$LOOP_DEV"

    $MKFS_EXT2 $EXT_MKFS_OPTS -N 1200000 $p1
    debugfs -w -R "set_super_value hash_seed $EXT_HASH_SEED" $p1 > /dev/null
    sudo mount $p1 $TEMP_DIR
    sudo chown $USER $TEMP_DIR -R
#
    mkdir $TEMP_DIR/dir_a
    $MKDIRRANGE $TEMP_DIR/dir_a 0 3  0 1
#
    mkdir $TEMP_DIR/dir_b
    $MKDIRRANGE $TEMP_DIR/dir_b 0 10  0 1
#
    mkdir $TEMP_DIR/dir_c
    $MKDIRRANGE $TEMP_DIR/dir_c 0 100  0 1
#
    mkdir $TEMP_DIR/dir_d
    $MKDIRRANGE $TEMP_DIR/dir_d 0 1000  0 1
#
#     mkdir $TEMP_DIR/dir_e
#     $MKDIRRANGE $TEMP_DIR/dir_e 0 10000  0 1
# #
#     mkdir $TEMP_DIR/dir_f
#     $MKDIRRANGE $TEMP_DIR/dir_f 0 64998  0 1
#
    sudo umount $TEMP_DIR
    sudo losetup -d $LOOP_DEV

    qemu-img convert -m 2 -O qcow2 -o $QCOW2_OPTS $img_raw $img
    rm $img_raw
}

fat12_s05k.qcow2 () {
    local img=$FUNCNAME
    local img_raw=$(basename $img .qcow2).raw

    fallocate -l 256MiB $img_raw
    $SGDISK --clear --new=0:0:0 $img_raw > /dev/null
    sudo losetup -P $LOOP_DEV $img_raw
    local p1="$LOOP_DEV"

    $MKFS_FAT -F 12 $p1 > /dev/null
    sudo mount -o $FAT_MOUNT_OPTS $p1 $TEMP_DIR
#
    mkdir $TEMP_DIR/dir_a
    $MKDIRRANGE $TEMP_DIR/dir_a 0 3  0 1
#
    mkdir $TEMP_DIR/dir_b
    $MKDIRRANGE $TEMP_DIR/dir_b 0 10  0 1
#
    mkdir $TEMP_DIR/dir_c
    $MKDIRRANGE $TEMP_DIR/dir_c 0 100  0 1
#
    mkdir $TEMP_DIR/dir_d
    $MKDIRRANGE $TEMP_DIR/dir_d 0 1000  0 1
#
    mkdir $TEMP_DIR/dir_e
    $MKDIRRANGE $TEMP_DIR/dir_e 0 2000  0 1
#
    sudo umount $TEMP_DIR
    sudo losetup -d $LOOP_DEV

    qemu-img convert -m 2 -O qcow2 -o $QCOW2_OPTS $img_raw $img
    rm $img_raw
}
TEMP_DIR=$(mktemp -d)
LOOP_DEV=$(losetup --find)

ext2_s05k.qcow2
ext4_s05k.qcow2
fat12_s05k.qcow2
