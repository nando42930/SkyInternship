sub InitScreenStack()
    m.screenStack = []
end sub

sub ShowScreen(node as Object)
    prev = m.screenStack.Peek() 'Take current screen from screen stack but don't delete it.
    if prev <> invalid
        prev.visible = false 'Hide current screen if exists.
    end if
    'Show new screen.
    m.top.AppendChild(node)
    node.visible = true
    node.SetFocus(true)
    m.screenStack.Push(node) 'Add new screen to the screen stack.
end sub

sub CloseScreen(node as Object)
    if node = invalid OR (m.screenStack.Peek() <> invalid AND m.screenStack.Peek().IsSameNode(node))
        last = m.screenStack.Pop() 'Remove screen from screenStack.
        last.visible = false 'Hide screen.
        m.top.RemoveChild(node) 'Remove screen from scene.

        'Take previous screen and make it visible.
        prev = m.screenStack.Peek()
        if prev <> invalid
            prev.visible = true
            prev.SetFocus(true)
        end if
    end if
end sub