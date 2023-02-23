' Channel entry point
sub Main(args as Object)
    ShowChannelRSGScreen(args)
end sub

sub ShowChannelRSGScreen(args as Object)
    ' The roSGScreen object is a SceneGraph canvas that displays the contents of a Scene node instance
    screen = CreateObject("roSGScreen")
    ' Message port is the place where events are sent
    m.port = CreateObject("roMessagePort")
    ' Sets the message port which will be used for events from the screen
    screen.setMessagePort(m.port)
    ' Create a scene and load /components/MainScene.xml
    ' Every screen object must have a Scene node, or a node that derives from the Scene node
    scene = screen.CreateScene("MainScene")
    screen.show() ' Init method in MainScene.brs is invoked
    scene.launchArgs = args
    inputObject = createObject("roInput")
    inputObject.setMessagePort(m.port)
    ' Event loop
    while(true)
        ' Waiting for events from screen
        msg = wait(0, m.port)
        msgType = type(msg)
        ' ? "msgType=" msgType
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if msgType = "roInputEvent"
            inputData = msg.getInfo()
            ' ? "input"
            ' Pass the deeplink to UI
            if inputData.DoesExist("mediaType") and inputData.DoesExist("contentId")
                deeplink = {
                    contentId: inputData.contentId
                    mediaType: inputData.mediaType
                }
                scene.inputArgs = deeplink
            end if
        end if
    end while
end sub