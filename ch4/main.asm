;使用第二种方式打印hello,world
mov ax,0xb800  ; 这个地址是显存文字模式的起始地址,在此处开始填入字符的ASCII码，就会在屏幕上显示字符。
mov es,ax      ; 使用[bx]形式寻址，默认是使用ds的值作为基本地址。

mov ax,0x07c0  ; 程序加载到内存的物理地址为0x07c00
mov ds,ax
;---------------------
mov ax,0
mov ss,ax ; 初始化栈段地址
mov sp,ax ; 初始化栈指针地址

mov cx,(text_end-text)/2 ; 循环次数
mov si,text ; 数据源源偏移地址,指向内存
mov di,0 ; 目标偏移地址，指向显存

begin1:
push word [si]
times 2 inc si
loop begin1

mov cx,(text_end-text)/2
begin2:
pop word [es:di]
times 2 inc di
loop begin2

jmp $ ;这个指令表示跳转到当前位置，也就是循环跳转当前位置，无限循环，防止cpu继续向下运行。
text: db 'h',0x70,'e',0x70,'l',0x70,'l',0x70,'o',0x70,',',0x70,'w',0x70,'o',0x70,'r',0x70,'l',0x70,'d',0x70
;--------------------
; times 表示当前指令执行多少次。
; $表示当前指令地址，$$表示起始地址，也就是0。
; db表示高速编译器在当前地址填入一个0
; 这行指令的意思就是当上述指令的长度不足510字节时，剩余的部分填入0
text_end: times  510-($-$$) db 0 

db 0x55,0xaa ; 这行的指令的意思是在511和512字节分别填入0x55，0xaa。这是BIOS对bootloader的要求，即512字节的最后两个字节必须是这两个数，以确实是有效的bootloader。
