' Returns width of the buttonBar. Returns backgroundRectangle width, 
' if such child exists, otherwise returns width of the BoundingRect()
function GetButtonBarWidth() 
    return GetButtonBarBounds().width
end function

' Returns width and height of the buttonBar. Returns backgroundRectangle dimensions, 
' if such child exists, otherwise returns width and height of the BoundingRect()
function GetButtonBarBounds() 
    buttonBar = m.top.getScene().buttonBar
    backgroundRectangle = buttonBar.FindNode("backgroundRectangle")
    bounds = {
        width: 0
        height: 0
    }
    if backgroundRectangle <> invalid
        bounds.width = backgroundRectangle.width
        bounds.height = backgroundRectangle.height
    else
        boundingRect = buttonBar.BoundingRect()
        bounds.width = boundingRect.width
        bounds.height = boundingRect.height
    end if
    return bounds
end function

'@param node - root AA or node for searching sub nodes
'@param map - developer defined config for theme
'@param theme - theme that should be set
sub SGDEX_setThemeFieldstoNode(node, map, theme)
    for each field in map
        attribute = map[field]
        if theme.DoesExist(field) then
            value = theme[field]
            if GetInterface(attribute, "ifAssociativeArray") <> invalid then
                SGDEX_SetValueToAllNodes(node, attribute, value)
            else
                SGDEX_SetThemeAttribute(node, field, value, "")
            end if
        end if
    end for
end sub

function GetViewXPadding()
    return 126
end function

sub SGDEX_SetValueToAllNodes(node, attributes, value)
    if node <> invalid then
        for each key in attributes
            properField = attributes[key]
            if GetInterface(properField, "ifAssociativeArray") <> invalid then
                SGDEX_SetValueToAllNodes(node[key], properField, value)
            else if GetInterface(properField, "ifArray") <> invalid
                for each arrayField in properField
                    if GetInterface(arrayField, "ifAssociativeArray") <> invalid then
                        SGDEX_SetValueToAllNodes(node[key], arrayField, value)
                    else if node[key] <> invalid
                        SGDEX_SetThemeAttribute(node[key], arrayField, value, "")
                    end if
                end for
            else if node[key] <> invalid
                SGDEX_SetThemeAttribute(node[key], properField, value, "")
            end if
        end for
    end if
end sub

sub SGDEX_SetThemeAttribute(node, field as String, value as Object, defaultValue = invalid)
    properValue = defaultValue
    if value <> invalid then
        properValue = value
    end if

    if m.themeDebug then ? "SGDEX_SetThemeAttribute, field="field" , value=["properValue"]"
    node[field] = properValue
end sub