;告诉全局描述符寄存器，全局描述符的信息，这儿指向一个6字节的内存地址。
lgdt [cs:0x7c00+gdtrf]

; 这步也要，为了解决历史遗留问题
in al,0x92 ;南桥芯片内的端口
or al,0000_0010B
out 0x92,al

; 模式切换，中断不能再使用了
cli

; cr0寄存器的第0位如果为1，就表示是保护模式
mov eax,cr0
or eax,1
mov cr0,eax

; 在执行这条命令之前，cr0已置位，并且当前代码段中内容未重置，还是默认的16位，还未加载我们的代码段全局描述符。所以此时处于16位的保护模式。
jmp dword 0x08:next ; 清段状态 0x08 -> 0*0_0000_1000 ; 1号段，也就是第二段

; bits 的使用如果和实际的cpu状态位数不一样，程序解析就会出问题。
[bits 32]
next:
mov eax,0x10
mov ds,eax
mov byte [0],'H'
mov byte [1],0x70
mov byte [2],'I'
mov byte [3],0x70
hlt

gdtrf:
dw 23
dd 0x7c00+gdts

gdts:
; 第一个段必须为0
times 8 db 0

; 第二个段为代码段
dw 0x1ff  ; 段界限的0-15位   0-1
dw 0x7c00 ; 段基址的0-15位   2-3
db 0x00     ; 段基址的16-23位  4
db 1_00_1_1000B  ; 段存在_0特权_代码或数据段_执行,无特权,不能读,未访问          5
db 0_1_0_0_0000B ; 字节粒度_默认32位操作数_不支持64位_无视此位_段界限的16-19位   6
db 0        ; 段基址的24-31位 7   

; 第三个段位数据段,指向显卡
dw 0xffff  ; 段界限的0-15位   0-1
dw 0x8000 ; 段基址的0-15位   2-3
db 0x0B     ; 段基址的16-23位  4
db 1_00_1_0010B  ; 段存在_0特权_代码或数据段_数据段,向上扩展,可写,未访问        5
db 0_1_0_0_0000B ; 字节粒度_默认32位操作数_不支持64位_无视此位_段界限的16-19位   6
db 0        ; 段基址的24-31位 7   

times  510-($-$$) db 0 
db 0x55,0xaa ; 这行的指令的意思是在511和512字节分别填入0x55，0xaa。这是BIOS对bootloader的要求，即512字节的最后两个字节必须是这两个数，以确实是有效的bootloader。