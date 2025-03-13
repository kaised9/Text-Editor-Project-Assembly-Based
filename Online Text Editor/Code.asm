.model small
.stack 100h


.data
posX      db 1 dup(0)        ;posX :row
posY      db 1 dup(0)        ;posY :column
matrix    db 80*25 dup(' ')  
curr_line dw ?
curr_char dw ?
color     db 2*16+15

filename db "KaiSed.txt",0   ;File path
handler dw ?                  
length dw ?                   

start_menu_str dw '  ',0ah,0dh

dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw ' ',0ah,0dh
dw '                ====================================================',0ah,0dh
dw '               ||                                                  ||',0ah,0dh                                        
dw '               ||      Welcome To Assembly Based - Text Editor     ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||--------------------------------------------------||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh          
dw '               ||             Please Type Text Here                ||',0ah,0dh
dw '               ||        Press ESC To Exit The Program.            ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '               ||             Press Enter To Start                 ||',0ah,0dh 
dw '               ||                                                  ||',0ah,0dh
dw '               ||                                                  ||',0ah,0dh
dw '                ====================================================',0ah,0dh
dw '$',0ah,0dh

error_msg db "Error !!! Could not save file.", 0dh, 0ah, '$'


.code

    mov  ax,@data
    mov  ds,ax
  
    call main_menu              
    
start_prog:
    call clear_screen
    jmp program
    
program:                        

    mov  curr_line, offset matrix
    mov  curr_char, 0

start:
    call read_char
    


;Display
any_char:
    mov  ah, 9
    mov  bh, 0
    mov  bl, color                            
    mov  cx, 1           
    int  10h 

    
    mov  si, curr_line   
    add  si, curr_char   
    mov  [ si ], al      
    inc  length          


moveRight:
    inc  curr_char      
    mov  dl, posX
    mov  dh, posY
    inc  dl              
    mov  posX, dl
    jmp  prntCrs

moveLeft:
    dec  curr_char       
    mov  dl, posX
    mov  dh, posY
    dec  dl             
    mov  posX, dl
    jmp  prntCrs

moveUp: 
    sub  curr_line, 80   
    mov  dl, posX
    mov  dh, posY
    dec  dh              
    mov  posY, dh
    jmp  prntCrs         

moveDown:   
    add  curr_line, 80   
    mov  dl, posX
    mov  dh, posY
    inc  dh             
    mov  posY, dh
    jmp  prntCrs 

moveNewLine:        
    mov si, curr_line
    add si, 79
    mov [si], 0dh
    add curr_line, 80
    mov curr_char, 0
    mov posX, 0
    mov dl, posX
    mov dh, posY
    inc dh
    mov posY, dh
    add length, 80
    jmp prntCrs

moveToBeginning:
    mov curr_char, 0
    mov posX, 0
    mov dl, posX
    jmp prntCrs
    
backSpace:
    cmp curr_char, 0
    je  preventBackSpace

    dec curr_char
    mov si, curr_line   
    add si, curr_char   
    mov [ si ], ' '     
    dec length          

    dec posX
    mov dl, posX

    mov  ah, 2h
    int  10h

    mov  al,' '
    mov  ah, 9
    mov  bh, 0
    mov  bl, 0000
    mov  cx, 1
    int  10h
    jmp prntCrs

prntCrs:               
    mov  ah, 2h
    int  10h
    jmp  start

fin:
    int  20h
    
saveToFile:
   
    mov  ah, 3Ch
    mov  cx, 0                
    mov  dx, offset filename
    int  21h

    jc   save_error         
    mov  handler, ax          

   
    mov  ah, 40h
    mov  bx, handler
    mov  cx, length          
    mov  dx, offset matrix   
    int  21h
    jc   save_error           

    mov  ah, 3Eh
    mov  bx, handler
    int  21h
    jmp  fin                  

save_error:
    mov  dx, offset error_msg 
    mov  ah, 09h              
    int  21h                 
    jmp  fin

preventBackSpace:
    call read_char

                                                                           ;;
clear_screen proc near
        mov ah,0             
        mov al,3             
        int 10h        
        ret
clear_screen endp

main_menu proc
    mov ah,09h
    mov dh,0
    mov dx, offset start_menu_str
    int 21h
    
    input:      
        mov  ah, 0
        int  16h
        cmp  al, 27          
        je   fin
        cmp  ax, 1C0Dh      
        je   start_prog
        jmp input
    
main_menu endp

read_char proc
    mov  ah, 0
    int  16h  

    cmp  al, 27          ; ESC
    je   fin
    cmp  ax, 4800h       ; Up
    je   moveUp
    cmp  ax, 4B00h       ; Left
    je   moveLeft
    cmp  ax, 4D00H       ; Rihht
    je   moveRight
    cmp  ax, 5000H       ; Down
    je   moveDown
    cmp  al, 0Dh         ; Enter
    je   moveNewLine
    cmp  ax, 4700H       ; Home
    je   moveToBeginning
    cmp  al, 08h         ; Backspace
    je   backSpace
    cmp  al, 13h         ; Ctrl+S
    je   saveToFile

    jmp  any_char
read_char endp 

end
