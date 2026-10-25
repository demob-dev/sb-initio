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
initio = initio or {}

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
    local thisday = ((editor.getCurrentPageMeta() or {}).date or date.today())
    initioWork.openOrCreate(thisday .. "_" .. os.date("%H%M"))
  end
}

command.define {
  name = "Initio: Add code fences",
  key = "Ctrl-a",
  run = function()
    editor.insertAtCursor("```\n|^|\n```\n", false, true)
  end
}

event.listen {
  name = "editor:pageCreating",
  run = function(e)
    local day =  string.sub(e.data.name, 6, 15)
    local hour = string.sub(e.data.name, -4, -3)
    local mnts = string.sub(e.data.name, -2, -1)
    local template = ""
    if e.data.name:startsWith("Days/") then
        local rawTemplate = space.readPage("Library/sb-initio/Day.template")
        --local tree = markdown.parseMarkdown(rawTemplate)
        --local expandedTree = markdown.expandMarkdown(tree)
        --local template = markdown.renderParseTree(expandedTree)
        template = string.gsub(rawTemplate, "${DATE}", day)
        return { text = template, perm = "rw" }
    elseif e.data.name:startsWith("Work/") then
        template = space.readPage("Library/sb-initio/Work.template")
        template = string.gsub(template, "${DATE}", day)
        template = string.gsub(template, "${HOUR}", hour)
        template = string.gsub(template, "${MNTS}", mnts)
        return { text = template, perm = "rw" }
    end
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
      term = schema.number(),
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
--
tag.define {
  name = "pack",
  schema = {
    type = "object",
    properties = {
      pack = schema.nullable("string"),
    },
  },
}
--
tag.define {
  name = "task",
  schema = {
    type = "object",
    properties = {
      pack = schema.nullable("string"),
      done = schema.number(),
    },
  },
}
```

## Utilites

```space-lua
templates.workEntry = template.new([==[
* [[${name}|${time}]]-${term}${ some(jira) and " [" .. jira .. "](https://git.esterdev.com/jira/browse/" .. jira ..")" or ""}${ some(case) and " "..case or ""} ${get_first_paragraph(name)}
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

## Widgets

```space-lua

function initio.generateWorkSlotLine(day, from, to)
  local res = ""
  for i = from, to do
    res = res .. string.format("**%02d**", i)
    for k, j in pairs({"00", "15", "30", "45"}) do
      res = res .. string.format("[[Work/%s_%02d%s|:%s]]", day, i, j, j)
    end
    res = res .. " "
  end
  return res
end

function initio.widgetWorkDailyBlock()
  local res = {}
  local day = ((editor.getCurrentPageMeta() or {}).date or "")
  -- prepare direct access to works
  table.insert(res, initio.generateWorkSlotLine(day,  8, 11))
  table.insert(res, initio.generateWorkSlotLine(day, 12, 15))
  table.insert(res, initio.generateWorkSlotLine(day, 16, 19))
  table.insert(res, " ")
  -- prepare work list
  for w in query[[
    from w = index.pages("work")
    where w.date == ((editor.getCurrentPageMeta() or {}).date or "")
    order by w.time
    select w
  ]] do
    local work = string.format("[[%s|%s]]-%d%s%s %s",
      w.name, w.time, w.term,
      (some(w.jira) and " [" .. w.jira .. "](https://git.esterdev.com/jira/browse/" .. w.jira ..")" or ""),
      (some(w.case) and " "..w.case or ""),
      get_first_paragraph(w.name)
    )
    table.insert(res, work)
  end
  -- prepare status line of jira timing
  local stat = ""
  local tota = 0
  for k in query[[
  from p = index.pages("work")
  where p.date == ((editor.getCurrentPageMeta() or {}).date or "")
  group by p.jira
  select {
    jira = p.jira,
    dura = sum(p.term),
  }]] do
    tota = tota + k.dura
    stat = stat .. string.format("\n[%10s](https://git.esterdev.com/jira/browse/%s): %s ",k.jira,k.jira, string.format("%02dh %02dm", math.floor(k.dura/60), k.dura % 60))
  end
  stat = stat .. string.format("\n     total: %02dh %02dm", math.floor(tota/60), tota % 60)
  table.insert(res, ""..stat)
  -- return markdown block
  return widget.markdownBlock(table.concat(res,"\n"))
end

```


