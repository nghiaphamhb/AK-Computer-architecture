.data 
.org    0x0
buf:     .byte '________________________________'    ; 32 bytes 
padding: .byte '\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0'    

input_addr:    .word 0x80                    
output_addr:   .word 0x84               

count:          .word 0
ptr:            .word 0
ptr2:           .word 0
i:              .word 0 
temp:           .word 0          ; Biến tạm để lưu ký tự input

const_overflow:           .word 0xCCCCCCCC    
const_1:            .word 1  
const_31:            .word 31   
const_end: .byte '____'             ; 0x5F,0x5F,0x5F,0x5F
const_newline:     .word 10         ; ASCII newline ('\n')
const_a:           .word 97         ; ASCII 'a'
const_z:           .word 122        ; ASCII 'z'
const_case_diff:   .word 32         ; Hiệu số chuyển chữ thường thành chữ hoa (32)
const_mask:        .word 255        ; Mask giữ 8-bit (0xFF)

.text
_start: 
    ; ptr2 dùng để ghi vào bộ nhớ đệm padding 
    ; ptr2 trỏ vào địa chỉ của padding 
    load_imm padding            
    store_addr ptr2          ; mem[ptr2] = padding[1]

; ----------------------------------------------------------------------------------------------------
count_loop:             ; đọc lần lượt các phần tử, in hoa chúng (rồi ghi vào padding), đồng thời đếm 
    ; đọc từ input vào temp; tới break_count nếu đọc phải '\n'
    load_ind input_addr     ; đọc từ input 
    store_addr temp         ; lưu vào biến tạm thời 
    sub const_newline       ; acc <- acc - 10   ; check new line 
    beqz break_count        ; break the loop

    ; tăng giá trị count lên 1 
    load_addr count    
    add const_1
    store_addr count            ; count = count + 1

    ; dừng vòng lặp khi đếm đủ số phần tử 
    load_addr const_31                ; check if count > 31 
    sub  count
    ble handle_overflow

check_uppercase:            ; kiểm tra xem có cần làm in hoa hay ko 
    load_addr temp 
    sub const_a           ; acc = acc - 'a'
    ble padding_write      ; dont need to uppercase 

    load_addr temp 
    sub const_z           ; acc = acc - 'z'
    bgt padding_write      ; dont need to uppercase 

get_uppercase:             ; làm in hoa 
    load_addr temp 
    sub const_case_diff   ; acc = acc - 32
    store_addr temp  

padding_write:                  
    ; ghi chữ in hoa vào padding 
    load_addr temp
    store_ind ptr2          ; temp -> padding

    ; con trỏ ptr2 tịnh tiến 
    load_addr ptr2          
    add const_1
    store_addr ptr2        ; ptr2 ++ 

    ; lặp lại vòng lặp 
    jmp count_loop

; ----------------------------------------------------------------------------------------------------
break_count:                        ; thoát khỏi count_loop và ghi số phần tử vào đầu buf 
    load_addr count   
    store_addr buf          ; mem[buf[0]] = count

; ----------------------------------------------------------------------------------------------------
buf_write:                 ; sắp xếp lại các con trỏ, chuẩn bị ghi lại từ padding sang buf 
    load_imm buf            ; trỏ ptr lên buf[1], tịnh tiến dần 
    add const_1             
    store_addr ptr          

    load_imm padding         ; trỏ ptr2 vào đầu padding 
    store_addr ptr2        

write_loop:                 ; vòng lặp ghi lại từ padding sang buf 
    ; chép từ pad ra temp 
    load_ind ptr2 
    store_addr temp         

    ; ngừng viết nếu temp = 0 
    load_addr temp
    beqz done
    
    ; chép temp vào buf 
    load_addr temp
    store_ind ptr            
    load_imm 0xFF            ; dùng filter 
    and temp
    store_ind output_addr    ; ghi vào output 

    ; tịnh tiến ptr
    load_addr ptr  
    add const_1
    store_addr ptr   

    ; tịnh tiến ptr2 
    load_addr ptr2  
    add const_1
    store_addr ptr2   

    ; lặp lại vòng lặp write_loop 
    jmp write_loop

; ----------------------------------------------------------------------------------------------------
done:           ; điền các chỗ trống của buf bằng '_'
    load_addr const_end
    store_ind ptr 
    halt

handle_overflow:        ; exceptions
    load_imm     0xCCCC_CCCC
    store_ind    output_addr                 ; mem[mem[output_addr]] = 0xCCCC_CCCC
    halt 