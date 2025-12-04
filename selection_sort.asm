############################################################
# Selection Sort em MIPS32
# - Ordena vetores de inteiros (word, 32 bits) in-place
# - Interface:
#     $a0 = endereço base do vetor
#     $a1 = tamanho do vetor (n)
# - Inclui impressão dos vetores (syscalls)
############################################################

.data
############################################################
# Vetores de teste
############################################################

array1:     .word 109, 28, 34, 17, 12         # n = 5
array2:     .word 11, 33, 4, 9, 1, 5     # n = 6

msg_a1_before: .asciiz "\nArray1 antes: "
msg_a1_after:  .asciiz "Array1 depois: "
msg_a2_before: .asciiz "\nArray2 antes: "
msg_a2_after:  .asciiz "Array2 depois: "

newline:    .asciiz "\n"
space:      .asciiz " "

.text
.globl main

############################################################
# main
############################################################

main:
    ########################################################
    # Teste com Array 1
    ########################################################
    # Antes
    li  $v0, 4
    la  $a0, msg_a1_before
    syscall

    la  $a0, array1
    li  $a1, 5
    jal print_array

    # Ordenando
    la  $a0, array1
    li  $a1, 5
    jal selection_sort

    # Depois
    li  $v0, 4
    la  $a0, msg_a1_after
    syscall

    la  $a0, array1
    li  $a1, 5
    jal print_array


    ########################################################
    # Teste com Array 2
    ########################################################
    # Antes
    li  $v0, 4
    la  $a0, msg_a2_before
    syscall

    la  $a0, array2
    li  $a1, 6
    jal print_array

    # Ordenando
    la  $a0, array2
    li  $a1, 6
    jal selection_sort

    # Depois
    li  $v0, 4
    la  $a0, msg_a2_after
    syscall

    la  $a0, array2
    li  $a1, 6
    jal print_array


    ########################################################
    # Encerrar programa
    ########################################################
    li  $v0, 10
    syscall


############################################################
# Função: print_array
# Exibe vetor no formato: v1 v2 v3 ...
############################################################

print_array:
    move $t4, $a0      # base
    move $t5, $a1      # n
    li   $t0, 0        # índice i = 0

print_loop:
    bge  $t0, $t5, print_end

    sll  $t1, $t0, 2   # offset = i*4
    add  $t2, $t4, $t1
    lw   $t3, 0($t2)   # load A[i]

    li   $v0, 1
    move $a0, $t3
    syscall

    li   $v0, 4
    la   $a0, space
    syscall

    addi $t0, $t0, 1
    j print_loop

print_end:
    li  $v0, 4
    la  $a0, newline
    syscall
    jr  $ra


############################################################
# Função: selection_sort
############################################################

selection_sort:
    # Prólogo
    addi $sp, $sp, -16
    sw   $ra, 12($sp)
    sw   $s0,  8($sp)
    sw   $s1,  4($sp)
    sw   $s2,  0($sp)

    move $s0, $a0   # base do vetor
    move $s1, $a1   # tamanho n

    li   $t0, 0     # i = 0

outer:
    addi $t6, $s1, -1
    bge  $t0, $t6, end_sort

    move $t2, $t0  # min_idx = i
    addi $t1, $t0, 1  # j = i + 1

inner:
    bge  $t1, $s1, check_swap

    sll  $t5, $t1, 2
    add  $t6, $s0, $t5
    lw   $t3, 0($t6)  # A[j]

    sll  $t5, $t2, 2
    add  $t6, $s0, $t5
    lw   $t4, 0($t6)  # A[min_idx]

    blt  $t3, $t4, update_min
    j    cont_inner

update_min:
    move $t2, $t1    # min_idx = j

cont_inner:
    addi $t1, $t1, 1
    j inner

check_swap:
    beq $t2, $t0, next_outer

    # Troca A[i] e A[min_idx]
    sll  $t5, $t0, 2
    add  $t6, $s0, $t5
    lw   $t3, 0($t6)

    sll  $t5, $t2, 2
    add  $t6, $s0, $t5
    lw   $t4, 0($t6)

    sll  $t5, $t0, 2
    add  $t6, $s0, $t5
    sw   $t4, 0($t6)

    sll  $t5, $t2, 2
    add  $t6, $s0, $t5
    sw   $t3, 0($t6)

next_outer:
    addi $t0, $t0, 1
    j outer

end_sort:
    # Epílogo
    lw   $s2,  0($sp)
    lw   $s1,  4($sp)
    lw   $s0,  8($sp)
    lw   $ra, 12($sp)
    addi $sp, $sp, 16
    jr   $ra
