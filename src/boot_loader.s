BITS 16

start:
	mov ax, 07C0h		; Set up 4K stack space after this bootloader
	add ax, 512		; (4096 + 512) / 16 bytes per paragraph
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
	
	

	jmp 0x07C0:0x100		; Jump to first process.


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
