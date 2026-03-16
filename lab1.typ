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
      [01.01.2026],
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
  #text[Вычисление для беззнаковых целых чисел]
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
      [01.01.2026],
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
Согласно варианту №79, необходимо вычислить значение функции для беззнаковых 64-битных чисел:
$Y = (9A^2 - 3B^2 + A dot C) / C^2$

Требования к программе:

Поддержка консольного ввода переменных $A, B, C$.

Вывод результата (частное и остаток) на консоль.

Использование только беззнаковых инструкций.

= Формализация
Реализация выполнена на языке ассемблера GAS для архитектуры x86_64 в ОС Linux.

Тип данных: Используются 64-битные регистры и формат %lu.

Математический модуль: Ограничение $9A^2 + A C >= 3B^2$.

Алгоритм: Ввод данных через scanf, умножение через mul, деление через div (с обнулением rdx).

Ссылка на репозиторий: #link("https://github.com/Dill3r/Assembler")

= Исходный код программы
```asm
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
```

= Тестирование

== Ручное тестирование

Набор 1: $A=4, B=3, C=2$. Результат: $31$ (ост. 1)

Набор 2: $A=2, B=1, C=3$. Результат: $4$ (ост. 3)

== Результаты работы программы
Ниже представлены результаты программного тестирования.

#figure(
table(
columns: 5,
align: center + horizon,
table.hline(),
[Тест], [A], [B], [C], [Ожидаемый результат],
table.hline(),
[1], [4], [3], [2], [31, ост 1],
[2], [2], [1], [3], [4, ост 3],
[3], [1], [1], [2], [2, ост 0],
table.hline(),
),
caption: [Сводная таблица тестов],
)

#figure(
image("output_test.png", width: 80%),
caption: [Скриншот выполнения программы],
)

= Выводы
В ходе лабораторной работы была изучена архитектура x86_64 и синтаксис GAS. Программа успешно вычисляет заданную функцию. Результаты тестов совпадают с расчетными. Лабораторная работа выполнена верно.