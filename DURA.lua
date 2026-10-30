function twoLists(left, right, opts)
  local cols = {
    dom.td { markdown.renderToDom(left) },
    dom.td { markdown.renderToDom(right) },
  }
  -- optional header <th> cells when opts.leftTitle/rightTitle are given
  return widget.htmlBlock(dom.table {
    class = "two-lists",
    dom.tbody { dom.tr { cols } },
  })
end

${twoLists(
  [[* Item A
     * Item B
     * Item C]],
  [[1. First
     2. Second
     3. Third]]
)}

function initio.widgetTwoCols(left, right)
  return widget.htmlBlock(dom.div {
    style = "display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px;",
    dom.div {
      style = "min-width: 0;",
      markdown.renderToDom(left)
    },
    dom.div {
      style = "min-width: 0;",
      markdown.renderToDom(right)
    }
  })
end


${twoColumns()}
