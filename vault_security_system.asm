# Vault Security System - MIPS assembly coursework
# Group: Hussam Murad Naim Abdelghani, Mahmoud Ahmad Naim Abdelghani,
# Mohamed Munir Hassan Munir, Abdullah Mohammed Salah Qasem.
# This program is an educational code analyzer, not an authentication system.

.data
# Ten 32-bit access codes (10 * 4 bytes).
.align 2
codes: .space 40

title:        .asciiz "\n=== Vault Security System ===\n"
promptCode:   .asciiz "Enter vault access code (1..9999) for slot "
colon:        .asciiz ": "
invalidMsg:   .asciiz "Invalid! Code must be between 1 and 9999. Try again.\n"
invalidChoiceMsg: .asciiz "Invalid menu choice. Enter a number from 1 to 8.\n"

menuStr: .ascii "\nMenu:\n"
        .ascii "1. Display Highest Access Code\n"
        .ascii "2. Count Even and Odd Codes\n"
        .ascii "3. Search for a Specific Code\n"
        .ascii "4. Find Second Largest Distinct Code\n"
        .ascii "5. Sort Codes Ascending\n"
        .ascii "6. Reverse Codes\n"
        .ascii "7. Display Only Odd Codes\n"
        .ascii "8. Exit Program\n"
        .asciiz "Choose option: "


highestMsg:   .asciiz "Highest access code is: "
evenMsg:      .asciiz "Even codes count: "
oddMsg:       .asciiz "Odd codes count: "
searchMsg:    .asciiz "Enter code to search: "
foundMsg:     .asciiz "Code found at zero-based index: "
notFoundMsg:  .asciiz "Code not found.\n"

secondMsg:    .asciiz "Second largest distinct code is: "
noSecondMsg:  .asciiz "No second distinct code: all ten codes are equal.\n"
sortedMsg:    .asciiz "Sorted ascending.\n"
reversedMsg:  .asciiz "Reversed list.\n"
oddOnlyMsg:   .asciiz "Odd codes: "
noOddMsg:     .asciiz "(none)"

arrMsg:       .asciiz "Codes: "
space:        .asciiz " "
newline:      .asciiz "\n"

.text
.globl main

main:
    #Print title
    li  $v0, 4
    la  $a0, title
    syscall

    la  $s0, codes

    # PART A: Input collection (Array + Loop + Validate)

    li  $t0, 0                  # i = 0

input_loop:
    beq $t0, 10, input_done     # if i==10 stop

    li  $v0, 4
    la  $a0, promptCode
    syscall

    li  $v0, 1
    addi $a0, $t0, 1          # Show slots 1..10 to the user.
    syscall

    li  $v0, 4
    la  $a0, colon
    syscall

    li  $v0, 5
    syscall
    move $t1, $v0

    blt $t1, 1, invalid_input
    bgt $t1, 9999, invalid_input

    sll $t2, $t0, 2
    add $t3, $s0, $t2
    sw  $t1, 0($t3)

    addi $t0, $t0, 1
    j input_loop

invalid_input:
    li  $v0, 4
    la  $a0, invalidMsg
    syscall
    j input_loop

input_done:

    jal print_array

    # PART A 2: Interactive Menu

menu_loop:
    li  $v0, 4
    la  $a0, menuStr
    syscall

    li  $v0, 5
    syscall
    move $t9, $v0               # choice

    beq $t9, 1, opt_highest
    beq $t9, 2, opt_evenodd
    beq $t9, 3, opt_search
    beq $t9, 4, opt_second
    beq $t9, 5, opt_sort_asc
    beq $t9, 6, opt_reverse
    beq $t9, 7, opt_odd_only
    beq $t9, 8, opt_exit

    li  $v0, 4
    la  $a0, invalidChoiceMsg
    syscall
    j menu_loop

opt_highest:
    jal highest_code
    j menu_loop

opt_evenodd:
    jal count_even_odd
    j menu_loop

opt_search:
    jal search_code
    j menu_loop

opt_second:
    jal second_largest
    j menu_loop

opt_sort_asc:
    jal sort_ascending
    jal print_array
    j menu_loop

opt_reverse:
    jal reverse_list
    jal print_array
    j menu_loop

opt_odd_only:
    jal display_only_odd
    j menu_loop

opt_exit:
    li  $v0, 10
    syscall



print_array:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li  $v0, 4
    la  $a0, arrMsg
    syscall

    li  $t0, 0                  # i=0
pa_loop:
    beq $t0, 10, pa_done

    sll $t1, $t0, 2
    add $t2, $s0, $t1
    lw  $t3, 0($t2)

    li  $v0, 1
    move $a0, $t3
    syscall

    li  $v0, 4
    la  $a0, space
    syscall

    addi $t0, $t0, 1
    j pa_loop

pa_done:
    li  $v0, 4
    la  $a0, newline
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# Option 1: highest_code

highest_code:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    lw  $t4, 0($s0)
    li  $t0, 1

hc_loop:
    beq $t0, 10, hc_done
    sll $t1, $t0, 2
    add $t2, $s0, $t1
    lw  $t3, 0($t2)

    ble $t3, $t4, hc_next
    move $t4, $t3

hc_next:
    addi $t0, $t0, 1
    j hc_loop

hc_done:
    li  $v0, 4
    la  $a0, highestMsg
    syscall

    li  $v0, 1
    move $a0, $t4
    syscall

    li  $v0, 4
    la  $a0, newline
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# Option 2: count_even_odd

count_even_odd:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li  $t6, 0
    li  $t7, 0
    li  $t0, 0

ceo_loop:
    beq $t0, 10, ceo_done
    sll $t1, $t0, 2
    add $t2, $s0, $t1
    lw  $t3, 0($t2)

    andi $t5, $t3, 1
    beq  $t5, $zero, is_even
    addi $t7, $t7, 1
    j ceo_next

is_even:
    addi $t6, $t6, 1

ceo_next:
    addi $t0, $t0, 1
    j ceo_loop

ceo_done:
    li  $v0, 4
    la  $a0, evenMsg
    syscall
    li  $v0, 1
    move $a0, $t6
    syscall
    li  $v0, 4
    la  $a0, newline
    syscall

    li  $v0, 4
    la  $a0, oddMsg
    syscall
    li  $v0, 1
    move $a0, $t7
    syscall
    li  $v0, 4
    la  $a0, newline
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# Option 3: search_code
search_code:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li  $v0, 4
    la  $a0, searchMsg
    syscall

    li  $v0, 5
    syscall
    move $t8, $v0

    li  $t0, 0

sc_loop:
    beq $t0, 10, sc_done

    sll $t1, $t0, 2
    add $t2, $s0, $t1
    lw  $t3, 0($t2)

    bne $t3, $t8, sc_next

    li  $v0, 4
    la  $a0, foundMsg
    syscall

    li  $v0, 1
    move $a0, $t0
    syscall

    li  $v0, 4
    la  $a0, newline
    syscall
    j sc_exit

sc_next:
    addi $t0, $t0, 1
    j sc_loop

sc_done:
    li  $v0, 4
    la  $a0, notFoundMsg
    syscall

sc_exit:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# Feature (Hussam Murad Naim Abdelghani): second_largest.
# Zero is a safe sentinel because validated access codes are in 1..9999.
# Equal copies of the maximum do not count as a second distinct value.

second_largest:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li  $t6, 0                 # largest
    li  $t7, 0                 # second-largest distinct
    li  $t0, 0
sl_loop:
    beq $t0, 10, sl_done

    sll $t1, $t0, 2
    add $t2, $s0, $t1
    lw  $t3, 0($t2)

    ble $t3, $t6, sl_check_second
    move $t7, $t6
    move $t6, $t3
    j sl_next

sl_check_second:
    beq $t3, $t6, sl_next     # Ignore repeated maximum.
    ble $t3, $t7, sl_next
    move $t7, $t3

sl_next:
    addi $t0, $t0, 1
    j sl_loop

sl_done:
    beq $t7, $zero, sl_no_second
    li  $v0, 4
    la  $a0, secondMsg
    syscall

    li  $v0, 1
    move $a0, $t7
    syscall

    li  $v0, 4
    la  $a0, newline
    syscall
    j sl_exit

sl_no_second:
    li  $v0, 4
    la  $a0, noSecondMsg
    syscall

sl_exit:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# Feature (Mahmoud Ahmad Naim Abdelghani): sort_ascending

sort_ascending:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li  $t0, 0
outer_loop:
    beq $t0, 9, sort_done
    li  $t1, 0
    li  $t8, 9
    sub $t8, $t8, $t0         # Last sorted positions need no comparison.

inner_loop:
    beq $t1, $t8, outer_next

    sll $t2, $t1, 2
    add $t3, $s0, $t2
    lw  $t4, 0($t3)
    lw  $t5, 4($t3)

    ble $t4, $t5, no_swap
    sw  $t5, 0($t3)
    sw  $t4, 4($t3)

no_swap:
    addi $t1, $t1, 1
    j inner_loop

outer_next:
    addi $t0, $t0, 1
    j outer_loop

sort_done:
    li  $v0, 4
    la  $a0, sortedMsg
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# Feature (Mohamed Munir Hassan Munir ): reverse_list

reverse_list:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li  $t0, 0
    li  $t1, 9

rev_loop:
    bge $t0, $t1, rev_done

    sll $t2, $t0, 2
    add $t3, $s0, $t2
    lw  $t4, 0($t3)

    sll $t5, $t1, 2
    add $t6, $s0, $t5
    lw  $t7, 0($t6)

    sw  $t7, 0($t3)
    sw  $t4, 0($t6)

    addi $t0, $t0, 1
    addi $t1, $t1, -1
    j rev_loop

rev_done:
    li  $v0, 4
    la  $a0, reversedMsg
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# Feature (Abdullah Mohammed Salah Qasem): display_only_odd

display_only_odd:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li  $v0, 4
    la  $a0, oddOnlyMsg
    syscall

    li  $t0, 0
    li  $t5, 0                 # Count printed codes.
odd_loop:
    beq $t0, 10, odd_done

    sll $t1, $t0, 2
    add $t2, $s0, $t1
    lw  $t3, 0($t2)

    andi $t4, $t3, 1
    beq  $t4, $zero, odd_next

    li  $v0, 1
    move $a0, $t3
    syscall
    addi $t5, $t5, 1

    li  $v0, 4
    la  $a0, space
    syscall

odd_next:
    addi $t0, $t0, 1
    j odd_loop

odd_done:
    bne $t5, $zero, odd_newline
    li  $v0, 4
    la  $a0, noOddMsg
    syscall

odd_newline:
    li  $v0, 4
    la  $a0, newline
    syscall

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
