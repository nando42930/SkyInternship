' Entry point of MainScene. Invoked by Main.
sub Init()
    ' Sets background color for scene. Applied only if backgroundUri has empty value.
    m.top.backgroundColor = "0x000000"
    m.top.backgroundUri = ""
    m.loadingIndicator = m.top.FindNode("loadingIndicator") ' Stores loadingIndicator node to m object reference (component scope).
    InitScreenStack() ' Initializes a stack of screens.
    ShowGridScreen() ' GridScreen is the first screen to be displayed.
    RunContentTask() ' Retrieves content feed to be presented on GridScreen.
    ' Measures channel launch time.
    ' Channel applications must fire an AppLaunchComplete beacon when the channel home page is fully rendered.
    m.top.SignalBeacon("AppLaunchComplete")
end sub

' The OnKeyEvent() function receives remote control key events.
function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        ' Handles "back" key press.
        if key = "back"
            numberOfScreens = m.screenStack.Count()
            ' Closes top screen if there are two or more screens in the screen stack.
            if numberOfScreens > 1
                CloseScreen(invalid)
                result = true
            end if
        end if
    end if
    ' The OnKeyEvent() function must return true if the component handled the event or false otherwise.
    return result
end function