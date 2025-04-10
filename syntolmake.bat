@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: %~nx0 script_file [step]
    exit /b 1
)

set "script_file=%~1"
set "target_step=%~2"
set "temp_file=%temp%\syntolmake_temp_%random%.cmd"

:: First pass - process variables
for /f "tokens=*" %%a in (%script_file%) do (
    set "line=%%a"
    if "!line:~0,4!"=="VAR " (
        set "rest=!line:~4!"
        for /f "tokens=1,* delims==" %%A in ("!rest!") do (
            set "var_name=%%A"
            set "var_value=%%B"
        )
        set "var_name=!var_name: =!"
        set "var_value=!var_value: =!"
        for /f "delims=/ tokens=1" %%C in ("!var_value!") do set "var_value=%%C"
        set "var_value=!var_value:"=!"
        set "!var_name!=!var_value!"
    )
)

:: Second pass - generate temp script
(
    set "execute=yes"
    for /f "tokens=*" %%a in (%script_file%) do (
        set "line=%%a"
        set "line=!line:$=%%!"
        
        :: Skip VAR lines and comments
        if not "!line:~0,4!"=="VAR " (
            if not "!line:~0,2!"=="//" (
                :: Process step markers
                if "!line:~0,1!"=="@" (
                    set "current_step=!line:~1!"
                    if defined target_step (
                        if "!current_step!"=="!target_step!" (
                            set "execute=yes"
                        ) else (
                            set "execute=no"
                        )
                    )
                    if "!execute!"=="yes" echo echo [STEP] !current_step!
                ) else if "!execute!"=="yes" (
                    echo !line!
                )
            )
        )
    )
) > "%temp_file%"

:: Execute temp script
call "%temp_file%"

:: Cleanup
del "%temp_file%" >nul 2>&1

endlocal	