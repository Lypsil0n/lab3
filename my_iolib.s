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
    movq $65, %rsi
    movq $0, %rdx
    
    call fgets
    
    addq $8, %rsp 

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
