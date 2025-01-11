#!/usr/bin/env powershell

#
# SPDX-FileCopyrightText: 2024 Duncan Greatwood
#
# SPDX-License-Identifier: Apache-2.0
#

<#
.Synopsis
checkLogWorking checks if Pistache correctly populates the Windows log
.Description
checkLogWorking.ps1 runs a test and then checks the Windows ETW log to make sure it contains valid entries for the Pistache test run. It usually requires that Pistache has already been built, and it looks for the Pistache DLL in the build directories used by mesbuild.ps1 or mesbuilddebug.ps1 for the release or debug cases respectively.
If $env:pistNoMcExe is set, and gcc is configured, then checkLogWorking.ps1 will use the "nomcexe" Pistache version. Typically, this will happen because "gccsetup.ps1 -nomcexe" was run prior to invoking mesbuild.ps1 or mesbuilddebug.ps1 and then checkLogWorking.ps1.
If the test fails, you may learn more by viewing the results of:
  Get-WinEvent -path pistache.tmp.etl -Oldest | Select-Object -First 5
(and compare those results with a working case)
.Parameter debug
Use the debug build; otherwise a release/non-debug build is used
.Parameter nomcexe
If gcc is configured, the nomcexe build is used if the nomcexe parameter is passed to checkLogWorking.ps1 or if $env:pistNoMcExe is set
#>

param([switch]$debug, [switch]$nomcexe)

$savedpwd=$pwd

if (($nomcexe) -and (! $env:pistNoMcExe)) {
    Write-Host `
      'NOTE: Configuring gcc with nomcexe, which was not set before'
    Write-Host `
      '      And double-checking that the nomcexe.gcc build is up-to-date'
    . $PSScriptRoot\gccsetup.ps1 -nomcexe
    if ($debug) { . $PSScriptRoot\mesbuilddebug.ps1 }
    else  { . $PSScriptRoot\mesbuild.ps1 }
}
elseif ($env:pistNoMcExe) {
    Write-Host `
      '$env:pistNoMcExe is set, so, in gcc case, will use nomcexe build'
}

# Find the build directory we want to test
if ($debug) {
    . $PSScriptRoot\helpers\mesdebugsetdirvars.ps1
}
else {
    . $PSScriptRoot\helpers\messetdirvars.ps1
}
. $PSScriptRoot\helpers\adjbuilddirformesbuild.ps1

# Run the test, and log it
cd "$savedpwd"
logman start -ets Pistache -p "Pistache-Provider" 0 0 -o pistache.tmp.etl
cd "$MESON_BUILD_DIR\tests"
Write-Host "Executing $pwd\run_cookie_test_3.exe"
.\run_cookie_test_3.exe;
cd "$savedpwd"
logman stop Pistache -ets

$fst5=Get-WinEvent -path "pistache.tmp.etl" -Oldest | Select-Object -First 5

$id_102_count=0
$id_102_start_msg_count=0
$id_1_count=0
foreach ($evitm in $fst5) {
    if ($evitm.Id -eq 102) {
        $id_102_count++

        $ldn=$evitm.LevelDisplayName
        if (! ($ldn -contains "Information")) {
            Write-Error "log LevelDisplayName not as expected: $ldn"
            throw "Windows log LevelDisplayName not as expected"
        }

        $msg=$evitm.Message
        if ((! $id_102_start_msg_count) -and `
            ((! ("$msg" -like "*INFO*")) -or `
          (! ("$msg" -like "*Pistache start*")))) {
              Write-Warning "log msg not as expected: $msg"
          }
        else {
            $id_102_start_msg_count++
        }
    }

    if ($evitm.Id -eq 1) {
        $id_1_count++

        $ldn=$evitm.LevelDisplayName
        if (! ($ldn -contains "Verbose")) {
            Write-Error "log LevelDisplayName not as expected: $ldn"
            throw "Windows log LevelDisplayName not as expected"
        }

        $msg=$evitm.Message
        if ((! ("$msg" -like "*DEBUG*")) -or `
          (! ("$msg" -like "*PSTCH*"))) {
              Write-Error "log msg not as expected: $msg"
              throw "Windows log message not as expected"
          }
    }
}

if (! $id_102_count) {
    throw "No Id=102 / INFO log messages found"
}
if (! $id_102_start_msg_count) {
    throw "No Id=102 / INFO Pistache start message found"
}
if ($debug) {
    if (! $id_1_count) {
        throw "No Id=1 / DEBUG log messages found"
    }
}
else {
    if ($id_1_count) {
        throw "Id=1 / DEBUG log messages found unexpectedly"
    }
}

echo "Logging test passed"
