;-----------------------------------------
section header align=16
    entry dw start ; 偏移地址
          dw section.code_main.start ; 段地址
    s_data dw 0x50 ; data段地址，此处保存的值，在加载到内存中，会替换成实际的data段物理地址
;----------------------------------------
section code_main align=16 vstart=0
    start:
    mov ds,[cs:s_data]
    mov si,text
    mov ax,0
    mov di,ax
    mov cx,text_end-text
    call print_hello

    print_hello:
        ; 寄存器状态保护
        push ax
        push es 
        push bx
        push si
        push di

        mov ax,0xb800  
        mov es,ax                   ; 使用es段寻址显存
        begin:
            mov bl,[si]             ; 将字符传入bl寄存器
            inc si

            mov [es:di],bl          ; 将字符写入显存
            inc di
            mov byte [es:di],0x70   ; 将颜色写入显存
            inc di
        loop begin                  ; 循环到cx为0

        ; 寄存器恢复
        pop di
        pop si
        pop bx
        pop es
        pop ax
    ret

    jmp $ 

;------------------------------------
section data align=16 vstart=0
    text db 'hello,world!'
    text_end:

section tail
    progoram_end: