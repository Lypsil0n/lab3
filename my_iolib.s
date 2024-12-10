.data
    inBuf: .space 8
    inPos: .quad 0

    outBuf: .space 8
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

.global putText
putText:

.global putChar
putChar:

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
