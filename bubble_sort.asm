############################################################
# Bubble Sort em MIPS32 com impressão dos vetores
# - Ordena vetores in-place
# - Imprime antes e depois da ordenação
############################################################

.data
############################################################
# Vetores de teste (não ordenados)
############################################################

array_name1: .asciiz "array n=200, sortedness=5"
array1: .word 524, 872, 560, 28, 883, 149, 945, 17, 984, 931, 872, 974, 5, 160, 21, 12, 958, 511, 616, 331, 897, 702, 766, 904, 33, 626, 802, 143, 19, 781, 508, 68, 367, 708, 252, 456, 587, 35, 98, 569, 255, 228, 30, 869, 758, 622, 908, 892, 784, 679, 296, 417, 641, 753, 298, 935, 887, 556, 76, 472, 622, 795, 422, 895, 803, 415, 982, 162, 506, 920, 385, 327, 795, 213, 382, 345, 900, 523, 255, 53, 709, 758, 612, 866, 112, 376, 433, 790, 522, 815, 104, 559, 439, 201, 436, 451, 15, 960, 185, 456, 380, 28, 504, 107, 397, 556, 401, 473, 741, 748, 266, 338, 893, 130, 996, 937, 314, 925, 130, 521, 808, 143, 516, 336, 845, 986, 659, 335, 333, 719, 441, 726, 896, 147, 564, 143, 456, 502, 272, 70, 366, 637, 765, 417, 395, 691, 434, 8, 502, 429, 23, 310, 444, 389, 624, 507, 798, 749, 975, 446, 415, 921, 317, 256, 829, 49, 890, 694, 133, 489, 820, 431, 342, 80, 821, 671, 69, 912, 475, 249, 447, 130, 801, 74, 589, 664, 220, 765, 463, 323, 532, 329, 755, 543, 122, 233, 759, 314, 134, 763
array_length1: 20

array_name2: .asciiz "array n=50, sortedness=0"
array2: .word 28, 57, 66, 67, 79, 143, 146, 173, 179, 183, 196, 210, 246, 336, 390, 396, 439, 458, 461, 515, 524, 535, 539, 576, 585, 593, 609, 614, 639, 643, 651, 693, 713, 714, 719, 728, 736, 737, 739, 749, 785, 806, 810, 823, 831, 859, 903, 909, 936, 960 
array_length2: 50

msg_before: .asciiz "before: "
msg_after:  .asciiz "after: "
msg_elapsed_ms: .asciiz "milisseconds elapsed: "
newline: .asciiz "\n"
space: .asciiz " "

.text
.globl main


main:
    array1_block:
        la   $a0, array1
        lw   $a1, array_length1
        la   $a2, array_name1
        la   $s7, array2_block
        j sort

    array2_block:
        la   $a0, array2
        lw   $a1, array_length2
        la   $a2, array_name2
        la   $s7, arrayend_block

        j sort

    arrayend_block:
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
