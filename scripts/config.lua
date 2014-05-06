
DEBUG                     = 2
DEBUG_FPS                 = false
DEBUG_MEM                 = true

CONFIG_SCREEN_ORIENTATION = "landscape"
CONFIG_SCREEN_WIDTH       = 960
CONFIG_SCREEN_HEIGHT      = 640
CONFIG_SCREEN_AUTOSCALE   = "FIXED_HEIGHT"

CONFIG_SCREEN_AUTOSCALE_CALLBACK = function(screenWidthInPixels, screenHeightInPixels, deviceModel)
    if (device.platform == "ios" and device.model == "iphone") or device.platform == "android" then
        return nil, nil
    end

    CONFIG_SCREEN_WIDTH = screenWidthInPixels
    CONFIG_SCREEN_HEIGHT = screenHeightInPixels
    return 1, 1
end
