@echo off
setlocal enabledelayedexpansion


set "algorithm="
set "file="
set "expected_hash="

if "%~1"=="" goto usage
set "algorithm=%~1"

if "%~2"=="" goto usage
set "file=%~2"

set "expected_hash=%~3"

if not exist "%file%" (
    echo File not found: "%file%"
    exit /b 1
)

:: Algo set
set "certutil_alg="
for %%A in (
    "MD2" 
    "MD4" 
    "MD5" 
    "SHA1" 
    "SHA256" 
    "SHA384" 
    "SHA512"
) do if /i "%%~A" == "%algorithm%" set "certutil_alg=%%~A"

if not defined certutil_alg (
    echo Unsupported algorithm: %algorithm%
    echo Supported algorithms: MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512
    exit /b 1
)

:: Hash computing
set "computed_hash="
for /f "delims=" %%i in (
    'CertUtil -hashfile "%file%" %certutil_alg% ^| findstr /rc:"^[0-9a-fA-F][0-9a-fA-F]*$"'
) do set "computed_hash=%%i"

set "computed_hash=%computed_hash: =%"
set "computed_hash=%computed_hash:^^=%%"

if not defined computed_hash (
    echo Failed to compute hash
    exit /b 1
)

:: Check hash mode
if defined expected_hash (
    set "expected_hash=%expected_hash: =%"
    set "expected_hash=%expected_hash:^^=%%"
    
    if /i "%computed_hash%" == "%expected_hash%" (
        echo Hashes match
        exit /b 0
    ) else (
        echo Hashes do NOT match
        echo Computed: %computed_hash%
        echo Expected: %expected_hash%
        exit /b 1
    )
)

:: Hash output
echo %computed_hash%
exit /b 0

:usage
echo Usage: %~nx0 algorithm file [expected_hash]
echo Supported algorithms: MD2, MD4, MD5, SHA1, SHA256, SHA384, SHA512
exit /b 1
