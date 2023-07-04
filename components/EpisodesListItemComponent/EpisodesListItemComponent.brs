' Entry point of EpisodesListItemComponent.
sub Init()
    ' Stores components to m to populate them with metadata.
    m.poster = m.top.FindNode("poster")
    m.title = m.top.FindNode("title")
    m.description = m.top.FindNode("description")
    m.info = m.top.FindNode("info")
    ' Sets font size for title and description labels.
    m.title.font.size = 20
    m.description.font.size = 16
    m.info.font.size = 16
end sub

sub itemContentChanged() ' Invoked when episode data is retrieved.
    itemContent = m.top.itemContent ' Episode metadata.
    if itemContent <> invalid
        ' Populates components with metadata.
        m.poster.uri = itemContent.hdPosterUrl
        m.title.text = itemContent.title
        divider = " | "
        episode = "Episode " + itemContent.episodePosition
        time = itemContent.duration
        date = itemContent.releaseDate
        m.info.text = episode + divider + date + divider + time.ToStr()
        m.description.text = itemContent.description
    end if
end sub