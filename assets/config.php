<?php

define('DS', DIRECTORY_SEPARATOR);

date_default_timezone_set("Asia/Chongqing");

define('TP_BIN', 'TexturePacker');
define('TP_FLAGS', '--algorithm MaxRects --smart-update '
        . '--trim --enable-rotation --shape-padding 1 --border-padding 1 '
        . '--padding 0 --inner-padding 0 --format cocos2d '
        . '--scale-mode smooth');

define('TP_TEXTURE_RGBA8888', '--opt RGBA8888');
define('TP_TEXTURE_RGBA4444', '--opt RGBA4444 --dither-fs-alpha');
define('TP_TEXTURE_RGB565',   '--opt RGB565 --dither-fs');

define('TP_FILE_RGBA8888',  '--allow-free-size --opt RGBA8888 --no-trim '
                            . '--disable-rotation --padding 0 --scale-mode smooth');

define('TP_FILE_RGBA4444',  '--allow-free-size --opt RGBA4444 --dither-fs-alpha --no-trim '
                            . '--disable-rotation --padding 0 --scale-mode smooth');

define('TP_FILE_RGB565',    '--allow-free-size --opt RGB565 --dither-fs --no-trim '
                            . '--disable-rotation --padding 0 --scale-mode smooth');

define('CWEBP_BIN', 'cwebp');
define('CWEBP_RGBA8888', '-q 90 -alpha_q 90 -af -alpha_cleanup -short');
define('CWEBP_RGBA4444', '-q 90 -alpha_q 90 -af -alpha_cleanup -short');
define('CWEBP_RGB565', '-q 90 -noalpha -short');

define('MODE_RGBA8888', 1);
define('MODE_RGBA4444', 2);
define('MODE_RGB565',   3);

if (!defined('USE_RGB565_WEBP')) define('USE_RGB565_WEBP', true);

define('NO_WEBP', 'NO_WEBP');

function createTexture(array $params)
{
    $workdir  = rtrim($params['workdir'], '/\\');
    $destdir  = rtrim($params['destdir'], '/\\');
    $destname = $params['destname'];
    $srcdirs  = $params['srcdirs'];
    $mode     = isset($params['mode']) ? $params['mode'] : TP_TEXTURE_RGBA8888;
    $scale    = isset($params['scale']) ? $params['scale'] : null;
    $webp     = isset($params['webp']) ? $params['webp'] : false;
    $freesize = isset($params['freesize']) ? $params['freesize'] : false;

    printf("-------------------- %s --------------------\n", $destname);
    printf("---- step1: create %s.png\n", $destname);
    $cmd = array();
    $cmd[] = TP_BIN;
    $cmd[] = TP_FLAGS;
    switch ($mode)
    {
        case MODE_RGBA4444:
            $cmd[] = TP_TEXTURE_RGBA4444;
            break;

        case MODE_RGB565:
            $cmd[] = TP_TEXTURE_RGB565;
            break;

        default: // MODE_RGBA8888
            $cmd[] = TP_TEXTURE_RGBA8888;
    }

    if ($scale)
    {
        $cmd[] = sprintf('--scale %0.2f', $scale);
    }
    if ($freesize)
    {
        $cmd[] = '--allow-free-size';
    }
    $cmd[] = sprintf('--sheet %s%s%s.png', $workdir, DS, $destname);
    $cmd[] = sprintf('--data %s%s%s.plist', $workdir, DS, $destname);

    if (DS == '\\')
    {
        foreach ($srcdirs as $dir)
        {
            $cmd[] = sprintf('%s%s', $dir, DS);
        }
    }
    else
    {
        foreach ($srcdirs as $dir)
        {
            $cmd[] = sprintf('%s%s*.png', $dir, DS);
        }
    }

    $cmd = implode(' ', $cmd);
    print($cmd . " .....");
    $ret = shell_exec($cmd);
    print("\n");
    print($ret);

    if ($webp)
    {
        $skip = false;
        if (substr($ret, 0, strlen('Nothing to do')) == 'Nothing to do')
        {
            printf("---- step2: [SKIP] convert %s.png to %s.webp\n", $destname, $destname);
            $skip = true;
        }

        if (!$skip)
        {
            printf("---- step2: convert %s.png to %s.webp\n", $destname, $destname);
            $cmd = array();
            $cmd[] = CWEBP_BIN;
            switch ($mode)
            {
                case MODE_RGBA4444:
                    $cmd[] = CWEBP_RGBA4444;
                    break;

                case MODE_RGB565:
                    $cmd[] = CWEBP_RGB565;
                    break;

                default: // MODE_RGBA8888
                    $cmd[] = CWEBP_RGBA8888;
            }

            $cmd[] = sprintf('-o %s%s%s.webp', $workdir, DS, $destname);
            $cmd[] = sprintf('%s%s%s.png', $workdir, DS, $destname);
            $cmd = implode(' ', $cmd);
            passthru($cmd);
        }

        printf("---- step3: copy %s.webp/.plist\n", $destname);
        copy($workdir . DS . $destname . '.webp', $destdir . DS . $destname . '.webp');
        copy($workdir . DS . $destname . '.plist', $destdir . DS . $destname . '.plist');
    }
    else
    {
        printf("---- step2: copy %s.png/.plist\n", $destname);
        copy($workdir . DS . $destname . '.png', $destdir . DS . $destname . '.png');
        copy($workdir . DS . $destname . '.plist', $destdir . DS . $destname . '.plist');
    }
    printf("done.\n\n");
}

function createFile(array $params)
{
    $workdir  = rtrim($params['workdir'], '/\\');
    $destdir  = rtrim($params['destdir'], '/\\');
    $srcdir   = $params['srcdir'];
    $destname = $params['destname'];
    $mode     = isset($params['mode']) ? $params['mode'] : TP_TEXTURE_RGBA8888;
    $scale    = isset($params['scale']) ? $params['scale'] : null;
    $webp     = isset($params['webp']) ? $params['webp'] : false;

    printf("-------- convert file %s.png\n", $destname);
    printf("---- step1: create %s.png\n", $destname);

    $workFileExtname = 'png';

    $cmd = array();
    $cmd[] = TP_BIN;
    switch ($mode)
    {
        case MODE_RGBA4444:
            $cmd[] = TP_FILE_RGBA4444;
            break;

        case MODE_RGB565:
            $cmd[] = TP_FILE_RGB565;
            if (!USE_RGB565_WEBP)
            {
                $workFileExtname = 'jpg';
                $noWebP = true;
                $cmd[] = '--jpg-quality 90';
            }
            break;

        default: // MODE_RGBA8888
            $cmd[] = TP_FILE_RGBA8888;
    }

    if ($scale)
    {
        $cmd[] = sprintf('--scale %0.2f', $scale);
    }
    $cmd[] = sprintf('--sheet %s%s%s.%s', $workdir, DS, $destname, $workFileExtname);
    $cmd[] = sprintf('--data %s%s%s.plist', $workdir, DS, $destname);
    $cmd[] = sprintf('%s%s%s.png', $srcdir, DS, $destname);

    $cmd = implode(' ', $cmd);
    $ret = shell_exec($cmd);
    print($ret);

    if ($webp)
    {
        $skip = false;
        if (substr($ret, 0, strlen('Nothing to do')) == 'Nothing to do')
        {
            printf("---- step2: [SKIP] convert %s.png to %s.webp\n", $destname, $destname);
            $skip = true;
        }

        if (!$skip)
        {
            printf("---- step2: convert %s.png to %s.webp\n", $destname, $destname);
            $cmd = array();
            $cmd[] = CWEBP_BIN;
            switch ($mode)
            {
                case MODE_RGBA4444:
                    $cmd[] = CWEBP_RGBA4444;
                    break;

                case MODE_RGB565:
                    $cmd[] = CWEBP_RGB565;
                    break;

                default: // MODE_RGBA8888
                    $cmd[] = CWEBP_RGBA8888;
            }

            $cmd[] = sprintf('-o %s%s%s.webp', $workdir, DS, $destname);
            $cmd[] = sprintf('%s%s%s.png', $workdir, DS, $destname);
            $cmd = implode(' ', $cmd);
            passthru($cmd);
        }

        printf("---- step3: copy %s.webp\n", $destname);
        copy($workdir . DS . $destname . '.webp', $destdir . DS . $destname . '.webp');
    }
    else
    {
        printf("---- step2: copy %s.%s\n", $destname, $workFileExtname);
        copy($workdir . DS . $destname . '.' . $workFileExtname, $destdir . DS . $destname . '.' . $workFileExtname);
    }

    printf("done.\n\n");
}

function createFiles(array $params)
{
    $workdir  = rtrim($params['workdir'], '/\\');
    $destdir  = rtrim($params['destdir'], '/\\');
    $srcdirs  = $params['srcdirs'];
    $mode     = isset($params['mode']) ? $params['mode'] : TP_TEXTURE_RGBA8888;
    $scale    = isset($params['scale']) ? $params['scale'] : null;
    $webp     = isset($params['webp']) ? $params['webp'] : false;

    // function createFile($workdir, $destdir, $srcdir, $destname, $mode, $noWebP)
    foreach ($srcdirs as $dir)
    {
        printf("------------ convert files in %s ------------\n", $dir);
        $files = glob(sprintf("%s%s*.png", $dir, DS));
        foreach ($files as $filename)
        {
            $basename = pathinfo($filename, PATHINFO_FILENAME);
            createFile(array(
                'workdir'  => $workdir,
                'destdir'  => $destdir,
                'srcdir'   => $dir,
                'destname' => $basename,
                'mode'     => $mode,
                'scale'    => $scale,
                'webp'     => $webp
            ));
        }
    }

    printf("done.\n\n");
}

