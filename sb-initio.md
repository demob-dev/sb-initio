---
name: Library/demob-dev/sb-initio
tags: meta/library
---

This is `demob-dev/sb-initio` library.

## Tags

This library defines the `work` tag, for tagging pages that contain a work entry, and the `day` tag, for pages that contain a day entry.

```space-lua
tag.define {
  name = "work",
  schema = {
    type = "object",
    properties = {
      date = schema.string(),
      time = schema.string(),
      duration = schema.number(),
      case = schema.nullable("string"),
      jira = schema.nullable("string"),
    },
  },
}
--
tag.define {
  name = "day",
  schema = {
    type = "object",
    properties = {
      date = schema.string(),
    },
  },
}
```

## Utilites

```space-lua
templates.workEntry =
template.new([==[
* [[${name}|${time}]]-${duration}${ some(jira) and " [" .. jira .. "](https://ya.ru)" or ""}${ some(case) and " "..case or ""} ${get_first_paragraph(name)}
]==])

-- Вспомогательная функция для рекурсивного поиска первого абзаца в дереве
local function find_first_paragraph(tree)
    if tree.type == "Paragraph" then
        return tree
    end
    if tree.children then
        for _, child in ipairs(tree.children) do
            local found = find_first_paragraph(child)
            if found then
                return found
            end
        end
    end
    return nil
end

-- Основная функция: Принимает имя страницы, читает её тело и парсит в дерево
function get_first_paragraph(page_name)
    -- 1. Безопасно читаем тело страницы
    local success, body = pcall(space.readPage, page_name)
    if not success or not body then
        return "Ошибка: Не удалось прочитать страницу '" .. page_name .. "'"
    end
    -- 2. Передаем полученную строку body в парсер Markdown
    local tree = markdown.parseMarkdown(body)
    -- 3. Выполняем полезную работу с деревом (например, ищем первый абзац)
    local paragraph_node = find_first_paragraph(tree)
    if paragraph_node then
        -- Рендерим узел обратно в Markdown-текст
        return markdown.renderParseTree(paragraph_node)
    else
        return "undescribed"
    end
end

local function generateHoursArray()
    local hours = {}
    for i = 0, 23 do
        local timeStr = string.format("%02d:00", i)
        hours[timeStr] = timeStr
    end
    return hours
end

local function mergeTablesInPlace(t1, t2)
    for k, v in pairs(t2) do
        if t1[k] == nil then
            t1[k] = v
        end
    end
    return t1
end

local --- Сливает две таблицы. Значения из t1 имеют приоритет.
-- @param t1 (table) Первая таблица
-- @param t2 (table) Вторая таблица
-- @return (table) Новая объединенная таблица
function mergeTables(t1, t2)
    local result = {}

    -- 1. Копируем все пары ключ-значение из первой таблицы
    for k, v in pairs(t1) do
        result[k] = v
    end

    -- 2. Добавляем пары из второй таблицы, только если ключа нет в первой
    for k, v in pairs(t2) do
        if result[k] == nil then
            result[k] = v
        end
    end

    return result
end
```



