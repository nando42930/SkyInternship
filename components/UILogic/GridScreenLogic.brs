' Invoked by MainScene.
sub ShowGridScreen()
    m.GridScreen = CreateObject("roSGNode", "GridScreen") ' GridScreen object creation.
    m.GridScreen.ObserveField("rowItemSelected", "OnGridScreenItemSelected") ' Observer to be aware when an asset is selected.
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