sub OnContentSet() ' Invoked when item metadata retrieved
    content = m.top.itemContent
    ' Set poster uri if content is valid
    if content <> invalid
        m.top.FindNode("poster").uri = content.hdPosterUrl
    end if
end sub