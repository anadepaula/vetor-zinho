############################################################
# Bubble Sort em MIPS32 com impressão dos vetores
# - Ordena vetores in-place
# - Imprime antes e depois da ordenação
############################################################

.data
############################################################
# Vetores de teste (não ordenados)
############################################################

array_length_11: 25
array_length_12: 25
array_length_13: 25
array_11: .word 72, 133, 150, 190, 191, 219, 230, 236, 265, 297, 301, 544, 656, 667, 682, 700, 701, 751, 762, 821, 866, 869, 890, 911, 931
array_name_11: .asciiz "array n=25, sortedness=0"
array_12: .word 931, 911, 890, 869, 866, 821, 762, 751, 701, 700, 682, 667, 656, 544, 301, 297, 265, 236, 230, 219, 191, 190, 150, 133, 72
array_name_12: .asciiz "array n=25, sortedness=-1"
array_13: .word 150, 869, 866, 191, 301, 682, 265, 890, 133, 219, 762, 931, 701, 821, 667, 297, 544, 700, 72, 911, 751, 236, 190, 230, 656
array_name_13: .asciiz "array n=25, sortedness=2"

msg_before: .asciiz "before: "
msg_after:  .asciiz "after: "
msg_elapsed_ms: .asciiz "milisseconds elapsed: "
newline: .asciiz "\n"
space: .asciiz " "

.text
.globl main

main:

    array_11_block:
        la $a0, array_11
        lw $a1, array_length_11
        la $a2, array_name_11
        la $s7, array_12_block
        j sort

    array_12_block:
        la $a0, array_12
        lw $a1, array_length_12
        la $a2, array_name_12
        la $s7, array_13_block
        j sort

    array_13_block:
        la $a0, array_13
        lw $a1, array_length_13
        la $a2, array_name_13
        la $s7, array_end_block
        j sort

    array_end_block:
        li   $v0, 10          # syscall 10 = exit
        syscall

############################################################
# sort
############################################################
sort:
    # Guardar parâmetros em temporários para não perder com syscalls
    move $s3, $a0          # array
    move $s4, $a1          # array_length

    ########################################################
    # array
    ########################################################
    # imprime o nome do array
    li   $v0, 4
    la   $a0, ($a2)
    syscall
    la $a0, newline
    syscall

    # imprime "array antes"
    li   $v0, 4
    la   $a0, msg_before
    syscall

    # imprime conteúdo de array antes de ordenar
    la   $a0, ($s3)
    la   $a1, ($s4)
    jal  print_array

    # captura a timestamp atual e armazena em $s5
    li  $v0, 30
    syscall
    la $s5, ($a0)

    # chama bubble_sort(array, 5)
    la   $a0, ($s3)
    la   $a1, ($s4)
    jal  bubble_sort

    # captura a timestamp atual e armazena em $s6
    li  $v0, 30
    syscall
    la $s6, ($a0)
    
    # imprime "array depois"
    li   $v0, 4
    la   $a0, msg_after
    syscall

    # imprime conteúdo de array depois de ordenar
    la   $a0, ($s3)
    la   $a1, ($s4)
    jal  print_array

    # calcula tempo de duração
    sub $s5, $s6, $s5
    # imprime "elapsed time"
    li   $v0, 4
    la   $a0, msg_elapsed_ms
    syscall
    li   $v0, 1
    la   $a0, ($s5)
    syscall
    li  $v0, 4
    la $a0, newline
    syscall

    jalr  $s7

############################################################
# print_array
# Imprime um vetor de inteiros: A[0..n-1]
#
# Parâmetros:
#   $a0 = endereço base do vetor
#   $a1 = tamanho (n)
#
# Saída (na aba I/O), ex:
#   5 1 4 2 8
############################################################

print_array:
    # Guardar parâmetros em temporários para não perder com syscalls
    move $t4, $a0          # base
    move $t5, $a1          # n

    li   $t0, 0            # i = 0

print_loop:
    # se i >= n, termina
    bge  $t0, $t5, print_end

    # offset = i * 4
    sll  $t1, $t0, 2
    add  $t2, $t4, $t1     # &A[i]
    lw   $t3, 0($t2)       # A[i]

    # syscall 1: print int
    li   $v0, 1
    move $a0, $t3
    syscall

    # imprime um espaço
    li   $v0, 4
    la   $a0, space
    syscall

    addi $t0, $t0, 1       # i++
    j    print_loop

print_end:
    # imprime quebra de linha
    li   $v0, 4
    la   $a0, newline
    syscall

    jr   $ra


############################################################
# bubble_sort
# Parâmetros:
#   $a0 = endereço base do vetor
#   $a1 = tamanho do vetor (n)
############################################################

bubble_sort:
    ########################################################
    # Prólogo: salvar contexto
    ########################################################
    addi $sp, $sp, -16
    sw   $ra, 12($sp)
    sw   $s0,  8($sp)
    sw   $s1,  4($sp)
    sw   $s2,  0($sp)      # não usado, mas reservado

    ########################################################
    # Inicializar variáveis locais
    ########################################################
    move $s0, $a0          # base do vetor
    move $s1, $a1          # n
    addi $s1, $s1, -1      # remaining = n - 1

    # Se remaining <= 0, já está ordenado
    blez $s1, bubble_end

outer_loop:
    li   $t0, 0            # j = 0

inner_loop:
    # se j >= remaining, sai do laço interno
    bge  $t0, $s1, end_inner

    # endereço de A[j]
    sll  $t1, $t0, 2       # j * 4
    add  $t2, $s0, $t1     # &A[j]

    lw   $t3, 0($t2)       # A[j]
    lw   $t4, 4($t2)       # A[j+1]

    # se A[j] <= A[j+1], não troca
    ble  $t3, $t4, no_swap

    # troca A[j] e A[j+1]
    sw   $t4, 0($t2)
    sw   $t3, 4($t2)

no_swap:
    addi $t0, $t0, 1       # j++
    j    inner_loop

end_inner:
    addi $s1, $s1, -1      # remaining--
    bgtz $s1, outer_loop

bubble_end:
    ########################################################
    # Epílogo: restaurar contexto
    ########################################################
    lw   $s2,  0($sp)
    lw   $s1,  4($sp)
    lw   $s0,  8($sp)
    lw   $ra, 12($sp)
    addi $sp, $sp, 16
    jr   $ra