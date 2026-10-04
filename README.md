# Automação de Instalação (TI)

Este repositório contém uma automação para facilitar e padronizar a instalação de softwares em máquinas da empresa, executando os instaladores de forma limpa e silenciosa em segundo plano.

## Como funciona?

A estrutura principal é dividida em dois componentes principais:

1. **`ExecutarInstalador.bat`**: É o ponto de entrada da automação. Sua principal função é invocar o script PowerShell garantindo que as políticas de restrição de scripts do sistema (ExecutionPolicy) sejam ignoradas (bypass). Isso evita erros de permissão de execução locais na máquina.
2. **Script PowerShell (`Instalar-Programas.ps1`)**: O script em si. Logo no início da execução, ele solicita as credenciais do usuário administrador. A partir desse momento, ele utiliza essa elevação de privilégio para acessar e executar todos os instaladores disponíveis dentro da pasta `Instaladores/` em segundo plano (silent install).

## Estrutura de Pastas

Para não sobrecarregar o repositório no GitHub, os arquivos binários pesados não estão incluídos aqui. Você deve colocar os executáveis manualmente antes de rodar:

- **`Instaladores/`**: Coloque os arquivos `.exe` (ou `.msi`) dos programas que deseja instalar (ex: Chrome, Adobe, Office) dentro desta pasta.
- **`Logs/`**: Pasta onde o script salvará os relatórios de instalação (ex: `Instalacao-NOMEPC-DATA.log`) detalhando o que foi instalado e possíveis erros.

## Como Usar

1. Baixe este repositório para o computador ou pendrive.
2. Adicione os instaladores desejados dentro da pasta `Instaladores/`.
3. Dê um duplo-clique no arquivo `ExecutarInstalador.bat`.
4. Insira a senha de administrador quando o PowerShell solicitar.
5. Aguarde a finalização da execução.
