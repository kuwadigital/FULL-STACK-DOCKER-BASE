#!/bin/bash
# =============================================================================
# Génération des certificats SSL auto-signés pour le développement local
# =============================================================================

set -e

CERTS_DIR="$(dirname "$0")"
DAYS_VALID=365

# Domaines à inclure dans le certificat
DOMAINS=(
    "*.local"
    "app.local"
    "api.local"
    "auth.local"
    "mail.local"
    "traefik.local"
    "parse.local"
    "*.parse.local"
    "localhost"
)

echo "=== Génération des certificats SSL pour le développement local ==="

# Création du fichier de configuration OpenSSL
cat > "${CERTS_DIR}/openssl.cnf" << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext
x509_extensions = v3_ca

[dn]
C = FR
ST = IDF
L = Paris
O = ABS-APP Development
OU = Development
CN = local

[req_ext]
subjectAltName = @alt_names

[v3_ca]
subjectAltName = @alt_names
basicConstraints = critical,CA:TRUE
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[alt_names]
EOF

# Ajout des domaines au fichier de configuration
i=1
for domain in "${DOMAINS[@]}"; do
    echo "DNS.$i = $domain" >> "${CERTS_DIR}/openssl.cnf"
    ((i++))
done
echo "IP.1 = 127.0.0.1" >> "${CERTS_DIR}/openssl.cnf"

# Génération de la clé privée
openssl genrsa -out "${CERTS_DIR}/local.key" 2048

# Génération du certificat
openssl req -new -x509 \
    -key "${CERTS_DIR}/local.key" \
    -out "${CERTS_DIR}/local.crt" \
    -days ${DAYS_VALID} \
    -config "${CERTS_DIR}/openssl.cnf"

# Vérification
echo ""
echo "=== Certificat généré avec succès ==="
echo "Fichiers créés:"
echo "  - ${CERTS_DIR}/local.key (clé privée)"
echo "  - ${CERTS_DIR}/local.crt (certificat)"
echo ""
echo "Domaines inclus:"
for domain in "${DOMAINS[@]}"; do
    echo "  - $domain"
done
echo ""
echo "=== Pour faire confiance au certificat ==="
echo "Linux:   sudo cp ${CERTS_DIR}/local.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates"
echo "macOS:   sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${CERTS_DIR}/local.crt"
echo "Windows: Importer local.crt dans 'Autorités de certification racines de confiance'"
echo ""

# Nettoyage
rm -f "${CERTS_DIR}/openssl.cnf"

echo "Terminé!"
