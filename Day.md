---
name: day
command: "Day: New Entry"
tags: meta/template/page
suggestedName: "Days/${os.date('%Y-%m-%d')}"
confirmName: false
openIfExists: true
frontmatter: |
  tags: day
  date: ${os.date('%Y-%m-%d')}
---

${[=[ ${initio.widgetDayInfo()} ]=]}

|^|