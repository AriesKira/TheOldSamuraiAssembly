pile    segment stack
pile    ends

donnees segment public
include GFX.inc

extrn run1:byte

x dw 10
y dw 100
old_x dw 10
old_y dw 100

icon_width dw 32
icon_height dw 32

floor dw 120

donnees ends

code    segment public

assume cs:code, ds:donnees, es:code, ss:pile

init:         
    call Video13h
    mov AX, donnees
    mov DS, AX

    mov Rx, 0
    mov Ry, 0
    mov Rw, 320
    mov Rh, 200
    mov col, 39
    call fillRect

    call draw_image

main:
    mov userinput, 0
    call PeekKey
    cmp userinput, 27 ; ESC
    jne inputs
    jmp fin

inputs:
    cmp userinput, 75 ; ARROW LEFT
    je move_left
    cmp userinput, 77 ; ARROW RIGHT
    je move_right
    cmp userinput, 32 ; SPACEBAR
    je jump

    mov DX, floor
    cmp y, DX
    jne load_gravity

    ;jmp main

load_gravity:
    add y, 1
    jmp update_image

move_left:
    sub x, 4
    jmp update_image

move_right:
    add x, 4
    jmp update_image

;jump:

update_image:
    mov AX, old_x
    mov Rx, AX
    mov AX, old_y
    mov Ry, AX
    mov AX, icon_width
    mov Rw, AX
    mov AX, icon_height
    mov Rh, AX
    mov col, 39
    call fillRect

    call draw_image
    jmp main

draw_image:
    mov AX, x
    mov old_x, AX
    mov hX, AX

    mov AX, y
    mov old_y, AX
    mov hY, AX

    mov BX, offset run1
    call drawIcon
    mov userinput, 0
    ret

fin:
    mov AH, 4Ch  ; Quitter le programme
    mov AL, 00h  
    int 21h

code    ends
end init
