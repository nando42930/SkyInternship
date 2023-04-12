' Entry point of DetailsScreen.
function Init()
    ' Observes "visible" so we can know when DetailsScreen changes visibility.
    m.top.ObserveField("visible", "OnVisibleChange")
    ' Observes "itemFocused" so we can know when another item gets in focus.
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
    ' Saves a reference to the DetailsScreen child components in the m variable,
    ' so we can access them easily from other functions (component scope).
    m.buttons = m.top.FindNode("buttons")
    m.poster = m.top.FindNode("poster")
    m.description = m.top.FindNode("descriptionLabel")
    m.timeLabel = m.top.FindNode("timeLabel")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.releaseLabel = m.top.FindNode("releaseLabel")
end function

sub OnContentChange(event as Object) ' Invoked when DetailsScreen "content" field is changed.
    ' Retrieves new content at the time of the change.
    content = event.getData()
    if content <> invalid
        m.isContentList = content.GetChildCount() > 0
        if m.isContentList = false
            SetDetailsContent(content)
            m.buttons.SetFocus(true)
        end if
    end if
end sub

sub SetButtons(buttons as Object)
    result = []
    ' Prepares array with each button's id and title.
    for each button in buttons
        result.push({title : button, id: LCase(button)})
    end for
    m.buttons.content = ContentListToSimpleNode(result) ' Populates buttons list.
end sub

sub SetDetailsContent(content as Object)
    ' Populates screen components with metadata.
    m.description.text = content.description
    m.poster.uri = content.hdPosterUrl
    if content.length <> invalid and content.length <> 0
        m.timeLabel.text = getTime(content.length)
    end if
    m.titleLabel.text = content.title
    m.releaseLabel.text = Left(content.releaseDate, 10)
    buttonList = ["Play", "PDP"] ' Regular buttons to be displayed on DetailsScreen.
    if content.mediaType = "series" ' Adds a button to list episodes by season of given series asset.
        buttonList.Push("See all episodes")
    end if
    SetButtons(buttonList)
end sub

sub OnVisibleChange()' Invoked when DetailsScreen visibility is changed.
    ' Sets focus for buttons list when DetailsScreen becomes visible.
    if m.top.visible = true
        m.buttons.SetFocus(true)
    end if
end sub

sub OnItemFocusedChanged(event as Object)' Invoked when another item is focused.
    focusedItem = event.GetData() ' Gets position of focused item.
    if m.top.content.GetChildCount() > 0
        content = m.top.content.GetChild(focusedItem) ' Gets metadata of focused item.
        SetDetailsContent(content) ' Populates DetailsScreen with item metadata.
    end if
end sub

sub OnJumpToItem() ' Invoked when jumpToItem field is populated.
    content = m.top.content
    ' Checks if jumpToItem field has a valid value,
    ' it should be set within interval from 0 to content.GetChildCount().
    if content <> invalid and m.top.jumpToItem >= 0 and content.GetChildCount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
    end if
end sub

' The OnKeyEvent() function receives remote control key events.
function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        currentItem = m.top.itemFocused ' Position of currently focused item.
        ' Handles "left" button keypress.
        if key = "left" and m.isContentList = true
            ' Navigates to the left item in case of "left" keypress.
            m.top.jumpToItem = currentItem - 1
            result = true
        ' Handles "right" button keypress.
        else if key = "right" and m.isContentList = true
            ' Navigates to the right item in case of "right" keypress.
            m.top.jumpToItem = currentItem + 1
            result = true
        end if
    end if
    return result
end function