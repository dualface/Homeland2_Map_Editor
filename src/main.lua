
-- for CCLuaEngine
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

cc.FileUtils:getInstance():addSearchPath("res/")

xpcall(function()
    require("config")
    require("framework.init")

    display.addSpriteFrames("SheetMapBattle.plist", "SheetMapBattle.png")
    display.addSpriteFrames("SheetEditor.plist", "SheetEditor.png")

    display.replaceScene(require("editor.EditorScene").new())
end, __G__TRACKBACK__)
