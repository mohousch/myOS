#
# Makefile for myOS
#

all: iso

bootloader: bootloader.asm
	nasm -f elf32 bootloader.asm -o bootloader.o
	
kernel: kernel.c
	gcc -m32 -c kernel.c -o kernel.o
	
image: bootloader kernel
	@printf "Building Kernel Image...\n"
	ld -m elf_i386 -T linker.ld -o kernel.bin bootloader.o kernel.o
	dd if=kernel.bin of=myOS.img bs=512 count=2880
	
iso: image
	@printf "Building ISO...\n"
	mkdir -p isodir/boot/grub
	rm -rf isodir/myOS.iso isodir/boot/kernel.bin
	cp -a kernel.bin isodir/boot/kernel.bin
	cp -a grub.cfg isodir/boot/grub/grub.cfg
	grub-file --is-x86-multiboot isodir/boot/kernel.bin
	grub-mkrescue -o myOS.iso -V "myOS" isodir
	 
run-image: myOS.img
	qemu-system-i386 -kernel myOS.img
	
run: myOS.iso
	qemu-system-i386 myOS.iso
	
clean:
	@printf "cleaning ...\n"
	rm -rf *.o kernel.bin myOS.img myOS.iso isodir mbr.bin
	
.PHONY: iso
