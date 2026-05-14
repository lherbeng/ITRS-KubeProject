#!/bin/bash

# Variables
SSL_DIR="/etc/nginx/ssl"
DOMAIN="lgesite.com"
VALIDITY_DAYS=365

# Certificate and Key Paths
PRIVATE_KEY="${SSL_DIR}/${DOMAIN}.key"
CSR="${SSL_DIR}/${DOMAIN}.csr"
CERTIFICATE="${SSL_DIR}/${DOMAIN}.crt"

# Ensure the SSL directory exists
echo "Creating SSL directory at $SSL_DIR..."
sudo mkdir -p $SSL_DIR

# Generate the Private Key
echo "Generating private key..."
sudo openssl genrsa -out $PRIVATE_KEY 2048

# Generate the Certificate Signing Request (CSR)
echo "Generating Certificate Signing Request (CSR)..."
sudo openssl req -new -key $PRIVATE_KEY -out $CSR \
  -subj "/C=PH/ST=Bulacan/L=San Jose/O=RhelTek/OU=IT/CN=$DOMAIN/emailAddress=brandonlucasfaye@gmail.com"

# Generate the Self-Signed Certificate
echo "Generating self-signed certificate..."
sudo openssl x509 -req -days $VALIDITY_DAYS -in $CSR -signkey $PRIVATE_KEY -out $CERTIFICATE

# Set Proper Permissions
echo "Setting file permissions..."
sudo chmod 600 $PRIVATE_KEY
sudo chmod 644 $CERTIFICATE

# Summary of Generated Files
echo "SSL Certificate and Key have been generated:"
echo "Private Key: $PRIVATE_KEY"
echo "Certificate: $CERTIFICATE"
