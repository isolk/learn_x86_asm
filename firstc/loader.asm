;boot.asm 加载loader至内存0x0处,同时跳转。在loader首部会写入loader的大小，以告知需要加载的扇区数
mov ah,0x02 ; 读
mov al,0x01 ; 一个扇区
mov ch,0x0  ; 柱面
mov cl,0x2  ; 扇区开始
mov dh,0x0  ; 磁头
mov dl,0x80 ; 硬盘驱动

; es:bx 为缓冲地址,这儿传到0
mov bx,0x0
mov es,bx
mov bx,0x2000  
int 0x13

;dx:ax / bx -> ax（商），dx（余数）
mov ax,[es:0x2000]
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
mov bx,0x2200 
int 0x13

end: 
jmp 0:0x2002

times  510-($-$$) db 0 
db 0x55,0xaa ; 这行的指令的意思是在511和512字节分别填入0x55，0xaa。这是BIOS对bootloader的要求，即512字节的最后两个字节必须是这两个数，以确实是有效的bootloader。