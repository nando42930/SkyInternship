sub OnContentSet()
    content = m.top.itemContent
    if content <> invalid
        label = m.top.FindNode("buttonLabel")
        label.text = content.title
        label.color = m.top.buttonTextColor

        buttonGradient = m.top.FindNode("buttonGradient")
        buttonBackground = m.top.FindNode("buttonBackground")

        buttonGradient.visible = false
        buttonBackground.color = m.top.buttonColor
    end if
end sub

sub OnItemFocused() ' Invoked when jumpToItem field is populated

end sub

sub HandleFocus()
    if NOT m.top.itemHasFocus then return

    buttonBackground = m.top.FindNode("buttonBackground")
    buttonLabel = m.top.FindNode("buttonLabel")
    buttonGradient = m.top.FindNode("buttonGradient")

    buttonBackground.color = m.top.focusedButtonColor
    buttonLabel.color = m.top.focusedButtonTextColor
    buttonGradient.visible = true

    return

    ' buttonBackground = m.top.FindNode("buttonBackground")
    ' buttonLabel = m.top.FindNode("buttonLabel")
    ' buttonGradient = m.top.FindNode("buttonGradient")

    ' buttonBackground.color = m.top.buttonColor
    ' buttonLabel.color = m.top.buttonTextColor
    ' buttonGradient.visible = false

    ' if m.top.itemFocused <> invalid
    '     buttonBackground.color = m.top.focusedButtonColor
    '     buttonLabel.color = m.top.focusedButtonTextColor
    '     buttonGradient.visible = true
    '     return
    ' end if

    ' content = m.top.itemContent
    ' if content <> invalid and content.itemHasFocus
    '     content.buttonBackground.color = m.focusedButtonColor
    '     content.buttonLabel.color = m.focusedButtonTextColor
    ' else if not content.itemHasFocus and content <> invalid
    '     content.buttonBackground.color = m.buttonColor
    '     content.buttonLabel.color = m.buttonTextColor
    ' end if
end sub

sub HandleSelection()
end sub