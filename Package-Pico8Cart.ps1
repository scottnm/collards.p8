<#
.SYNOPSIS
This script will take a Pico8 cartridge where code is split into multiple included lua files and package it together
into one pico8 cart. This script relies on p8tool being installed and is mostly just a slight tweak on its expected
functionality. I currently prefer this flow for multi-file lua stuff rather than using lua's require directive.
#>
Param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$false)][string]$OutputCartName = "proto.p8"
)

$Cart = Get-Item $Path
$cartIncludes = sls "#include\s+([A-Za-z_]+.lua)" $Cart.FullName

cp $Path $OutputCartName
$tmpLuaFile = (Get-Item $OutputCartName).BaseName + ".lua"
rm $tmpLuaFile -ErrorAction SilentlyContinue

# verify all of the includes are there
foreach ($cartInclude in $cartIncludes.Matches)
{
    $luaFile = $cartInclude.Groups[1].Value
    $luaPath = Join-Path $Cart.DirectoryName $luaFile
    if (! (Test-Path $luaPath))
    {
        throw "Can't find included file $luaFile @ $luaPath"
    }

    Write-Host -foregroundcolor cyan "Packaging... $luaFile"
    echo "-- $luaFile" >> $tmpLuaFile
    cat $luaPath >> $tmpLuaFile
    echo "" >> $tmpLuaFile
}

$cmd = "p8tool build $OutputCartName --lua $tmpLuaFile"
Write-Host -ForegroundColor Yellow $cmd
Invoke-Expression -command $cmd
rm $tmpLuaFile
