#!/usr/bin/env python3

import subprocess
import os
import sys
from datetime import datetime

def executar_comando_tree(caminho_diretorio):
    # Executa o comando tree sem cores, organiza diretórios primeiro no caminho especificado
    comando = f"tree -n --dirsfirst {caminho_diretorio}"
    resultado = subprocess.run(comando, shell=True, text=True, capture_output=True)
    return resultado.stdout

def encontrar_arquivos(caminho_diretorio, extensoes):
    arquivos_encontrados = []
    for root, dirs, files in os.walk(caminho_diretorio):
        for file in files:
            # Inclui arquivos Dockerfile (com ou sem extensões) e arquivos com as extensões desejadas
            if file == "Dockerfile" or file.startswith("Dockerfile.") or any(file.endswith(ext) for ext in extensoes):
                arquivos_encontrados.append(os.path.join(root, file))
    return arquivos_encontrados

def ler_conteudo_arquivo(caminho_arquivo):
    try:
        with open(caminho_arquivo, "r", encoding="utf-8") as file:
            return file.read()
    except Exception as e:
        return f"Erro ao ler {caminho_arquivo}: {e}"

def gerar_documentacao(saida_tree, arquivos_documentados, caminho_diretorio):
    # Extrai o nome do diretório pai e gera um timestamp
    nome_diretorio = os.path.basename(os.path.normpath(caminho_diretorio))
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    nome_txt = f"{nome_diretorio}_{timestamp}.txt"

    # Cria o arquivo de documentação
    with open(nome_txt, "w", encoding="utf-8") as file:
        # Escreve a estrutura do diretório
        file.write("Estrutura de Diretórios:\n")
        file.write(saida_tree + "\n\n")

        # Escreve o conteúdo dos arquivos encontrados
        for arquivo, conteudo in arquivos_documentados.items():
            file.write(f"Arquivo: {arquivo}\n")
            file.write(conteudo + "\n")
            file.write("="*50 + "\n")  # Separador entre arquivos
    
    print(f"Documento gerado: {nome_txt}")

# Usa o diretório atual se nenhum caminho for passado como argumento
caminho_diretorio = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
extensoes_desejadas = [".py", ".js", ".css", ".html", ".sh", ".c", ".cpp", ".yml"]

# Executa o comando tree no caminho especificado
saida_tree = executar_comando_tree(caminho_diretorio)

# Encontra arquivos e lê o conteúdo
arquivos_encontrados = encontrar_arquivos(caminho_diretorio, extensoes_desejadas)
arquivos_documentados = {arquivo: ler_conteudo_arquivo(arquivo) for arquivo in arquivos_encontrados}

# Gera o arquivo de documentação com o nome do diretório e o timestamp
gerar_documentacao(saida_tree, arquivos_documentados, caminho_diretorio)
