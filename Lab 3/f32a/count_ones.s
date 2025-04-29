.data

input_addr:      .word  0x80
output_addr:     .word  0x84

.text

_start:       
    @p input_addr a! @+        \ n:[] 
    lit 0 !                     \ n:[] ; mem[A] = count 

    count_start

    @                           \ count:n:[]
    @p output_addr a! !         
    halt

count_start:
    lit -32                   \ step:n:[]
count_while:
    dup                         \ step:step:n:[]
    if count_end                 \ step:n:[]
    lit 1 +                       \ 1 + step:n:[]
    over                           \ n:step:[]
    dup                             \ n:n:step:[]
    lit 1 and                        \ n&1:n:step:[]
    @ + !                             \ mem[A] = count +  n&1 ; n:step:[]
    2/                                 \ n >> 1 :step:[]
    over                                \ step:n:[]
    count_while ;

count_end:
    ; 
    


    
