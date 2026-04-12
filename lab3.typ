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
      [15.04.2026],
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
  #text[Ветвления в ассемблере]
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
      [15.04.2026],
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

= Описание задания
Согласно варианту №14, необходимо разработать программу на языке ассемблера, которая:

Запрашивает ввод трех целых чисел $A$, $B$ и $C$.

Проверяет каждое число на отрицательность.

Если число меньше нуля, заменяет его абсолютным значением (модулем).

Выводит итоговые значения переменных.

= Формализация
Реализация выполнена на языке ассемблера GAS для архитектуры x86_64 в ОС Linux.

Тип данных: Используется знаковое 64-битное целое число (long), формат %ld.

Алгоритм:

Ввод данных осуществляется через стандартную функцию scanf.

Для вычисления модуля используется команда сравнения cmp с нулем и условный переход jge (Jump if Greater or Equal).

Если число отрицательное, применяется инструкция neg, которая выполняет арифметическое отрицание (инверсию знака).

Вывод результата производится через функцию printf.

Ссылка на репозиторий: #link("https://gitlab.com/dill3r-group/Assembler/-/tree/main")

= Исходный код программы
```asm
#№ 14 - Замена отрицательных чисел их абсолютными значениями

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
```

= Тестирование

== Ручное тестирование
Для проверки логики переходов выбраны сценарии с разными знаками чисел:

$A=10, B=-5, C=0$ -> Ожидается: $10, 5, 0$.

$A=-1, B=-2, C=-3$ -> Ожидается: $1, 2, 3$.

== Результаты работы программы
Ниже представлены результаты тестирования программы в терминале Linux.

#figure(
table(
columns: 4,
align: center + horizon,
table.hline(),
[№], [Входные данные (A, B, C)], [Результат программы], [Статус],
table.hline(),
[1], [10, -5, 0], [10, 5, 0], [Успех],
[2], [-1, -2, -3], [1, 2, 3], [Успех],
[3], [100, 200, 300], [100, 200, 300], [Успех],
table.hline(),
),
caption: [Таблица тестовых случаев],
)

#figure(
image("output_test.png", width: 80%),
caption: [Скриншот выполнения программы lab3],
)

= Выводы
В ходе выполнения лабораторной работы были изучены механизмы ветвления в языке ассемблера x86_64. Были освоены команды сравнения (cmp), условные переходы (jge) и арифметическая инверсия (neg). Программа корректно обрабатывает как положительные, так и отрицательные числа, приводя их к абсолютному значению.
