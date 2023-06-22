' Entry point of SeriesLoaderTask invoked by ContentTaskLogic.
sub Init()
    ' Sets the name of the function in the Task node component to be executed when the state field changes to RUN.
    ' This method is executed after the following cmd: m.contentTask.control = "run" on ContentTaskLogic.
    m.top.functionName = "GetFilteredContent"
end sub



sub GetFilteredContent()
    links = ParseJson(ReadAsciiFile("pkg:/links.json"))
    moviesURL = links["moviesURL"]
    tvShowsURL = links["tvShowsURL"]
    sportsURL = links["sportsURL"]
    wweURL = links["wweURL"]

    button = m.top.content.filter
    
    if button = "Movies"
        sectionURL = moviesURL
    else if button = "TV Shows"
        sectionURL = tvShowsURL
    else if button = "Sports"
        sectionURL = sportsURL
    else if button = "WWE"
        sectionURL = wweURL
    end if
    
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
    
    ut.SetUrl(sectionURL)
    sectionJson = ut.GetToString()
    section = ParseJson(sectionJson)
    
    rootChildren = []
    ' Parses the feed and builds a tree of ContentNodes to populate the GridView.
    if sectionJson <> invalid
        homeRowIndex = 0
        rails = section["data"]["group"]["rails"]
        for each rail in rails
            row = {}
            row.title = rail.title
            row.children = []
            railItems = rail["items"]
            homeItemIndex = 0
            if railItems <> invalid
                for each asset in railItems
                    if asset.type <> "CATALOGUE/LINK" and asset.type <> "CATALOGUE/COLLECTION" and asset.type <> "ASSET/LINEAR_SLOT"
                        itemData = GetItemData(asset)
                        itemData.homeRowIndex = homeRowIndex
                        itemData.homeItemIndex = homeItemIndex
                        row.children.Push(itemData)
                        homeItemIndex++
                    end if
                end for
                if row.children.Count() > 0
                    rootChildren.Push(row)
                    homeRowIndex++
                end if
            end if
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