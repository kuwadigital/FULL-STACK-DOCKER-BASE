<?php
/**
 * Custom Roundcube configuration for Greenmail integration
 *
 * Greenmail uses 'user' as login, not 'user@domain'
 * This config strips the domain from the username before authentication
 */

// Strip domain from username before sending to IMAP
// Greenmail expects 'user1' not 'user1@mail.local'
$config['login_lc'] = 2;  // Convert to lowercase and strip domain

// Alternative: Use a username filter hook
$config['username_domain'] = '';
$config['username_domain_forced'] = false;

// Force the mail domain for display purposes
$config['mail_domain'] = 'mail.local';
