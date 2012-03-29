BITS 16
;ORG 10000
;ORG 07D0h

first_process:
	mov ax, 1000h		; 
	mov ds, ax
	mov ax, 1500h		 
	mov ss, ax		; setting stack segment
	mov sp, 5000h


.fstprmsgprint:	
	
	mov si, fstpr_text_string	; Put string position into SI
	call fstpr_print_string	; Call our string-printing routine
        
	mov cx,005Eh		; delay for few micro seconds
	mov dx,8480h
	mov ah,86h
	int 15h
	jmp .fstprmsgprint			; print message infinitely


	fstpr_text_string db 'This is first process ', 0

fstpr_print_string:			; Routine: output string in SI to screen
	mov ah, 0Eh		; int 10h 'print char' function

.fstprrepeat:
	lodsb			; Get character from string
	cmp al, 0
	je .fstprdone		; If char is zero, end of string
	int 10h			; Otherwise, print it
	jmp .fstprrepeat

.fstprdone:
	ret
