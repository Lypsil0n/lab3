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
    je getInt_callInImage

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
    # markera tal som positivt
    movq $1, %rbx                      
    incq %rsi
    jmp read_digits

negative_number:
    # markera tal som negativt
    movq $-1, %rbx              
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
    movzbq %al, %rdx            # "zero extend", rensa bort så vi bara har heltalet
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

getInt_callInImage:
    call inImage
    jmp getInt

.global getText
getText:
    movq %rdi, %r8             # buf (adress till minnesutrymme att kopiera sträng) -> %r8
    movl %esi, %r9d            # n (antalet tecken att läsa) -> %r9d

    # Load input buffer position and base
    movq inPos(%rip), %rcx     # ladda inPos
    leaq inBuf(%rip), %rdx     # ladda inBuf
    addq %rcx, %rdx            # justera pekare till aktuell position: %rdx = inBuf + inPos

    cmpb $0, (%rdx)             # kolla ifall bufferten är tom
    je getText_callInImage

    # skippa whitespace
strip_whitespace:
    movb (%rdx), %al           # ladda nuvarande tecken
    cmpb $' ', %al             # kolla om det är ett mellanslag, tab eller newline
    je increment               # om mellanslag, tab eller newline, gå till increment
    cmpb $'\t', %al            
    je increment               
    cmpb $'\n', %al            
    je increment               
    jmp determine_copy_size    # om inget mellanslag/tab/newline, bestäm hur många tecken som ska kopieras

increment:
    incq %rdx                  # flytta pekare till nästa tecken i inBuf
    subq inBuf(%rip), %rdx     # uppdatera inPos
    movq %rdx, inPos(%rip)     # uppdatera inPos till nya positionen
    addq inBuf(%rip), %rdx     # återställ inBuf pekaren
    jmp strip_whitespace        # fortsätt tills vi hittar ett tecken som inte är whitespace

determine_copy_size:
    # beräkna hur många tecken som ska kopieras
    movq %r9, %rax             # bestäm återstående storlek för inBuf
    subq %rcx, %rax            # beräkna tillgängliga tecken i bufferten
    cmpq %rax, %r9             # jämför tillgängliga tecken med n
    jbe use_available          # om tillgängliga tecken större eller lika med n, använd alla
    movq %r9, %rax             # annars använd bara n tecken

use_available:
    movq %rax, %r10            # spara antalet tecken som ska kopieras i %r10
    testq %r10, %r10           # kontrollera om det finns tecken att kopiera
    jz null_terminate          # om inget ska kopieras, hoppa till null-terminering

copy_loop:
    movb (%rdx), %al           # ladda tecken från inBuf
    movb %al, (%r8)            # lagra i destiantionsbuffert
    incq %rdx                  # öka pekaren för inBuf (input buffer)
    incq %r8                   # öka pekaren för buf (output buffer)
    decq %r10                  # minska antalet tecken som ska kopieras
    jnz copy_loop              # upprepa tills alla tecken är kopierade

null_terminate:
    movb $0, (%r8)             # nullterminera strängen
    subq inBuf(%rip), %rdx     # beräkna ny inPos
    movq %rdx, inPos(%rip)     # uppdatera inPos

    movq %rax, %rax            # returnera antalet överförda tecken
    ret                        

getText_callInImage:
    call inImage
    jmp getText                

.global getChar
getChar:
    leaq inBuf(%rip), %rax
    movq inPos, %rcx
    movzbq (%rax,%rcx), %rax
    addq $1, inPos
    ret
 
.global getInPos
getInPos:
    movq inPos, %rax
    ret


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
    subq $16, %rsp              

    leaq outBuf(%rip), %rdi     # ladda outBuf

    movq outPos(%rip), %rcx     # ladda outPos

    movb $0, (%rdi, %rcx, 1)    # nullterminera strängen

    call puts                  # skriv ut

    movq $0, outPos(%rip)      # återställ outPos

    addq $16, %rsp             
    ret

.global putInt
putInt:
    # Load the integer (n) from %rdi and initialize the buffer position
    movq %rdi, %rax          # %rdi contains the integer to be written (n)
    leaq outBuf(%rip), %rdi  # Load the output buffer address into %rdi
    movq outPos(%rip), %rsi  # Load the current outPos into %rsi

    # Special case for zero, handle it directly
    testq %rbx, %rbx         # Check if the number is zero
    jz .print_zero           # If zero, go to print_zero

    # Convert the integer to a string (storing digits in reverse order)
convert_loop:
    xorq %rdx, %rdx          # Clear the remainder register
    movq $10, %rcx           # Set divisor to 10
    divq %rcx                # Divide %rbx by 10 (quotient in %rax, remainder in %rdx)
    addb $'0', %dl           # Convert the remainder to ASCII ('0' to '9')
    movb %dl, (%rdi, %rsi, 1) # Store the ASCII character in the output buffer
    incq %rsi                # Increment the buffer position
    testq %rax, %rax         # Check if the quotient is zero
    jnz convert_loop         # If quotient is not zero, continue the loop

    # At this point, %rsi is past the last character
    # Save the current position before reversing
    movq %rsi, %rcx          # %rcx now holds the end of the string (one past the last character)

    # Reverse the string (since it is stored in reverse order)
reverse_string:
    decq %rcx                # Move to the last written character (point to the last character)
    cmpq outBuf(%rip), %rcx   # Compare the start of the buffer with the current position
    jl .done_reverse         # If %rcx points to the start, we’re done

    # Swap characters at %rsi (start) and %rcx (end)
    movb (%rdi, %rsi, 1), %al # Load byte at start into %al
    movb (%rdi, %rcx, 1), %bl # Load byte at end into %bl
    movb %bl, (%rdi, %rsi, 1) # Store byte from end at start
    movb %al, (%rdi, %rcx, 1) # Store byte from start at end

    # Move start pointer forward, end pointer backward
    incq %rsi
    decq %rcx
    jmp reverse_string

.done_reverse:
    # Update outPos to the current buffer position (now pointing to the first free byte after the integer string)
    movq %rsi, outPos(%rip)  # Store the current buffer position in outPos
    ret

.print_zero:
    # Handle the special case where the integer is zero
    movb $'0', (%rdi, %rsi, 1)  # Store '0' in the buffer
    incq %rsi                  # Increment the buffer position
    movq %rsi, outPos(%rip)     # Update outPos
    ret


                                    
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
    je putText_outImage                 # om den är tom, flusha bufferten

    movb %al, (%rdi, %rsi, 1)           # skriv tecknet till utbufferten
    inc %rsi                            # öka nuvarande position i bufferten
    inc %rbx                            # gå till nästa tecken
    jmp putText_loop                    # repetera

putText_outImage:
    call outImage              # skriv ut bufferten
    jmp putText_loop           # fortsätt

putText_done:
    mov %rsi, outPos(%rip)              # uppdatera outPos
    ret

.global putChar
putChar:
    leaq outBuf(%rip), %rax
    movq outPos, %rcx
    movb %dil, (%rax,%rcx)
    addq $1, outPos
    ret

.global getOutPos
getOutPos:
    movq outPos(%rip), %rax
    ret

.global setOutPos
setOutPos:
    movsxd %edi, %rdi
    cmpq $0, %rdi
    jl outMin
    cmpq $64, %rdi
    jg outMax
    movq %rdi, outPos(%rip)
    ret

outMin:
    movq $0, outPos
    ret

outMax:
    movq $64, outPos
    ret
