#!/bin/bash

# Função para verificar e fazer commit em um repositório git
check_and_commit() {
    cd "$1" || return
    if [[ -d ".git" ]]; then
        # Verifica todas as branches locais
        for branch in $(git branch | cut -c 3-); do
            git checkout "$branch" 2>/dev/null
            # Verifica se há alterações na branch
            if [[ $(git status --porcelain) ]]; then
                # Adiciona todas as alterações, faz o commit e push
                git add .
                git commit -m "Commit automático"
                git push origin "$branch"
                echo "Repositório $1 sincronizado"
            else
                echo "Nenhuma alteração para commit em $1"
            fi
        done
    fi

    # Verifica subdiretórios recursivamente, ignorando erros se não houver correspondências
    shopt -s nullglob
    for dir in */; do
        check_and_commit "$dir"
    done

    # Volta para o diretório pai
    cd ..
}

# Entrar na pasta workspace
cd ~/dados/workspace || exit

# Chamada inicial da função
check_and_commit "$(pwd)"

