;----------动态时间显示----------
section header align=16
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
    process_interrupt:
        push ax
        push bx
        push cx
        push dx
        push es

        .r:
            mov al,0x0a
            out 0x70,al
            in al,0x71
            test al,0x80  ; 测试第7位是否为1，为1表示当前时钟数据还不能访问
            jnz .r
        
        ; 从cmoss读出时间值
        mov al,0
        out 0x70,al
        in al,0x71  
        push ax     ; 读入秒，压栈

        mov al,2
        out 0x70,al
        in al,0x71  
        push ax     ; 读入分，压栈

        mov al,4
        out 0x70,al
        in al,0x71  
        push ax     ; 读入小时，压栈
        
        mov al,0x0c
        out 0x70,al
        in al,0x71  ; 读c寄存器，仅仅是为了告诉时钟芯片，中断已经处理，可以继续接受新的中断。

        ; 将时间输出到显存中
        mov ax,0xb800
        mov es,ax

        pop ax
        call transter_bcd
        mov [es:0],ah      
        mov byte [es:1],0x70
        mov [es:2],al      
        mov byte [es:3],0x70 ; 小时
        mov byte [es:4],':'      
        mov byte [es:5],0x70 

        pop ax
        call transter_bcd
        mov [es:6],ah      
        mov byte [es:7],0x70
        mov [es:8],al      
        mov byte [es:9],0x70 ; 分钟
        mov byte [es:10],':'      
        mov byte [es:11],0x70 

        pop ax
        call transter_bcd
        mov [es:12],ah      
        mov byte [es:13],0x70
        mov [es:14],al      
        mov byte [es:15],0x70 ; 秒

        mov al,0x20
        out 0xa0,al
        out 0x20,al

        pop es
        pop dx
        pop cx
        pop bx
        pop ax
        iret
    
    ; 将bcd转为字符形式，输入:al,返回ax
    transter_bcd:
        push bx
        push cx
        ; al=0x52 =0101_0010 表示十进制52
        mov bl,al  ; 先赋值给bl al,bl=0101_0010
        shr bl,4   ; bl=0000_0101
        add bl,0x30; bl=0011_0101  5

        mov cl,al   ; cl=0101_0010
        and cl,0x0f ; cl=0000_0010
        add cl,0x30 ; cl=0011_0010 2

        mov ah,bl
        mov al,cl   

        pop cx
        pop bx
        ret

    start:
        ; 初始化栈段、数据段
        mov ax,s_stack
        mov ss,ax
        mov sp,ss_pointer ; 栈自顶向下，所以初始指针要指向栈顶部。
        mov ax,s_data
        mov ds,ax

        ; 计算时钟芯片的中断向量地址
        mov al,0x70 ; 8259从芯片默认中断号为0x70，并且刚好0引脚对应的设备就是时钟芯片。
        mov bl,4
        mul bl
        mov bx,ax   ; 计算时钟芯片的中断向量
        cli         ; 防止此时发生对应中断，导致程序错乱。

        ; 写入自己的中断处理程序地址
        push es              
        mov ax,0
        mov es,ax
        mov word [es:bx],process_interrupt ; 先写入偏移地址
        mov word [es:bx+2],cs         ; 再写入段地址
        pop es

        ; 设置时钟芯片的寄存器状态，告诉它可以发送中断
        mov al,0x0b ; 这个值表示cmoss的第0x0b地址，保存着时钟芯片的b寄存器状态。
        out 0x70,al ; 不要和之前的0x70混淆，这个是cmoss的内存索引端口，此端口要传入需要访问cmoss的内部地址。
        mov al,0x12 ; 00010010
        out 0x71,al ; 0x71是cmoss的数据端口，传入0x12，请参考b寄存器各位的标志含义。

        ; 必须读一下c寄存器，不然中断不会开始
        mov al,0x0c ; c寄存器
        out 0x70,al
        in al,0x71  

        ; 设置8259的IMR寄存器，使可以通过时钟芯片连接的引脚的中断。
        in al,0xa1  ; 这个端口就可以访问IMR。
        and al,0xfe  ; 将第0位置位零,它正好连着时钟芯片，置零表示中断可以送到cpu
        out 0xa1,al ; 写回

        ; 设置cpu可以接受中断
        sti

        mov cx,0xb800
        mov ds,cx
        mov byte [12*160 + 33*2],'@'
        mov byte [12*160 + 33*2+1],0x70

    .idle:
        hlt
        not byte [12*160 + 33*2+1]
        jmp .idle

;----------栈段----------
section stack align=16 vstart=0
    resb 256
    ss_pointer:

;----------数据段----------
section data align=16 vstart=0