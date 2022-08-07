<#
.SYNOPSIS
This script will take a Pico8 cartridge where code is split into multiple included lua files and package it together
into one pico8 cart. This script relies on p8tool being installed and is mostly just a slight tweak on its expected
functionality. I currently prefer this flow for multi-file lua stuff rather than using lua's require directive.
#>
Param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$false)][string]$PrototypeLabel = "1",
    [Parameter(Mandatory=$false)][string]$OutputCartName,
    [Parameter(Mandatory=$false)][switch]$Minify,
    [Parameter(Mandatory=$false)][string]$ReleaseName
)


if (!$OutputCartName)
{
    $OutputCartName = "proto_$PrototypeLabel.p8"
}

$Cart = Get-Item $Path
$cartIncludes = sls "^#include\s+([A-Za-z_]+.lua)" $Cart.FullName

cp $Path $OutputCartName
$tmpLuaFile = (Get-Item $OutputCartName).BaseName + ".lua"
rm $tmpLuaFile -ErrorAction SilentlyContinue

# verify all of the includes are there
for ($i = 0; $i -lt $cartIncludes.Matches.Count; $i++)
{
    $cartInclude = $cartIncludes.Matches[$i]
    $luaFile = $cartInclude.Groups[1].Value
    $luaPath = Join-Path $Cart.DirectoryName $luaFile
    if (! (Test-Path $luaPath))
    {
        throw "Can't find included file $luaFile @ $luaPath"
    }

    Write-Host -foregroundcolor cyan "Packaging... $luaFile"
    if ($i -ne 0)
    {
        echo "-->8" >> $tmpLuaFile
    }
    cat $luaPath >> $tmpLuaFile
    echo "" >> $tmpLuaFile
}

$cmd = "p8tool build $OutputCartName --lua $tmpLuaFile"
Write-Host -ForegroundColor Yellow $cmd
Invoke-Expression -command $cmd
if ($Minify)
{
    $cmd = "p8tool luamin $OutputCartName"
    Write-Host -ForegroundColor Yellow $cmd
    Invoke-Expression -command $cmd
    $minCartName = (Get-Item $OutputCartName).BaseName + "_fmt.p8"
    mv $minCartName $OutputCartName -force
}
rm $tmpLuaFile

if ($ReleaseName)
{
    $releaseDir = "$PSScriptRoot\releases\$ReleaseName"
    rm $releaseDir -rec -ErrorAction SilentlyContinue
    mkdir $releaseDir
    mv $OutputCartName $releaseDir
}
