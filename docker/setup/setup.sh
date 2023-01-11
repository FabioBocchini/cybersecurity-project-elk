# Exit on Error
set -e

CONFIG_DIR=/usr/share/elasticsearch/config
OUTPUT_FILE=/secrets/elasticsearch.keystore
NATIVE_FILE=$CONFIG_DIR/elasticsearch.keystore
OUTPUT_DIR=/secrets
CA_DIR=$OUTPUT_DIR/certificate_authority
KEYSTORES_DIR=$OUTPUT_DIR/keystores
CERT_DIR=$OUTPUT_DIR/certificates
CA_P12=$CA_DIR/elastic-stack-ca.p12
CA_ZIP=$CA_DIR/ca.zip
CA_CERT=$CA_DIR/ca/ca.crt
CA_KEY=$CA_DIR/ca/ca.key
BUNDLE_ZIP=$OUTPUT_DIR/bundle.zip
CERT_KEYSTORES_ZIP=$OUTPUT_DIR/cert_keystores.zip
HTTP_ZIP=$OUTPUT_DIR/http.zip

apt-get update
apt-get install unzip openssl -y

create_self_signed_ca()
{
    printf "====== Creating Self-Signed Certificate Authority ======\n"
    printf "=====================================================\n"
    echo "Generating Self-Signed Certificate Authority PEM ..."
    bin/elasticsearch-certutil ca --pass "" --pem --out $CA_ZIP --silent
    unzip $CA_ZIP -d $CA_DIR
    echo "Generating Self-Signed Certificate Authority P12 ..."
    bin/elasticsearch-certutil ca --pass "" --out $CA_P12 --silent
    echo "elastic-stack-ca.p12 is located $CA_P12"
}

create_certificates()
{
    printf "====== Generating Certiticate Keystores ======\n"
    printf "=====================================================\n"
    echo "Creating p12 certificate keystores"
    bin/elasticsearch-certutil cert --silent --in $CONFIG_DIR/instances.yml --out $CERT_KEYSTORES_ZIP --ca $CA_P12 --ca-pass "" --pass ""
    unzip $CERT_KEYSTORES_ZIP -d $KEYSTORES_DIR
    echo "Creating crt and key certificates"
    bin/elasticsearch-certutil cert --silent --in $CONFIG_DIR/instances.yml --out $BUNDLE_ZIP --ca-cert $CA_CERT --ca-key $CA_KEY --ca-pass "" --pem
    unzip $BUNDLE_ZIP -d $CERT_DIR
}

setup_passwords()
{
    printf "====== Setting up Default User Passwords ======\n"
    printf "=====================================================\n"
    
    bin/elasticsearch-setup-passwords auto -u "https://0.0.0.0:9200" -v --batch
}

create_keystore()
{
    printf "========== Creating Elasticsearch Keystore ==========\n"
    printf "=====================================================\n"
    elasticsearch-keystore create >> /dev/null

    ## Setting Bootstrap Password
    echo "Setting bootstrap password..."
    (echo "$ELASTIC_PASSWORD" | elasticsearch-keystore add -x 'bootstrap.password')

    # Replace current Keystore
    if [ -f "$OUTPUT_FILE" ]; then
        echo "Remove old elasticsearch.keystore"
        rm $OUTPUT_FILE
    fi

    #setup_passwords
    echo "Saving new elasticsearch.keystore"
    mv $NATIVE_FILE $OUTPUT_FILE
    chmod 0644 $OUTPUT_FILE

    printf "======= Keystore setup completed successfully =======\n"
    printf "=====================================================\n"
}


remove_existing_certificates()
{
    printf "====== Removing Existing Secrets ======\n"
    printf "=====================================================\n"
    for f in $OUTPUT_DIR/* ; do
        if [ -d "$f" ]; then
            echo "Removing directory $f"
            rm -rf $f
        fi
        if [ -f "$f" ]; then
            echo "Removing file $f"
            rm $f
        fi
    done
}

create_directory_structure()
{
    printf "====== Creating Required Directories ======\n"
    printf "=====================================================\n"
    echo "Creating Certificate Authority Directory..."
    mkdir $CA_DIR
    echo "Creating Keystores Directory..."
    mkdir $KEYSTORES_DIR
    echo "Creating Certificates Directory..."
    mkdir $CERT_DIR
}


remove_existing_certificates
create_directory_structure
create_keystore
create_self_signed_ca
create_certificates

openssl pkcs8 -in /secrets/certificates/logstash/logstash.key -topk8 -nocrypt -out /secrets/certificates/logstash/logstash.pkcs8.key

chown -R 1000:0 $OUTPUT_DIR

printf "=====================================================\n"
printf "SSL Certificates generation completed successfully.\n"
printf "=====================================================\n"