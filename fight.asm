pile    segment stack
pile    ends

donnees segment public
include GFX.inc

extrn run1:byte

x dw 10      ; Position X initiale
y dw 100     ; Position Y initiale
old_x dw 10  ; Ancienne position X
old_y dw 100 ; Ancienne position Y

icon_width dw 32  ; Largeur de l'icône (ajuste selon ton image)
icon_height dw 32 ; Hauteur de l'icône (ajuste selon ton image)

donnees ends

code    segment public

assume cs:code, ds:donnees, es:code, ss:pile

init:         
    call Video13h  ; Active le mode vidéo 13h
    mov AX, donnees
    mov DS, AX

    ; Dessiner le fond initial
    mov Rx, 0
    mov Ry, 0
    mov Rw, 320
    mov Rh, 200
    mov col, 39
    call fillRect

    call draw_image  ; Dessiner l'image initiale

main:
    mov userinput, 0
    call PeekKey
    cmp userinput, 27 ; ESC
    jne continue
    jmp fin           ; Utiliser JMP pour éviter l'erreur de saut

continue:
    cmp userinput, 72
    je move_up
    cmp userinput, 80
    je move_down
    cmp userinput, 75
    je move_left
    cmp userinput, 77
    je move_right

    jmp main

move_up:
    sub y, 10
    jmp update_image

move_down:
    add y, 10
    jmp update_image

move_left:
    sub x, 10
    jmp update_image

move_right:
    add x, 10
    jmp update_image

update_image:
    ; Effacer l'ancienne image en remplissant la zone avec la couleur de fond
    mov AX, old_x
    mov Rx, AX       ; Position X de l'ancien sprite
    mov AX, old_y
    mov Ry, AX       ; Position Y de l'ancien sprite
    mov AX, icon_width
    mov Rw, AX       ; Largeur de l'icône
    mov AX, icon_height
    mov Rh, AX       ; Hauteur de l'icône
    mov col, 39      ; Couleur de fond
    call fillRect    ; Effacer l'ancienne image

    call draw_image  ; Dessiner l'image à la nouvelle position
    jmp main

draw_image:
    ; Sauvegarder l'ancienne position
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
