export PULP_ADMIN_CONFIG="/etc/pulp/admin/admin.conf"
export PULP_SERVER_CONFIG="/etc/pulp/server.conf"
export REPO_AUTH_CONFIG="/etc/pulp/repo_auth.conf"
export HTTPD_SSL_CONFIG="/etc/httpd/conf.d/ssl.conf"
export HOSTNAME=`hostname --long`
export CA_CERT="/etc/pki/pulp/ca.crt"
export CA_KEY="/etc/pki/pulp/ca.key"
export CA_SERIAL="/etc/pki/pulp/ca.serial"
export HTTPS_CERT="/etc/pki/pulp/${HOSTNAME}.crt"
export HTTPS_KEY="/etc/pki/pulp/${HOSTNAME}.key"
export HTTPS_CSR="/etc/pki/pulp/${HOSTNAME}.csr"

if [ ! -f ${CA_SERIAL} ]; then
  echo "01" >> ${CA_SERIAL}
fi

openssl genrsa -out ${HTTPS_KEY} 2048
openssl req -new -key ${HTTPS_KEY} -out ${HTTPS_CSR} -subj "/C=US/ST=NC/L=Raleigh/O=Red Hat/OU=Pulp/CN=${HOSTNAME}"
openssl x509 -req -days 10950 -CA ${CA_CERT} -CAkey ${CA_KEY} -in ${HTTPS_CSR} -out ${HTTPS_CERT} -CAserial ${CA_SERIAL}

# Update Pulp server config
sed -i "s/# server_name: server_hostname/server_name: ${HOSTNAME}/" ${PULP_SERVER_CONFIG}
echo "Updated ${PULP_SERVER_CONFIG} server_name to ${HOSTNAME}"

# Update Pulp admin config
sed -i "s/host = localhost.localdomain/host = ${HOSTNAME}/" ${PULP_ADMIN_CONFIG}
echo "Updated ${PULP_ADMIN_CONFIG} host to ${HOSTNAME}"

# Enable Pulp repo auth
sed -i "s/enabled: false/enabled: true/" ${REPO_AUTH_CONFIG}
echo "Enabled repo auth in ${REPO_AUTH_CONFIG}"

# Update httpd ssl.conf
# Note, it's important we use a different delimiter since the path 
# we are inserting uses '/' in it's value
#
sed -i "s@^SSLCertificateFile.*@SSLCertificateFile ${HTTPS_CERT}@" ${HTTPD_SSL_CONFIG}
sed -i "s@^SSLCertificateKeyFile.*@SSLCertificateKeyFile ${HTTPS_KEY}@" ${HTTPD_SSL_CONFIG}
echo "Update ${HTTPD_SSL_CONFIG} for SSL Cert '${HTTPS_CERT}' and SSL Key '${HTTPS_KEY}'"