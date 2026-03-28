# Лабораторная работа: Вычисление выражения (4*A^3 - 3*A^2) / B^2

.section .rodata
    prompt_a:   .string "Enter A: "
    prompt_b:   .string "Enter B: "
    fmt_in:     .string "%lu"
    fmt_out:    .string "Result X = %lu, Remainder = %lu\n"
    err_div0:   .string "Error: Division by zero!\n"

.section .text
.globl main
main:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp           # Резервируем место под A (-8) и B (-16)

    # Ввод значения A
    mov $prompt_a, %rdi
    xor %rax, %rax
    call printf
    mov $fmt_in, %rdi
    lea -8(%rbp), %rsi
    xor %rax, %rax
    call scanf

    # Ввод значения B
    mov $prompt_b, %rdi
    xor %rax, %rax
    call printf
    mov $fmt_in, %rdi
    lea -16(%rbp), %rsi
    xor %rax, %rax
    call scanf

    # --- Вычисление числителя (4*A^3 - 3*A^2) ---
    mov -8(%rbp), %r8       # r8 = A
    
    # 1. Считаем A^2
    mov %r8, %rax
    mul %r8                 # rax = A * A = A^2
    mov %rax, %r9           # сохраняем A^2 в r9

    # 2. Считаем 3 * A^2
    mov $3, %rcx
    mul %rcx                # rax = 3 * A^2
    mov %rax, %r10          # r10 = 3 * A^2

    # 3. Считаем 4 * A^3
    mov %r9, %rax           # rax = A^2
    mul %r8                 # rax = A^2 * A = A^3
    mov $4, %rcx
    mul %rcx                # rax = 4 * A^3

    # 4. Финальный числитель
    sub %r10, %rax          # rax = 4*A^3 - 3*A^2
    mov %rax, %r11          # r11 = числитель

    # --- Вычисление знаменателя (B^2) ---
    mov -16(%rbp), %rax     # rax = B
    mul %rax                 # rax = B * B = B^2
    mov %rax, %rcx          # rcx = знаменатель

    # Проверка на деление на ноль
    test %rcx, %rcx
    jz .Ldiv_error

    # --- Деление ---
    mov %r11, %rax          # rax = числитель
    xor %rdx, %rdx          # обнуляем rdx перед div (важно!)
    div %rcx                # rax = частное, rdx = остаток

    # Вывод результата
    mov $fmt_out, %rdi
    mov %rax, %rsi          # X
    # rdx уже содержит остаток после div
    xor %rax, %rax
    call printf
    jmp .Lend

.Ldiv_error:
    mov $err_div0, %rdi
    xor %rax, %rax
    call printf

.Lend:
    leave
    ret
