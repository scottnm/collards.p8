<#
.SYNOPSIS
This script intends to help identify which words and tokens take up the most codespace in pico8 carts so that time
can be spent finding shorter identifiers for commonly used names/phrases and less time spent worrying about one-offs.
#>
Param(
    [Parameter(Mandatory=$true)][string]$CartPath,
    [Parameter(Mandatory=$false)][switch]$WordsIncludeUnderscores,
    [Parameter(Mandatory=$false)][int]$Top = 20,
    [Parameter(Mandatory=$false)][switch]$RetainTmp
)

$Cart = Get-Item $CartPath
$cartIncludes = sls "^#include\s+([A-Za-z_]+.lua)" $Cart.FullName

$tmpLuaFile = (Get-Item $CartPath).BaseName + "_tmp.lua"
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

    Write-Host -foregroundcolor cyan "Including... $luaFile"
    if ($i -ne 0)
    {
        echo "-->8" >> $tmpLuaFile
    }
    cat $luaPath >> $tmpLuaFile
    echo "" >> $tmpLuaFile
}

$wordPattern = if ($WordsIncludeUnderscores) { "\b([A-Za-z_]+)\b" } else { "\b([A-Za-z]+)\b" }

$words = @{}
sls -Pattern $wordPattern $tmpLuaFile | %{
    $matchedWord = $_.Matches[0].Groups[1].Value
    $matchedWord = $matchedWord.ToLower()
    $words[$matchedWord] += 1
}

$allChars = (Get-Content $tmpLuaFile -AsByteStream -Raw)

$words[" "] = ($allChars.GetEnumerator() | ?{$_ -eq 32}).Count
$words["("] = ($allChars.GetEnumerator() | ?{$_ -eq 40 -or $_ -eq 41}).Count

$wordRatios = $words.GetEnumerator() | %{
    $kvp = $_
    $word = $kvp.Key
    $wordCount = $kvp.Value
    $wordTotalChars = $word.Length * $wordCount
    $wordRatio = [Math]::floor(($wordTotalChars * 10000) / ($allChars.Count)) / 100
    @{Word=$word;Count=$wordCount;Ratio=$wordRatio}
} | %{
    [pscustomobject]$_
}

$wordRatios | sort -Property Ratio -Descending | select -first $Top

if ($RetainTmp)
{
    Write-Host -foregroundcolor yellow "Warning! retaining tmp... $tmpLuaFile"
}
else
{
    Write-Host -foregroundcolor cyan "Cleaning up... $tmpLuaFile"
    rm $tmpLuaFile
}
