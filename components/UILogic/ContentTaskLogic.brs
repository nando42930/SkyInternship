sub RunContentTask()
    m.contentTask = CreateObject("roSGNode", "MainLoaderTask") 'Create task for feed retrieving.
    'Observe content so we can know when feed content will be parsed.
    m.contentTask.ObserveField("content", "OnMainContentLoaded")
    m.contentTask.control = "run" 'GetContent(see MainLoaderTask.brs) method is executed.
    m.loadingIndicator.visible = true 'Show loading indicator while content is loading.
end sub

sub OnMainContentLoaded() 'Invoked when content is ready to be used.
    m.GridScreen.SetFocus(true) 'Set focus to GridScreen.
    m.loadingIndicator.visible = false 'Hide loading indicator because content was retrieved.
    m.GridScreen.content = m.contentTask.content 'Populate GridScreen with content.
end sub