;-----------------------------------------
section header align=16
    entry dw start              ; 入口的段内偏移地址
          dw section.code.start ; 入口的段首地址
    segment_length dw (s_data-s_code)/2+1
    s_code dw section.code.start ; 代码段首地址
    s_data dw section.data.start ; data段地址，此处保存的值，在加载到内存中，会替换成实际的data段物理地址
;----------------------------------------
section code align=16 vstart=0
    start:
    mov ds,[s_data] ; 此时，ds被loader初始化为本程序头部段，把它指向自己的数据段
    mov si,text
    mov ax,0
    mov di,ax
    mov cx,text_end-text
    call print_hello
    jmp $ 

    print_hello:
        ; 寄存器状态保护
        push ax
        push es 
        push bx
        push si
        push di
        push dx

        mov ax,0xb800  
        mov es,ax                   ; 使用es段寻址显存
        begin:
            call print_char
        loop begin                  ; 循环到cx为0

        mov dx,0x3d4
        mov al,0x0e
        out dx,al
        mov dx,0x3d5
        mov al,0x00
        out dx,al

        mov dx,0x3d4
        mov al,0x0f
        out dx,al
        mov dx,0x3d5
        mov al,80
        out dx,al

        ; 寄存器恢复
        pop dx
        pop di
        pop si
        pop bx
        pop es
        pop ax
    ret

    print_char:
        mov bl,[es:si]
        inc si
        cmp bl,0xa
        je new_line

        mov [es:di],bl          
        inc di
        mov byte [es:di],0x70
        inc di
    ret
    
    new_line:
        add di,0xa0
        inc si
        jmp print_char

;------------------------------------
section data align=16 vstart=0
    text db 'hello,world'
    text_end:

section tail
    progoram_end: