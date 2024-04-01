all:
	sudo modprobe nbd
	sudo bash ext4.sh
clean:
	@ rm -rf *qcow* *raw*
	@ echo "ALL IMAGES HAVE BEEN CLEANED"
connect:
	sudo qemu-nbd --connect=/dev/nbd0 ext4_s05k.qcow2
disconnect:
	sudo qemu-nbd --disconnect /dev/nbd0
