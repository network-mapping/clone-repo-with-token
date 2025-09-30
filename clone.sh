#!/usr/bin/env bash

client_id="$1"
installation_id="$2"
pem="$3"
org="$4"
repo="$5"
ref="$6"
path="$7"

#install git
_=$(sudo yum -yq install git)

# Code from GitHub exmpple
# https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#example-using-bash-to-generate-a-jwt
# generate a jwt and get a token
now=$(date +%s)
iat=$((${now} - 60)) # Issues 60 seconds in the past
exp=$((${now} + 300)) # Expires 5 minutes in the future

b64enc() { openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'; }

header_json='{
    "typ":"JWT",
    "alg":"RS256"
}'
# Header encode
header=$( echo -n "${header_json}" | b64enc )

payload_json="{
    \"iat\":${iat},
    \"exp\":${exp},
    \"iss\":\"${client_id}\"
}"
# Payload encode
payload=$( echo -n "${payload_json}" | b64enc )

# Signature
header_payload="${header}"."${payload}"
signature=$(
    openssl dgst -sha256 -sign <(echo -n "${pem}") \
    <(echo -n "${header_payload}") | b64enc
)

# Create JWT
JWT="${header_payload}"."${signature}"

response=$( curl -sS --request POST \
    --url "https://api.github.com/app/installations/${installation_id}/access_tokens" \
    --header "Accept: application/vnd.github+json" \
    --header "Authorization: Bearer ${JWT}" \
    --header "X-GitHub-Api-Version: 2022-11-28")

token="$(echo "${response}" | jq -r '.token')"

# clone the repo
set_token "${client_id}" \
    "${installation_id}" \
    "${pem}" \
    "${org}" \
    "${repo}" \
    "${ref}" \
    "${path}"
url="https://x-access-token:${token}@github.com/${org}/${repo}.git"
git clone --depth 1 --branch ${ref} "${url}" "${path}" &> /dev/null
