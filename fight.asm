.model huge
pile    segment stack
pile    ends

donnees segment public
include GFX.inc
extrn image:byte

donnees ends

donnees2 segment public
extrn image1:byte
donnees2 ends

code    segment public
x dw 0  ; Déclaration de la variable x
y dw 0  ; Déclaration de la variable y
assume cs:code, ds:donnees, es:code, ss:pile

myprog:         ; debut de la zone instructions
main: 


    call Video13h
    mov AX, donnees
    mov DS, AX
    ; Affiche l'image de map 1 
    mov BX, offset image
    call drawIcon
    mov DX, 100  ; Position X initiale
    mov x, DX
    mov DX, 100  ; Position Y initiale
    mov y, DX

    mov AX, donnees2
    mov DS, AX
    mov BX, offset image1
    call drawIcon

main_loop:
    call PeekKey
    cmp userinput, 0
    je main_loop
    
    ; Efface l'image à l'ancienne position
    mov ax, x
    mov Rx, ax
    mov ax, y
    mov Ry, ax
    mov Rw, 32  ; Largeur de l'image (à ajuster selon la taille de votre image)
    mov Rh, 32  ; Hauteur de l'image (à ajuster selon la taille de votre image)
    mov col, 15  ; Couleur de fond (blanc)
    call fillRect

    ; Met à jour les coordonnées en fonction des touches du clavier
    cmp userinput, 72
    je moove_up
    cmp userinput, 80
    je moove_down
    cmp userinput, 75
    je moove_left
    cmp userinput, 77
    je moove_right
    cmp userinput, 27
    je fin
    jmp draw_image

moove_up:
    sub y, 10
    jmp draw_image

moove_down:
    add y, 10
    jmp draw_image

moove_left:
    sub x, 10
    jmp draw_image

moove_right:
    add x, 10
    jmp draw_image

draw_image:
    ; Redessine l'image à la nouvelle position
    mov ax, x
    mov Hx, ax
    mov ax, y
    mov hY, ax
    mov AX, donnees2
    mov DS, AX
    mov BX, offset image1
    call drawIcon

    mov userinput, 0
    jmp main_loop

fin:
    mov AH, 4Ch  ; 4Ch = fonction exit DOS
    mov AL, 00h  ; code de sortie 0 (OK)
    int 21h

code    ends               ; Fin du segment de code

end myprog                 ; Fin du programme