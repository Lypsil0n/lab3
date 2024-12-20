.data
    inBuf: .space 64
    inPos: .quad 0

    outBuf: .space 64
    outPos: .quad 0

.text
# Inmatning
.global inImage
inImage:
    subq $8, %rsp

    leaq inBuf(%rip), %rdi
    movq $63, %rsi
    movq stdin, %rdx

    call fgets
    
    movq $0, inPos(%rip)

    addq $8, %rsp 
    ret

.global getInt
getInt:

.global getText
getText:

.global getChar
getChar:
 
.global getInPos
getInPos:
    movq inPos, %rax
    ret

.global setInPos
setInPos:

# Utmatning
.global outImage
outImage:
    subq $8, %rsp

    leaq outBuf(%rip), %rdi

    call puts
    
    movq $0, outPos(%rip) 
    addq $8, %rsp 
    ret

.global putInt
putInt:

.global putText
putText:
    mov %rdi, %rbx                      # %rdi innehåller strängen som ska läsas
    leaq outBuf(%rip), %rdi             # ladda utbufferten
    movq outPos(%rip), %rsi             # ladda nuvarande outPos

putText_loop:
    movb (%rbx), %al                    # ladda tecken från strängen
    testb %al, %al                      # kolla ifall tecknet är NULL
    je putText_done                     # om null, gå till slutet

    cmp $64, %rsi                       # kolla ifall bufferten är full
    je flush_buffer                     # om den är tom, flusha bufferten

    movb %al, (%rdi, %rsi, 1)           # skriv tecknet till utbufferten
    inc %rsi                            # öka nuvarande position i bufferten
    inc %rbx                            # gå till nästa tecken
    jmp putText_loop                    # repetera

flush_buffer:
    movb $0, (%rdi, %rsi, 1)   # nullterminate bufferten
    call outImage              # skriv ut bufferten

    jmp putText_loop           # fortsätt

putText_done:
    mov %rsi, outPos(%rip)              # uppdatera outPos
    movb $0, (%rdi, %rsi, 1)
    ret


.global putChar
putChar:

.global getOutPos
getOutPos:
    movq outPos, %rax
    ret

.global setOutPos
setOutPos:
