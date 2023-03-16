' Entry point of ButtonBar
' This file has to be referenced in ButtonBar.xml using relative path
sub Init()
    ' Button bar node
    m.buttonBar = m.top.FindNode("buttonBar")
    ' Nodes in each button
    m.buttonBackground = m.top.FindNode("buttonBackground")
    m.buttonLabel = m.top.FindNOde("buttonLabel")

    buttonLabels = ["Browse", "Movies", "TV Shows", "Sports", "WWE"]
    ' Different button's labels
    SetButtons(buttonLabels)
end sub

sub SetButtons(buttons as Object)
    result = []
    ' Prepare array with button's labels
    for each button in buttons
        result.push({title: button, id: LCase(button)})
    end for
    content = ContentListToSimpleNode(result)
    node = CreateObject("roSGNode", "ContentNode")
    node.AppendChild(content)

    m.buttonBar.content = node ' Populate buttons list
end sub

sub OnJumpToItem() ' Invoked when jumpToItem field is populated
    content = m.top.content
    ' Check if jumpToItem field has valid value
    ' It should be set within interval from 0 to content.Getchildcount()
    if content <> invalid and m.top.jumpToItem >= 0 and content.GetChildCount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
    end if
end sub

sub HandleFocus()
    content = m.top.buttonContent
    if content.itemHasFocus
        content.buttonBackground.color = m.focusedButtonColor
        content.buttonLabel.color = m.focusedButtonTextColor
    else if not content.itemHasFocus
        content.buttonBackground.color = m.buttonColor
        content.buttonLabel.color = m.buttonTextColor
    end if
end sub

sub HandleSelection()
end sub

' sub OnButtonBarItemSelected(event as Object)
'     ' This is where you can handle a selection event
' end sub