sub OnContentSet()
    content = m.top.itemContent
    if content <> invalid
        label = m.top.FindNode("buttonLabel")
        label.text = content.title
    end if
end sub