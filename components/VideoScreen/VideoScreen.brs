' Entry point of VideoScreen
function Init()
    ' Set rectangle fields
    m.top.width = 1280
    m.top.height = 720
    m.top.color="0x000000"
    ' Store reference for playerTask so we can use it in other functions
    m.playerTask = m.top.FindNode("PlayerTask")
    m.playerTask.ObserveField("state", "OnPlayerTaskStateChange")   ' Close screen once exited
    m.top.ObserveField("visible", "OnVisibleChanged")
end function

sub OnVisibleChanged(event as Object) ' Invoked when VideoScreen visibility is changed
    visible = event.GetData()
    ' Video node content must be invalidated if videoScreen is closed but playerTask still running
    if visible = false and m.playerTask <> invalid
        m.playerTask.UnobserveField("state")
        m.playerTask.control = "STOP"
        ' Get video node wrapper created by RAF
        RAFRenderer = m.top.GetChild(m.top.GetChildCount()-1)
        if RafRenderer <> invalid
            ' Get video node
            video = RAFRenderer.getChild(0)
            if video <> invalid and LCase(video.id) = "contentvideo"
                video.content = invalid ' Reseting RAF video node content to kill it
                RAFRenderer = invalid
            end if
        end if
        m.playerTask = invalid
    end if
end sub

sub OnIndexChanged(event as Object) ' Invoked when "startIndex" field is changed
    content = m.top.content
    index = event.GetData()
    ' Check if content was populated
    if content <> invalid
        ' Set playlist data and start task
        m.playerTask.content = content
        m.playerTask.startIndex = index
        m.playerTask.isSeries = m.top.isSeries
        m.playerTask.control = "RUN"
    end if
end sub

' The OnKeyEvent() function receives remote control key events
function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        ' Handle "back" key press
        if key = "back" and m.playerTask <> invalid
            ' We should stop playback and close this screen when user press "back" button
            m.playerTask.control = "STOP" ' As a result OnPlayerTaskStateChange is invoked
            result = true
        end if
    end if
    return result
end function