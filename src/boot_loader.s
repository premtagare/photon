BITS 16

start:
	mov ax, 07C0h		; Set up 4K stack space after this bootloader
	add ax, 20h		; (4096 + 512) / 16 bytes per paragraph
	mov ss, ax
	mov sp, 4096

	mov ax, 07C0h		; Set data segment to where we're loaded
	mov ds, ax


;	mov ah,0Eh		; print A and B on screen
;        mov al,65		; this should check it now
;        int 10h
;        mov al,66
;        int 10h	

;	mov cx,005Eh            ; delay for few micro seconds
;        mov dx,8480h
;        mov ah,86h
;        int 15h

	mov si, text_string	; Put string position into SI
	call print_string	; Call our string-printing routine
	
.ResetSProc:
        mov             ah, 0                                   ; reset floppy disk function
        mov             dl, 0                                   ; drive 0 is floppy drive
        int             13h                                     ; call BIOS
        jc              .ResetSProc                                  ; If Carry Flag (CF) is set, there was an error. Try resetting again

        mov             ax, 2000h                               ; we are going to read sector to into address 0x2000:0
        mov             es, ax
        xor             bx, bx

.ReadSProc:
        mov             ah, 02h                                 ; function 2
        mov             al, 1                                   ; read 1 sector
        mov             ch, 0                                   ; we are reading the second sector past us, so its still on track 0
        mov             cl, 3                                   ; sector to read (The 3rd sector)
        mov             dh, 0                                   ; head number
        mov             dl, 0                                   ; drive number. Remember Drive 0 is floppy drive.
        int             13h                                     ; call BIOS - Read the sector
        jc              .ReadSProc                                   ; Error, so try again

;        jmp             0x2000:0x0                              ; jump to execute the process




.Reset:
	mov		ah, 0					; reset floppy disk function
	mov		dl, 0					; drive 0 is floppy drive
	int		13h					; call BIOS
	jc		.Reset					; If Carry Flag (CF) is set, there was an error. Try resetting again
 
	mov		ax, 1000h				; we are going to read sector to into address 0x1000:0
	mov		es, ax
	xor		bx, bx
 
.Read:
	mov		ah, 02h					; function 2
	mov		al, 1					; read 1 sector
	mov		ch, 0					; we are reading the second sector past us, so its still on track 0
	mov		cl, 2					; sector to read (The second sector)
	mov		dh, 0					; head number
	mov		dl, 0					; drive number. Remember Drive 0 is floppy drive.
	int		13h					; call BIOS - Read the sector
	jc		.Read					; Error, so try again
 
	jmp		0x1000:0x0				; jump to execute the sector!	
	
;	jmp $


	text_string db 'I am awake now, give me a minute I will load OS :-) ', 0

print_string:			; Routine: output string in SI to screen
	mov ah, 0Eh		; int 10h 'print char' function

.repeat:
	lodsb			; Get character from string
	cmp al, 0
	je .done		; If char is zero, end of string
	int 10h			; Otherwise, print it
	jmp .repeat

.done:
	ret

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature
