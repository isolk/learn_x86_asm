;使用第二种方式打印hello,world
mov ax,0xb800  ; 这个地址是显存文字模式的起始地址,在此处开始填入字符的ASCII码，就会在屏幕上显示字符。
mov es,ax      ; 使用[bx]形式寻址，默认是使用ds的值作为基本地址。

mov ax,0x07c0  ; 程序加载到内存的物理地址为0x07c00
mov ds,ax
;---------------------
mov cx,inf-text ; 循环次数
mov si,text
mov di,0

begin:
mov al,[si]
mov [es:di],al
inc si
inc di

mov byte [es:di],0x70
inc di

dec cx
cmp cx,0

jg begin

text db 'hello,world!'
;--------------------

inf:jmp $ ;这个指令表示跳转到当前位置，也就是循环跳转当前位置，无限循环，防止cpu继续向下运行。

; times 表示当前指令执行多少次。
; $表示当前指令地址，$$表示起始地址，也就是0。
; db表示高速编译器在当前地址填入一个0
; 这行指令的意思就是当上述指令的长度不足510字节时，剩余的部分填入0
times  510-($-$$) db 0 

db 0x55,0xaa ; 这行的指令的意思是在511和512字节分别填入0x55，0xaa。这是BIOS对bootloader的要求，即512字节的最后两个字节必须是这两个数，以确实是有效的bootloader。
