sub OnContentSet()
    ? m.top.buttonContent
    content = m.top.buttonContent
    if content <> invalid
        m.top.FindNode("buttonLabel").text = content.title
    end if
end sub