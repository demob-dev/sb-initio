---
name: Library/sb-initio/sb-initio
tags: meta/library
---

This is `sb-initio/sb-initio` library.

## Core

```space-lua
-- priority: 10

initioDay = initioDay or {}
initioWork = initioWork or {}

function initioDay.openOrCreate(dateStr)
  local pageName = "Days/" .. dateStr
  if space.pageExists(pageName) then
    editor.navigate(pageName)
    return
  end
  local templatePage = "Library/sb-initio/Day"
  template.createPageFromTemplate(templatePage, pageName, true)
end

function initioDay.entries()
  return query[[
    from j = index.pages("day")
    order by j.date desc
  ]]
end

function initioWork.openOrCreate(dateStr)
  local pageName = "Work/" .. dateStr
  if space.pageExists(pageName) then
    editor.navigate(pageName)
    return
  end
  local templatePage = "Library/sb-initio/Work"
  template.createPageFromTemplate(templatePage, pageName, true)
end

function initioWork.entries()
  return query[[
    from j = index.pages("work")
    order by j.date desc
  ]]
end

command.define {
  name = "Day: Today",
  run = function()
    initioDay.openOrCreate(date.today())
  end
}

command.define {
  name = "Day: New Work",
  run = function()
    initioWork.openOrCreate(os.date("%Y-%m-%d") .. "_" .. os.date("%H%M"))
  end
}

event.listen {  
  name = "editor:pageCreating",  
  run = function(e)  
    if not e.data.name:startsWith("Days/") then return end  
    local rawTemplate = space.readPage("Library/sb-initio/DayFC")  
    --local tree = markdown.parseMarkdown(rawTemplate)  
    --local expandedTree = markdown.expandMarkdown(tree)  
    --local template = markdown.renderParseTree(expandedTree)
    local template = string.gsub(rawTemplate, "${DATE}", string.sub(e.data.name,6))
    return { text = template, perm = "rw" }  
  end  
}

```

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
templates.workEntry = template.new([==[
* [[${name}|${time}]]-${duration}${ some(jira) and " [" .. jira .. "](https://git.esterdev.com/jira/browse/" .. jira ..")" or ""}${ some(case) and " "..case or ""} ${get_first_paragraph(name)}
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



