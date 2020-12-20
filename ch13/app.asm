;----------动态时间显示----------
section header align=16 vstart=0
    entry dw start                  
          dw section.code.start     
    s_lengh dw (s_end-s_begin)/2
    s_begin:
        s_code dw section.code.start  
        s_stack dw section.stack.start
        s_data dw section.data.start  
    s_end:
;----------代码段----------
section code align=16 vstart=0
    start:
        ; 初始化栈段、数据段
        mov ax,[s_stack]
        mov ss,ax
        mov sp,ss_pointer ; 栈自顶向下，所以初始指针要指向栈顶部。
        mov ax,[s_data]
        mov ds,ax

        mov cx,text_end-text
        mov si,text

        ;mov ah,00
        ;mov al,03
        ;int 0x10

    .put:
        mov ah,0x0e
        mov al,[si]
        int 0x10
        inc si
        loop .put

    .read:
        mov ah,0
        int 0x16

        mov ah,0x0e
        mov bl,0x70
        int 0x10
        jmp .read

;----------栈段----------
section stack align=16 vstart=0
    resb 256
    ss_pointer:

;----------数据段----------
section data align=16 vstart=0
    text :db 'isadfsadfsfadasfd'
    text_end: