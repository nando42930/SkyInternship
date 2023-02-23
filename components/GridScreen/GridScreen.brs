' Entry point of GridScreen
' Note that we need to import this file in GridScreen.xml using relative path.
sub Init()
    m.rowList = m.top.FindNode("rowList")
    m.rowList.SetFocus(true)
    ' Label with item description
    m.descriptionLabel = m.top.FindNode("descriptionLabel")
    ' Observe "visible" field so we can see GridScreen change visibility
    m.top.ObserveField("visible", "OnVisibleChange")
    ' Label with item title
    m.titleLabel = m.top.FindNode("titleLabel")
    ' Observe "rowItemFocused" so we can know when another item of rowList will be focused
    m.rowList.ObserveField("rowItemFocused", "OnItemFocused")
end sub

sub OnVisibleChange() ' Invoked when GridScreen change visibility
    if m.top.visible = true
        m.rowList.SetFocus(true) ' Set focus to RowList if GridScreen is visible
    end if
end sub

sub OnItemFocused() ' Invoked when another item is focused
    focusedIndex = m.rowList.rowItemFocused ' Get position of focused item
    row = m.rowList.content.GetChild(focusedIndex[0]) ' Get all items of row
    row.GetChild(focusedIndex[1]) ' Get focused item
end sub