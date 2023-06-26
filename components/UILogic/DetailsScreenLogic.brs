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

sub OnButtonSelected(event as Object) ' Invoked when a button in DetailsScreen is pressed.
    ' Holds a pointer to the DetailsScreen node.
    details = event.GetRoSGNode()
    ' DetailsScreen content of the current displayed asset.
    if details.content.GetChildCount() = 0
        content = details.content
    else
        selectedItem = details.itemFocused ' Index of the focused item.
        content = details.content.GetChild(selectedItem)
    end if
    buttonIndex = event.getData() ' Index of selected button.
    button = details.buttons.getChild(buttonIndex) ' Button node.
    scene = m.top.GetScene() ' Scene node.

    links = ParseJson(ReadAsciiFile("pkg:/links.json"))
    dlBaseURL = "http://" + links["serverIP"] + links["dlBaseURL1"] + links["boxIP"] + links["dlBaseURL2"]
    deeplinkURI = links["deeplinkURI"]
    itemType = content.mediaType
    if itemType = "sle" then itemType = UCase(itemType)
    typeParam = """type"":""" + itemType + """"
    mediaType = "&mediaType=" + itemType
    ' Deeplink to Peacock Channel.
    if button.id = "play" ' Starts playback on Peacock if user has selected "Play" button.
        actionParam = """action"":""PLAY"""
    else if button.id = "pdp" ' Shows asset information on Peacock if user has selected "PDP" button.
        actionParam = """action"":""PDP"""
    else if button.id = "see all episodes" ' Creates EpisodesScreen instance and shows it.
        m.seriesContentTask = CreateObject("roSGNode", "SeriesLoaderTask") ' Creates task for feed retrieval.
        m.seriesContentTask.content = content
        m.seriesContentTask.ObserveFieldScoped("content", "OnSeriesContentLoaded")
        m.seriesContentTask.control = "run" ' Executes GetSeriesContent method on SeriesLoaderTask.
        ' ShowEpisodesScreen(content.GetChild(selectedItem))
        return
    end if

    if content.providerVariantId <> invalid
        providerVariantID = """pvid"":""" + content.providerVariantId + """"
        paramsURI = typeParam + "," + actionParam + "," + providerVariantID + "}"
        paramsURI = deeplinkURI + paramsURI
        scene.url = dlBaseURL + paramsURI.EncodeUriComponent() + mediaType
        ? scene.url
    else
        assetURL = content.contentId
        scene.url = dlBaseURL + assetURL + mediaType
    end if
end sub

sub OnSeriesContentLoaded()
    ShowEpisodesScreen(m.seriesContentTask.content)
end sub