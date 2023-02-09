sub Init()
    ? "teste"
    m.top.backgroundColor = "0x6f1bb1"
    m.top.backgroundUri = ""
    m.loadingIndicator = m.top.FindNode("loadingIndicator") ' Store loadingIndicator node to m
    InitScreenStack()
    ShowGridScreen()
    RunContentTask() ' Retrieving content
end sub