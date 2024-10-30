#!/bin/bash

# Verifica se o NordVPN está instalado
if ! command -v nordvpn &> /dev/null; then
    echo "NordVPN não está instalado. Instalando agora..."

    # Verifica se o curl ou wget está instalado, caso contrário instala o curl
    if command -v curl &> /dev/null; then
        sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
    elif command -v wget &> /dev/null; then
        sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)
    else
        echo "Nem curl nem wget foram encontrados. Instalando curl..."
        if [ -f /etc/debian_version ]; then
            sudo apt update && sudo apt install -y curl
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y curl
        else
            echo "Sistema operacional não suportado para instalação automática de curl. Por favor, instale-o manualmente."
            exit 1
        fi
        # Instala o NordVPN após instalar o curl
        sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
    fi

    # Configuração pós-instalação
    sudo usermod -aG nordvpn $USER
    echo "Instalação do NordVPN concluída. Reinicie a sessão para que as permissões de grupo tenham efeito."
    exit 0
fi

# Lista de localidades
localidades=("United_Kingdom" "Spain" "Brazil" "Sair")

# Função para exibir o menu
mostrar_menu() {
    echo "Selecione a localidade para conectar:"
    for i in "${!localidades[@]}"; do
        echo "$((i + 1)) - ${localidades[$i]}"
    done
}

# Função para conectar à localidade selecionada
conectar_localidade() {
    local localidade=${localidades[$1]}
    if [ "$localidade" == "Sair" ]; then
        echo "Saindo do script."
        exit 0
    else
        echo "Conectando à VPN em $localidade..."
        nordvpn connect "$localidade"
    fi
}

# Verifica se um argumento foi fornecido
if [ -z "$1" ]; then
    while true; do
        mostrar_menu
        read -p "Digite o número da localidade: " escolha

        # Verifica se o argumento é um número válido
        if ! [[ "$escolha" =~ ^[0-9]+$ ]]; then
            echo "Erro: O argumento deve ser um número."
            continue
        fi

        # Verifica se o número está dentro do intervalo das localidades
        if [ "$escolha" -le 0 ] || [ "$escolha" -gt "${#localidades[@]}" ]; then
            echo "Erro: Número inválido. Selecione um número entre 1 e ${#localidades[@]}."
            continue
        fi

        # Conecta à localidade selecionada ou sai
        conectar_localidade $((escolha - 1))
        break
    done
else
    # Verifica se o argumento é um número válido
    if ! [[ "$1" =~ ^[0-9]+$ ]]; then
        echo "Erro: O argumento deve ser um número."
        mostrar_menu
        exit 1
    fi

    # Verifica se o número está dentro do intervalo das localidades
    if [ "$1" -le 0 ] || [ "$1" -gt "${#localidades[@]}" ]; then
        echo "Erro: Número inválido. Selecione um número entre 1 e ${#localidades[@]}."
        mostrar_menu
        exit 1
    fi

    # Conecta à localidade selecionada ou sai
    conectar_localidade $(( $1 - 1 ))
fi
