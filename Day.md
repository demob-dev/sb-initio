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
### day works ${[=[ ${widgets.commandButton("new work", "Day: New Work")} ]=]} 
${[=[ ${initio.widgetWorkDailyBlock()} ]=]}

### day tasks
- [ ]

### day notes
|^|
