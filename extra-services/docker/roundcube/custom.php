<?php
/**
 * Custom Roundcube configuration for Greenmail
 * This file must be included manually in config.inc.php
 */

// Strip domain from username (user1@mail.local -> user1)
// Greenmail expects login without domain
$config['login_lc'] = 2;

// Mail domain for compose
$config['mail_domain'] = 'mail.local';
