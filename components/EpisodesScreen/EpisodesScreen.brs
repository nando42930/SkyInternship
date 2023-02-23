' Entry point of EpisodesScreen
function Init()
    ' Observe "visible" so we can know when EpisodesScreen change visibility
    m.top.ObserveField("visible", "OnVisibleChange")
    m.categoryList = m.top.FindNode("categoryList")
    ' Observe "itemFocused" so we can know which season gain focus
    m.categoryList.ObserveField("itemFocused", "OnCategoryItemFocused")
    m.itemsList = m.top.FindNode("itemsList")
    ' Observe "itemFocused" so we can know which episode gain focus
    m.itemsList.ObserveField("itemFocused", "OnListItemFocused")
    ' Observe "itemSelected" so we can know which episode is selected
    m.itemsList.ObserveField("itemSelected", "OnListItemSelected")
    m.top.ObserveField("content", "OnContentChange")
end function

sub OnListItemFocused(event as Object) ' Invoked when episode is focused
    focusedItem = event.GetData() ' Index of episode
    ' Index of season which contains focused episode
    categoryIndex = m.itemToSection[focusedItem]
    ' Change focused item in seasons list
    if (categoryIndex - 1) = m.categoryList.jumpToItem
        m.categoryList.animateToItem = categoryIndex
    else if not m.categoryList.IsInFocusChain()
        m.categoryList.jumpToItem = categoryIndex
    end if
end sub

sub InitSections(content as Object)
    ' Save the position of the first episode for each season
    m.firstItemInSection = [0]
    ' Save the season index to which the episode belongs
    m.itemToSection = []
    ' Save the title of each season
    sections = []
    sectionCount = 0
    ' Goes through seasons and populate "firstItemInSection" and "itemToSection" arrays
    for each section in content.GetChildren(-1, 0)
        itemsPerSection = section.GetChildCount()
        for each child in section.GetChildren(-1, 0)
            m.itemToSection.Push(sectionCount)
        end for
        sections.Push({title: section.title}) ' Save title of each season
        m.firstItemInSection.Push(m.firstItemInSection.Peek() + itemsPerSection)
        sectionCount++
    end for
    m.firstItemInSection.Pop() ' Remove last item
    m.categoryList.content = ContentListToSimpleNode(sections) ' Populate categoryList with list of seasons
end sub

sub OnCategoryItemFocused(event as Object) ' Invoked when season is focused
    ' We shouldn't change the focus in the episodes list as soon as we have switched to the list of seasons
    if m.categoryListGainFocus = true
        m.categoryListGainFocus = false
    else
        focusedItem = event.GetData() ' Index of season
        ' Navigate to the first episode of season
        m.itemsList.jumpToItem = m.firstItemInSection[focusedItem]
    end if
end sub

sub OnJumpToItem(event as Object) ' Invoked when "jumpToItem" field is changed
    itemIndex = event.GetData()
    m.itemsList.jumpToItem = itemIndex ' Navigate to the specified item
end sub

sub OnContentChange() ' Invoked when EpisodesScreen content is changed
    content = m.top.content
    InitSections(content) ' Populate seasons list
    m.itemsList.content = content ' Populate episodes list
end sub

sub OnVisibleChange() ' Invoked when EpisodesScreen becomes visible
    if m.top.visible = true
        m.itemsList.SetFocus(true) ' Set focus to the episodes list
    end if
end sub

sub OnListItemSelected(event as Object) ' Invoked when episode is selected
    itemSelected = event.GetData() ' Index of selected item
    sectionIndex = m.itemToSection[itemSelected] ' Season which contains selected episode
    ' OnEpisodesScreenItemSelected method in EpisodesScreenLogic.brs is invoked when selectedItem array is populated
    m.top.selectedItem = [sectionIndex, itemSelected - m.firstItemInSection[sectionIndex]]
end sub

' The OnKeyEvent() function receives remote control key events
function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        ' handle "left" key press
        if key = "left" and m.itemsList.HasFocus() ' Episodes list should be focused
            m.categoryListGainFocus = true
            ' Navigate to seasons list
            m.categoryList.SetFocus(true)
            m.itemsList.drawFocusFeedback = false
            result = true
        ' Handle "right" key press
        else if key = "right" and m.categoryList.HasFocus() ' Seasons list should be focused
            m.itemsList.drawFocusFeedback = true
            ' Navigate to episodes list
            m.itemsList.SetFocus(true)
            result = true
        end if
    end if
    return result
end function