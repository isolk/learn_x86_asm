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


; 读取数据并放在内存的0x10000处 
mov di,0
mov ax,0x1000
mov ds,ax

begin:
in ax,dx ; 从dx端口读，写入ax
mov [di],ax
add di,2
loop begin

; 程序已经读取完，并存放到0x10000-0x10200处

; 进行段地址替换，换成实际的物理地址
mov ax,[2] ;入口的段首地址，要将其替换成目前的物理地址段。[2]=0x10,ax=0x10
shr ax,4   ;右移四位，除以16，得到段地址。 ax=0x01
add ax,0x1000 ; ax=0x1001
mov [2],ax; [2]=0x1001，这个地址会作为jmp far的段地址，也就是赋给cs寄存器。

; 段内偏移地址不需要动，实际也为0，jmp far命令会直接取它作为IP的值。
; 所以此时访问如果调用访问 jmp far [0],就是跳转到 0x1001:0处，也就是物理地址的0x10010处，而我们的要执行的第一条程序指令，也就是加载到内存的这个位置。

; 更改代码段的段地址
mov ax,[4]
shr ax,4
add ax,0x1000;
mov [4],ax;

; 更改数据段的首地址
mov ax,[6]
shr ax,4
add ax,0x1000;
mov [6],ax;

;初始化ds和es，指向用户程序的头地址处
mov ax,0x1000
mov ds,ax  
mov es,ax 

jmp far [0]

times  510-($-$$) db 0 
db 0x55,0xaa ; 这行的指令的意思是在511和512字节分别填入0x55，0xaa。这是BIOS对bootloader的要求，即512字节的最后两个字节必须是这两个数，以确实是有效的bootloader。