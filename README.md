
# Documentação dos Scripts

Este projeto contém scripts úteis para facilitar o trabalho com VPNs e documentar projetos automaticamente. Abaixo está uma descrição detalhada de cada script, junto com instruções de configuração e uso.

## Estrutura do Diretório

```
/home/leonardo/Dev/meus_scripts
├── nvc.sh
├── README.md
└── tdoc.sh
```

### Scripts

#### 1. `nvc.sh`

Este script automatiza a configuração e a conexão com a VPN **NordVPN**. Ele funciona da seguinte forma:

1. **Verificação e Instalação**: Verifica se o NordVPN está instalado no sistema. Caso contrário, ele tenta instalar automaticamente:
   - Verifica a presença dos comandos `curl` ou `wget` para baixar o instalador do NordVPN.
   - Instala o `curl` se necessário, dependendo do sistema operacional.
   - Adiciona o usuário ao grupo `nordvpn`, exigindo reiniciar a sessão para efetivar as permissões.

2. **Conexão com VPN**:
   - O script apresenta um menu com algumas opções de localidade (`United Kingdom`, `Spain`, `Brazil`, e `Sair`).
   - Permite que o usuário escolha uma localidade para se conectar.
   - O usuário pode passar uma localidade como argumento ou escolher interativamente.
   - Caso o usuário selecione “Sair”, o script encerra.

Esse script facilita o processo de configuração e conexão com servidores VPN, especialmente para aqueles que utilizam o NordVPN.

#### 2. `tdoc.sh`

Este script em Python gera automaticamente um arquivo de documentação para a estrutura de diretórios e os conteúdos de arquivos específicos em um projeto. O funcionamento dele é:

1. **Estrutura do Diretório**: Utiliza o comando `tree` para exibir a estrutura do diretório no caminho especificado (ou no diretório atual, caso nenhum caminho seja passado como argumento).

2. **Identificação de Arquivos**: Procura arquivos com extensões específicas (como `.py`, `.js`, `.css`, `.html`, `.sh`, `.c`, `.cpp`, `.yml`) ou `Dockerfile` (com ou sem extensões).

3. **Leitura do Conteúdo dos Arquivos**: Lê o conteúdo dos arquivos encontrados e adiciona ao documento.

4. **Geração do Documento**:
   - Gera um arquivo de documentação com o nome `documentacao_projeto_<nome_do_diretorio>_<timestamp>.txt`.
   - Inclui a estrutura do diretório e o conteúdo dos arquivos encontrados, separados por divisores.

Esse script é útil para manter uma documentação atualizada da estrutura do projeto e dos arquivos de configuração, especialmente em projetos que envolvem várias linguagens e arquivos de configuração.

### Como Configurar e Executar os Scripts sem `./`

Para executar esses scripts diretamente sem o uso de `./`, você pode copiá-los para o diretório `~/.local/bin`, que geralmente está no `PATH` do usuário. Isso permite que você execute os scripts como comandos normais de qualquer local no sistema.

1. **Copiar os scripts para `~/.local/bin`:**
   ```bash
   cp /home/leonardo/Dev/meus_scripts/nvc.sh ~/.local/bin/nvc
   cp /home/leonardo/Dev/meus_scripts/tdoc.sh ~/.local/bin/tdoc
   ```

2. **Garantir permissões de execução:**
   ```bash
   chmod +x ~/.local/bin/nvc
   chmod +x ~/.local/bin/tdoc
   ```

3. **Executar os scripts**:
   Após a configuração, você poderá executá-los simplesmente digitando `nvc` ou `tdoc` no terminal:
   ```bash
   nvc       # Inicia o script de VPN
   tdoc      # Inicia o script de documentação
   ```

### Notas

- **Dependências**: Verifique se as dependências necessárias, como `nordvpn` (para `nvc.sh`) e `tree` (para `tdoc.sh`), estão instaladas no sistema.
- **Atualizações**: Caso você faça alterações nos scripts, será necessário copiá-los novamente para `~/.local/bin` para refletir as mudanças.

---

Este README fornece uma visão detalhada dos scripts e instruções para torná-los facilmente acessíveis no sistema.
