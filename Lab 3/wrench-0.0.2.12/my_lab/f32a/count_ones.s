.data
input_addr:      .word  0x80
output_addr:     .word  0x84

.text
_start: 
    @p input_addr         
    a! @                    
    lit 0 a!                 \ A likes count 

    count_start             

    @p output_addr        
    b! !b                     
    halt

count_start:
    lit 31 >r   

count_loop:
    dup                  
    lit 1 and              
    a + a!                 
    2/                    
    next count_loop       

count_end:
    a  
    ; 