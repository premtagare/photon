BITS 16
;ORG 10000
;ORG 07C00h

second_process:
	mov ax, 2000h		; second process is located at 20000h 
	mov ds, ax		; setting data segment
	mov ax, 2500h
	mov ss, ax		; setting stack segment
	mov sp, 5000h

	mov ah,0Eh		; print SE
	mov al,83
	int 10h
	mov al,69
	int 10h

.scndprmsgprint:	
	mov si, scndpr_text_string	; Put string position into SI
	call scndpr_print_string	; Call our string-printing routine
        
	mov cx,005Eh			; delay for few micro seconds
	mov dx,8480h
	mov ah,86h
	int 15h
	jmp .scndprmsgprint		; print message continuously

	scndpr_text_string db 'This is second process ', 0

scndpr_print_string:			; Routine: output string in SI to screen
	mov ah, 0Eh			; int 10h 'print char' function

.scndprrepeat:
	lodsb				; Get character from string
	cmp al, 0
	je .scndprdone			; If char is zero, end of string
	int 10h				; Otherwise, print it
	jmp .scndprrepeat

.scndprdone:
	ret
