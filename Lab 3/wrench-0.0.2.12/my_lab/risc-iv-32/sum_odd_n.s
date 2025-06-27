.data
input_addr:    .word 0x80
output_addr:   .word 0x84

.text
.org 0x100    

; k = floor((n + 1)/2)
; sum = k^2

_start:
    lui     sp, %hi(0x500)      
    addi    sp, sp, %lo(0x500)

    lui     t0, %hi(input_addr)
    addi    t0, t0, %lo(input_addr)
    lw      t0, 0(t0)
    lw      a0, 0(t0)           ; a0 = n

    jal     ra, sum_odd_n      

    lui     t0, %hi(output_addr)
    addi    t0, t0, %lo(output_addr)
    lw      t0, 0(t0)
    sw      a1, 0(t0)          

    halt

sum_odd_n:
    ble     a0, zero, return_minus_one      

    addi    sp, sp, -8
    sw      ra, 4(sp)
    sw      a0, 0(sp)       

    addi    a0, a0, 1           
    jal     ra, compute_k       ; a1 = k
    mv      t1, a1             

    mul     a1, t1, t1          ; a1 = sum 

    lw      ra, 4(sp)          
    lw      a0, 0(sp)
    addi    sp, sp, 8          

    bgt     zero, a1, return_overflow
    jr      ra

compute_k:
    addi    a2, zero, 1
    srl     a1, a0, a2          
    jr      ra

return_minus_one:
    addi    a1, zero, -1
    jr      ra

return_overflow:
    lui     a1, %hi(0xCCCCCCCC)
    addi    a1, a1, %lo(0xCCCCCCCC)
    jr      ra
