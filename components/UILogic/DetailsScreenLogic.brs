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
    ' Deeplink to Peacock Channel.
    if button.id = "play" ' Starts playback on Peacock if user has selected "Play" button.
        
    else if button.id = "pdp" ' Shows asset information on Peacock if user has selected "PDP" button.

    else if button.id = "see all episodes" ' Creates EpisodesScreen instance and shows it.
        ShowEpisodesScreen(content.GetChild(selectedItem))
    end if
end sub

' scene.url = "http://10.18.128.17:8060/launch/593099?contentId=GMO_00000000008705_01&mediaType=series"
' scene.url = "http://10.18.128.17:8060/launch/593099?contentId=https%3A%2F%2Fwww.peacocktv.com%2Fdeeplink%3FdeeplinkData%3D%7B%22type%22%3A%22SLE%22%2C%22action%22%3A%22PDP%22%2C%22pvid%22%3A%22721e43de-2953-3764-9f3b-d0ccb9e1adf6%22%7D&mediaType=SLE"