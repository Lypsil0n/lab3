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
    mov %rdi, %rbx                      # %rdi contains the address of the input string (buf)
    leaq outBuf(%rip), %rdi             # Load the address of outBuf into %rdi
    movq outPos(%rip), %rsi             # Load the current position in the buffer (outPos)

putText_loop:
    movb (%rbx), %al                    # Load 1 byte from the input string (buf)
    testb %al, %al                      # Check if the byte is NULL (end of string)
    je putText_done                     # If it's NULL, terminate the loop

    cmp $64, %rsi                       # Check if the buffer is full (outPos >= 64)
    je flush_buffer                    # If buffer is full (outPos == 64), flush it

    movb %al, (%rdi, %rsi, 1)           # Write the byte to the buffer at the correct position
    inc %rsi                            # Increment the current position (outPos)
    inc %rbx                            # Move to the next byte in the input string
    jmp putText_loop                    # Repeat the loop

flush_buffer:
    movb $0, (%rdi, %rsi, 1) 
    # Call outImage to print the current contents of the buffer
    call outImage                       # Flush the buffer (print it)

    # Reset outPos to 0 after flushing the buffer
    movq $0, %rsi                       # Reset position (outPos) to 0
    movq %rsi, outPos(%rip)             # Update outPos to 0 (buffer is now empty)
    jmp putText_loop                    # Continue processing the string

putText_done:
    movb $0, (%rdi, %rsi, 1)
    mov %rsi, outPos(%rip)              # Update outPos with the current position in the buffer
    ret


.global putChar
putChar:

.global getOutPos
getOutPos:
    movq outPos, %rax
    ret

.global setOutPos
setOutPos:
