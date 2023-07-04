' Invoked by MainScene.
sub RunContentTask()
    m.contentTask = CreateObject("roSGNode", "MainLoaderTask") ' Creates task for feed retrieval.
    ' Observes content so we can know when feed content will be parsed.
    m.contentTask.ObserveField("content", "OnMainContentLoaded")
    m.contentTask.control = "run" ' Executes GetContent method on MainLoaderTask.
    m.loadingIndicator.visible = true ' Shows loading indicator while content is still loading.
end sub

sub OnMainContentLoaded() ' Invoked when content is ready to be used.
    m.GridScreen.SetFocus(true) ' Sets focus to GridScreen.
    m.loadingIndicator.visible = false ' Hides loading indicator because content was retrieved.
    m.GridScreen.content = m.contentTask.content ' Populates GridScreen with content.
    args = m.top.launchArgs
    if args <> invalid and ValidateDeepLink(args)
        DeepLink(m.contentTask.content, args.mediaType, args.contentId)
    end if
end sub