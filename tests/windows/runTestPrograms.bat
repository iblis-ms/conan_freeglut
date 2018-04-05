@ECHO off 
SETLOCAL EnableDelayedExpansion

ECHO "------------------ program tests ------------------"

SET "CURRENT_PATH=%~dp0"
 
IF EXIST "%HOME%\.conan\data\FreeGlut" RD /q /s "%HOME%\.conan\data\FreeGlut"

CALL startConanServer.bat

FOR %%m IN (True False) DO (
    SET "demos=%%m"
    FOR %%t IN (True False) DO (
        SET "static=%%t"
        FOR %%s IN (True False) DO (
            SET "gles=%%s"
            FOR %%a IN (True False) DO (
                SET "printErrors=%%a"
                FOR %%b IN (True False) DO (
                    SET "printWarnings=%%b"
                    
                    CALL runVisual.bat !demos! !static! !gles! !printErrors! !printWarnings! || exit /b 1
                    
                    CALL runGcc.bat !demos! !static! !gles! !printErrors! !printWarnings! libstdc++ || exit /b 1
                    
                    CALL runGcc.bat !demos! !static! !gles! !printErrors! !printWarnings! libstdc++11 || exit /b 1
                )
            )
        )
    )
)

CALL stopConanServer.bat

CD %CURRENT_PATH%
