' entry point of GridScreen
' Note that we need to import this file in GridScreen.xml using relative path.
sub Init()
    m.rowList = m.top.FindNode("rowList")
    m.top.ObserveField("visible", "OnVisibleChange")
    m.buttonGroup = m.top.FindNode("buttonBar")
    m.buttonGroup.SetFocus(true)
    m.buttonGroup.ObserveField("buttonFocused", "OnButtonFocusedChange")
    m.buttonGroup.ObserveField("buttonSelected", "OnButtonSelectedChange")
end sub

sub OnVisibleChange() ' invoked when GridScreen change visibility
    if m.top.visible = true
        m.rowList.SetFocus(true) ' set focus to rowList if GridScreen visible
    end if
end sub

sub OnButtonFocusedChange()
end sub

sub OnButtonSelectedChange()
end sub


' Typically, you should use the ifSGNodeField observeField() method
' to handle changes in the subject node fields caused by automatic key event handling of the node.
function onKeyEvent(_key_ as String, _press_ as Boolean) as Boolean  
    return true
end function