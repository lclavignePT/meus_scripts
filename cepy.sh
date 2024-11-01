#!/bin/bash

# Verificar se o caminho do projeto foi fornecido como parâmetro
if [[ -z "$1" ]]; then
    echo "Erro: Você deve fornecer o caminho da pasta do projeto como argumento."
    echo "Uso: $0 /caminho/para/pasta_do_projeto"
    exit 1
fi

# Caminho do projeto
project_path="$1"

# Verificar se a pasta existe; se não, criar a pasta
if [[ -d "$project_path" ]]; then
    echo "Pasta do projeto encontrada em: $project_path"
else
    echo "Pasta do projeto não encontrada. Criando pasta em: $project_path"
    mkdir -p "$project_path" || { echo "Erro ao criar a pasta do projeto."; exit 1; }
fi

# Entrar na pasta do projeto
pushd "$project_path" || { echo "Erro ao acessar a pasta do projeto."; exit 1; }

# Função para verificar e instalar Python 3
check_install_python() {
    if command -v python3 &>/dev/null; then
        echo "Python 3 já está instalado: $(python3 --version)"
        return 0
    else
        echo "Python 3 não está instalado no sistema."
        read -p "Deseja instalar o Python 3? (s/n): " install_python

        if [[ "$install_python" == "s" || "$install_python" == "S" ]]; then
            echo -e "\nComandos que serão executados para instalar o Python 3:"
            echo "1. sudo apt update"
            echo "2. sudo apt install -y python3"
            read -p "Confirmar instalação do Python 3? (s/n): " confirm_python_install

            if [[ "$confirm_python_install" == "s" || "$confirm_python_install" == "S" ]]; then
                echo "Atualizando repositórios..."
                sudo apt update
                echo "Instalando Python 3..."
                sudo apt install -y python3
                echo "Python 3 foi instalado com sucesso."
            else
                echo "Instalação do Python 3 cancelada pelo usuário."
            fi
        else
            echo "Instalação do Python 3 foi cancelada."
        fi
    fi
}

# Função para verificar e instalar o pyenv
check_install_pyenv() {
    if command -v pyenv &>/dev/null; then
        echo "pyenv já está instalado: $(pyenv --version)"
    else
        echo "pyenv não está instalado."
        read -p "Deseja instalar o pyenv para gerenciar versões do Python? (s/n): " install_pyenv

        if [[ "$install_pyenv" == "s" || "$install_pyenv" == "S" ]]; then
            echo -e "\nComandos que serão executados para instalar o pyenv:"
            echo "1. sudo apt update"
            echo "2. sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl git"
            echo "3. curl https://pyenv.run | bash"
            echo "4. Configuração do PATH e inicialização do pyenv no bash"
            read -p "Confirmar instalação do pyenv? (s/n): " confirm_pyenv_install

            if [[ "$confirm_pyenv_install" == "s" || "$confirm_pyenv_install" == "S" ]]; then
                echo "Instalando dependências para o pyenv..."
                sudo apt update
                sudo apt install -y make build-essential libssl-dev zlib1g-dev \
                    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                    libncurses5-dev libncursesw5-dev xz-utils tk-dev \
                    libffi-dev liblzma-dev python-openssl git

                echo "Instalando o pyenv..."
                curl https://pyenv.run | bash

                # Adicionar pyenv ao caminho
                export PATH="$HOME/.pyenv/bin:$PATH"
                eval "$(pyenv init --path)"
                eval "$(pyenv init -)"

                # Adicionar pyenv ao perfil do shell
                echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
                echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
                echo 'eval "$(pyenv init -)"' >> ~/.bashrc

                echo "Instalação do pyenv concluída. Reinicie o terminal ou execute 'source ~/.bashrc' para ativar o pyenv."
            else
                echo "Instalação do pyenv cancelada pelo usuário."
            fi
        else
            echo "Instalação do pyenv foi cancelada."
        fi
    fi
}

# Função para definir uma versão específica do Python no projeto
set_python_version() {
    if [[ -f .python-version ]]; then
        current_version=$(cat .python-version)
        echo "Uma versão do Python já está configurada para este diretório: $current_version"
        read -p "Deseja sobrescrever essa versão com uma nova? (s/n): " overwrite_version
        if [[ "$overwrite_version" != "s" && "$overwrite_version" != "S" ]]; then
            echo "Configuração de versão mantida. Nenhuma alteração foi feita."
            return 0
        fi
    else
        current_version=$(python3 --version 2>/dev/null || echo "Python não encontrado")
    fi

    echo "Listando versões disponíveis no pyenv..."
    pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+' 

    read -p "Digite a versão do Python que deseja instalar e usar no projeto (ex: 3.8.12): " python_version

    if [[ -z "$python_version" ]]; then
        echo "Nenhuma versão foi especificada."
        echo "Versão \"$current_version\" foi definida como padrão para este diretório."
        return 0
    fi

    if ! pyenv install --list | grep -q -w "$python_version"; then
        echo "Erro: A versão $python_version não é válida ou não está disponível no pyenv."
        echo "Por favor, verifique a lista e tente novamente."
        return 1
    fi

    echo -e "\nComandos que serão executados para configurar a versão $python_version:"
    echo "1. Verificar se a versão $python_version está instalada."
    echo "2. Se necessário, instalar a versão com 'pyenv install $python_version'."
    echo "3. Definir a versão para o diretório atual com 'pyenv local $python_version'."
    read -p "Deseja continuar com esses comandos? (s/n): " confirm_commands

    if [[ "$confirm_commands" != "s" && "$confirm_commands" != "S" ]]; then
        echo "Configuração de versão cancelada pelo usuário."
        return 0
    fi

    if ! pyenv versions | grep -q "$python_version"; then
        echo "Instalando Python $python_version..."
        pyenv install "$python_version" || { echo "Erro ao instalar a versão $python_version."; return 1; }
    fi

    pyenv local "$python_version" && echo "Versão $python_version foi definida como padrão para este diretório."
}

# Função para criar um ambiente virtual
create_virtualenv() {
    echo -e "\nEscolha uma ferramenta para criar o ambiente virtual:"
    echo "1. venv (forma nativa do Python)"
    echo "2. virtualenv"
    echo "3. pipenv"
    echo "4. poetry"
    echo "5. Voltar ao menu anterior"
    echo "6. Sair"
    read -p "Escolha uma opção: " env_option

    case $env_option in
        1)
            echo "Criando o ambiente virtual com venv..."
            python3 -m venv env
            ;;
        2)
            pip install virtualenv
            virtualenv env
            ;;
        3)
            pip install pipenv
            pipenv --python "$(python3 --version | awk '{print $2}')"
            ;;
        4)
            pip install poetry
            poetry init --no-interaction
            poetry install
            ;;
        5)
            version_menu
            return
            ;;
        6)
            echo "Saindo do script."
            exit 0
            ;;
        *)
            echo "Opção inválida. Por favor, escolha uma opção válida."
            create_virtualenv
            return
            ;;
    esac

    # Informar os comandos para ativar e desativar o ambiente virtual
    echo "Ambiente virtual criado com sucesso em '$project_path'."
    echo "Para ativar o ambiente virtual, use o seguinte comando:"
    case $env_option in
        1 | 2)
            echo "source env/bin/activate"
            echo "Para desativar, use: source deactivate"
            ;;
        3)
            echo "pipenv shell"
            echo "Para desativar, use: exit"
            ;;
        4)
            echo "poetry shell"
            echo "Para desativar, use: exit"
            ;;
    esac
}


# Menu principal
main_menu() {
    echo -e "\nMenu de Configuração de Ambiente Python"
    echo "1. Verificar e instalar Python 3"
    echo "2. Sair"
    read -p "Escolha uma opção: " option

    case $option in
        1)
            check_install_python
            if command -v python3 &>/dev/null; then
                pyenv_menu
            fi
            ;;
        2)
            echo "Saindo do script."
            exit 0
            ;;
        *)
            echo "Opção inválida. Por favor, escolha uma opção válida."
            main_menu
            ;;
    esac
}

# Submenu para instalar o pyenv
pyenv_menu() {
    echo -e "\nConfiguração de Gerenciamento de Versões Python"
    echo "1. Verificar e instalar pyenv"
    echo "2. Voltar ao menu anterior"
    echo "3. Sair"
    read -p "Escolha uma opção: " option

    case $option in
        1)
            check_install_pyenv
            if command -v pyenv &>/dev/null; then
                version_menu
            fi
            ;;
        2)
            main_menu
            ;;
        3)
            echo "Saindo do script."
            exit 0
            ;;
        *)
            echo "Opção inválida. Por favor, escolha uma opção válida."
            pyenv_menu
            ;;
    esac
}

# Submenu para definir a versão do Python
version_menu() {
    echo -e "\nDefinir Versão do Python para o Projeto"
    echo "1. Definir uma versão específica do Python"
    echo "2. Voltar ao menu anterior"
    echo "3. Sair"
    read -p "Escolha uma opção: " option

    case $option in
        1)
            set_python_version
            env_menu
            ;;
        2)
            pyenv_menu
            ;;
        3)
            echo "Saindo do script."
            exit 0
            ;;
        *)
            echo "Opção inválida. Por favor, escolha uma opção válida."
            version_menu
            ;;
    esac
}

# Submenu para criar ambiente virtual
env_menu() {
    echo -e "\nConfiguração do Ambiente Virtual"
    echo "1. Criar ambiente virtual"
    echo "2. Voltar ao menu anterior"
    echo "3. Sair"
    read -p "Escolha uma opção: " option

    case $option in
        1)
            create_virtualenv
            ;;
        2)
            version_menu
            ;;
        3)
            echo "Saindo do script."
            exit 0
            ;;
        *)
            echo "Opção inválida. Por favor, escolha uma opção válida."
            env_menu
            ;;
    esac
}

# Executar o menu principal
main_menu

# Garantir que o script finaliza no diretório do projeto
exec $SHELL