section code align=128:
mov ax,0
mov ax,section.data.start
mov ax,section.const_data.start
mov ax,name
mov ax,num

section data align=16 vstart=0:
name db 'yht'

section const_data align=16:
num db 0xFF
