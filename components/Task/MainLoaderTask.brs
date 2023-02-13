sub Init()
    ' Set the name of the function in the Task node component to be executed when the state field changes to RUN.
    ' In our case, this method executed after the following cmd: m.contentTask.control = "run" (see Init method in MainScene).
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    ' Request the content feed from the API.
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.SetURL("https://jonathanbduval.com/roku/feeds/roku-developers-feed-v1.json")
    ' xfer.SetURL("content_data.json")
    rsp = xfer.GetToString()
    rootChildren = []

    ' Parse the feed and build a tree of ContentNodes to populate the GridView
    json = ParseJson(rsp)
    if json <> invalid
        for each category in json
            value = json.Lookup(category)
            if Type(value) = "roArray" ' If parsed key value having other objects in it.
                if category <> "series" ' Ignore series for this phase.
                    row = {}
                    row.children = []
                    for each item in value ' Parse items and push them to row
                        itemData = GetItemData(item)
                        row.children.Push(itemData)
                    end for
                    rootChildren.Push(row)
                end if
            end if
        end for
        ' Set up a root ContentNode to represent rowList on the GridScreen
        contentNode = CreateObject("roSGNode", "ContentNode")
        contentnoDE.Update({
            children: rootChildren
        }, true)
        ' Populate content field with root content node.
        ' Observer(see OnMainContentLoaded in MainScene.brs) is invoked at that moment.
        m.top.content = contentNode
    end if
end sub

function GetItemData(video as Object) as Object
    item = {}
    ' Populate some standard content metadata fields to be displayed on the GridScreen.
    ' http://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md
    item.hdPosterUrl = video.thumbnail
    item.id = video.id
    return item
end function