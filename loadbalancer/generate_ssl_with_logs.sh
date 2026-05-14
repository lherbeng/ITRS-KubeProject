#!/bin/bash

# Variables
SSL_DIR="/etc/nginx/ssl"
DOMAIN="lgesite.com"
VALIDITY_DAYS=365

# Certificate and Key Paths
PRIVATE_KEY="${SSL_DIR}/${DOMAIN}.key"
CSR="${SSL_DIR}/${DOMAIN}.csr"
CERTIFICATE="${SSL_DIR}/${DOMAIN}.crt"
LOG_FILE="/var/log/ssl_generation.log"

# Log Function
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"


# Exit Script on Error
handle_error() {
  log "ERROR: $1"
  exit 1
}

# Start Logging
log "Starting SSL generation for domain: $DOMAIN"

# Ensure the SSL directory exists
log "Creating SSL directory at $SSL_DIR..."
sudo mkdir -p "$SSL_DIR" || handle_error "Failed to create SSL directory."

# Generate the Private Key
log "Generating private key..."
sudo openssl genrsa -out "$PRIVATE_KEY" 2048 2>>"$LOG_FILE" || handle_error "Failed to generate private key."

# Generate the Certificate Signing Request (CSR)
log "Generating Certificate Signing Request (CSR)..."
sudo openssl req -new -key "$PRIVATE_KEY" -out "$CSR" \
  -subj "/C=PH/ST=Bulacan/L=San Jose/O=RhelTek/OU=IT/CN=$DOMAIN/emailAddress=brandonlucasfaye@gmail.com" \
  2>>"$LOG_FILE" || handle_error "Failed to generate CSR."

# Generate the Self-Signed Certificate
log "Generating self-signed certificate..."
sudo openssl x509 -req -days "$VALIDITY_DAYS" -in "$CSR" -signkey "$PRIVATE_KEY" -out "$CERTIFICATE" \
  2>>"$LOG_FILE" || handle_error "Failed to generate self-signed certificate."

# Set Proper Permissions
log "Setting file permissions for SSL files..."
sudo chmod 600 "$PRIVATE_KEY" 2>>"$LOG_FILE" || handle_error "Failed to set permissions for private key."
sudo chmod 644 "$CERTIFICATE" 2>>"$LOG_FILE" || handle_error "Failed to set permissions for certificate."

# Final Log Summary
log "SSL generation completed successfully."
log "Private Key: $PRIVATE_KEY"
log "Certificate: $CERTIFICATE"
log "Logs are available at: $LOG_FILE"