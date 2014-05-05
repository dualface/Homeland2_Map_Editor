
DEBUG                   = 2
DEBUG_FPS               = false
DEBUG_MEM_USAGE         = false
DEVICE_ORIENTATION      = "landscape"
CONFIG_SCREEN_WIDTH     = 960
CONFIG_SCREEN_HEIGHT    = 640
CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"

CONFIG_SCREEN_AUTOSCALE_CALLBACK = function(screenWidthInPixels, screenHeightInPixels, deviceModel)
    CONFIG_SCREEN_WIDTH = screenWidthInPixels
    CONFIG_SCREEN_HEIGHT = screenHeightInPixels
    local scaleX, scaleY = 1, 1
    return scaleX, scaleY
end

TEXTURE_FORMAT = {}
TEXTURE_FORMAT["MapA0001Bg.png"]    = kCCTexture2DPixelFormat_RGB565
