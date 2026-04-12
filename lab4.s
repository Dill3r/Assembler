.section .rodata
    prompt:     .string "Введите число K: "
    fmt_in:     .string "%ld"
    fmt_out:    .string "%ld "
    newline:    .string "\n"

.section .text
.globl main
main:
    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp           # Выделяем место на стеке для переменной K

    # --- 1. Ввод числа K ---
    mov $prompt, %rdi
    xor %rax, %rax          # rax = 0 для printf
    call printf

    mov $fmt_in, %rdi
    lea -8(%rbp), %rsi      # Передаем адрес K в scanf
    xor %rax, %rax
    call scanf

    # --- 2. Подготовка к разбору ---
    mov -8(%rbp), %rax      # rax = K
    
    # Если число отрицательное, делаем его положительным
    cmp $0, %rax
    jge .prepare_loop
    neg %rax

.prepare_loop:
    xor %rcx, %rcx          # rcx будет счетчиком найденных цифр
    mov $10, %rbx           # делитель всегда 10

.split_loop:
    xor %rdx, %rdx          # обнуляем rdx перед делением (важно!)
    div %rbx                # делим rax на 10. Частное в rax, остаток в rdx
    
    push %rdx               # сохраняем цифру (остаток) в стек
    inc %rcx                # увеличиваем счетчик цифр
    
    test %rax, %rax         # проверяем, не закончилось ли число
    jnz .split_loop         # если частное не 0, продолжаем делить

    # --- 3. Вывод цифр из стека ---
    # В rcx сейчас лежит общее количество цифр
.print_loop:
    push %rcx               # сохраняем счетчик (printf его может испортить)
    
    pop %rax                # возвращаем счетчик в rax временно
    mov %rcx, %r12          # используем r12 (callee-saved) как копию счетчика
    
.print_actual:
    cmp $0, %r12            # проверяем, остались ли цифры в стеке
    je .done
    
    pop %rsi                # достаем очередную цифру из стека в rsi
    mov $fmt_out, %rdi      # формат вывода "%ld "
    xor %rax, %rax
    call printf
    
    dec %r12
    jmp .print_actual

.done:
    mov $newline, %rdi
    xor %rax, %rax
    call printf

    # Эпилог
    mov %rbp, %rsp
    pop %rbp
    ret
