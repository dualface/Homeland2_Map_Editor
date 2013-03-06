<?php

require(__DIR__ . '/config.php');

define('BASE_DIR', rtrim(__DIR__, '/\\'));
define('WORK_DIR', BASE_DIR . DS . 'workdir_');
define('SRC_DIR',  BASE_DIR . DS . 'maps');
define('DEST_DIR', rtrim(realpath(BASE_DIR . '/../res'), '/\\'));
define('SCALE', 0.5);


function help()
{
    printf("usage: php update_maps.php mapIndex | all\n");
    printf("    mapIndex: A\n");
    printf("    all: update all maps\n\n");
}
$indexs = array('A');

if (!isset($argv[1]))
{
    help();
    exit(1);
}

$arg = strtoupper($argv[1]);
$sourceDirs = array();
if ($arg == 'ALL')
{
    $sourceDirs = $indexs;
}
elseif (in_array($arg, $indexs, true))
{
    $sourceDirs = array($arg);
}
else
{
    help();
    exit(1);
}

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

createFiles(array(
    'workdir' => WORK_DIR,
    'destdir' => DEST_DIR,
    'srcdirs' => $sourceDirs,
    'mode'    => MODE_RGB565,
    'scale'   => SCALE,
    'webp'    => false
));
