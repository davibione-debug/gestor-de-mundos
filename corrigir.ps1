$arquivo = "C:\Users\HMTecInfo\gestor_de_mundos\lib\screens\mapa\local_edit_screen.dart"
$backup  = "$arquivo.bak"
Copy-Item -Path $arquivo -Destination $backup -Force
Write-Host "Backup criado: $backup" -ForegroundColor Green
$conteudo = [System.IO.File]::ReadAllText($arquivo, [System.Text.Encoding]::UTF8)
$trocas = @(
    @{ de = ' ,Á‚Â¢ ';      para = ' • ' },
    @{ de = ' ,?o';         para = '–' },
    @{ de = ' ,? ';         para = ' × ' },
    @{ de = ',? Eventos';   para = '— Eventos' },
    @{ de = 'í§í£';         para = 'çã' },
    @{ de = 'í§íµ';         para = 'çõ' },
    @{ de = 'Preí§o';       para = 'Preço' },
    @{ de = 'í§';           para = 'ç' },
    @{ de = 'í£';           para = 'ã' },
    @{ de = 'íµ';           para = 'õ' },
    @{ de = 'í¡';           para = 'á' },
    @{ de = 'í©';           para = 'é' },
    @{ de = 'í';            para = 'í' }
)
foreach ($t in $trocas) { $conteudo = $conteudo.Replace($t.de, $t.para) }
$utf8SemBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($arquivo, $conteudo, $utf8SemBom)
Write-Host "Arquivo corrigido e salvo em UTF-8 (sem BOM)." -ForegroundColor Green
