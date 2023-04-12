function GetSupportedMediaTypes() as Object ' Returns AA with supported media types.
    return {
        "series": "series"
        "season": "episode"
        "episode": "episode"
        "movie": "movies"
        "shortFormVideo": "shortFormVideos"
    }
end function

sub OnInputDeepLinking(event as Object)  ' Invoked in case of "roInputEvent".
    args = event.getData()
    if args <> invalid and ValidateDeepLink(args) ' Validates deep link arguments.
        DeepLink(m.GridScreen.content, args.mediaType, args.contentId) ' Performs deep linking.
    end if
end sub

' Checks if deep link arguments are valid.
function ValidateDeepLink(args as Object) as Boolean
    mediaType = args.mediaType
    contentId = args.contentId
    types = GetSupportedMediaTypes()
    return mediaType <> invalid and contentId <> invalid and types[mediaType] <> invalid
end function

' Performs deep linking.
sub DeepLink(content as Object, mediaType as String, contentId as String)
    playableItem = FindNodeById(content, contentId) ' Finds content for deep linking by contentId.
    types = GetSupportedMediaTypes()
    ' Checks if chosen item has appropriate mediaType.
    if playableItem <> invalid and playableItem.mediaType = types[mediaType]
        ClearScreenStack() ' Removes all screens from screen stack except GridScreen.
        PrepareDetailsScreen(playableItem) ' Creates detailsScreen and pushes it to the screen stack.
        ShowScreen(playableItem) ' Launches detailsScreen.
    end if
end sub

sub PrepareDetailsScreen(content as Object)
    ' Creates DetailsScreen to be shown when user navigates from Video player.
    ' It will contain info about played content.
    m.deepLinkDetailsScreen = CreateObject("roSGNode", "DetailsScreen")
    m.deepLinkDetailsScreen.content = content
    m.deepLinkDetailsScreen.ObserveField("visible", "OnDeepLinkDetailsScreenVisibilityChanged")
    m.deepLinkDetailsScreen.ObserveField("buttonSelected", "OnDeepLinkDetailsScreenButtonSelected")
    AddScreen(m.deepLinkDetailsScreen) ' Adds DetailsScreen to screen stack but doesn't show it.
end sub

sub OnDeepLinkDetailsScreenVisibilityChanged(event as Object) ' Invoked when DetailsScreen "visible" field is changed.
    visible = event.GetData()
    screen = event.GetRoSGNode()
    if visible = false and IsScreenInScreenStack(screen) = false
        content = screen.content
        if content <> invalid
            ' Jumps to appropriate tile on GridScreen.
            m.GridScreen.jumpToRowItem = [content.homeRowIndex, content.homeItemIndex]
            ' Invalidates deepLinkDetailsScreen if user presses "Back" button on DetailsScreen.
            if m.deepLinkDetailsScreen <> invalid
                m.deepLinkDetailsScreen = invalid
            end if
        end if
    end if
end sub

sub OnDeepLinkDetailsScreenButtonSelected(event as Object) ' invoked when button is  pressed on DetailsScreen
    buttonIndex = event.getData() ' index of selected button
    details = event.GetRoSGNode()
    button = details.buttons.getChild(buttonIndex)
    content = m.deepLinkDetailsScreen.content.clone(true)
    ' Starts playback if user has selected "Play" button.
    if button.id = "play"

    ' Shows asset information if user has selected "PDP" button.
    else if button.id = "pdp"
        
    end if
end sub