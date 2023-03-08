' Entry point of GridScreen
' Note that we need to import this file in GridScreen.xml using relative path
sub Init()
    ' Observe "visible" field so we can know when GridScreen change visibility
    m.top.ObserveField("visible", "OnVisibleChange")
    m.rowList = m.top.FindNode("rowList")
    m.buttonBar = m.top.FindNode("buttonBar")
end sub

function SetButtonBarContent() as Object
    buttonBarContent = CreateObject("roSGNode", "ContentNode")
    buttonBarContent.Update({
        children: [{
            title: "Browse"
        }, {
            title: "Movies"
        }, {
            title: "TV Shows"
        }, {
            title: "Sports"
        }, {
            title: "WWE"
        }, {
            title: "Search"
        }]
    }, true)
    return buttonBarContent
end function

sub OnButtonBarItemSelected(event as Object)
    ' This is where you can handle a selection event
end sub

sub OnVisibleChange()' Invoked when GridScreen visibility is changed
    ' Set focus for button bar when GridScreen becomes visible
    if m.top.visible = true
        m.buttonBar.SetFocus(true)
    end if
end sub

sub SetButtons(buttons as Object)
    result = []
    ' Prepare array with button's labels
    for each button in buttons
        result.push({title : button, id: LCase(button)})
    end for
    m.buttonBar.content = ContentListToSimpleNode(result) ' Populate buttons list
end sub

sub OnJumpToItem() ' Invoked when jumpToItem field is populated
    content = m.top.content
    ' Check if jumpToItem field has valid value
    ' It should be set within interval from 0 to content.Getchildcount()
    if content <> invalid and m.top.jumpToItem >= 0 and content.GetChildCount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
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