' Entry point of SeriesLoaderTask invoked by ContentTaskLogic.
sub Init()
    ' Sets the name of the function in the Task node component to be executed when the state field changes to RUN.
    ' This method is executed after the following cmd: m.contentTask.control = "run" on ContentTaskLogic.
    m.top.functionName = "GetFilteredSearch"
end sub



sub GetFilteredSearch()
    query = m.top.content.query

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

    links = ParseJson(ReadAsciiFile("pkg:/links.json"))
    ut.SetUrl(links["searchBaseURL"] + query + links["searchParamsURL"])
    searchJson = ut.GetToString()
    searchResults = ParseJson(searchJson)
    
    infoURL1 = links["infoURL1"]
    infoURL2 = links["infoURL2"]

    ' Parses the feed and builds a tree of ContentNodes to populate the GridView.
    if searchJson <> invalid and searchResults <> invalid
        assets = [] ' roArray declaration
        for each asset in searchResults["results"]
            ut.SetUrl(infoURL1 + asset.uuid + infoURL2)
            infoJson = ut.GetToString()
            info = ParseJson(infoJson)
            if info[0] <> invalid
                itemData = {} ' roAssociativeArray declaration
                itemData.uuid = asset.uuid
                itemData = getData(info[0]["attributes"])
                itemData.mediaType = getType(info[0].type)
                ' images = info[0]["attributes"]["images"]
                ' for each image in images
                '     if image.type = "titleArt169" or image.type = "scene169" then itemData.hdPosterUrl = image.url
                ' end for
                assets.Push(itemData)
            end if
        end for
        ' set up a root ContentNode to represent rowList on the GridScreen
        contentNode = CreateObject("roSGNode", "ContentNode")
        contentNode.Update({
            children: assets
        }, true)
        ' populate content field with root content node.
        ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment
        abstractContentNode = CreateObject("roSGNode", "ContentNode")
        abstractContentNode.Update({
            children: [ contentNode ]
        }, true)
        m.top.content = abstractContentNode
    end if
end sub