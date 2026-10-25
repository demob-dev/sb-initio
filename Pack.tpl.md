---
command: "Initio: New Pack"
tags: meta/template/page
suggestedName: "pack_${os.date('%Y-%m-%d_%H%M')}"
confirmName: false
openIfExists: true
frontmatter: |
  tags: pack
  pack: "[[${editor.getCurrentPage() or ''}]]"
---
pack description

${[=[${initio.widgetPackInfo()}]=]}
|^|

### pack deeds
- [ ]
