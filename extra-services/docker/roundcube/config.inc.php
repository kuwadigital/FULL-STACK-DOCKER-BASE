<?php
    $config['plugins'] = [];
    $config['log_driver'] = 'stdout';
    $config['zipdownload_selection'] = true;
    $config['des_key'] = 'xeUr9lFo0rZRJmyFwUyqz4Sp';
    $config['enable_spellcheck'] = true;
    $config['spellcheck_engine'] = 'pspell';

    // Include Docker configuration
    include(__DIR__ . '/config.docker.inc.php');

    // Custom configuration for Greenmail integration
    // Strip domain from username (user1@mail.local -> user1)
    $config['login_lc'] = 2;
    $config['mail_domain'] = 'mail.local';
