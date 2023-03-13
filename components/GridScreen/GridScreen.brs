' Entry point of GridScreen
' This file has to be referenced in GridScreen.xml using relative path
sub Init()
    ' Observe "visible" field so we can know when GridScreen change visibility
    m.top.ObserveField("visible", "OnVisibleChange")
    m.rowList = m.top.FindNode("rowList")
end sub

sub OnVisibleChange()' Invoked when GridScreen visibility is changed
    ' Set focus for button bar when GridScreen becomes visible
    if m.top.visible = true
        m.buttonBar.SetFocus(true)
    end if
end sub

' Typically, you should use the ifSGNodeField observeField() method
' to handle changes in the subject node fields caused by automatic key event handling of the node.
function OnKeyEvent(key as String, pressed as Boolean) as Boolean
    handled = false
    if pressed
        currentItem = m.top.itemFocused ' Index of currently focused item
        ' Handle "left" button keypress
        if key = "left" and m.isContentList = true
            ' Navigate to the left item in case of "left" keypress
            m.top.jumpToItem = currentItem - 1
            handled = true
        ' Handle "right" button keypress
        else if key = "right" and m.isContentList = true
            ' Navigate to the right item in case of "right" keypress
            m.top.jumpToItem = currentItem + 1
            handled = true
        end if
    end if
    ' The OnKeyEvent() function must return true if the component handled the event,
    ' or false if it did not handle the event.
    return handled
end function