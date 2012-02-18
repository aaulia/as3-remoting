<?php

if (!isset($_POST['request'])) {
    exit;
}

require_once 'config.php';
require_once 'crypto/aes.php';

spl_autoload_register();

$request = \crypto\AESCtr::decrypt($_POST['request'], AES_KEYWORD, 256);
$request = json_decode($request, true);
if ($request == null) {
    exit;
}

$object = new $request['class']();
$method = $request['method'];
$params = $request['params'];
$result = call_user_func_array(array($object, $method), $params);

$request['result'] = $result;
echo \crypto\AESCtr::encrypt(json_encode($request), AES_KEYWORD, 256);
exit;
?>
