' Entry point of DetailsScreen
function Init()
    ' Observe "visible" so we can know when DetailsScreen change visibility
    m.top.ObserveField("visible", "OnVisibleChange")
    ' Observe "itemFocused" so we can know when another item gets in focus
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
    ' Save a reference to the DetailsScreen child components in the m variable
    ' so we can access them easily from other functions
    m.buttons = m.top.FindNode("buttons")
    m.poster = m.top.FindNode("poster")
    m.description = m.top.FindNode("descriptionLabel")
    m.timeLabel = m.top.FindNode("timeLabel")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.releaseLabel = m.top.FindNode("releaseLabel")
end function

sub OnVisibleChange() ' Invoked when DetailsScreen visibility is changed
    ' Set focus for buttons list when DetailsScreen becomes visible
    if m.top.visible = true
        m.buttons.SetFocus(true)
    end if
end sub

sub SetButtons(buttons as Object)
        ' Create buttons
        result = []
        ' Prepare array with button's titles
        for each button in buttons
            result.Push({title: button, id: LCase(button)})
        end for
        m.buttons.content = ContentListToSimpleNode(result) ' Set list of buttons for DetailsScreen
end sub

sub OnContentChange(event as Object)
    content = event.GetData()
    if content <> invalid
        m.isContentList = content.GetChildCount() > 0
        if m.isContentList = false
            SetDetailsContent(content)
            m.buttons.SetFocus(true)
        end if
    end if
end sub

sub SetDetailsContent(content as Object)
    ' Populate screen components with metadata
    m.description.text = content.description ' Set description of content
    m.poster.uri = content.hdPosterUrl ' Set url of content poster
    if content.lenght <> invalid and content.length <> 0
        m.timeLabel.text = GetTime(content.length) ' Set length of content
    end if
    m.titleLabel.text = content.title ' Set title of content
    m.releaseLabel.text = Left(content.releaseDate, 10) ' Set release date of content
    buttonList = ["Play"]
    if content.mediaType = "series"
        smartBookmarks = MasterChannelSmartBookmarks()
        ' episodeId contains id of the episode which should be played
        episodeId = smartBookmarks.GetSmartBookmarkForSeries(content.id)
        if episodeId <> invalid and episodeId <> ""
            episode = FindNodeById(content, episodeId)
            if episode <> invalid
                episode.bookmarkPosition = MasterChannelBookmarks().GetBookmarkForVideo(episode)
                buttonList.Push("Continue")
            end if
        end if
        buttonList.Push("See all episodes")
    else
        ' Set playback start position using bookmarks
        content.bookmarkPosition = MasterChannelBookmarks().GetBookmarkForVideo(content)
        ' Add Continue button if user started this content, but didn't finish it
        if content.bookmarkPosition > 0
            buttonList.Push("Continue")
        end if
    end if
    ' Buttons for content DetailsScreen
    SetButtons(buttonList)
end sub

sub OnJumpToItem() ' Invoked when jumpToItem field is populated
    content = m.top.content
    ' Check if jumpToItem field has valid value
    ' It should be set within interval from 0 to content.GetChildCount()
    if content <> invalid and m.top.jumpToItem >= 0 and content.GetChildCount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
    end if
end sub

sub OnItemFocusedChanged(event as Object) ' Invoked when another item is focused
    focusedItem = event.GetData() ' Get position of focused item
    if m.top.content.GetChildCount() > 0
        content = m.top.content.GetChild(focusedItem) ' Get metadata of focused item
        SetDetailsContent(content) ' Populate DetailsScreen with item metadata
    end if
end sub

' The OnKeyEvent() function receives remote control key events
function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        currentItem = m.top.itemFocused ' Position of currently focused item
        ' Handle "left" button keypress
        if key = "left" and m.isContentList = true
            ' Navigate to the left item in case of "left" keypress
            m.top.jumpToItem = currentItem - 1
            result = true
        ' Handle "right" button keypress
        else if key = "right" and m.isContentList = true
            ' Navigate to the right item in case of "right" keypress
            m.top.jumpToItem = currentItem + 1
            result = true
        end if
    end if
    return result
end function