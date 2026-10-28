---
command: "Initio: New Case (Task)"
tags: meta/template/page
suggestedName: "case_${os.date('%Y-%m-%d_%H%M')}"
confirmName: false
openIfExists: true
frontmatter: |
  tags: case
  pack: "${initio.getCurrentPageLink("pack")}"
  done: 0
---
case description

${[=[${initio.widgetCaseInfo()}]=]}
|^|

### case deeds
- [ ]
