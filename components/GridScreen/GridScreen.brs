' Entry point of GridScreen.
sub Init()
    ' Observe "visible" field so we can know when GridScreen change visibility
    m.top.ObserveField("visible", "OnVisibleChange")
    m.buttonBarRowList = m.top.FindNode("buttonBarRowList")
    m.rowList = m.top.FindNode("rowList")
end sub

' Handles visibility of GridScreen.
sub OnVisibleChange()' Invoked when GridScreen visibility is changed
    ' Set focus for button bar when GridScreen becomes visible
    if m.top.visible = true
        m.rowList.SetFocus(true)
    end if
end sub

' Typically, you should use the ifSGNodeField observeField() method
' to handle changes in the subject node fields caused by automatic key event handling of the node.
function OnKeyEvent(key as String, pressed as Boolean) as Boolean
    if pressed
        if key = "up"
            m.rowList.SetFocus(false)
            m.buttonBarRowList.SetFocus(true)
            return true
        else if key = "down"
            m.buttonBarRowList.SetFocus(false)
            m.rowList.SetFocus(true)
            return true
        end if
    end if
    ' The OnKeyEvent() function must return true if the component handled the event,
    ' or false if it did not handle the event.
    return false
end function