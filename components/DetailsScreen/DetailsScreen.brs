' entry point of detailsScreen
function Init()
    ' observer "visible" so we can know when DetailsScreen change visibility
    m.top.ObserveField("visible", "OnVisibleChange")
    ' observe "itemFocused" so we can know when another item gets in focus
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
    ' save a reference to the DetailsScreen child components in the m variable
    ' so we can access them easily from other functions
    m.buttons = m.top.FindNode("buttons")
    m.poster = m.top.FindNode("poster")
    m.description = m.top.FindNode("descriptionLabel")
    m.timeLabel = m.top.FindNode("timeLabel")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.releaseLabel = m.top.FindNode("releaseLabel")
end function

sub OnVisibleChange() ' invoked when DetailsScreen visibility is changed
    ' set focus for buttons list when DetailsScreen become visible
    if m.top.visible = true
        m.buttons.SetFocus(true)
    end if
end sub

sub SetButtons(buttons)
        ' create buttons
        result = []
        for each button in buttons
            result.Push({title : button})
        end for
        m.buttons.content = ContentListToSimpleNode(result) ' set list of buttons for DetailsScreen
end sub

sub SetDetailsContent(content)
    ' Populate content details information
    ' m.description.text = content.description ' set description of content
    ' m.poster.uri = content.hdPosterUrl ' set url of content poster
    if content.lenght <> invalid and content.length <> 0
        m.timeLabel.text = GetTime(content.length) ' set length of content
    end if
    ' m.titleLabel.text = content.title ' set title of content
    ' m.releaseLabel.text = Left(content.releaseDate, 10) ' set release date of content
    if content.mediaType = "series"
        ' buttons for series DetailsScreen
        SetButtons(["Play", "See all episodes"])
    else
        ' buttons for content DetailsScreen
        SetButtons(["Play"])
    end if
end sub

sub OnJumpToItem() ' invoked when jumpToItem field is populated
    content = m.top.content
    ' check if jumpToItem field has valid value
    ' it should be set within interval from 0 to content.GetChildCount()
    if content <> invalid and m.top.jumpToItem >= 0 and content.GetChildCount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
    end if
end sub

sub OnItemFocusedChanged(event as Object) ' invoked when another item is focused
    focusedItem = event.GetData() ' get position of focused item
    content = m.top.content.GetChild(focusedItem) ' get metadata of focused item
    SetDetailsContent(content) ' populate DetailsScreen with item metadata
end sub

' The OnKeyEvent() function receives remote control key events
function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        currentItem = m.top.itemFocused ' position of currently focused item
        ' handle "left" button keypress
        if key = "left"
            ' navigate to the left item in case of "left" keypress
            m.top.jumpToItem = currentItem - 1
            result = true
        ' handle "right" button keypress
        else if key = "right"
            ' navigate to the right item in case of "right" keypress
            m.top.jumpToItem = currentItem + 1
            result = true
        end if
    end if
    return result
end function