$ErrorActionPreference = "Stop"

$destino = Join-Path (Get-Location) "Dados_Escudo_do_Mestre.xlsx"
$temp = Join-Path $env:TEMP "escudo_mestre_xlsx"

Write-Host "=========================================="
Write-Host " CRIANDO PLANILHA"
Write-Host "=========================================="
Write-Host "Modo: Open XML direto - sem Excel"
Write-Host ""

if (Test-Path $temp) {
    Remove-Item $temp -Recurse -Force
}

New-Item -ItemType Directory -Path "$temp\_rels" -Force | Out-Null
New-Item -ItemType Directory -Path "$temp\xl\_rels" -Force | Out-Null
New-Item -ItemType Directory -Path "$temp\xl\worksheets" -Force | Out-Null

function Salvar-Texto {
    param(
        [string]$Caminho,
        [string]$Texto
    )

    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Caminho, $Texto, $utf8)
}

function Escapar-Xml {
    param([string]$Texto)

    if ($null -eq $Texto) {
        return ""
    }

    return [System.Security.SecurityElement]::Escape($Texto)
}

function Coluna-Letra {
    param([int]$Numero)

    $resultado = ""

    while ($Numero -gt 0) {
        $resto = ($Numero - 1) % 26
        $resultado = [char](65 + $resto) + $resultado
        $Numero = [math]::Floor(($Numero - 1) / 26)
    }

    return $resultado
}

function Criar-SheetXml {
    param(
        [object[]]$Linhas
    )

    $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    $xml += '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
    $xml += '<sheetData>'

    for ($r = 0; $r -lt $Linhas.Count; $r++) {

        $linha = $r + 1
        $xml += "<row r=""$linha"">"

        $valores = $Linhas[$r]

        for ($c = 0; $c -lt $valores.Count; $c++) {

            $coluna = Coluna-Letra ($c + 1)
            $referencia = "$coluna$linha"
            $valor = Escapar-Xml ([string]$valores[$c])

            $xml += "<c r=""$referencia"" t=""inlineStr""><is><t>$valor</t></is></c>"
        }

        $xml += '</row>'
    }

    $xml += '</sheetData>'
    $xml += '</worksheet>'

    return $xml
}

$abas = @(
    @{
        Nome = "Configuração"
        Linhas = @(
            @("Campo", "Valor"),
            @("Versão do modelo", "2"),
            @("Sistema", "Escudo do Mestre"),
            @("Referências", "Registros relacionados usam o Nome."),
            @("Unicidade", "Não existem nomes duplicados no jogo."),
            @("Encontros", "Pertencem diretamente ao Local."),
            @("D6", "O Mestre realiza a rolagem fisicamente.")
        )
    },
    @{
        Nome = "Itens"
        Linhas = @(
            @("Nome", "Tipo", "Custo em Créditos", "Efeito")
        )
    },
    @{
        Nome = "Pokémon"
        Linhas = @(
            @(
                "Nome",
                "Número",
                "Lendário",
                "Tipo 1",
                "Tipo 2",
                "Força",
                "Habilidade",
                "Resistência",
                "Armadura",
                "Defesa Especial",
                "Poder de Fogo"
            ),
            @(
                "Pidgey",
                "16",
                "Não",
                "Normal",
                "Voador",
                "1",
                "2",
                "1",
                "1",
                "1",
                "1"
            )
        )
    },
    @{
        Nome = "NPCs"
        Linhas = @(
            @(
                "Nome",
                "Kit",
                "Força",
                "Habilidade",
                "Resistência",
                "Inteligência",
                "Armadura",
                "Poder de Fogo",
                "PV",
                "Manobras",
                "Captura",
                "Controle",
                "Compreensão",
                "Tratamento",
                "Ecologia",
                "Itens",
                "Vantagens e Desvantagens",
                "Pokémon",
                "Nível Mínimo",
                "Nível Máximo",
                "Local",
                "Período"
            )
        )
    },
    @{
        Nome = "Locais"
        Linhas = @(
            @(
                "Nome",
                "Região",
                "Descrição",
                "Léguas",
                "Terreno",
                "Encontro Diurno",
                "Encontro Noturno",
                "Pesca",
                "Surfe"
            ),
            @(
                "Rota 1",
                "Kanto",
                "Rota entre Pallet e Viridian.",
                "1",
                "Fácil",
                "Pidgey, Rattata",
                "Rattata, Pidgey",
                "",
                ""
            )
        )
    },
    @{
        Nome = "Pontos de Interesse"
        Linhas = @(
            @(
                "Nome",
                "Local",
                "Tipo",
                "Descrição"
            )
        )
    },
    @{
        Nome = "Eventos"
        Linhas = @(
            @(
                "Nome",
                "Local",
                "Tipo",
                "Descrição",
                "Período"
            )
        )
    }
)

$contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
$contentTypes += '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
$contentTypes += '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
$contentTypes += '<Default Extension="xml" ContentType="application/xml"/>'
$contentTypes += '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'

for ($i = 1; $i -le 7; $i++) {
    $contentTypes += '<Override PartName="/xl/worksheets/sheet' + $i + '.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
}

$contentTypes += '</Types>'

Salvar-Texto "$temp\[Content_Types].xml" $contentTypes

$rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
$rels += '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
$rels += '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
$rels += '</Relationships>'

Salvar-Texto "$temp\_rels\.rels" $rels

$workbook = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
$workbook += '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
$workbook += '<sheets>'

for ($i = 0; $i -lt $abas.Count; $i++) {
    $id = $i + 1
    $nome = Escapar-Xml $abas[$i].Nome
    $workbook += '<sheet name="' + $nome + '" sheetId="' + $id + '" r:id="rId' + $id + '"/>'
}

$workbook += '</sheets>'
$workbook += '</workbook>'

Salvar-Texto "$temp\xl\workbook.xml" $workbook

$wbRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
$wbRels += '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'

for ($i = 0; $i -lt $abas.Count; $i++) {
    $id = $i + 1
    $wbRels += '<Relationship Id="rId' + $id + '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet' + $id + '.xml"/>'
}

$wbRels += '</Relationships>'

Salvar-Texto "$temp\xl\_rels\workbook.xml.rels" $wbRels

for ($i = 0; $i -lt $abas.Count; $i++) {
    $numero = $i + 1
    $nome = $abas[$i].Nome
    $caminho = "$temp\xl\worksheets\sheet$numero.xml"

    Write-Host "Criando aba: $nome"

    $sheetXml = Criar-SheetXml $abas[$i].Linhas

    Salvar-Texto $caminho $sheetXml
}

if (Test-Path $destino) {
    Remove-Item $destino -Force
}

Write-Host ""
Write-Host "Gerando arquivo XLSX..."

Add-Type -AssemblyName System.IO.Compression.FileSystem

[System.IO.Compression.ZipFile]::CreateFromDirectory(
    $temp,
    $destino,
    [System.IO.Compression.CompressionLevel]::Optimal,
    $false
)

Remove-Item $temp -Recurse -Force

if (-not (Test-Path $destino)) {
    throw "O arquivo XLSX não foi criado."
}

Write-Host ""
Write-Host "=========================================="
Write-Host " PLANILHA CRIADA COM SUCESSO"
Write-Host "=========================================="
Write-Host ""
Write-Host "Arquivo:"
Write-Host $destino
Write-Host ""
Write-Host "Abas:"
foreach ($aba in $abas) {
    Write-Host " - $($aba.Nome)"
}
