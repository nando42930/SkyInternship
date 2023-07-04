' Helper function convert AA to Node
function ContentListToSimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object
    result = CreateObject("roSGNode", nodeType) ' create node instance based on specified nodeType
    if result <> invalid
        ' go through contentList and create node instance for each item of list
        for each itemAA in contentList
            item = CreateObject("roSGNode", nodeType)
            item.SetFields(itemAA)
            result.AppendChild(item)
        end for
    end if
    return result
end function

' Helper function converts seconds to mm:ss format
' getTime(138) returns 2:18
function GetTime(length as Integer) as String
    minutes = (length \ 60).ToStr()
    seconds = length MOD 60
    if seconds < 10
       seconds = "0" + seconds.ToStr()
    else
       seconds = seconds.ToStr()
    end if
    return minutes + ":" + seconds
end function

' Helper function converts seconds or milliseconds to DD-MM-YY.
function GetDate(createdDate as LongInteger) as String
    if len(createdDate.ToStr()) = 13 then createdDate = createdDate / 1000
    if not len(createdDate.ToStr()) = 10 then return "Date Error"
    date = CreateObject("roDateTime")
    date.FromSeconds(createdDate)
    date.ToISOString()
    day = date.GetDayOfMonth().ToStr()
    month = date.GetMonth().ToStr()
    year = date.GetYear().ToStr()
    if len(day) = 1 then day = "0" + day
    if len(month) = 1 then month = "0" + month
    return day + "-" + month + "-" + year
end function

' Helper function clones node children
function CloneChildren(node as Object, startItem = 0 as Integer)
    numOfChildren = node.GetChildCount() ' get number of row items
    ' populate children array only with  items started from selected one.
    ' example: row has 3 items. user select second one so we must take just second and third items.
    children = node.GetChildren(numOfChildren - startItem, startItem)
    childrenClone = []
    ' go through each item of children array and clone them.
    for each child in children
    ' we need to clone item node because it will be damaged in case of video node content invalidation
        childrenClone.Push(child.Clone(false))
    end for
    return childrenClone
end function

' Helper function finds child node by specified contentId
function FindNodeById(content as Object, contentId as String) as Object
    for each element in content.GetChildren(-1, 0)
        if element.id = contentId
            return element
        else if element.getChildCount() > 0
            result = FindNodeById(element, contentId)
            if result <> invalid
                return result
            end if
        end if
    end for
    return invalid
end function

' Reads and returns the value of the specified key
function RegRead(key as String, section = invalid As Dynamic) As Dynamic
    If section = invalid Then section = "Default"
    reg = CreateObject("roRegistrySection", section)
    If reg.Exists(key) Then return reg.Read(key)
    return invalid
end function

' Replaces the value of the specified key
sub RegWrite(key as String, val as String, section = invalid As Dynamic)
    If section = invalid Then section = "Default"
    reg = CreateObject("roRegistrySection", section)
    reg.Write(key, val)
    reg.Flush()
end sub

' Deletes the specified key
sub RegDelete(key as String, section = invalid As Dynamic)
    If section = invalid Then section = "Default"
    reg = CreateObject("roRegistrySection", section)
    reg.Delete(key)
    reg.Flush()
end sub

' Helper function to determine whether view is full sized (doesn't have overhang)
function IsFullSizeView(view as Object)
    viewSubtype = view.Subtype()
    isFullSizeMediaView = (viewSubtype = "MediaView") and not IsAudioMediaView(view)  
    return isFullSizeMediaView or viewSubtype = "SlideShowView" or viewSubtype = "EndcardView"
end function

' Helper function to determine whether view is MediaView with audio mode
function IsAudioMediaView(view as Object)
    viewSubtype = view.Subtype()
    return viewSubtype = "MediaView" and view.hasField("mode") and view.mode = "audio"
end function

'get parent based on index
' @param index [Integer] parent subtype
Function Utils_getParentbyIndex(index as Integer, node = GetGlobalAA().top as Object) as Object
    
    while node <> invalid and index > 0 
        node = node.getParent()
        index--
    end while
    
    'if node <> invalid AND index = 0 
    return node
End Function

function getData(video as Object) as Object
    item = {}
    ' Populates some standard content metadata fields to be displayed on the GridScreen
    ' https://developer.roku.com/docs/developer-program/getting-started/architecture/content-metadata.md
    item.description = video.synopsisLong
    if item.description = invalid then item.description = video.synopsisShort
    images = video["images"]
    if images <> invalid
        item.hdPosterURL = images.GetEntry(0).url
        for each image in images
            if image.type = "titleArt169" or image.type = "scene169" then item.hdPosterURL = image.url
            if image.type = "landscape" then item.hdPosterURL = image.url
        end for
    end if
    item.title = video.title
    item.releaseDate = ""
    createdDate = video.createdDate
    if createdDate <> invalid then item.releaseDate = GetDate(createdDate)
    if video.createdDate = invalid and video.year <> invalid then item.releaseDate = "Year " + video.year.ToStr()
    if video.episodeNumber <> invalid then item.episodePosition = video.episodeNumber.ToStr()
    ' populate length of content to be displayed on the GridScreen
    if video.runtime <> invalid
        item.duration = video.runtime
    else if video.duration <> invalid
        item.duration = GetTime(video.duration.durationSeconds)
    else if video.durationSeconds <> invalid
        item.duration = video.durationSeconds
    end if
    if video["formats"]["HD"].contentId <> invalid then item.contentId = video["formats"]["HD"].contentId
    if video.providerVariantId <> invalid then item.providerVariantId = video.providerVariantId
    if video.providerSeriesId <> invalid then item.providerSeriesId = video.providerSeriesId
    return item
end function

function getType(assetType as String)
    if assetType = "CATALOGUE/SERIES"
        return "series"
    else if assetType = "ASSET/PROGRAMME"
        return "movie"
    else if assetType = "ASSET/EPISODE"
        return "episode"
    else if assetType = "ASSET/SLE"
        return "sle"
    end if
end function