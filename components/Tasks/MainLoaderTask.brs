' Entry point of MainLoaderTask invoked by ContentTaskLogic.
sub Init()
    ' Sets the name of the function in the Task node component to be executed when the state field changes to RUN.
    ' This method is executed after the following cmd: m.contentTask.control = "run" on ContentTaskLogic.
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    contentFeed = ReadAsciiFile("pkg:/rails.json")
    rootChildren = []

    ' Parses the feed and builds a tree of ContentNodes to populate the GridView.
    railsJson = ParseJson(contentFeed)
    seasonsFeed = ReadAsciiFile("pkg:/seasons.json")
    seasonsJson = ParseJson(seasonsFeed)
    if railsJson <> invalid
        homeRowIndex = 0
        rails = railsJson.Lookup("rails")
        for each rail in rails
            row = {}
            rail = rails.Lookup(rail)
            row.title = rail.title
            row.children = []
            homeItemIndex = 0
            railItems = rail.Lookup("items")
            for each asset in railItems
                if asset.type = "CATALOGUE/SERIES"
                    relationships = seasonsJson.Lookup("relationships")
                    items = relationships.Lookup("items")
                    seasons = items.Lookup("data") ' Information related to every single season of an asset.
                    seasonsData = GetSeasonData(seasons, homeRowIndex, homeItemIndex, asset.id)
                    series = GetItemData(asset)
                    series.children = seasonsData
                    series.mediaType = "series"
                    row.children.Push(series)
                else if asset.type = "ASSET/PROGRAMME"
                    itemData = GetItemData(asset)
                    itemData.homeRowIndex = homeRowIndex
                    itemData.homeItemIndex = homeItemIndex
                    itemData.mediaType = "movie"
                    row.children.Push(itemData)
                else if asset.type = "ASSET/EPISODE"
                    itemData = GetItemData(asset)
                    itemData.homeRowIndex = homeRowIndex
                    itemData.homeItemIndex = homeItemIndex
                    itemData.mediaType = "episode"
                    row.children.Push(itemData)
                else if asset.type = "ASSET/SLE"
                    itemData = GetItemData(asset)
                    itemData.homeRowIndex = homeRowIndex
                    itemData.homeItemIndex = homeItemIndex
                    itemData.mediaType = "sle"
                    row.children.Push(itemData)
                end if
                homeItemIndex++
            end for
            rootChildren.Push(row)
            homeRowIndex++
        end for

        ' set up a root ContentNode to represent rowList on the GridScreen
        contentNode = CreateObject("roSGNode", "ContentNode")
        contentNode.Update({
            children: rootChildren
        }, true)
        ' populate content field with root content node.
        ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment
        m.top.content = contentNode
    end if
end sub

function GetItemData(video as Object) as Object
    item = {}
    ' populate some standard content metadata fields to be displayed on the GridScreen
    ' https://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md
    if video.synopsisLong <> invalid
        item.description = video.synopsisLong
    else
        item.description = video.synopsisShort
    end if
    if video.Lookup("images") <> invalid
        images = video.Lookup("images")
        for each image in images
            if image.type = "titleArt169" or image.type = "scene169" then item.hdPosterURL = image.url
            if image.type = "landscape" then item.hdPosterURL = image.url
        end for
        if item.hdPosterURL = invalid then item.hdPosterURL = images.GetChild(0).url
    end if
    item.title = video.title
    item.releaseDate = ""
    createdDate = video.createdDate
    if createdDate <> invalid
        item.releaseDate = GetDate(createdDate)
    end if
    if video.createdDate = invalid and video.year <> invalid then item.releaseDate = "Year " + video.year.ToStr()
    if video.episodeNumber <> invalid
        item.episodePosition = video.episodeNumber.ToStr()
    end if
    ' populate length of content to be displayed on the GridScreen
    if video.runtime <> invalid
        item.duration = video.runtime
    else if video.duration <> invalid
        item.duration = GetTime(video.duration.durationSeconds)
    else if video.durationSeconds <> invalid
        item.duration = video.durationSeconds
    end if
    if video.Lookup("formats") <> invalid
        formats = video.Lookup("formats")
        hd = formats.Lookup("HD")
        item.contentId = hd.contentId
    end if
    if video.providerVariantId <> invalid then item.providerVariantId = video.providerVariantId
    return item
end function

function GetSeasonData(seasons as Object, homeRowIndex as Integer, homeItemIndex as Integer, seriesId as String) as Object
    seasonsArray = []
    if seasons <> invalid
        episodeCounter = 0
        episodesFeed = ReadAsciiFile("pkg:/episodes.json")
        episodesJson = ParseJson(episodesFeed)
        for each season in seasons
            if season <> invalid
                if season.id = episodesJson.id
                    relationships = episodesJson.Lookup("relationships")
                    items = relationships.Lookup("items")
                    allEpisodes = items.Lookup("data")
                    seasonEpisodes = []
                    seasonNumber = season.attributes.seasonNumber
                    for each episode in allEpisodes
                            attributes = episode.Lookup("attributes")
                            episodeData = GetItemData(attributes)

                            ' save season title for element to represent it on the episodes screen
                            episodeData.titleSeason = "Season " + seasonNumber.ToStr()
                            episodeData.numEpisodes = episodeCounter
                            episodeData.mediaType = "episode"
                            episodeData.homeRowIndex = homeRowIndex
                            episodeData.homeItemIndex = homeItemIndex
                            episodeData.seriesId = seriesId

                            seasonEpisodes.Push(episodeData)
                            episodeCounter++
                    end for
                    seasonData = GetItemData(season)
                    seasonData.title = "Season " + seasonNumber.ToStr()
                    ' populate season's children field with its episodes
                    ' as a result season's ContentNode will contain episode's nodes
                    seasonData.children = seasonEpisodes
                    ' set content type for season object to represent it on the screen as section with episodes
                    seasonData.contentType = "section"
                    seasonsArray.Push(seasonData)
                end if
            end if
        end for
    end if
    return seasonsArray
end function