.data
    inBuf: .space 64
    inPos: .quad 0

    outBuf: .space 64
    outPos: .quad 0

.text

# Inmatning
.global inImage
inImage:

.global getInt
getInt:

.global getText
getText:

.global getChar
getChar:
leaq inBuf(%rip), %rax
movq inPos, %rcx
movzbq (%rax,%rcx), %rax
addq $1, inPos
ret
 
.global getInPos
getInPos:

.global setInPos
setInPos:
movsxd %edi, %rdi
cmpq $0, %rdi
jl inMin
cmpq $64, %rdi
jg inMax
movq %rdi, inPos
ret

inMin:
movq $0, inPos
ret

inMax:
movq $64, inPos
ret

# Utmatning
.global outImage
outImage:

.global putInt
putInt:
//leaq outBuf(%rip), %rax
//movq outPos, %rcx
movq %rax, %rdi
movq $10, %rcx
xor %rdx, %rdx
divq %rcx
addq $0x30, %rdx
//PUSH
//go to putInt if rax more than 0
//POP
leaq outBuf(%rip), %rax
movq outPos, %rcx
movb %dil, (%rax,%rcx)
addq $1, outPos
//return to line 64 (POP)
ret

.global putText
putText:

.global putChar
putChar:
leaq outBuf(%rip), %rax
movq outPos, %rcx
movb %dil, (%rax,%rcx)
addq $1, outPos
ret

.global getOutPos
getOutPos:

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
