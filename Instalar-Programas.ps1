# ============================================================
# INSTALADOR DE POS-FORMATACAO - TI
# ============================================================

Clear-Host

# ============================================================
# CONFIGURACAO
# ============================================================

$PastaBase = Split-Path -Parent $MyInvocation.MyCommand.Path

$PastaInstaladores = Join-Path $PastaBase "Instaladores"

$PastaLogs = Join-Path $PastaBase "Logs"

# Tempo maximo para um instalador permanecer ativo
$TimeoutInstalador = 300

# Quantidade maxima de instaladores simultaneos
$LimiteSimultaneo = 2

# ============================================================
# CRIAR PASTA DE LOG
# ============================================================

if (-not (Test-Path $PastaLogs)) {

    New-Item `
        -ItemType Directory `
        -Path $PastaLogs `
        -Force | Out-Null
}

# ============================================================
# ARQUIVO DE LOG
# ============================================================

$NomeLog = "Instalacao-$($env:COMPUTERNAME)-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

$ArquivoLog = Join-Path $PastaLogs $NomeLog

# ============================================================
# PROGRAMAS
# ============================================================

$Programas = @(

    [PSCustomObject]@{
        Nome            = "Adobe Acrobat Pro DC"
        Arquivo         = "Adobe.Acrobat.Pro.DC.v2023.001.20085 (1).exe"
        Argumentos      = ""
        Habilitado      = $true
        Processo        = ""
        ProcessoAux     = ""
        DetectarPor     = "Adobe"
    },

    [PSCustomObject]@{
        Nome            = "AnyDesk"
        Arquivo         = "AnyDesk.exe"
        Argumentos      = ""
        Habilitado      = $true
        Processo        = "AnyDesk"
        ProcessoAux     = "AnyDesk"
        DetectarPor     = "AnyDesk"
    },

    [PSCustomObject]@{
        Nome            = "Google Chrome"
        Arquivo         = "ChromeSetup.exe"
        Argumentos      = "/silent /install"
        Habilitado      = $true
        Processo        = "chrome"
        ProcessoAux     = "chrome"
        DetectarPor     = "Chrome"
    },

    [PSCustomObject]@{
        Nome            = "FortiClient VPN"
        Arquivo         = "FortiClientVPNInstaller.exe"
        Argumentos      = ""
        Habilitado      = $true
        Processo        = "FortiClient"
        ProcessoAux     = "FortiClient"
        DetectarPor     = "FortiClient"
    },

    [PSCustomObject]@{
        Nome            = "Microsoft Office"
        Arquivo         = "OfficeSetup.exe"
        Argumentos      = ""
        Habilitado      = $true
        Processo        = "OfficeClickToRun"
        ProcessoAux     = "OfficeC2RClient"
        DetectarPor     = "Office"
    },

    [PSCustomObject]@{
        Nome            = "ScreenRec"
        Arquivo         = "ScreenRec_webinstall_all.exe"
        Argumentos      = ""
        Habilitado      = $true
        Processo        = "ScreenRec"
        ProcessoAux     = "ScreenRec"
        DetectarPor     = "ScreenRec"
    }

)

# ============================================================
# GOOGLE CHAT
# ============================================================

$GoogleChatHabilitado = $true

$GoogleChatURL = "https://chat.google.com"

# ============================================================
# RESULTADOS
# ============================================================

$Resultados = @()

# ============================================================
# FUNCAO DE LOG
# ============================================================

function Escrever-Log {

    param (
        [string]$Mensagem
    )

    $DataHora = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $Linha = "[$DataHora] $Mensagem"

    Add-Content `
        -Path $ArquivoLog `
        -Value $Linha

    Write-Host $Linha
}

# ============================================================
# VERIFICAR ADMINISTRADOR
# ============================================================

function Testar-Administrador {

    $Identidade = [Security.Principal.WindowsIdentity]::GetCurrent()

    $Principal = New-Object Security.Principal.WindowsPrincipal($Identidade)

    return $Principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

# ============================================================
# PREPARAR AMBIENTE
# ============================================================

function Preparar-Ambiente {

    Clear-Host

    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "     INSTALADOR DE POS-FORMATACAO TI" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Computador : $env:COMPUTERNAME"
    Write-Host "Usuario    : $env:USERNAME"
    Write-Host "Pasta      : $PastaBase"
    Write-Host ""

    if (-not (Testar-Administrador)) {

        Write-Host "ERRO: O PowerShell nao esta como administrador." -ForegroundColor Red

        Escrever-Log "ERRO: Sem privilegios administrativos."

        Pause

        exit
    }

    Escrever-Log "Privilegios administrativos confirmados."

    if (-not (Test-Path $PastaInstaladores)) {

        Write-Host "ERRO: Pasta Instaladores nao encontrada." -ForegroundColor Red

        Escrever-Log "ERRO: Pasta Instaladores nao encontrada."

        Pause

        exit
    }

    Escrever-Log "Pasta de instaladores encontrada."
}

# ============================================================
# DETECTAR PROCESSO
# ============================================================

function Testar-ProcessoPrograma {

    param (
        [string]$NomeProcesso
    )

    if ([string]::IsNullOrWhiteSpace($NomeProcesso)) {

        return $false
    }

    $Processo = Get-Process `
        -Name $NomeProcesso `
        -ErrorAction SilentlyContinue

    return ($null -ne $Processo)
}

# ============================================================
# DETECTAR INSTALACAO
# ============================================================

function Testar-ProgramaInstalado {

    param (
        [PSCustomObject]$Programa
    )

    switch ($Programa.DetectarPor) {

        "AnyDesk" {

            $Caminhos = @(
                "$env:ProgramFiles\AnyDesk\AnyDesk.exe",
                "${env:ProgramFiles(x86)}\AnyDesk\AnyDesk.exe",
                "$env:ProgramData\AnyDesk\AnyDesk.exe",
                "$env:APPDATA\AnyDesk\AnyDesk.exe"
            )

            foreach ($Caminho in $Caminhos) {

                if (Test-Path $Caminho) {

                    return $true
                }
            }

            return (Testar-ProcessoPrograma "AnyDesk")
        }

        "ScreenRec" {

            $Caminhos = @(
                "$env:ProgramFiles\ScreenRec\ScreenRec.exe",
                "${env:ProgramFiles(x86)}\ScreenRec\ScreenRec.exe",
                "$env:LOCALAPPDATA\ScreenRec\ScreenRec.exe",
                "$env:APPDATA\ScreenRec\ScreenRec.exe"
            )

            foreach ($Caminho in $Caminhos) {

                if (Test-Path $Caminho) {

                    return $true
                }
            }

            return (Testar-ProcessoPrograma "ScreenRec")
        }

        "Chrome" {

            $Caminhos = @(
                "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
                "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
            )

            foreach ($Caminho in $Caminhos) {

                if (Test-Path $Caminho) {

                    return $true
                }
            }

            return $false
        }

        "FortiClient" {

            $Caminhos = @(
                "$env:ProgramFiles\Fortinet\FortiClient\FortiClient.exe",
                "${env:ProgramFiles(x86)}\Fortinet\FortiClient\FortiClient.exe"
            )

            foreach ($Caminho in $Caminhos) {

                if (Test-Path $Caminho) {

                    return $true
                }
            }

            return (
                (Testar-ProcessoPrograma "FortiClient") -or
                (Testar-ProcessoPrograma "FortiTray")
            )
        }

        "Office" {

            $Caminhos = @(
                "$env:ProgramFiles\Microsoft Office\root\Office16\WINWORD.EXE",
                "${env:ProgramFiles(x86)}\Microsoft Office\root\Office16\WINWORD.EXE"
            )

            foreach ($Caminho in $Caminhos) {

                if (Test-Path $Caminho) {

                    return $true
                }
            }

            return $false
        }

        "Adobe" {

            $Caminhos = @(
                "$env:ProgramFiles\Adobe\Acrobat DC\Acrobat\Acrobat.exe",
                "${env:ProgramFiles(x86)}\Adobe\Acrobat DC\Acrobat\Acrobat.exe"
            )

            foreach ($Caminho in $Caminhos) {

                if (Test-Path $Caminho) {

                    return $true
                }
            }

            return (
                (Testar-ProcessoPrograma "Acrobat") -or
                (Testar-ProcessoPrograma "AcroRd32")
            )
        }
    }

    return $false
}

# ============================================================
# INICIAR INSTALADOR
# ============================================================

function Iniciar-Instalador {

    param (
        [PSCustomObject]$Programa
    )

    $Caminho = Join-Path `
        $PastaInstaladores `
        $Programa.Arquivo

    if (-not (Test-Path $Caminho)) {

        Write-Host ""
        Write-Host "ERRO: $($Programa.Nome)" -ForegroundColor Red
        Write-Host "Arquivo nao encontrado:" -ForegroundColor Red
        Write-Host $Caminho

        Escrever-Log "ERRO: arquivo nao encontrado: $Caminho"

        return $null
    }

    try {

        Write-Host ""
        Write-Host "Iniciando: $($Programa.Nome)" -ForegroundColor Yellow

        Escrever-Log "Iniciando instalador: $($Programa.Nome)"

        if ([string]::IsNullOrWhiteSpace($Programa.Argumentos)) {

            $Processo = Start-Process `
                -FilePath $Caminho `
                -PassThru
        }
        else {

            $Processo = Start-Process `
                -FilePath $Caminho `
                -ArgumentList $Programa.Argumentos `
                -PassThru
        }

        Escrever-Log "PID inicial de $($Programa.Nome): $($Processo.Id)"

        return $Processo
    }
    catch {

        Write-Host "ERRO ao iniciar $($Programa.Nome)" -ForegroundColor Red

        Escrever-Log "ERRO ao iniciar $($Programa.Nome): $($_.Exception.Message)"

        return $null
    }
}

# ============================================================
# AGUARDAR INSTALADOR
# ============================================================

function Aguardar-Instalador {

    param (
        [PSCustomObject]$Programa,
        [System.Diagnostics.Process]$Processo
    )

    Write-Host ""
    Write-Host "Aguardando: $($Programa.Nome)" -ForegroundColor Cyan

    $Tempo = 0

    while ($Tempo -lt $TimeoutInstalador) {

        # ----------------------------------------------------
        # VERIFICAR SE JA ESTA INSTALADO
        # ----------------------------------------------------

        if (Testar-ProgramaInstalado -Programa $Programa) {

            Write-Host ""
            Write-Host "$($Programa.Nome): INSTALADO" -ForegroundColor Green

            Escrever-Log "INSTALADO: $($Programa.Nome)"

            return "Sucesso"
        }

        # ----------------------------------------------------
        # VERIFICAR PROCESSO ORIGINAL
        # ----------------------------------------------------

        if ($Processo -ne $null) {

            try {

                if ($Processo.HasExited) {

                    $Codigo = $Processo.ExitCode

                    Write-Host ""
                    Write-Host "Processo finalizado - Codigo: $Codigo"

                    Escrever-Log "$($Programa.Nome) processo finalizado - Codigo: $Codigo"

                    # Dar alguns segundos para processos filhos
                    # terminarem de registrar a instalacao.

                    Start-Sleep -Seconds 5

                    if (Testar-ProgramaInstalado -Programa $Programa) {

                        Write-Host "$($Programa.Nome): INSTALADO" -ForegroundColor Green

                        Escrever-Log "INSTALADO apos finalizacao: $($Programa.Nome)"

                        return "Sucesso"
                    }

                    # Codigo 0 ou 3010 normalmente indica sucesso
                    if ($Codigo -eq 0 -or $Codigo -eq 3010) {

                        Write-Host "$($Programa.Nome): FINALIZADO" -ForegroundColor Green

                        Escrever-Log "$($Programa.Nome) finalizado com codigo $Codigo."

                        return "Sucesso"
                    }

                    # AnyDesk e ScreenRec podem usar instaladores
                    # auxiliares/processos filhos.
                    if (
                        $Programa.DetectarPor -eq "AnyDesk" -or
                        $Programa.DetectarPor -eq "ScreenRec"
                    ) {

                        Write-Host "$($Programa.Nome): processo terminou, verificando instalacao..." -ForegroundColor Yellow

                        Start-Sleep -Seconds 5

                        if (Testar-ProgramaInstalado -Programa $Programa) {

                            Write-Host "$($Programa.Nome): INSTALADO" -ForegroundColor Green

                            return "Sucesso"
                        }
                    }

                    Write-Host "$($Programa.Nome): FALHA - Codigo $Codigo" -ForegroundColor Red

                    Escrever-Log "FALHA: $($Programa.Nome) - Codigo $Codigo"

                    return "Falha"
                }

            }
            catch {
            }
        }

        # ----------------------------------------------------
        # STATUS
        # ----------------------------------------------------

        Write-Host "." -NoNewline

        Start-Sleep -Seconds 2

        $Tempo += 2
    }

    # ========================================================
    # TIMEOUT
    # ========================================================

    Write-Host ""

    Write-Host "TIMEOUT: $($Programa.Nome)" -ForegroundColor Yellow

    Escrever-Log "TIMEOUT: $($Programa.Nome)"

    # Ultima verificacao
    Start-Sleep -Seconds 3

    if (Testar-ProgramaInstalado -Programa $Programa) {

        Write-Host "$($Programa.Nome): INSTALADO" -ForegroundColor Green

        Escrever-Log "$($Programa.Nome) detectado como instalado apos timeout."

        return "Sucesso"
    }

    Write-Host "$($Programa.Nome): NAO FOI POSSIVEL CONFIRMAR" -ForegroundColor Yellow

    Escrever-Log "$($Programa.Nome) nao pode ser confirmado."

    return "Verificacao"
}

# ============================================================
# INSTALAR LOTE
# ============================================================

function Instalar-Lote {

    param (
        [array]$Lote
    )

    $Processos = @()

    Write-Host ""
    Write-Host "============================================" -ForegroundColor DarkCyan
    Write-Host "             NOVO LOTE" -ForegroundColor DarkCyan
    Write-Host "============================================" -ForegroundColor DarkCyan

    foreach ($Programa in $Lote) {

        Write-Host " -> $($Programa.Nome)" -ForegroundColor Yellow
    }

    Write-Host ""

    # ========================================================
    # INICIAR TODOS DO LOTE
    # ========================================================

    foreach ($Programa in $Lote) {

        $Processo = Iniciar-Instalador -Programa $Programa

        if ($null -ne $Processo) {

            $Processos += [PSCustomObject]@{
                Programa = $Programa
                Processo = $Processo
            }
        }
        else {

            $Resultados += [PSCustomObject]@{
                Programa = $Programa.Nome
                Resultado = "Falha ao iniciar"
            }
        }

        Start-Sleep -Seconds 2
    }

    # ========================================================
    # AGUARDAR OS PROGRAMAS
    # ========================================================

    foreach ($Item in $Processos) {

        $Resultado = Aguardar-Instalador `
            -Programa $Item.Programa `
            -Processo $Item.Processo

        $Resultados += [PSCustomObject]@{
            Programa = $Item.Programa.Nome
            Resultado = $Resultado
        }
    }

    Write-Host ""
    Write-Host "Lote finalizado." -ForegroundColor Green

    Start-Sleep -Seconds 3
}

# ============================================================
# INSTALAR TODOS
# ============================================================

function Instalar-Todos {

    Clear-Host

    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "     INSTALACAO - 2 PROGRAMAS POR VEZ" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    Escrever-Log "Inicio da instalacao completa."

    $ProgramasAtivos = @(
        $Programas | Where-Object {
            $_.Habilitado -eq $true
        }
    )

    $Total = $ProgramasAtivos.Count

    # ========================================================
    # CRIAR LOTES DE 2
    # ========================================================

    for ($i = 0; $i -lt $Total; $i += $LimiteSimultaneo) {

        $Fim = [Math]::Min(
            $i + $LimiteSimultaneo - 1,
            $Total - 1
        )

        $Lote = @(
            $ProgramasAtivos[$i..$Fim]
        )

        Instalar-Lote -Lote $Lote
    }

    # ========================================================
    # GOOGLE CHAT
    # ========================================================

    if ($GoogleChatHabilitado) {

        Write-Host ""
        Write-Host "Configurando Google Chat..." -ForegroundColor Cyan

        Configurar-GoogleChat
    }

    # ========================================================
    # RESUMO
    # ========================================================

    Mostrar-ResultadoFinal
}

# ============================================================
# VERIFICAR INSTALADORES
# ============================================================

function Verificar-Instaladores {

    Clear-Host

    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "       VERIFICACAO DOS INSTALADORES" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    foreach ($Programa in $Programas) {

        $Caminho = Join-Path `
            $PastaInstaladores `
            $Programa.Arquivo

        if (Test-Path $Caminho) {

            Write-Host "[OK] $($Programa.Nome)" -ForegroundColor Green

        }
        else {

            Write-Host "[ERRO] $($Programa.Nome)" -ForegroundColor Red

            Write-Host "       $($Programa.Arquivo)" -ForegroundColor DarkGray
        }
    }

    Write-Host ""

    Pause
}

# ============================================================
# CONFIGURAR GOOGLE CHAT
# ============================================================

function Configurar-GoogleChat {

    Write-Host ""
    Write-Host "Configurando Google Chat..." -ForegroundColor Yellow

    Escrever-Log "Configurando Google Chat."

    $ChromePossiveis = @(

        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",

        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",

        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"

    )

    $Chrome = $null

    foreach ($Caminho in $ChromePossiveis) {

        if (Test-Path $Caminho) {

            $Chrome = $Caminho

            break
        }
    }

    if ($null -eq $Chrome) {

        Write-Host "Chrome nao encontrado." -ForegroundColor Red

        Escrever-Log "ERRO: Chrome nao encontrado."

        return
    }

    try {

        Start-Process `
            -FilePath $Chrome `
            -ArgumentList "--app=$GoogleChatURL"

        Write-Host "Google Chat iniciado." -ForegroundColor Green

        Escrever-Log "Google Chat iniciado."

    }
    catch {

        Write-Host "Erro ao iniciar Google Chat." -ForegroundColor Red

        Escrever-Log "ERRO Google Chat: $($_.Exception.Message)"
    }
}

# ============================================================
# RESULTADO FINAL
# ============================================================

function Mostrar-ResultadoFinal {

    Clear-Host

    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "           RESULTADO DA INSTALACAO" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    foreach ($Resultado in $Resultados) {

        switch ($Resultado.Resultado) {

            "Sucesso" {

                Write-Host "[OK]      $($Resultado.Programa)" -ForegroundColor Green
            }

            "Falha" {

                Write-Host "[FALHA]   $($Resultado.Programa)" -ForegroundColor Red
            }

            default {

                Write-Host "[ATENCAO] $($Resultado.Programa)" -ForegroundColor Yellow
            }
        }
    }

    Write-Host ""

    $QuantidadeSucesso = @(
        $Resultados | Where-Object {
            $_.Resultado -eq "Sucesso"
        }
    ).Count

    $QuantidadeFalha = @(
        $Resultados | Where-Object {
            $_.Resultado -eq "Falha"
        }
    ).Count

    Write-Host "Total processado : $($Resultados.Count)"
    Write-Host "Sucesso          : $QuantidadeSucesso"
    Write-Host "Falhas           : $QuantidadeFalha"
    Write-Host ""

    Escrever-Log "============================================"
    Escrever-Log "RESULTADO FINAL"
    Escrever-Log "Total: $($Resultados.Count)"
    Escrever-Log "Sucesso: $QuantidadeSucesso"
    Escrever-Log "Falhas: $QuantidadeFalha"
    Escrever-Log "============================================"

    Pause
}

# ============================================================
# SELECIONAR PROGRAMA
# ============================================================

function Selecionar-Programas {

    while ($true) {

        Clear-Host

        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "             INSTALAR PROGRAMA" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""

        $Indice = 1

        foreach ($Programa in $Programas) {

            if ($Programa.Habilitado) {

                Write-Host "$Indice - $($Programa.Nome)"

                $Indice++
            }
        }

        Write-Host ""
        Write-Host "0 - Voltar"
        Write-Host ""

        $Escolha = Read-Host "Digite o numero"

        if ($Escolha -eq "0") {

            return
        }

        $ProgramasHabilitados = @(
            $Programas | Where-Object {
                $_.Habilitado -eq $true
            }
        )

        $Numero = 0

        if ([int]::TryParse($Escolha, [ref]$Numero)) {

            if (
                $Numero -ge 1 -and
                $Numero -le $ProgramasHabilitados.Count
            ) {

                $ProgramaSelecionado = $ProgramasHabilitados[$Numero - 1]

                $Processo = Iniciar-Instalador `
                    -Programa $ProgramaSelecionado

                if ($null -ne $Processo) {

                    Aguardar-Instalador `
                        -Programa $ProgramaSelecionado `
                        -Processo $Processo
                }

                Write-Host ""

                Pause
            }
            else {

                Write-Host ""
                Write-Host "Opcao invalida." -ForegroundColor Red

                Start-Sleep -Seconds 2
            }
        }
        else {

            Write-Host ""
            Write-Host "Digite apenas um numero." -ForegroundColor Red

            Start-Sleep -Seconds 2
        }
    }
}

# ============================================================
# MOSTRAR RESUMO DOS PROGRAMAS
# ============================================================

function Mostrar-Resumo {

    Clear-Host

    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "          PROGRAMAS CONFIGURADOS" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    foreach ($Programa in $Programas) {

        if ($Programa.Habilitado) {

            Write-Host "[ATIVO] $($Programa.Nome)" -ForegroundColor Green

        }
        else {

            Write-Host "[DESATIVADO] $($Programa.Nome)" -ForegroundColor DarkGray
        }
    }

    Write-Host ""

    if ($GoogleChatHabilitado) {

        Write-Host "[ATIVO] Google Chat" -ForegroundColor Green

    }
    else {

        Write-Host "[DESATIVADO] Google Chat" -ForegroundColor DarkGray
    }

    Write-Host ""

    Pause
}

# ============================================================
# MOSTRAR LOG
# ============================================================

function Mostrar-Log {

    Clear-Host

    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "                    LOG" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""

    if (Test-Path $ArquivoLog) {

        Get-Content $ArquivoLog

    }
    else {

        Write-Host "Nenhum log encontrado." -ForegroundColor Yellow
    }

    Write-Host ""

    Pause
}

# ============================================================
# MENU PRINCIPAL
# ============================================================

function Menu-Principal {

    while ($true) {

        Clear-Host

        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "       INSTALADOR DE POS-FORMATACAO TI" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "Computador: $env:COMPUTERNAME"
        Write-Host "Usuario:    $env:USERNAME"

        Write-Host ""

        Write-Host "1 - Instalar TODOS os programas"
        Write-Host "2 - Selecionar programa"
        Write-Host "3 - Verificar instaladores"
        Write-Host "4 - Configurar Google Chat"
        Write-Host "5 - Ver programas configurados"
        Write-Host "6 - Ver log"
        Write-Host "7 - Sair"

        Write-Host ""

        $Opcao = Read-Host "Escolha uma opcao"

        switch ($Opcao) {

            "1" {

                Instalar-Todos
            }

            "2" {

                Selecionar-Programas
            }

            "3" {

                Verificar-Instaladores
            }

            "4" {

                Clear-Host

                Configurar-GoogleChat

                Write-Host ""

                Pause
            }

            "5" {

                Mostrar-Resumo
            }

            "6" {

                Mostrar-Log
            }

            "7" {

                Escrever-Log "Script encerrado pelo usuario."

                Clear-Host

                Write-Host "Instalador encerrado."

                exit
            }

            default {

                Write-Host ""
                Write-Host "Opcao invalida." -ForegroundColor Red

                Start-Sleep -Seconds 2
            }
        }
    }
}

# ============================================================
# INICIO DO SCRIPT
# ============================================================

Preparar-Ambiente

Escrever-Log "============================================"
Escrever-Log "SCRIPT INICIADO"
Escrever-Log "Computador: $env:COMPUTERNAME"
Escrever-Log "Usuario: $env:USERNAME"
Escrever-Log "============================================"

Menu-Principal