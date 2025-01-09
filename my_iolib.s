.data
    inBuf: .space 64                # inbuffert och utbuffert med positoner
    inPos: .quad 0

    outBuf: .space 64
    outPos: .quad 0

.text
# Inmatning
.global inImage
inImage:

    leaq inBuf(%rip), %rdi          # ladda inbufferten
    movq $63, %rsi                  # ladda antal tecken
    movq stdin, %rdx                # ladda stdin

    call fgets
    
    movq $0, inPos(%rip)            # återställ inpos

    ret

.global getInt
getInt:
    leaq inBuf(%rip), %rdi             # ladda inbufferten
    movq inPos(%rip), %rsi             # ladda nuvarande inPos

    cmpb $0, (%rdi,%rsi,1)             # kolla ifall bufferten är tom
    je getInt_callInImage

parse_number:
    movq $1, %r8               # default är positivt tal (inget tecken = positivt tal)
skip_whitespace:
    movb (%rdi,%rsi,1), %al     # ladda tecken
    cmpb $' ', %al              # jämför med mellanslag
    jne check_sign              # om inte mellanslag, börja kolla tal
    incq %rsi                   # öka buffertpositonen
    jmp skip_whitespace         # läs nytt tecken

check_sign:
    # kolla efter plus-eller minustecken
    movb (%rdi,%rsi,1), %al     # ladda tecken
    cmpb $43, %al               # jämför med plus
    je positive_number
    cmpb $45, %al               # jämför med minus
    je negative_number
    jmp read_digits

positive_number:
    # markera tal som positivt
    movq $1, %r8                      
    incq %rsi
    jmp read_digits

negative_number:
    # markera tal som negativt
    movq $-1, %r8              
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
    movzbq %al, %rdx            # "zero extend", lägger översta 56 bitarna till 0 så vi bara har heltalet ("trycker in" ett 8 bitars tal i ett 64 bitars register)
    imulq $10, %rcx, %rcx       # multiplicera med 10 för att stega upp från ental till tiotal osv
    addq %rdx, %rcx             # lägg till talet i resultatet

    # flytta fram bufferpositionen
    incq %rsi
    jmp read_loop

finish:
    # uppdatera buffertposition
    movq %rsi, inPos(%rip)

    # ifall resultat var negativt
    cmpq $-1, %r8
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
    leaq inBuf(%rip), %rdx     # ladda inBuf
    movq inPos(%rip), %rcx     # ladda inPos

    movq %rdi, %r8             # buf (adress till minnesutrymme att kopiera sträng) -> %r8 (64 bitars)
    movq %rsi, %r9            # n (antalet tecken att läsa) -> %r9d (32 bitars)

    cmpb $0, (%rdx,%rcx,1)              # kolla ifall bufferten är tom
    je getText_callInImage

    # skippa whitespace
strip_whitespace:
    movb (%rdx, %rcx, 1), %al           # ladda nuvarande tecken
    cmpb $' ', %al             # kolla om det är ett mellanslag, tab eller newline
    je increment               # om mellanslag, tab eller newline, gå till increment
    cmpb $'\t', %al            
    je increment               
    cmpb $'\n', %al            
    je increment               
    jmp determine_copy_size    # om inget mellanslag/tab/newline, bestäm hur många tecken som ska kopieras

increment:
    incq %rcx                  # öka inPos
    movq %rcx, inPos(%rip)     # uppdatera inPos
    jmp strip_whitespace       # continue skipping whitespace

determine_copy_size:
    # beräkna hur många tecken som ska kopieras
    movq %r9, %rax             # bestäm återstående storlek för inBuf
    subq %rcx, %rax            # beräkna tillgängliga tecken i bufferten
    cmpq %rax, %r9             # jämför tillgängliga tecken med n
    jbe use_available          # om tillgängliga tecken större eller lika med n, använd n tecken
    movq %r9, %rax             # annars använd så många som finns kvar i inBuf

use_available:
    movq %rax, %r10            # spara antalet tecken som ska kopieras i %r10
    testq %r10, %r10           # kontrollera om det finns tecken att kopiera
    jz end                      # om inget ska kopieras, hoppa till slutet

copy_loop:
    movb (%rdx, %rcx, 1), %al  # ladda tecken från inBuf
    movb %al, (%r8)            # lagra i destiantionsbuffert
    incq %rcx                  # öka index för inbufferten (inPos)
    incq %r8                   # öka index för buf (strängen som ska kopieras)
    decq %r10                  # minska antalet tecken som ska kopieras
    jnz copy_loop              # upprepa tills alla tecken är kopierade

end:
    movb $0, (%r8)             # nullterminera strängen
    movq %rcx, inPos(%rip)     # uppdatera inPos
    ret                        

getText_callInImage:
    pushq %rdi
    pushq %rsi

    call inImage

    popq %rsi
    popq %rdi

    jmp getText       
              

.global getChar
getChar:
    leaq inBuf(%rip), %rax              # ladda inBuf
    movq inPos(%rip), %rcx              # ladda inPos

    cmpb $0, (%rax,%rcx,1)              # ifall inBuf är tom, kalla inImage
    je getChar_callInImage

    movzbq (%rax,%rcx), %rax            # ladda tecknet till rax
    incq %rcx                                   
    movq %rcx, inPos(%rip)              # öka och uppdatera inPos
    ret
getChar_callInImage:
    call inImage
    jmp getChar
 
.global getInPos
getInPos:
    movq inPos, %rax                    # flytta inPos till rax
    ret

.global setInPos
setInPos:
    movsxd %edi, %rdi                   # sign extend edi till 64-bitars längd
    cmpq $0, %rdi                       
    jl inMin                            # compare ifall parametern är mindre än 0
    cmpq $64, %rdi
    jg inMax                            # compare ifall parametern är större än 64
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

    leaq outBuf(%rip), %rdi     # ladda outBuf

    movq outPos(%rip), %rcx     # ladda outPos

    movb $0, (%rdi, %rcx, 1)    # nullterminera strängen

    call puts                  # skriv ut

    movq $0, outPos(%rip)      # återställ outPos
        
    ret

.global putInt
putInt:
    movsxd %edi, %rdi       # sign extend edi till 64-bitars längd
    movq %rdi, %rax         # flytta talet till rax

    leaq outBuf(%rip), %rdi # ladda outBuf
    movq outPos(%rip), %rsi # ladda outPos

    cmp $64, %rsi           # kolla ifall bufferten är full
    je putInt_outImage

    # specialfall för talet 0
    testq %rax, %rax        
    jz putInt_print_zero    # ifall talet är 0, hoppa till specialfallet 

    movq $0, %r8           # sätt r8 till 0 för veta hur många siffror

    cmp $0, %rax            
    jl putInt_negative      # kolla ifall talet är negativt

    jmp putInt_convert_loop # om inte, börja kolla talen

putInt_negative:
    movb $45, (%rdi, %rsi, 1)  # sätt ett minustecken i bufferten framför talet
    incq %rsi                  # öka outPos
    negq %rax                  # gör själva talet positivt så att vi kan använda det

putInt_convert_loop:
    xorq %rdx, %rdx         # rensa så att vi har nytt tal varje gång
    movq $10, %rcx          # bestäm delare till 10
    divq %rcx               # dela rax med 10 (kvot i %rax, rest i %rdx)
    addb $'0', %dl          # konvertera resten till ASCII
    
    incq %r8               # öka räknaren för att veta hur många tecken vi ska lägga tillbaka

    pushq %rdx              # pusha tecknet till stacken

    testq %rax, %rax        # kolla ifall kvoten är 0
    jnz putInt_convert_loop        # ifall kvoten inte är 0, fortsätt loopa

putInt_pop_loop:
    popq %rdx               # poppa tecknet från stacken
    movb %dl, (%rdi, %rsi, 1) # lägg in den outBuf
    incq %rsi               # öka outPos
    decq %r8
    testq %r8, %r8        # kolla ifall r8 är 0 (stacken tom)
    jnz putInt_pop_loop            # ifall r8 inte är 0, fortsätta poppa 

    movq %rsi, outPos(%rip) # uppdatera outPos
    ret

putInt_print_zero:
    # specialfall där talet är 0
    movb $'0', (%rdi, %rsi, 1)  # lagra 0 i bufferten
    incq %rsi                  # öka outPos
    movq %rsi, outPos(%rip)     # uppdatera outPos
    ret

putInt_outImage:
    pushq %rax

    call outImage 
    movq $0, %rsi     

    popq %rax      
    jmp putInt
       
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
    movq $0, %rsi
    jmp putText_loop           # fortsätt

putText_done:
    mov %rsi, outPos(%rip)              # uppdatera outPos
    ret

.global putChar
putChar:
    leaq outBuf(%rip), %rax         # ladda outBuf
    movq outPos(%rip), %rcx         # ladda outPos

    cmp $64, %rcx           # kolla ifall bufferten är full
    je putChar_outImage

    movb %dil, (%rax,%rcx)     # lägg tecknet i outBuf

    incq %rcx                   # öka outPos
    movq %rcx, outPos(%rip)     # uppdatera outPos
    ret

putChar_outImage:
    call outImage
    movq $0, %rcx
    jmp putChar                     

.global getOutPos
getOutPos:
    movq outPos(%rip), %rax     # flytta outPos till rax
    ret

.global setOutPos
setOutPos:
    movsxd %edi, %rdi           # sign extend edi till 64-bitars längd
    cmpq $0, %rdi               
    jl outMin                   # compare ifall parametern är mindre än 0
    cmpq $64, %rdi
    jg outMax                   # compare ifall parametern är större än 64
    movq %rdi, outPos(%rip)     # uppdatera outPos
    ret

outMin:
    movq $0, outPos
    ret

outMax:
    movq $64, outPos
    ret
    