---
name: work
command: "Work: New Entry"
tags: meta/template/page
suggestedName: "Work/${os.date('%Y-%m-%d')}_${os.date('%H%M')}"
confirmName: false
frontmatter: |
  tags: work
  date: ${os.date('%Y-%m-%d')}
  time: "${os.date('%H:%M')}"
  duration: 20
  case: ""
  jira: ""
---
|^|
