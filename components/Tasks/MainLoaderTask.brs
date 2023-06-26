' Entry point of MainLoaderTask invoked by ContentTaskLogic.
sub Init()
    ' Sets the name of the function in the Task node component to be executed when the state field changes to RUN.
    ' This method is executed after the following cmd: m.contentTask.control = "run" on ContentTaskLogic.
    m.top.functionName = "GetContent"
end sub



sub GetContent()
    ' Content URLs.
    links = ParseJson(ReadAsciiFile("pkg:/links.json"))
    menuURL = links["menuURL"]
    railsURL = links["railsURL"]

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

    ' Fetches menu titles.
    ut.SetUrl(menuURL)
    menuTitles = GetMenuTitles(ut)
    
    ' Fetches all kinds of assets (Movies, Series, Episodes, SLEs,...).
    ut.SetUrl(railsURL)
    GetAssets(ut)
end sub



function GetMenuTitles(ut as Object)
    menuJson = ut.GetToString() ' Returns the response body as a JSON string.
    menu = ParseJson(menuJson) ' Parses a JSON string into a BrightScript object.
    sideNav = menu["relationships"]["items"]["data"][1]
    menuItems = sideNav["relationships"]["items"]["data"][2]["relationships"]["items"]["data"]
    menuTitles = []
    for each menuItem in menuItems
        menuTitles.Push({title: menuItem["attributes"].title, id: menuItem.id})
    end for
    return menuTitles
end function



sub GetAssets(ut as Object)
    railsJson = ut.GetToString() ' Returns the response body as a JSON string.
    rails = ParseJson(railsJson) ' Parses a JSON string into a BrightScript object.

    rootChildren = []
    ' Parses the feed and builds a tree of ContentNodes to populate the GridView.
    if railsJson <> invalid
        homeRowIndex = 0
        rails = rails["data"]["group"]["rails"]
        for each rail in rails
            row = {}
            row.TITLE = rail.title
            row.children = []
            railItems = rail["items"]
            homeItemIndex = 0
            if railItems <> invalid
                for each asset in railItems
                    if asset.type <> "CATALOGUE/LINK" and asset.type <> "CATALOGUE/COLLECTION" and asset.type <> "ASSET/LINEAR_SLOT" and asset.type <> "ASSET/SHORTFORM/THEATRICAL"
                        itemData = GetItemData(asset)
                        itemData.homeRowIndex = homeRowIndex
                        itemData.homeItemIndex = homeItemIndex
                        itemData.mediaType = getType(asset.type)
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