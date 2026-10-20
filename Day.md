---
name: day
command: "Day: New Entry"
tags: meta/template/page
suggestedName: "Days/${os.date('%Y-%m-%d')}"
confirmName: false
frontmatter: |
  tags: day
  date: ${os.date('%Y-%m-%d')}
---
### day works ${[=[
${widgets.commandButton("new work", "Day: New Work")}
]=]} ${[=[
${some(query[[
  from j = index.pages("work")
  where j.date == ((editor.getCurrentPageMeta() or {}).date or "")
  order by j.time
  select templates.workEntry(j)
]]) or "_No work entries yet!_"}
]=]}

### day tasks
- [ ]

### day notes
|^|
