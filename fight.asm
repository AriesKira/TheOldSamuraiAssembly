pile    segment stack
pile    ends

donnees segment public
include GFX.inc

extrn run1:byte
extrn run2:byte
extrn run3:byte
extrn run4:byte
extrn run5:byte
extrn run6:byte
extrn run7:byte

extrn sol:byte

extrn fenemy1:byte
extrn senemy1:byte

x dw 10
y dw 100
old_x dw 10
old_y dw 100

icon_width dw 32
icon_height dw 32

player_speed dw 4

floor dw 120
jump_value dw 0
jump_velocity dw 40
is_jump dw 0
jump_state dw 0

right_limit dw 290
left_limit dw 0

run_frame dw 1

enemy_x dw 270
enemy_y dw 121
bullet_x dw 270
bullet_y dw 10
is_shooting dw 0

shoot_interval dw 300

bullet_active dw 0
shoot_timer dw 0

bullet_speed dw 3
bullet_counter dw 0

enemy_type dw 0  ; 0 = fenemy1, 1 = senemy1

enemy_shoot_speed dw 3

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

    mov hX, 20
    mov hY, 152
    mov BX, offset sol
    call drawIcon

    mov hX, 270
    mov hY, 121
    mov BX, offset fenemy1
    call drawIcon

    call draw_image

move_left:
    mov DX, left_limit
    cmp x, DX
    jl main

    mov DX, player_speed
    sub x, DX

    call update_run_frame
    jmp update_image

move_right:
    mov DX, right_limit
    cmp x, DX
    jg main

    mov DX, player_speed
    add x, DX

    call update_run_frame
    jmp update_image

inputs:
    cmp userinput, 75 ; ARROW LEFT
    je move_left
    cmp userinput, 77 ; ARROW RIGHT
    je move_right
    cmp userinput, 32 ; SPACEBAR
    je check_jump

    mov DX, floor
    cmp y, DX
    jne load_gravity

    mov is_jump, 0
    jmp main

check_jump:
    cmp is_jump, 1
    je main

    jmp jump

load_gravity:
    add y, 1
    jmp update_image

main:
    call check_shoot_timer
    mov BX, enemy_shoot_speed
    mov tempo, BX
    call sleep
    call move_bullet
    call check_collision
    call check_enemy_collision

    mov userinput, 0
    call PeekKey
    cmp userinput, 27 ; ESC
    jne inputs
    jmp fin

check_enemy_collision:
    mov DX, 5  ; Marge de tolérance sinon trop dur
    mov AX, x
    add AX, icon_width
    cmp AX, enemy_x
    jl return_enemy_collision

    mov BX, enemy_x
    add BX, icon_width
    cmp x, BX
    jg return_enemy_collision

    mov AX, y
    add AX, icon_height
    cmp AX, enemy_y
    jl return_enemy_collision

    mov BX, enemy_y
    add BX, icon_height
    cmp y, BX
    jg return_enemy_collision

    jmp enemy_touched

return_enemy_collision:
    ret

enemy_touched:
    cmp enemy_type, 0
    jne restart_game
    sub enemy_shoot_speed, 2
    mov enemy_type, 1   ; Change l'ennemi en senemy1
    jmp restart_game

restart_game:
    call erase_old_position
    call reset_game
    jmp main

reset_game:
    mov x, 10
    mov y, 100
    mov old_x, 10
    mov old_y, 100
    mov enemy_x, 270
    mov enemy_y, 121
    mov bullet_active, 0
    mov shoot_timer, 0

    mov hX, 20
    mov hY, 152
    mov BX, offset sol
    call drawIcon

    cmp enemy_type, 0
    je load_fenemy1

    mov BX, offset senemy1
    jmp draw_enemy_icon

load_fenemy1:
    mov BX, offset fenemy1

draw_enemy_icon:
    mov DX, enemy_x
    mov hX, DX
    mov DX, enemy_y
    mov hY, DX
    call drawIcon
    ret

erase_old_position:
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
    ret

check_shoot_timer:
    cmp shoot_timer, 0
    jle enemy_shoot

    dec shoot_timer
    ret

enemy_shoot:
    cmp bullet_active, 1
    je return_shoot

    mov bullet_active, 1
    mov AX, enemy_x
    mov bullet_x, AX
    mov AX, enemy_y
    add AX, 20   ; ↓ Décale le projectile de 10 pixels vers le bas
    mov bullet_y, AX
    mov shoot_timer, 0
return_shoot:
    ret

move_bullet:
    cmp bullet_active, 0
    je return_move

    mov AX, left_limit
    cmp bullet_x, AX
    jle reset_bullet

    mov DX, bullet_x
    mov cCX, DX
    mov DX, bullet_y
    mov cDX, DX
    mov col, 39
    call BigPixl

    dec bullet_x

    mov CX, bullet_x
    mov cCX, CX
    mov CX, bullet_y
    mov cDX, CX
    mov col, 1
    call BigPixl

return_move:
    ret

reset_bullet:
    mov bullet_active, 0
    ret

update_run_frame:
    mov AX, run_frame
    cmp AX, 7
    je reset_run_frame
    inc run_frame
    ret

reset_run_frame:
    mov run_frame, 1
    ret

jump:
    mov is_jump, 1
    mov jump_state, 1
    sub y, 1
    inc jump_value

    mov DX, jump_velocity
    cmp DX, jump_value
    jne update_image

    mov jump_state, 0
    mov jump_value, 0
    jmp update_image

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

    cmp jump_state, 1
    je jump

    jmp main

draw_image:
    mov AX, x
    mov old_x, AX
    mov hX, AX

    mov AX, y
    mov old_y, AX
    mov hY, AX

    mov AX, run_frame
    cmp AX, 1
    je load_run1
    cmp AX, 2
    je load_run2
    cmp AX, 3
    je load_run3
    cmp AX, 4
    je load_run4
    cmp AX, 5
    je load_run5
    cmp AX, 6
    je load_run6
    cmp AX, 7
    je load_run7

load_run1:
    mov BX, offset run1
    jmp draw_icon_call
load_run2:
    mov BX, offset run2
    jmp draw_icon_call
load_run3:
    mov BX, offset run3
    jmp draw_icon_call
load_run4:
    mov BX, offset run4
    jmp draw_icon_call
load_run5:
    mov BX, offset run5
    jmp draw_icon_call
load_run6:
    mov BX, offset run6
    jmp draw_icon_call
load_run7:
    mov BX, offset run7
    jmp draw_icon_call

check_collision:
    cmp bullet_active, 0
    je return_collision

    mov DX, 5  ; Marge de 5 pixels sinon trop dur

    mov AX, bullet_x
    add AX, DX
    cmp AX, x
    jl return_collision

    mov BX, x
    add BX, icon_width
    sub BX, DX
    cmp AX, BX
    jg return_collision

    mov AX, bullet_y
    add AX, DX
    cmp AX, y
    jl return_collision

    mov BX, y
    add BX, icon_height
    sub BX, DX
    cmp AX, BX
    jg return_collision

    jmp collision_detected

check_x_end:
    mov BX, x
    add BX, icon_width
    cmp AX, BX
    jg return_collision

check_y_collision:
    mov AX, bullet_y
    cmp AX, y
    jl return_collision
    cmp AX, y
    jg check_y_end
    jmp collision_detected

check_y_end:
    mov BX, y
    add BX, icon_height
    cmp AX, BX
    jg return_collision

return_collision:
    ret

collision_detected:
    call blackout_screen
    jmp fin

blackout_screen:
    mov Rx, 0
    mov Ry, 0
    mov Rw, 320
    mov Rh, 200
    mov col, 0
    call fillRect
    ret

draw_icon_call:
    call drawIcon
    mov userinput, 0
    ret

fin:
    mov AH, 4Ch  ; Quitter le programme
    mov AL, 00h  
    int 21h

code    ends
end init