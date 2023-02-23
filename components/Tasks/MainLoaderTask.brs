' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    ' Set the name of the function in the Task node component to be executed when the state field changes to RUN
    ' In our case, this method executed after the following cmd: m.contentTask.control = "run" (see Init method in MainScene)
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    ' Request the content feed from the API
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL("https://jonathanbduval.com/roku/feeds/roku-developers-feed-v1.json")
    rsp = xfer.GetToString()
    rootChildren = []

    ' Parse the feed and build a tree of ContentNodes to populate the GridView
    json = ParseJson(rsp)
    if json <> invalid
        homeRowIndex = 0
        for each category in json
            value = json.Lookup(category)
            if Type(value) = "roArray" ' If parsed key value having other objects in it
                row = {}
                row.children = []
                homeItemIndex = 0
                for each item in value ' Parse items and push them to row
                    seasons = GetSeasonData(item.seasons, homeRowIndex, homeItemIndex, item.id)
                    itemData = GetItemData(item)
                    itemData.homeRowIndex = homeRowIndex
                    itemData.homeItemIndex = homeItemIndex
                    itemData.mediaType = category
                    if seasons <> invalid and seasons.Count() > 0
                        itemData.children = seasons
                    end if
                    row.children.Push(itemData)
                    homeItemIndex++
                end for
                rootChildren.Push(row)
                homeRowIndex++
            end if
        end for
        ' Set up a root ContentNode to represent rowList on the GridScreen
        contentNode = CreateObject("roSGNode", "ContentNode")
        contentNode.Update({
            children: rootChildren
        }, true)
        ' Populate content field with root content node
        m.top.content = contentNode
    end if
end sub

function GetItemData(video as Object) as Object
    item = {}
    ' Populate some standard content metadata fields to be displayed on the GridScreen
    ' http://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md
    item.hdPosterUrl = video.thumbnail
    item.id = video.id
    if video.episodeNumber <> invalid
        item.episodePosition = video.episodeNumber.ToStr()
    end if
    if video.content <> invalid
        ' Populate length of content to be displayed on the GridScreen
        item.length = video.content.duration
        ' Populate meta-data for playback
        item.url = video.content.videos[0].url
        item.streamFormat = video.content.videos[0].videoType
    end if
    return item
end function

function GetSeasonData(seasons as Object, homeRowIndex as Integer, homeItemIndex as Integer, seriesId as String) as Object
    seasonsArray = []
    if seasons <> invalid
        episodeCounter = 0
        for each season in seasons
            if season.episodes <> invalid
                episodes = []
                for each episode in season.episodes
                    episodeData = GetItemData(episode)
                    ' Save season title for element to represent it on the episodes screen
                    episodeData.titleSeason = season.title
                    episodeData.numEpisodes = episodeCounter
                    episodeData.mediaType = "episode"
                    episodeData.homeRowIndex = homeRowIndex
                    episodeData.homeItemIndex = homeItemIndex
                    episodeData.seriesId = seriesId
                    episodes.Push(episodeData)
                    episodeCounter++
                end for
                seasonData = GetItemData(season)
                ' Populate season's children field with its episodes
                ' As a result season's ContentNode will contain episode's nodes
                seasonData.children = episodes
                ' Set content type for season object to represent it on the screen as section with episodes
                seasonData.contentType = "section"
                seasonsArray.Push(seasonData)
            end if
        end for
    end if
    return seasonsArray
end function