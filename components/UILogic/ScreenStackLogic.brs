sub InitScreenStack()
    m.screenStack = [] ' Screen stack initialization.
end sub

sub ShowScreen(node as Object)
    prev = m.screenStack.Peek() ' Takes current screen from screen stack without deleting it.
    if prev <> invalid
        prev.visible = false ' Hides current screen if exists.
    end if
    m.top.AppendChild(node) ' Adds new screen to scene.
    ' Shows and focuses new screen.
    node.visible = true
    node.SetFocus(true)
    if m.screenStack <> invalid then m.screenStack.Push(node) ' Adds new screen to the screen stack.
end sub

sub CloseScreen(node as Object)
    if node = invalid or (m.screenStack.Peek() <> invalid and m.screenStack.Peek().IsSameNode(node))
        last = m.screenStack.Pop() ' Removes last screen from screenStack.
        last.visible = false ' Hides screen.
        m.top.RemoveChild(last)
        ' Takes previous screen and makes it visible.
        prev = m.screenStack.Peek()
        if prev <> invalid
            ' Shows and focuses previous screen.
            prev.visible = true
            prev.SetFocus(true)
        end if
    end if
end sub

sub AddScreen(node as Object)
    m.top.AppendChild(node) ' Adds new screen to scene.
    m.screenStack.Push(node) ' Adds new screen to the screen stack.
end sub

sub ClearScreenStack()
    if m.screenStack.Count() > 1
        while m.screenStack.Count() > 1
            last = m.screenStack.Pop() ' Removes screen from screenStack.
            if last.visible = true
                last.visible = false ' Hides screen.
            end if
            m.top.RemoveChild(last)
        end while
    else
        m.screenStack.Peek().visible = false ' Takes current screen from screen stack without deleting it.
    end if
end sub

function GetCurrentScreen()
    return m.screenStack.Peek() ' Returns current screen.
end function

function IsScreenInScreenStack(node as Object) as Boolean
    ' Checks if screen stack contains specified node.
    for each screen in m.screenStack
        result = screen.IsSameNode(node)
        if result = true
            return true
        end if
    end for
    return false
end function