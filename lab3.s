.section .rodata
    prompt:     .string "Enter number: "
    fmt_in:     .string "%ld"
    fmt_out:    .string "Result: A=%ld, B=%ld, C=%ld\n"

.section .text
.globl main
main:
    push %rbp
    mov %rsp, %rbp
    sub $48, %rsp           # Место для A (-8), B (-16), C (-24)

    # --- Ввод A ---
    mov $prompt, %rdi
    xor %al, %al
    call printf
    mov $fmt_in, %rdi
    lea -8(%rbp), %rsi
    call scanf

    # --- Ввод B ---
    mov $prompt, %rdi
    xor %al, %al
    call printf
    mov $fmt_in, %rdi
    lea -16(%rbp), %rsi
    call scanf

    # --- Ввод C ---
    mov $prompt, %rdi
    xor %al, %al
    call printf
    mov $fmt_in, %rdi
    lea -24(%rbp), %rsi
    call scanf

    # --- Логика модуля (ABS) ---
    
    # Обработка A
    mov -8(%rbp), %rax
    cmp $0, %rax            # Сравниваем A с нулем
    jge .skip_a             # Если A >= 0, прыгаем мимо смены знака
    neg %rax                # Если меньше — меняем знак (инвертируем)
.skip_a:
    mov %rax, -8(%rbp)      # Сохраняем обратно

    # Обработка B
    mov -16(%rbp), %rax
    cmp $0, %rax
    jge .skip_b
    neg %rax
.skip_b:
    mov %rax, -16(%rbp)

    # Обработка C
    mov -24(%rbp), %rax
    cmp $0, %rax
    jge .skip_c
    neg %rax
.skip_c:
    mov %rax, -24(%rbp)

    # --- Вывод результата ---
    mov $fmt_out, %rdi
    mov -8(%rbp), %rsi      # A
    mov -16(%rbp), %rdx     # B
    mov -24(%rbp), %rcx     # C
    xor %al, %al
    call printf

    leave
    ret
