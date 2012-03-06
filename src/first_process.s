BITS 16
;ORG 10000
;ORG 07D0h

first_process:
	mov ax, 07D0h		; set ds to address 2nd half of MBR 
	mov ds, ax		 
;	mov ss, ax		; setting stack segment
;	mov sp, 005000h


.fstprmsgprint:	
	
;        mov ah,0Eh		; print A and B
;        mov al,65
;        int 10h
;        mov al,66
;        int 10h

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
