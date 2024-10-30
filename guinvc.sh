#!/bin/bash

# Arquivo que contém as localidades
localidades_file="$HOME/.localidades"

# Carrega as localidades a partir do arquivo
if [ -f "$localidades_file" ]; then
    mapfile -t localidades < "$localidades_file"
else
    localidades=("United_Kingdom" "Spain" "Brazil")
fi

# Função para exibir a janela principal
mostrar_menu() {
    while true; do
        escolha=$(zenity --list --title="Menu Principal" --column="Opções" "Conectar à VPN" "Adicionar Localidade" "Remover Localidade" --width=600 --height=600)
        
        case $escolha in
            "Conectar à VPN")
                selecionar_localidade ;;
            "Adicionar Localidade")
                adicionar_localidade ;;
            "Remover Localidade")
                remover_localidade ;;
            "Fechar" | *)
                exit 0 ;;
        esac
    done
}

# Função para exibir a lista de localidades para conexão
selecionar_localidade() {
    localidade=$(zenity --list --title="Selecione a localidade para conectar" --column="Localidades" "${localidades[@]}" --width=600 --height=600)
    
    if [ -n "$localidade" ]; then
        zenity --info --text="Conectando à VPN em $localidade..." --width=300 --height=150
        nordvpn connect "$localidade"
    fi
}

# Função para adicionar uma nova localidade
adicionar_localidade() {
    nova_localidade=$(zenity --entry --title="Adicionar Localidade" --text="Digite o nome da nova localidade:" --width=600 --height=150)
    
    if [ -n "$nova_localidade" ]; then
        localidades+=("$nova_localidade")
        salvar_localidades
        zenity --info --text="Localidade $nova_localidade adicionada com sucesso!" --width=300 --height=150
    fi
}

# Função para remover uma localidade existente
remover_localidade() {
    while true; do
        localidade=$(zenity --list --title="Remover Localidade" --column="Localidades" "${localidades[@]}" --extra-button="Voltar" --width=600 --height=600)
        
        if [[ "$localidade" == "Voltar" ]]; then
            break
        fi

        if [ -n "$localidade" ]; then
            localidades=("${localidades[@]/$localidade}")
            salvar_localidades
            zenity --info --text="Localidade $localidade removida com sucesso!" --width=300 --height=150
        fi
    done
}

# Função para salvar as localidades no arquivo
salvar_localidades() {
    printf "%s\n" "${localidades[@]}" > "$localidades_file"
}

# Exibe o menu principal
mostrar_menu
