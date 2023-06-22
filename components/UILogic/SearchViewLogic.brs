sub ShowSearchViewScreen()
    m.searchView = CreateObject("roSGNode", "SearchView")
    m.searchView.ObserveField("query", "OnSearchQuery")
    m.searchView.ObserveField("rowItemSelected", "OnItemSelected")
    ShowScreen(m.searchView)
end sub

sub OnSearchQuery(event as Object)
    query = event.GetData()
    content = CreateObject("roSGNode", "ContentNode")
    if query.Len() > 2 ' only search if user has typed at least three characters
        ' BUILD URL WITH QUERY
        content.AddFields({query: query})
        m.filterTask = CreateObject("roSGNode", "FilterSearchTask") ' Creates task for feed retrieval.
        m.filterTask.content = content
        m.filterTask.ObserveField("content", "OnFilterSearchLoaded")
        m.filterTask.control = "run" ' Executes GetFilteredSearch method on FilterSearchTask.
    end if
    ' setting the content with handlerConfigSearch will trigger creation
    ' of grid view and its content manager
    ' setting an empty content node clears the grid
    ' event.GetRoSGNode().content = content
    m.searchViewNode = event.GetRoSGNode()
end sub

sub OnFilterSearchLoaded(event as Object)
    m.searchViewNode.content = m.filterTask.content
end sub

sub OnItemSelected(event as Object)
    searchViewScreen = event.GetRoSGNode()
    selectedIndex = event.GetData()
    rowContent = searchViewScreen.content.GetChild(0).GetChild(selectedIndex[1])
    ShowDetailsScreen(rowContent, selectedIndex[1])
end sub