#!/bin/bash

# Carregar variáveis do .env, se existir
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Arquivo .env não encontrado. Certifique-se de que ele existe e contém o GITHUB_TOKEN."
    exit 1
fi

# Verifica se o token foi carregado
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Variável GITHUB_TOKEN não encontrada. Verifique o arquivo .env."
    exit 1
fi

# URL da API do GitHub para obter os repositórios do usuário
API_URL="https://api.github.com/user/repos?type=all"

# Faz a solicitação GET para a API do GitHub para obter os repositórios (autenticando com o token)
repos=$(curl -s -H "Accept: application/vnd.github.v3+json" \
                -H "Authorization: Bearer $GITHUB_TOKEN" \
                -X GET $API_URL | jq -r '.[].ssh_url')

# Mostra a lista de URLs SSH dos repositórios antes da clonagem
echo "Lista de URLs SSH dos repositórios:"
echo "$repos"

# Solicita uma pausa para que você possa revisar a lista antes de prosseguir com a clonagem
read -p "Pressione Enter para continuar com a clonagem..."

# Entra no diretório de trabalho
echo "Entrando no Workspace"
cd ~/Dev/ || exit

# Itera sobre a lista de URLs SSH dos repositórios e clona cada um
for repo in $repos; do
    repo_name=$(basename "$repo" .git)
    echo "Clonando $repo_name ..."
    git clone "$repo"
done

echo "Todos os repositórios foram clonados!"
