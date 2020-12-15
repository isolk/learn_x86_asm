mov dx,0x1f2 ; 硬盘的端口号，这儿表示要读的扇区数
mov al,0x01  ; 访问1个扇区
out dx,al    ; 写入

; 读取第1个扇区，并且扇区地址形式为LBA，注意，第1个扇区表示第0个
mov dx,0x1f3 ;
mov al,1
out dx,al

mov dx,0x1f4
mov al,0
out dx,al

mov dx,0x1f5
mov al,0
out dx,al

mov dx,0x1f6
mov al,0xe0
out dx,al

mov dx,0x1f7
mov al,0x20
out dx,al

.wait:
    in al,dx
    and al,0x88
    cmp al,0x08
jnz .wait

mov cx,256
mov dx,0x1f0


; 读取数据并放在内存的0x00000处 
mov di,0
mov ds,di

begin:
in ax,dx
mov [di],ax
add di,2
loop begin

jmp 0:0

times  510-($-$$) db 0 
db 0x55,0xaa ; 这行的指令的意思是在511和512字节分别填入0x55，0xaa。这是BIOS对bootloader的要求，即512字节的最后两个字节必须是这两个数，以确实是有效的bootloader。