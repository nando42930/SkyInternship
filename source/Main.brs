' Channel entry point.
sub Main(args as Object)
    ShowChannelRSGScreen(args)
end sub

sub ShowChannelRSGScreen(args as Object)
    ' The roSGScreen object is a SceneGraph canvas that displays the contents of a Scene node instance.
    screen = CreateObject("roSGScreen")
    ' Message port is the place messages (events) are sent.
    m.port = CreateObject("roMessagePort")
    ' Sets the message port to be used for all events from the screen.
    screen.SetMessagePort(m.port)
    ' Every screen object must have a Scene node or a node that derives from the Scene node.
    scene = screen.CreateScene("MainScene")
    screen.Show() ' Init method in MainScene.brs is invoked.
    ' vscode_rdb_on_device_component_entry
    scene.launchArgs = args
    ' Receives events sent from a network client using the External Control Protocol (ECP).
    inputObject = CreateObject("roInput")
    inputObject.SetMessagePort(m.port)
    ' Transfers data to or from remote servers specified by URLs.
    url = CreateObject("roUrlTransfer")
    scene.ObserveField("url", m.port)
    ' Event loop.
    while(true)
        ' Waits for events from screen without a timeout.
        msg = wait(0, m.port)
        ' Retrieves type of object which generated an event.
        msgType = type(msg)
        ' Events sent to a scene graph.
        if msgType = "roSGScreenEvent"
            if msg.IsScreenClosed() then return ' Screen was closed and is no longer displayed to the user.
        else if msgType = "roInputEvent"
            ' Holds an roAssociativeArray describing the input event.
            inputData = msg.getInfo()
            ' Passes the deeplink to UI.
            if inputData.DoesExist("mediaType") and inputData.DoesExist("contentId") ' Checks if input has certain fields.
                deeplink = {
                    contentId: inputData.contentID
                    mediaType: inputData.mediaType
                }
                scene.inputArgs = deeplink
            end if
        ' Receives messages on m.port when changes occur in nodes.
        else if msgType = "roSGNodeEvent"
            ' Retrieves the new field value at the time of the change.
            inputData = msg.getData()
            ' Retrieves the name of the field that changed.
            inputField = msg.getField()
            if inputField = "url" ' Checks if changed field was "url".
                ' Sets the URL to use for the transfer request.
                url.SetUrl(inputData)
                ' Uses the HTTP POST method to send the supplied string to the current URL.
                url.PostFromString(url.GetUrl())
            end if
        end if
    end while
end sub