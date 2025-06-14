# Реализация игровой механики управления популяцией на основе генетических алгоритмов



Этот проект на [Godot v4.4.1 stable](https://godotengine.org/download/archive/4.4.1-stable/) реализует классы для вышеуказанной механики и содержит демонстрацию её работы.



Основной сценой демонстрации является `game.tscn` (установлена как сцена по-умолчанию). Демонстрация рассчитана под мобильные устройства, для более удобного тестирования на декстопе может понадобиться изменить размеры viewport'а в настройках проекта и изменить границы мира для организмов в `config/organism2d-params.tres`.

## Структура

- `addons/` - используемые аддоны

- `config/` - основные параметры классов. Поведение демонстрации можно изменить здесь. Так как inspector Godot'а не позволяет указывать ссылки на функции, используемые функции ГА указаны в скрипте `population/population.gd`

- `etc/` - скрипты без особой категории. Здесь, в том числе, находится скрипт с функциями ГА `etc/ga-callables.gd`

- `local-effect/` - скрипты и сцены, отвечающие за изменение окружения и функции приспособленности организмов

- `population/` - основные классы симуляции организмов на основе ГА

- `tests/` - тесты для некоторых классов

- `ui/` - сцены и скрипты для интерфейса демонстрации

## Используемые аддоны

- [GUT](https://github.com/bitwes/Gut) для тестирования некоторых классов

- [gdlinter](https://github.com/el-falso/gdlinter/) и [GDScript-Formatter](https://github.com/Daylily-Zeleen/GDScript-Formatter) для форматирования кода

## Основные классы

- `population/organism/genome.gd` - отвечает за геном (параметры) организма. Хранит в себе сами параметры и предоставляет методы для их изменения.

- `population/organism/fitness-function.gd` - содержит функцию приспособленности организма и методы для изменения этой функции.

- `population/organism/organism.gd` - организм со стороны ГА, содержит в себе `genome`, `fitness_function` и функции ГА для мутации, выбора партнёра (2-ого родителя) и кроссовера.

- `population/population.gd` - отвечает за создание организмов и их глобальное окружение.

Остальные уже почти не связаны с ГА и отвечают поведение организма в мире, его визуальную часть, изменение окружения организма и т.п.


