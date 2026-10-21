---
frontmatter: 
  tags: day
  date: ${DATE}
---
### day works ${widgets.commandButton("new work", "Day: New Work")}
${some(query[[
  from j = index.pages("work")
  where j.date == ((editor.getCurrentPageMeta() or {}).date or "")
  order by j.time
  select templates.workEntry(j)
]]) or "_No work entries yet!_"}

### day tasks
- [ ]

### day notes
|^|
