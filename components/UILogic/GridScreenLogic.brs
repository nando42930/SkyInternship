' Invoked by MainScene.
sub ShowGridScreen()
    m.GridScreen = CreateObject("roSGNode", "GridScreen") ' GridScreen object creation.
    m.GridScreen.ObserveField("rowItemSelected", "OnGridScreenItemSelected") ' Observer to be aware when an asset is selected.
    m.GridScreen.ObserveField("buttonSelected", "OnButtonBarSelected") ' Observer to be aware when an asset is selected.
    ShowScreen(m.GridScreen) ' Shows GridScreen.
end sub

sub OnGridScreenItemSelected(event as Object)
    ' Holds a pointer to the GridScreen node.
    grid = event.GetRoSGNode()
    ' Extracts the row and column indexes of the item the user selected.
    m.selectedIndex = event.GetData()
    ' Every asset present in the chosen row.
    rowContent = grid.content.GetChild(m.selectedIndex[0])
    ' Index of the selected row.
    m.selectedRow = m.selectedIndex[0]
    ' Displays DetailsScreen.
    ShowDetailsScreen(rowContent, m.selectedIndex[1])
end sub

sub OnButtonBarSelected(event as Object)
    buttonIdx = event.GetRoSGNode().buttonSelected[1]
    data = event.GetData()
    layoutGroup = m.GridScreen.GetChild(0)
    buttonBar = layoutGroup.GetChild(1).GetChild(0)
    buttons = buttonBar.GetChild(0).content.GetChild(0).GetChildren(-1,0)
    searchButton = buttonBar.GetChild(3).id
    button = buttons[buttonIdx]

    ' Filters content.
    for each btn in buttons
        if button.id = btn.id
            m.filterTask = CreateObject("roSGNode", "FilterContentTask") ' Creates task for feed retrieval.
            contentNode = CreateObject("roSGNode", "ContentNode")
            contentNode.Update({
                filter: button.title
            }, true)
            m.filterTask.content = contentNode
            m.filterTask.ObserveField("content", "OnFilterContentLoaded")
            m.filterTask.control = "run" ' Executes GetFilteredContent method on FilterContentTask.
            return
        end if
    end for
    ' Case when "Search" button was selected.
    ShowSearchViewScreen()
end sub

sub OnFilterContentLoaded()
    m.GridScreen.content = m.filterTask.content
end sub