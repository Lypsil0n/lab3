.data
    .globl inBuf
    inBuf: .space 64
    inPos: .quad 0

    .globl outBuf
    outBuf: .space 64
    outPos: .quad 0

.text
# Inmatning
.global inImage
inImage:
    subq $8, %rsp

    leaq inBuf(%rip), %rdi
    movq $65, %rsi
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

    addq $8, %rsp 
    ret

.global putInt
putInt:

.global putText
putText:
    

.global putChar
putChar:

.global getOutPos
getOutPos:

.global setOutPos
setOutPos:
