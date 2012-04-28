BITS 16

start:
	mov ax, 07C0h		; Set up 4K stack space after this bootloader
	add ax, 20h		; (4096 + 512) / 16 bytes per paragraph
	mov ss, ax
	mov sp, 4096
	mov ax, 07C0h		; Set data segment to where we're loaded
	mov ds, ax

	mov ah,0Eh		; print BL on screen
        mov al,66		
        int 10h
        mov al,76
        int 10h	

	mov si, text_string	; Put string position into SI
	call print_string	; Call our string-printing routine
	
.ResetSProc:
        mov             ah, 0                                   ; reset floppy disk function
        mov             dl, 0                                   ; drive 0 is floppy drive
        int             13h                                     ; call BIOS
        jc              .ResetSProc                             ; If Carry Flag (CF) is set, there was an error. Try resetting again

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
        jc              .ReadSProc                              ; Error, so try again

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

	;programming PIT
        ; COUNT = input hz / frequency
        mov     dx, 1193180 / 20       				; 20hz, or 50 milliseconds

        ; FIRST send the command word to the PIT. Sets binary counting,
        ; Mode 3, Read or Load LSB first then MSB, Channel 0

;        mov     al,00110110b
        mov     al,36h
        out     43h, al

        ; Now we can write to channel 0. Because we set the "Load LSB first then MSB" bit, that is
        ; the way we send it

        mov     ax, dx
        out     0x40, al        ;LSB
        xchg    ah, al
        out     0x40, al        ;MSB

	mov ax,0h 	
	mov es,ax
	pushf
	cli
	mov word [es:1ch*4],mytmr
	mov word [es:1ch*4+2],07C0h
	sti
	popf

	jmp		0x1000:0x0				; jump to execute first process!	
	
	jmp $							; In case something is wrong.
	
	text_string db 'I am awake now, give me a minute I will load OS :-) ', 0
	oldss  dw 2500h
	oldds  dw 2000h
	oldcs  dw 2000h
	oldes  dw 2000h
	oldsp  dw 5000h
	oldsi  dw 0h

	newss  dw 2500h
	newds  dw 2000h
	newcs  dw 2000h
	newes  dw 2000h
	newsp  dw 5000h
	newsi  dw 0h
	
	timespent dw 00h
	firsttime db 0

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

mytmr:
	pusha			; save all registers (16-bit)
	mov ah,0Eh		; print TMR on screen
        mov al,84		
        int 10h
        mov al,77
        int 10h
	mov al,82
	int 10h
	
	mov cx,ds		; change data segment to timer's ds
	mov ax,0x07C0
	mov ds,ax

	mov dx,0		; task switch for every 0.5 second
	mov ax,[timespent]
	add ax,1
	mov [timespent],ax
	mov bx,10		
	div bx
	cmp dx,0
	jne .skipswitch		; if it is less than 500ms then don't switch
	
	mov ax,[oldss]		; storing previous segment registers into new before switching task
	mov [newss],ax
	mov ax,[oldds]
	mov [newds],ax
	mov ax,[oldes]
	mov [newes],ax

	mov ax,ss		; store current segment registers before task switching
	mov [oldss],ax		; note cs is not stored since it is read from stack along with pc during iret	
	mov ax,cx
	mov [oldds],ax	
	mov ax,es
	mov [oldes],ax

	mov al,[firsttime]	; If it is first time then set up second process
	cmp al,0
	jnz .normalswitch	; If it not first time then we already have two processes so we can go ahead and execute other one
	mov byte [firsttime],1h

	;Fun starts here, time to set up second process manually
	;we cannot just modify second process's stack to have new IP, CS, flags and assume magic to happen.
	;We need to take care of many things
	
	;copy stack		
	mov ax,0x2500
	mov es,ax
	mov ax,sp
	mov si,ax
.copynext:
	mov ax,[ss:si]
	mov [es:si],ax
	add si,2
	cmp si,5000h
	jle .copynext

	mov si,0x4FFA
	mov word [es:si],0x0000
	mov si,0x4FFC
	mov word [es:si],0x2000
	mov ax,2500h
	mov ss,ax
	jmp .inthndldone

.normalswitch:
	mov ax,[newss]
	mov ss,ax
	mov ax,[newes]
	mov es,ax
	mov ax,[newds]		; make sure you modify ds in the end to make your life easy.
	mov ds,ax
	jmp .inthndldone

.skipswitch:
	mov ds,cx
.inthndldone:
	popa
	iret

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature
