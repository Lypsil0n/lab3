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
    leaq inBuf(%rip), %rdi             # ladda inbufferten
    movq inPos(%rip), %rsi             # ladda nuvarande inPos

    cmpb $0, (%rdi,%rsi,1)             # kolla ifall bufferten är tom
    je callInImage

parse_number:
    movq $1, %rbx               # default är positivt tal
skip_whitespace:
    movb (%rdi,%rsi,1), %al     # ladda tecken
    cmpb $32, %al               # jämför med mellanslag
    jne check_sign              # om inte mellanslag, börja kolla tal
    incq %rsi                   # öka buffertpositonen
    jmp skip_whitespace         # läs nytt tecken

check_sign:
    # kolla efter plus-eller minustecken
    movb (%rdi,%rsi,1), %al
    cmpb $43, %al               # jämför med plus
    je positive_number
    cmpb $45, %al               # jämför med minus
    je negative_number
    jmp read_digits

positive_number:
    # hoppa över plustecken
    movq $1, %rbx                      
    incq %rsi
    jmp read_digits

negative_number:
    # markera tal som negativt
    movq $-1, %rbx              # gör talet negativt
    incq %rsi
    jmp read_digits

read_digits:
    xorq %rax, %rax             
    xorq %rdx, %rdx             # rensa register så vi alltid får ett nytt värde
    xorq %rcx, %rcx          
read_loop:
    movb (%rdi,%rsi,1), %al
    cmpb $48, %al               # jämför med 0
    jb finish
    cmpb $57, %al               # jämför med 9
    ja finish

    # konvertera ASCII-tecken till heltal
    subb $48, %al               # omvandla ASCII till int
    movzbq %al, %rdx            # "zero extend", rensa bort högre bits
    imulq $10, %rcx, %rcx       # multiplicera med 10 för att stega upp från ental till tiotal osv
    addq %rdx, %rcx             # lägg till talet i resultatet

    # flytta fram bufferpositionen
    incq %rsi
    jmp read_loop

finish:
    # uppdatera buffertposition
    movq %rsi, inPos(%rip)

    # ifall resultat var negativt
    cmpq $-1, %rbx
    jne return_result
    negq %rcx

return_result:
    movq %rcx, %rax             # ladda in talet för retur
    ret

callInImage:
    call inImage
    movq $0, %rsi               # återställ bufferposition
    movq %rsi, inPos(%rip)
    jmp getInt

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
    movsxd %edi, %rdi
    cmpq $0, %rdi
    jl outMin
    cmpq $64, %rdi
    jg outMax
    movq %rdi, outPos
    ret

outMin:
movq $0, outPos
ret

outMax:
movq $64, outPos
ret