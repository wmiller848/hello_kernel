i686-elf-as boot.s -o boot.o

#i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
rustc -O --emit=obj --crate-type=lib --target=i686-unknown-linux-gnu -L /opt/libcore-i686-unknown-linux-gnu kernel.rs

i686-elf-gcc -T linker.ld -o hello_kernel.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc
