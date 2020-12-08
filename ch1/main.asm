mov ax,0xb800  ; 这个地址是显存文字模式的起始地址,在此处开始填入字符的ASCII码，就会在屏幕上显示字符。
mov ds,ax      ; 使用[bx]形式寻址，默认是使用ds的值作为基本地址。

;---------------------
xor bx,bx          ; 将bx值变为0
mov byte [bx],'h'  ; 在ds:bx,也就是0xb8000处传入'h'的ASCII码
inc bx             ; 将bx的值增加1，此时bx值为1
mov byte [bx],0x70 ; 在0xb8000处传入0x70，这个0x70表示'h'子字符以白底黑字的颜色显示

;剩下的逻辑类似，不断增加bx值，然后传入对应字符和对应的颜色属性
inc bx
mov byte [bx],'e'  
inc bx
mov byte [bx],0x70
inc bx
mov byte [bx],'l'
inc bx
mov byte [bx],0x70
inc bx
mov byte [bx],'l'  
inc bx
mov byte [bx],0x70
inc bx
mov byte [bx],'o'
inc bx
mov byte [bx],0x70
inc bx
mov byte [bx],','
inc bx
mov byte [bx],0x70
inc bx
mov byte [bx],'w'
inc bx
mov byte [bx],0x70
inc bx
mov byte [bx],'o'
inc bx
mov byte [bx],0x70
inc bx
mov byte [bx],'r'
inc bx
mov byte [bx],0x70
inc bx
mov byte [bx],'l'
inc bx
mov byte [bx],0x70
inc bx
mov byte [bx],'d'
inc bx
mov byte [bx],0x70
;---------------

jmp $ ;这个指令表示跳转到当前位置，也就是循环跳转当前位置，无限循环，防止cpu继续向下运行。

; times 表示当前指令执行多少次。
; $表示当前指令地址，$$表示起始地址，也就是0。
; db表示高速编译器在当前地址填入一个0
; 这行指令的意思就是当上述指令的长度不足510字节时，剩余的部分填入0
times  510-($-$$) db 0 

db 0x55,0xaa ; 这行的指令的意思是在511和512字节分别填入0x55，0xaa。这是BIOS对bootloader的要求，即512字节的最后两个字节必须是这两个数，以确实是有效的bootloader。
