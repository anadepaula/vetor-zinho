############################################################
# Bubble Sort em MIPS32 com impressão dos vetores
# - Ordena vetores in-place
# - Imprime antes e depois da ordenação
############################################################

.data
############################################################
# Vetores de teste (não ordenados)
############################################################

array1:     .word 5, 1, 4, 2, 8         # n = 5
array2:     .word 10, 9, 8, 7, 6, 5     # n = 6

msg_a1_before: .asciiz "Array1 antes: "
msg_a1_after:  .asciiz "Array1 depois: "
msg_a2_before: .asciiz "Array2 antes: "
msg_a2_after:  .asciiz "Array2 depois: "
newline:       .asciiz "\n"
space:         .asciiz " "

.text
.globl main

############################################################
# main
############################################################

main:
    ########################################################
    # Array1
    ########################################################
    # imprime "Array1 antes"
    li   $v0, 4
    la   $a0, msg_a1_before
    syscall

    # imprime conteúdo de array1 antes de ordenar
    la   $a0, array1
    li   $a1, 5
    jal  print_array

    # chama bubble_sort(array1, 5)
    la   $a0, array1
    li   $a1, 5
    jal  bubble_sort

    # imprime "Array1 depois"
    li   $v0, 4
    la   $a0, msg_a1_after
    syscall

    # imprime conteúdo de array1 depois de ordenar
    la   $a0, array1
    li   $a1, 5
    jal  print_array

    ########################################################
    # Array2
    ########################################################
    # imprime "Array2 antes"
    li   $v0, 4
    la   $a0, msg_a2_before
    syscall

    # imprime conteúdo de array2 antes de ordenar
    la   $a0, array2
    li   $a1, 6
    jal  print_array

    # chama bubble_sort(array2, 6)
    la   $a0, array2
    li   $a1, 6
    jal  bubble_sort

    # imprime "Array2 depois"
    li   $v0, 4
    la   $a0, msg_a2_after
    syscall

    # imprime conteúdo de array2 depois de ordenar
    la   $a0, array2
    li   $a1, 6
    jal  print_array

    ########################################################
    # Encerrar o programa
    ########################################################
    li   $v0, 10          # syscall 10 = exit
    syscall


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
