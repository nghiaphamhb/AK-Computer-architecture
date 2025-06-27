.data 
.org    0x0
buf:                .byte '________________________________'    ; 32 bytes 
padding:            .byte '__________________________________'  

input_addr:         .word 0x80                    
output_addr:        .word 0x84               

count:              .word 0        
ptr:                .word 0        
ptr2:               .word 0         
temp:               .word 0        

; hằng số / константы 
const_overflow:     .word 0xCCCCCCCC    
const_1:            .word 1  
const_31:           .word 31   
const_end:          .byte '____'     ; 0x5F,0x5F,0x5F,0x5F
const_newline:      .word 10         ; ASCII newline ('\n')
const_a:            .word 97         ; ASCII 'a'
const_z:            .word 122        ; ASCII 'z'
const_case_diff:    .word 32         ; Переход от строчных букв к заглавным 
const_mask:         .word 255        ; 8-битный фильтр

.text
.org 0x100 
_start: 
    load_imm padding            
    store ptr2                       ; mem[ptr2] = padding[1]

; ----------------------------------------------------------------------------------------------------
count_loop:   
    load_ind input_addr     
    store temp         
    sub const_newline                ; check new line 
    beqz break_count                 ; break the loop

    load count    
    add const_1
    store count                      ; count = count + 1

    load const_31                    
    sub count
    ble handle_overflow              ; check if count > 31 

check_uppercase:  
    load temp 
    sub const_a            ; acc = acc - 'a'
    ble padding_write      ; dont need to uppercase 

    load temp 
    sub const_z            ; acc = acc - 'z'
    bgt padding_write      ; dont need to uppercase 

get_uppercase:          
    load temp 
    sub const_case_diff    ; uppercase 
    store temp  

padding_write:                  
    load temp
    store_ind ptr2          ; temp -> padding

    load ptr2          
    add const_1
    store ptr2              ; ptr2 ++ 

    jmp count_loop          

; ----------------------------------------------------------------------------------------------------
break_count:         
    load_imm 0                      
    store_ind ptr2           

    load count   
    store buf                

; ----------------------------------------------------------------------------------------------------
buf_write:                 
    load_imm buf             
    add const_1             
    store ptr          

    load_imm padding        
    store ptr2        

write_loop:       
    load_ind ptr2            
    store temp         

    load temp              
    beqz done                
    
    load temp             
    store_ind ptr            
    load_imm 0xFF            ; use filter 
    and temp
    store_ind output_addr    ; write to output 

    load ptr  
    add const_1
    store ptr                ; ptr ++

    load ptr2  
    add const_1
    store ptr2               ; ptr2 ++ 

    jmp write_loop          

; ----------------------------------------------------------------------------------------------------
done:           
    load const_end
    store_ind ptr 
    halt

; exceptions
handle_overflow:        
    load_imm     0xCCCC_CCCC
    store_ind    output_addr                 ; mem[mem[output_addr]] = 0xCCCC_CCCC
    halt 