<?php

require(__DIR__ . '/config.php');

define('BASE_DIR', rtrim(__DIR__, '/\\'));
define('WORK_DIR', BASE_DIR . DS . 'workdir_');
define('SRC_DIR',  BASE_DIR . DS . 'battle');
define('DEST_DIR', rtrim(realpath(BASE_DIR . '/../res'), '/\\'));
define('SCALE', 0.5);

if (!file_exists(WORK_DIR))
{
    mkdir(WORK_DIR);
}

chdir(SRC_DIR);

printf("======================================================================\n");
$time = time();
printf("START TIME: %s\n", date('Y-m-d H:i:s', $time));
printf("SRC_DIR  = %s\n", SRC_DIR);
printf("WORK_DIR = %s\n", WORK_DIR);
printf("DEST_DIR = %s\n", DEST_DIR);
print("\n");

// ----------------------------------------

createTexture(array(
    'workdir' => WORK_DIR,
    'destdir' => DEST_DIR,
    'destname' => 'SheetMapBattle',
    'srcdirs' => array(
        'battle',
        'effects',
        'static',
    ),
    'mode' => MODE_RGBA8888,
    'scale' => SCALE,
    'freesize' => false,
    'webp' => false
));
