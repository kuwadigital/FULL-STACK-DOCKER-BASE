/**
 * =============================================================================
 * SendGrid Inbound Parse Simulator
 * =============================================================================
 * Reproduction fidèle du SendGrid Inbound Parse Webhook pour le développement local.
 *
 * Fonctionnalités:
 * - Serveur SMTP pour recevoir les emails
 * - Parsing des emails (headers, body, attachments)
 * - Routage vers les webhooks configurés par domaine/sous-domaine
 * - Support du mode raw et parsed
 * - Gestion des pièces jointes
 * - Format de données identique à SendGrid
 * =============================================================================
 */

import express from 'express';
import { SMTPServer } from 'smtp-server';
import { simpleParser } from 'mailparser';
import FormData from 'form-data';
import fetch from 'node-fetch';
import { v4 as uuidv4 } from 'uuid';
import pino from 'pino';
import fs from 'fs/promises';
import path from 'path';

// =============================================================================
// Configuration
// =============================================================================

const CONFIG_PATH = process.env.CONFIG_PATH || '/app/config/config.json';
const HTTP_PORT = parseInt(process.env.HTTP_PORT || '8080');
const SMTP_PORT = parseInt(process.env.SMTP_PORT || '2525');
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

const logger = pino({
  level: LOG_LEVEL,
  transport: {
    target: 'pino-pretty',
    options: { colorize: true }
  }
});

let config = {
  routes: {},
  defaultRoute: null
};

// =============================================================================
// Configuration Loader
// =============================================================================

async function loadConfig() {
  try {
    const configData = await fs.readFile(CONFIG_PATH, 'utf-8');
    config = JSON.parse(configData);
    logger.info({ routes: Object.keys(config.routes) }, 'Configuration loaded');
  } catch (error) {
    logger.warn({ error: error.message }, 'Config file not found, using defaults');
    config = {
      routes: {
        "parse.local": {
          url: "http://api.local/webhooks/email",
          raw: false,
          spam_check: true
        }
      },
      defaultRoute: null
    };
  }
}

// =============================================================================
// Email Parser - Convertit l'email au format SendGrid
// =============================================================================

async function parseEmailToSendGridFormat(parsed, rawEmail, recipientDomain) {
  const routeConfig = config.routes[recipientDomain] || config.defaultRoute || {};

  // Headers
  const headers = {};
  if (parsed.headers) {
    for (const [key, value] of parsed.headers) {
      headers[key.toLowerCase()] = typeof value === 'object' ? JSON.stringify(value) : value;
    }
  }

  // Envelope
  const envelope = {
    to: parsed.to?.value?.map(addr => addr.address) || [],
    from: parsed.from?.value?.[0]?.address || ''
  };

  // Charsets
  const charsets = {
    to: 'UTF-8',
    from: 'UTF-8',
    subject: 'UTF-8',
    text: parsed.textAsHtml ? 'UTF-8' : null,
    html: parsed.html ? 'UTF-8' : null
  };

  // Attachments info
  const attachments = parsed.attachments || [];
  const attachmentInfo = {};

  attachments.forEach((att, index) => {
    const key = `attachment${index + 1}`;
    attachmentInfo[key] = {
      filename: att.filename || `attachment${index + 1}`,
      name: att.filename || `attachment${index + 1}`,
      type: att.contentType || 'application/octet-stream',
      'content-id': att.contentId || null,
      charset: 'UTF-8'
    };
  });

  // SPF et DKIM (simulés pour le développement)
  const spf = 'pass';
  const dkim = JSON.stringify({ signed: false, valid: false });

  // Spam check (simulé)
  let spamScore = 0;
  let spamReport = '';
  if (routeConfig.spam_check) {
    spamScore = Math.random() * 2; // Score bas pour les tests
    spamReport = `Spam detection disabled in development mode. Score: ${spamScore.toFixed(1)}`;
  }

  // Construction du payload SendGrid
  const payload = {
    headers: JSON.stringify(headers),
    dkim: dkim,
    'content-ids': JSON.stringify(attachments.filter(a => a.contentId).map(a => a.contentId)),
    to: parsed.to?.text || '',
    cc: parsed.cc?.text || '',
    from: parsed.from?.text || '',
    subject: parsed.subject || '',
    text: parsed.text || '',
    html: parsed.html || '',
    sender_ip: '127.0.0.1',
    spam_report: spamReport,
    envelope: JSON.stringify(envelope),
    attachments: attachments.length.toString(),
    'attachment-info': JSON.stringify(attachmentInfo),
    charsets: JSON.stringify(charsets),
    SPF: spf,
    spam_score: spamScore.toString()
  };

  // Mode raw: inclure l'email MIME complet
  if (routeConfig.raw) {
    payload.email = rawEmail;
  }

  return { payload, attachments, routeConfig };
}

// =============================================================================
// Webhook Sender - Envoie les données au webhook configuré
// =============================================================================

async function sendToWebhook(payload, attachments, routeConfig) {
  const webhookUrl = routeConfig.url;

  if (!webhookUrl) {
    logger.warn('No webhook URL configured for this domain');
    return false;
  }

  const formData = new FormData();

  // Ajouter tous les champs du payload
  for (const [key, value] of Object.entries(payload)) {
    if (value !== null && value !== undefined) {
      formData.append(key, value);
    }
  }

  // Ajouter les pièces jointes
  attachments.forEach((att, index) => {
    const key = `attachment${index + 1}`;
    formData.append(key, att.content, {
      filename: att.filename || `attachment${index + 1}`,
      contentType: att.contentType || 'application/octet-stream'
    });
  });

  try {
    const response = await fetch(webhookUrl, {
      method: 'POST',
      body: formData,
      headers: formData.getHeaders()
    });

    if (response.ok) {
      logger.info({ url: webhookUrl, status: response.status }, 'Webhook delivered successfully');
      return true;
    } else {
      logger.error({ url: webhookUrl, status: response.status }, 'Webhook delivery failed');
      return false;
    }
  } catch (error) {
    logger.error({ url: webhookUrl, error: error.message }, 'Webhook delivery error');
    return false;
  }
}

// =============================================================================
// SMTP Server
// =============================================================================

const smtpServer = new SMTPServer({
  secure: false,
  authOptional: true,
  disabledCommands: ['AUTH'],

  onConnect(session, callback) {
    logger.debug({ remoteAddress: session.remoteAddress }, 'SMTP connection');
    callback();
  },

  onMailFrom(address, session, callback) {
    logger.debug({ from: address.address }, 'MAIL FROM');
    callback();
  },

  onRcptTo(address, session, callback) {
    logger.debug({ to: address.address }, 'RCPT TO');
    callback();
  },

  async onData(stream, session, callback) {
    const messageId = uuidv4();
    logger.info({ messageId }, 'Receiving email');

    const chunks = [];

    stream.on('data', chunk => chunks.push(chunk));

    stream.on('end', async () => {
      try {
        const rawEmail = Buffer.concat(chunks).toString('utf-8');
        const parsed = await simpleParser(rawEmail);

        // Déterminer le domaine de destination
        const recipientEmail = session.envelope.rcptTo[0]?.address || '';
        const recipientDomain = recipientEmail.split('@')[1] || 'unknown';

        logger.info({
          messageId,
          from: parsed.from?.text,
          to: parsed.to?.text,
          subject: parsed.subject,
          domain: recipientDomain
        }, 'Email parsed');

        // Convertir au format SendGrid
        const { payload, attachments, routeConfig } = await parseEmailToSendGridFormat(
          parsed,
          rawEmail,
          recipientDomain
        );

        // Envoyer au webhook
        if (routeConfig && routeConfig.url) {
          await sendToWebhook(payload, attachments, routeConfig);
        } else {
          logger.warn({ domain: recipientDomain }, 'No route configured for domain');
        }

        callback();
      } catch (error) {
        logger.error({ error: error.message }, 'Error processing email');
        callback(error);
      }
    });
  }
});

// =============================================================================
// HTTP Server (API et Dashboard)
// =============================================================================

const app = express();
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'inbound-parse-simulator' });
});

// Configuration API
app.get('/api/config', (req, res) => {
  res.json(config);
});

app.post('/api/config/routes', (req, res) => {
  const { domain, url, raw = false, spam_check = true } = req.body;

  if (!domain || !url) {
    return res.status(400).json({ error: 'domain and url are required' });
  }

  config.routes[domain] = { url, raw, spam_check };
  logger.info({ domain, url }, 'Route added');
  res.json({ success: true, routes: config.routes });
});

app.delete('/api/config/routes/:domain', (req, res) => {
  const { domain } = req.params;

  if (config.routes[domain]) {
    delete config.routes[domain];
    logger.info({ domain }, 'Route deleted');
    res.json({ success: true });
  } else {
    res.status(404).json({ error: 'Route not found' });
  }
});

// Dashboard simple
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>SendGrid Inbound Parse Simulator</title>
      <style>
        body { font-family: system-ui, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; }
        h1 { color: #1a73e8; }
        .info { background: #e8f5e9; padding: 15px; border-radius: 8px; margin: 20px 0; }
        .route { background: #fff3e0; padding: 10px; border-radius: 4px; margin: 10px 0; }
        code { background: #f5f5f5; padding: 2px 6px; border-radius: 3px; }
      </style>
    </head>
    <body>
      <h1>SendGrid Inbound Parse Simulator</h1>
      <div class="info">
        <strong>SMTP Server:</strong> Port ${SMTP_PORT}<br>
        <strong>HTTP API:</strong> Port ${HTTP_PORT}
      </div>
      <h2>Routes configurées</h2>
      ${Object.entries(config.routes).map(([domain, cfg]) => `
        <div class="route">
          <strong>${domain}</strong> → <code>${cfg.url}</code><br>
          Raw: ${cfg.raw ? 'Oui' : 'Non'} | Spam Check: ${cfg.spam_check ? 'Oui' : 'Non'}
        </div>
      `).join('')}
      <h2>API Endpoints</h2>
      <ul>
        <li><code>GET /health</code> - Health check</li>
        <li><code>GET /api/config</code> - Voir la configuration</li>
        <li><code>POST /api/config/routes</code> - Ajouter une route</li>
        <li><code>DELETE /api/config/routes/:domain</code> - Supprimer une route</li>
      </ul>
    </body>
    </html>
  `);
});

// =============================================================================
// Startup
// =============================================================================

async function start() {
  await loadConfig();

  smtpServer.listen(SMTP_PORT, () => {
    logger.info({ port: SMTP_PORT }, 'SMTP server started');
  });

  app.listen(HTTP_PORT, () => {
    logger.info({ port: HTTP_PORT }, 'HTTP server started');
  });
}

start().catch(error => {
  logger.error({ error: error.message }, 'Failed to start server');
  process.exit(1);
});
