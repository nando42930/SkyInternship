' Entry point of SeriesLoaderTask invoked by ContentTaskLogic.
sub Init()
    ' Sets the name of the function in the Task node component to be executed when the state field changes to RUN.
    ' This method is executed after the following cmd: m.contentTask.control = "run" on ContentTaskLogic.
    m.top.functionName = "GetSeriesContent"
end sub



sub GetSeriesContent()
    asset = m.top.content
    ' Base and parameters URL to fetch seasons data of a series by its providerSeriesId field.
    links = ParseJson(ReadAsciiFile("pkg:/links.json"))
    seriesBaseURL = links["seriesBaseURL"]
    seriesParamsURL = links["seriesParamsURL"]

    ' URL object setup.
    ut = CreateObject("roUrlTransfer")
    ut.AddHeader("X-SkyOTT-Proposition", "NBCUOTT")
    ut.AddHeader("X-SkyOTT-Device", "SETTOPBOX")
    ut.AddHeader("X-SkyOTT-Language", "en")
    ut.AddHeader("X-SkyOTT-Platform", "ROKU")
    ut.AddHeader("X-SkyOTT-Provider", "NBCU")
    ut.AddHeader("X-SkyOTT-Territory", "US")
    ut.AddHeader("X-SkyOTT-ActiveTerritory", "US")
    ut.SetCertificatesFile("common:/certs/ca-bundle.crt") ' Authentication.
    
    seriesURL = seriesBaseURL + asset["providerSeriesId"] + seriesParamsURL
    ut.SetUrl(seriesURL)
    ut.SetRequest("GET")
    seriesJson = ut.GetToString() ' Returns the response body as a JSON string.
    series = ParseJson(seriesJson) ' Parses a JSON string into a BrightScript object.
    ' Escapes a series which only has a trailer at the moment.

    ' if not series["attributes"].availableEpisodeCount > 0
    '     homeItemIndex++
    ' end if

    seasons = series["relationships"]["items"]["data"] ' Information related to every single season of an asset.
    seasonsData = GetSeasonData(seasons, asset.homeRowIndex, asset.homeItemIndex, series.id, ut)
    asset.children = seasonsData
    m.top.content = asset
end sub



function GetSeasonData(seasons as Object, homeRowIndex = 0 as Integer, homeItemIndex = 0 as Integer, seriesId as String, ut as Object) as Object
    ' Base and parameters URL to fetch episodes data of a season by its providerSeriesId field.
    episodesBaseURL = "https://atom.peacocktv.com/adapter-calypso/v3/query/node/"
    episodesParamsURL = "?represent=(items%2Cnext_items[take%3D1])&features=upcoming"

    seasonsArray = []
    if seasons <> invalid
        for each season in seasons
            ' Fetches episodes of a season.
            ut.SetUrl(episodesBaseURL + season.id + episodesParamsURL)
            ut.SetRequest("GET")
            episodesJson = ut.GetToString()
            episodes = ParseJson(episodesJson)
            episodeCounter = 0
            if season <> invalid and season.id = episodes.id
                episodes = episodes["relationships"]["items"]["data"]
                seasonEpisodes = []
                seasonNumber = season.attributes.seasonNumber
                for each episode in episodes
                        attributes = episode["attributes"]
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
        end for
    end if
    return seasonsArray
end function