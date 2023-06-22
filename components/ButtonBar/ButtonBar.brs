' Entry point of ButtonBar
' This file has to be referenced in ButtonBar.xml using relative path
sub Init()
    ' Button bar nodes
    m.buttonBarRowList = m.top.FindNode("buttonBarRowList")
    m.search = m.top.FindNode("search")
    m.buttons = ["Browse", "Movies", "TV Shows", "Sports", "WWE"]
    SetButtons()
end sub

sub SetButtons()
    result = []
    content = CreateObject("roSGNode", "ContentNode")
    ' Prepare array with button's labels
    for each button in m.buttons
        result.push({title: button, id: LCase(button)})
    end for
    content = ContentListToSimpleNode(result)
    node = CreateObject("roSGNode", "ContentNode")
    node.AppendChild(content)
    m.buttonBarRowList.content = node ' Populate buttons list
end sub

sub OnRowItemFocused()
    SetButtons()
    m.buttonBarRowList.jumpToItem = m.top.rowItemFocused[1]
end sub

sub OnJumpToItem() ' Invoked when jumpToItem field is populated
    content = m.top.content
    ' Check if jumpToItem field has valid value
    ' It should be set within interval from 0 to content.Getchildcount()
    if content <> invalid and m.top.jumpToItem >= 0 and content.GetChildCount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
    end if
end sub

' sub OnItemSelected()
'     content = m.top.content
'     label = content.FindNode("buttonLabel").text
'     if label = "Browse"
'         return
'     else if label = "Movies"
'         return
'     else if label = "TV Shows"
'         return
'     else if label = "Sports"
'         return
'     else if label = "WWE"
'         return
'     end if
' end sub

function OnKeyEvent(key as String, pressed as Boolean) as Boolean
    searchBackground = m.top.FindNode("searchBackground")
    buttonGradient = m.top.FindNode("buttonGradient")
    if pressed
        if key = "right" and m.buttonBarRowList.hasFocus()
            m.search.setFocus(true)
            buttonGradient.visible = true
            searchBackground.blendColor = m.top.focusedButtonColor
            SetButtons()
        else if key = "left" and m.search.hasFocus()
            m.buttonBarRowList.setFocus(true)
            buttonGradient.visible = false
            searchBackground.blendColor = m.top.buttonColor
            SetButtons()
        else if key = "OK" and m.search.hasFocus()
            scene = m.top.GetScene()
            scene.callFunc("ShowSearchScreen")
        end if
    end if
    return false
end function