nasm -o boot.bin $1/*.asm
dd bs=512 count=1 of=boot.img if=boot.bin
rm boot.bin
bochs -qf bochs.cfg
rm boot.img
