.data
input_addr:    .word 0x80
output_addr:   .word 0x84

.text
.org 0x100    ; để tránh việc ghi đè lên vùng data 
; k = floor((n + 1)/2)
; sum = k^2

; a0 = n
; a1 = output value 
; a2 = 1 
; t0 -> input_addr/ output_addr
; t1 = k 
; ra
; sp 

_start:
    lui     sp, %hi(0x500)      ; stack pointer là ô cao nhất, khi thêm dữ liệu vào stack thì sp cần có chỗ để lùi xuống 
    addi    sp, sp, %lo(0x500)

    lui     t0, %hi(input_addr)
    addi    t0, t0, %lo(input_addr)
    lw      t0, 0(t0)
    lw      a0, 0(t0)           ; a0 = n

    jal     ra, sum_odd_n      ; Gọi thủ tục tính tổng số lẻ

    lui     t0, %hi(output_addr)
    addi    t0, t0, %lo(output_addr)
    lw      t0, 0(t0)
    sw      a1, 0(t0)           ; Ghi kết quả từ a1 vào output

    halt

; Thủ tục chính 
sum_odd_n:
    ble     a0, zero, return_minus_one      ; nếu n <= 0 thì là lỗi 

    addi    sp, sp, -8
    sw      ra, 4(sp)
    sw      a0, 0(sp)        ; lưu 2 stack đầu lần lượt là ra và a0 ; ra chứa pc của dòng 18 và a0 chứa n 

    addi    a0, a0, 1           ; a0 = n + 1
    jal     ra, compute_k ; a1 = floor((n + 1)/2)
    mv      t1, a1              ; t1 = k

    mul     a1, t1, t1          ; a1 = k^2

    lw      ra, 4(sp)           ; lấy lại các giá trị ra và a0 từ stack 
    lw      a0, 0(sp)
    addi    sp, sp, 8           ; sp quay trở lại top stack 

    bgt     zero, a1, return_overflow
    jr      ra

; Thủ tục phụ nên đổi tên thành tính tổng trung bình .l... 
compute_k:
    addi    a2, zero, 1
    srl     a1, a0, a2          ; a1 = a0 >> 1 = floor((n + 1)/2)
    jr      ra

; Trả về -1 nếu sai
return_minus_one:
    addi    a1, zero, -1
    jr      ra

; Trả về giá trị lỗi nếu tràn
return_overflow:
    lui     a1, %hi(0xCCCCCCCC)
    addi    a1, a1, %lo(0xCCCCCCCC)
    jr      ra
