
-- for CCLuaEngine
function __G__TRACKBACK__(errorMessage)
    CCLuaLog("----------------------------------------")
    CCLuaLog("LUA ERROR: "..tostring(errorMessage).."\n")
    CCLuaLog(debug.traceback("", 2))
    CCLuaLog("----------------------------------------")
end

xpcall(function()
    require("config")
    require("framework.init")
    require("framework.client.init")

    CCFileUtils:sharedFileUtils():addSearchResolutionsOrder("res/")
    display.addSpriteFramesWithFile("SheetMapBattle.plist", "SheetMapBattle.png")
    display.addSpriteFramesWithFile("SheetEditor.plist", "SheetEditor.png")

    display.replaceScene(require("editor.EditorScene").new())
end, __G__TRACKBACK__)
