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

' this method convert seconds to mm:ss format
' GetTime(138) returns 2:18
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


function CloneChildren(rowContent as Object, startItem = 0 as Integer)
    numOfChildren = rowContent.GetChildCount() ' get number of row items
    ' populate children array only with items started from selected one.
    ' example: row has 3 items. user select second one so we must take just second and third items.
    children = rowContent.GetChildren(numOfChildren - startItem, startItem)
    childrenClone = []
    ' go through each item of children array and clone them.
    for each child in children
        ' we need to clone item node because it will be damaged in case of video node code invalidation
        childrenClone.Push(child.Clone(false))
    end for
end function