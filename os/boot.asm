; 系统引导模块，负责将内核加载器（loader.asm）从磁盘的第2-N个扇区加载至内存的0:0x2000处，然后移交控制权。
mem_start equ 0x2000
mov ah,0x02 ; 读
mov al,0x01 ; 一个扇区
mov ch,0x0  ; 柱面
mov cl,0x2  ; 扇区开始
mov dh,0x0  ; 磁头
mov dl,0x80 ; 硬盘驱动

; es:bx 为缓冲地址,这儿传到0
mov bx,0x0
mov es,bx
mov bx,mem_start  
int 0x13

;dx:ax / bx -> ax（商），dx（余数）
mov ax,[es:mem_start]
mov dx,0
mov bx,512
div bx 

cmp dx,0
jz next
inc ax

next:
dec ax
mov bx,ax
cmp bx,0
jz end

mov ah,0x02 ; 读
mov al,bl   ; bl个扇区
mov ch,0x0  ; 柱面
mov cl,0x3  ; 扇区开始
mov dh,0x0  ; 磁头
mov dl,0x80 ; 硬盘驱动

mov bx,0x0
mov es,bx
mov bx,mem_start+0x200
int 0x13

end: 
jmp 0:mem_start+2

times  510-($-$$) db 0 
db 0x55,0xaa ; 这行的指令的意思是在511和512字节分别填入0x55，0xaa。这是BIOS对bootloader的要求，即512字节的最后两个字节必须是这两个数，以确实是有效的bootloader。