' Invoked by GridScreenLogic.
sub ShowDetailsScreen(content as Object, selectedItem as Integer)
    ' Creates a new instance of DetailsScreen.
    detailsScreen = CreateObject("roSGNode", "DetailsScreen")
    ' Content of the assets present in a row.
    detailsScreen.content = content
    ' Sets index of item to be focused.
    detailsScreen.jumpToItem = selectedItem
    ' Observes DetailsScreen visibility.
    detailsScreen.ObserveField("visible", "OnDetailsScreenVisibilityChanged")
    ' Observer to be aware of when a button is selected on DetailsScreen.
    detailsScreen.ObserveField("buttonSelected", "OnButtonSelected")
    ' Displays DetailsScreen.
    ShowScreen(detailsScreen)
end sub

sub OnDetailsScreenVisibilityChanged(event as Object) ' Invoked when DetailsScreen "visible" field is changed.
    ' Retrieves the new "visible" value at the time of the change.
    visible = event.GetData()
    ' Holds a pointer to the DetailsScreen node.
    detailsScreen = event.GetRoSGNode()
    ' Retrieves current screen node.
    currentScreen = GetCurrentScreen()
    ' Retrieves current screen node subtype.
    screenType = currentScreen.SubType()
    if visible = false
        if screenType = "GridScreen"
            ' Updates GridScreen's focus when navigating back from DetailsScreen.
            currentScreen.jumpToRowItem = [m.selectedIndex[0], detailsScreen.itemFocused]
        else if screenType = "EpisodesScreen"
            ' Updates EpisodesScreen's focus when navigating back from DetailsScreen.
            content = detailsScreen.content.GetChild(detailsScreen.itemFocused)
            currentScreen.jumpToItem = content.numEpisodes
        end if
    end if
end sub

sub OnButtonSelected(event) ' Invoked when a button in DetailsScreen is pressed.
    ' Holds a pointer to the DetailsScreen node.
    details = event.GetRoSGNode()
    ' DetailsScreen content of the current displayed asset.
    content = details.content
    buttonIndex = event.getData() ' Index of selected button.
    button = details.buttons.getChild(buttonIndex) ' Button node.
    selectedItem = details.itemFocused ' Index of the focused item.
    scene = m.top.GetScene() ' Scene node.
    baseURL = "http://10.18.128.17:8060/launch/593099?contentId="
    deeplinkURL = "https%3A%2F%2Fwww.peacocktv.com%2Fdeeplink%3FdeeplinkData%3D{"
    contentType = chr(34) + "type" + chr(34) + "%3A" + chr(34) + UCase(content.GetChild(selectedItem).mediaType) + chr(34)
    mediaType = "&mediaType=" + content.GetChild(selectedItem).mediaType
    ' Deeplink to Peacock Channel.
    if button.id = "play" ' Starts playback on Peacock if user has selected "Play" button.
        ' url = "http://10.18.128.17:8060/launch/593099?contentId=" + assetURL + "&mediaType=" + content.GetChild(selectedItem).mediaType
        action = chr(34) + "action" + chr(34) + "%3A" + chr(34) + "PLAY" + chr(34)
    else if button.id = "pdp" ' Shows asset information on Peacock if user has selected "PDP" button.
        action = chr(34) + "action" + chr(34) + "%3A" + chr(34) + "PDP" + chr(34)
    else if button.id = "see all episodes" ' Creates EpisodesScreen instance and shows it.
        ShowEpisodesScreen(content.GetChild(selectedItem))
        return
    end if
    if content.GetChild(selectedItem).providerVariantId <> invalid
        providerVariantID = chr(34) + "pvid" + chr(34) + "%3A" + chr(34) + content.GetChild(selectedItem).providerVariantId + chr(34)
        url = deeplinkURL + contentType + "%2C" + action + "%2C" + providerVariantID + "}" + mediaType
    else
        assetURL = content.GetChild(selectedItem).contentId
        url = deeplinkURL + assetURL + mediaType
    end if
    scene.url = baseURL + url.EncodeUri()
end sub