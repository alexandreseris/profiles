#!/usr/bin/env bash

################
#### CERTS ####

server_cert() {
    local srv_hostname="$1"
    local srv_port="$2"
    if [[ -z "$srv_port" ]]; then srv_port=443; fi
    openssl s_client -showcerts -servername "$srv_hostname" -connect "$srv_hostname:$srv_port" < /dev/null
}

cert_info() {
    local filepath="$1"
    openssl x509 -noout -text -certopt no_pubkey -certopt no_pubkey -certopt no_sigdump -in "$filepath"
}

cert_gen_self_signed_RSA() {
    local target_hostname="$1"
    openssl req \
        -keyout "$target_hostname.key" -out "$target_hostname.crt" \
        -x509 -newkey rsa:4096 -sha256 \
        -nodes -days 365000 -subj "/CN=$target_hostname" -addext "subjectAltName = DNS:$target_hostname"
}

cert_gen_ca() {
    openssl req \
        -keyout "ca.key" -out "ca.crt" \
        -x509 -newkey rsa:4096 -sha256 \
        -nodes -days 365000 -subj "/CN=test CA" -addext "keyUsage=Certificate Sign,CRL Sign"
}

cert_gen_req() {
    local target_hostname="$1"
    local alg="$2"
    if [[ -z "$alg" ]]; then alg=RSA; fi

    local req_args=("-out" "$target_hostname.req" "-new" "-nodes" "-subj" "/CN=$target_hostname")
    if [[ "$alg" == "RSA" ]]; then
        req_args+=("-keyout" "$target_hostname.key" "-newkey" "rsa:4096")
    else
        req_args+=("-key" "$target_hostname.key")
        if [[ "$alg" == "DSA" ]]; then
            openssl dsaparam -out "$target_hostname.dsaparam" 3072
            openssl gendsa -out "$target_hostname.key" "$target_hostname.dsaparam"
        elif [[ "$alg" == "EC" ]]; then
            openssl ecparam -name prime256v1 -genkey -noout -out "$target_hostname.key"
        elif [[ "$alg" == "ED25519" ]]; then
            openssl genpkey -algorithm ed25519 -out "$target_hostname.key"
        elif [[ "$alg" == "ED448" ]]; then
            openssl genpkey -algorithm ed448 -out "$target_hostname.key"
        else
            echo "algorithm $alg unknown"
        fi
    fi;
    openssl req $req_args
}
_cert_gen_req_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local arg_num=$COMP_CWORD
    if [[ $arg_num -eq 2 ]]; then
        COMPREPLY=( $(compgen -W "RSA DSA EC ED25519 ED448" -- "$cur") )
    fi
}
complete -F _cert_gen_req_completion cert_gen_req

cert_gen_x509_cert() {
    local target_hostname="$1"
    echo "authorityKeyIdentifier=keyid,issuer" > "$target_hostname.v3.ext"
    echo "subjectAltName = @alt_names" >> "$target_hostname.v3.ext"
    echo "[alt_names]" >> "$target_hostname.v3.ext"
    echo "DNS.1 = $target_hostname" >> "$target_hostname.v3.ext"
    # generate certificate signed by CA
    openssl x509 \
        -in "$target_hostname.req" -CA ca.crt -CAkey ca.key -out "$target_hostname.crt" \
        -req -sha256 -CAcreateserial \
        -days 365000 -extfile "$target_hostname.v3.ext"
    rm "$target_hostname.v3.ext"
}

cert_gen_ca_signed_RSA() {
    local target_hostname="$1"
    if [ ! -f "ca.crt" ]; then cert_gen_ca; fi
    if [ ! -f "$target_hostname.req" ]; cert_gen_req "$target_hostname" RSA; fi
    cert_gen_x509_cert "$target_hostname"
}

################
#### SYS ####

open_ports() {
    sudo ss --tcp --udp --listening --processes --numeric
}

process_tree() {
    local search="$1"
    if [[ -z  "$search" ]]; then
        ps -A u --forest
    else
        ps -A u --forest | less "+/$search"
    fi
}

process_list() { 
    local search="$1"
    if [[ -z  "$search" ]]; then
        ps -A u
    else
        local out=$(ps -A u)
        echo "$out" | head -n 1
        echo "$out" | grep "$search"
    fi
}
