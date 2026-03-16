# № 79 - Y = (9*A^2 - 3*B^2 + A*C) / C^

.section .rodata
    prompt_a:   .string "Enter A: "
    prompt_b:   .string "Enter B: "
    prompt_c:   .string "Enter C: "
    fmt_in:     .string "%lu"
    fmt_out:    .string "Result Y = %lu, Remainder = %lu\n"
    err_div0:   .string "Error: Division by zero!\n"

.section .text
.globl main

main:
    push %rbp
    mov %rsp, %rbp
    sub $32, %rsp           # Выделяем место в стеке для переменных A, B, C

    # --- Ввод A ---
    mov $prompt_a, %rdi
    xor %al, %al
    call printf
    mov $fmt_in, %rdi
    lea -8(%rbp), %rsi      # Адрес для A
    xor %al, %al
    call scanf

    # --- Ввод B ---
    mov $prompt_b, %rdi
    xor %al, %al
    call printf
    mov $fmt_in, %rdi
    lea -16(%rbp), %rsi     # Адрес для B
    xor %al, %al
    call scanf

    # --- Ввод C ---
    mov $prompt_c, %rdi
    xor %al, %al
    call printf
    mov $fmt_in, %rdi
    lea -24(%rbp), %rsi     # Адрес для C
    xor %al, %al
    call scanf

    # Загружаем значения
    mov -8(%rbp), %r8       # r8 = A
    mov -16(%rbp), %r9      # r9 = B
    mov -24(%rbp), %r10     # r10 = C

    # --- Вычисления ---

    # 1. Считаем 9 * A^2
    mov %r8, %rax           # rax = A
    mul %r8                 # rax = A * A (результат в rdx:rax)
    mov $9, %rcx
    mul %rcx                # rax = 9 * A^2
    mov %rax, %r11          # r11 = 9 * A^2

    # 2. Считаем A * C
    mov %r8, %rax           # rax = A
    mul %r10                # rax = A * C
    add %rax, %r11          # r11 = 9A^2 + AC

    # 3. Считаем 3 * B^2
    mov %r9, %rax           # rax = B
    mul %r9                 # rax = B * B
    mov $3, %rcx
    mul %rcx                # rax = 3 * B^2
    
    # 4. Числитель = (9A^2 + AC) - 3B^2
    sub %rax, %r11          # r11 = числитель

    # 5. Знаменатель = C^2
    mov %r10, %rax          # rax = C
    mul %r10                # rax = C^2
    mov %rax, %rcx          # rcx = знаменатель

    # Проверка на ноль
    test %rcx, %rcx
    jz division_error

    # 6. Деление: rdx:rax / rcx
    mov %r11, %rax          # Числитель в rax
    xor %rdx, %rdx          # Обнуляем rdx (важно для div!)
    div %rcx                # rax = частное, rdx = остаток

    # --- Вывод ---
    mov $fmt_out, %rdi
    mov %rax, %rsi          # Y
    mov %rdx, %rdx          # Остаток (уже там, но для ясности)
    xor %al, %al
    call printf
    jmp exit_prog

division_error:
    mov $err_div0, %rdi
    xor %al, %al
    call printf

exit_prog:
    leave
    xor %eax, %eax
    ret
