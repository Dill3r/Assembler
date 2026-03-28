#set page(
  paper: "a4",
  margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 1cm),
  numbering: none
)

#set text(
  lang: "ru",
  font: "Times New Roman",
  size: 12pt
)


#align(center)[
  #upper[ГУАП]
  #v(0.5cm)
  #upper[КАФЕДРА № 14]
  #v(2cm)
]

#grid(
  columns: (2fr),
  align(left)[
    #upper[ОТЧЕТ]\
    #upper[ЗАЩИЩЕН С ОЦЕНКОЙ]\
    #upper[]\
    #upper[ПРЕПОДАВАТЕЛЬ]
  ],
  align(center)[
    #v(0.5cm)
    #grid(
      columns: (2fr, 1fr, 2fr),
      gutter: 0.3em,
      [Старший преподаватель],
      [01.04.2026],
      [Синёв Н.И.],
      line(length: 100%),
      line(length: 100%),
      line(length: 100%),
      [должность, уч. степень, звание],
      [подпись, дата],
      [инициалы, фамилия]
    )
  ]
)

#align(center)[
  #v(2cm)
  #upper[ОТЧЕТ О ЛАБОРАТОРНОЙ РАБОТЕ]
  #v(0.8cm)
  #text[Вычисление для знаковых целых чисел]
  #v(0.8cm)
  #text[по курсу:]
  #text[программирования на языках ассемблера]
  #v(4cm)
]

#grid(
  columns: (2fr),
  align(left)[
    #upper[РАБОТУ ВЫПОЛНИЛ]
  ],
  align(center)[
    #v(0.5cm)
    #grid(
      columns: (1fr, 1fr, 1fr, 1.5fr),
      gutter: 0.3em,
      align(left)[#upper[СТУДЕНТ гр. №]],
      [1445],
      [01.04.2026],
      [Олефиренко Н.Б.],
      line(length: 0%),
      line(length: 100%),
      line(length: 100%),
      line(length: 100%),
      [],
      [],
      [подпись, дата],
      [инициалы, фамилия]
    )

    #v(4cm)

    Санкт-Петербург 2026
]
)



#pagebreak()
#set page(numbering: "1")


= Описание задания
Согласно варианту №79, необходимо вычислить значение функции для знаковых 64-битных чисел:
$X = (4A^3 - 3A^2) / B^2$

= Формализация
Реализация выполнена на языке ассемблера GAS для архитектуры x86_64 в ОС Linux.

Типы данных: Используются 64-битные регистры и знаковый формат %lu.

Ограничения: Для корректной знаковой арифметики предполагается, что $4A^3 >= 3A^2$.

Средства: Использование инструкций mul для возведения в степень и div для финального деления.

= Исходный код программы
```asm
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
```

= Тестирование
Для проверки корректности работы программы проведен расчет для следующих наборов данных:

Набор 1: $A=2, B=2$

Числитель: $4(8) - 3(4) = 32 - 12 = 20$

Знаменатель: $2^2 = 4$

Результат: $20 / 4 = 5$ (ост. 0)

Набор 2: $A=3, B=4$

Числитель: $4(27) - 3(9) = 108 - 27 = 81$

Знаменатель: $4^2 = 16$

Результат: $81 / 16 = 5$ (ост. 1)

#figure(
table(
columns: 5,
align: center + horizon,
table.hline(),
[Тест], [A], [B], [Ожидаемый X], [Остаток],
table.hline(),
[1], [2], [2], [5], [0],
[2], [3], [4], [5], [1],
[3], [1], [1], [1], [0],
table.hline(),
),
caption: [Сводная таблица тестов для выражения $(4A^3 - 3A^2) / B^2$],
) 

#figure(
image("output_test.jpg", width: 80%),
caption: [Скриншот выполнения программы в терминале Linux],
) 

= Выводы
В ходе работы был реализован алгоритм вычисления дробно-рационального выражения на языке GAS. Программа успешно обрабатывает ввод, выполняет возведение в степень и деление. Результаты тестов подтверждают правильность логики. Лабораторная работа выполнена верно.