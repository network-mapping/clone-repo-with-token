# clone-repo-with-token
Bash scripts to clone a repo from GitHub with an installation token. 
The script installs git, generates a token and clones the repo.
The script is silent and intended to be used in an AWS automation runbook.

## Requirements
  - A GitHub App with permission to read the repo.
  - Bash shell
  - yum package manager

## Usage

    url='https://raw.githubusercontent.com/<org>/clone-repo-with-token/refs/heads/main/clone.sh'
    curl -sSL -o ./clone.sh "${url}"
    chmod -R +x "./clone.sh"
    
    source ./clone.sh <client_id> <installation_id> <pem> <org> <repo> <ref> <path>

### Parameters
$1 = client_id: GitHub client id.
$2 = installation_id: GitHub installation id.
$3 = pem: GitHub private key.
$4 = org: GitHub organisation
$5 = repo: GitHub repo.
$6 = ref: Tepository branch/tag.
$7 = path: Path to clone into.
