;使用第二种方式打印hello,world
mov ax,0xb800  ; 这个地址是显存文字模式的起始地址,在此处开始填入字符的ASCII码，就会在屏幕上显示字符。
mov es,ax      ; 使用[bx]形式寻址，默认是使用ds的值作为基本地址。

;---------------------
mov ax,cs
mov ds,ax ; 代码段和数据段一致

mov cx,text_end-text
mov di,0 
mov si,text

begin:
mov bl,[si]
inc si

mov [es:di],bl
inc di
mov byte [es:di],0x70
inc di
loop begin

jmp $ ;这个指令表示跳转到当前位置，也就是循环跳转当前位置，无限循环，防止cpu继续向下运行。

text db 'hello,world!'
text_end:
;--------------------