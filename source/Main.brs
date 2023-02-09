'*************************************************************
'** Hello World example
'** Copyright (c) 2015 Roku, Inc.  All rights reserved.
'** Use of the Roku Platform is subject to the Roku SDK Licence Agreement:
'** https://docs.roku.com/doc/developersdk/en-us
'*************************************************************

sub Main()
    print "in showChannelSGScreen"
    'Indicate this is a Roku SceneGraph application
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    'Create a scene and load /components/helloworld.xml
    scene = screen.CreateScene("MainScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
        if msg.isScreenClosed() then return
        end if
    end while
end sub

' Create root content node
' root_content_node = createObject("RoSGNode", "ContentNode")

' row.title = "movies"
' for each movie in row
'   child = root_content_node.createChild("ContentNode")
'   child.hdPostedUrl = movie.thumbnail
'   child.title = movie.title
'   child.description = movie.longDescription
'   child.streamUrl = movie.content.videos[0].url
'   child.streamFormat = movie.content.videos[0].format
' end for
