@echo off
chcp 65001 >nul
title 移动xaero文件夹脚本
setlocal enabledelayedexpansion

echo 正在执行脚本...
echo.

REM 获取当前脚本所在目录
set "currentDir=%~dp0"
set "currentDir=%currentDir:~0,-1%"

echo 当前目录：%currentDir%

REM 检查当前目录下是否存在xaero文件夹
if not exist "%currentDir%\xaero\" (
    echo 错误：当前目录下未找到xaero文件夹！
    pause
    exit /b 1
)

echo.
REM 获取上一级目录
for %%A in ("%currentDir%\..") do set "parentDir=%%~fA"
echo 上一级目录：%parentDir%

REM 清理可能存在的旧版本
if exist "%parentDir%\xaero\" (
    echo 检测到上一级目录已存在xaero文件夹，正在删除旧版本...
    rmdir /s /q "%parentDir%\xaero" 2>nul
)

echo 正在复制xaero文件夹...
REM 使用robocopy处理中文路径和权限问题
robocopy "%currentDir%\xaero" "%parentDir%\xaero" /E /COPY:DAT /R:1 /W:1 /NJH /NJS
if errorlevel 8 (
    echo 复制xaero文件夹失败！
    pause
    exit /b 1
)
echo 已成功复制xaero文件夹到：%parentDir%

echo.
set "maxFlag=0"
set "targetFolder="

echo 正在搜索 %parentDir% 目录下的flag数字txt文件...
echo.

echo 搜索flag*.txt文件...
for /f "delims=" %%F in ('dir /b /s "%parentDir%\flag*.txt" 2^>nul') do (
    set "filePath=%%F"
    set "fileName=%%~nxF"
    
    echo 找到文件：%%F
    
    REM 检查文件名格式
    if "!fileName:~0,4!"=="flag" (
        REM 提取数字部分
        set "numPart=!fileName:flag=!"
        set "numPart=!numPart:~0,-4!"
        
        REM 验证是否为纯数字
        set "isNumber=1"
        for /f "delims=0123456789" %%N in ("!numPart!") do set "isNumber=0"
        
        if !isNumber! equ 1 (
            set /a num=!numPart! 2>nul
            if not "!num!"=="" (
                REM 获取文件所在目录
                for %%D in ("%%~dpF.") do set "folderPath=%%~fD"
                
                echo   有效文件：!fileName! ^(数字：!num!^)
                echo   所在文件夹：!folderPath!
                
                REM 比较数字大小
                if !num! gtr !maxFlag! (
                    set "maxFlag=!num!"
                    set "targetFolder=!folderPath!"
                    echo   更新最大数字为：!maxFlag!
                )
            )
        )
    )
)

echo.
echo 搜索完成。

if %maxFlag% equ 0 (
    echo 未找到包含flag数字txt文件的文件夹！
    
    REM 清理复制的xaero文件夹
    if exist "%parentDir%\xaero\" (
        echo 正在清理复制的xaero文件夹...
        rmdir /s /q "%parentDir%\xaero" 2>nul
    )
    
    pause
    exit /b 1
)

echo.
echo 最大flag数字：%maxFlag%
echo 目标文件夹：%targetFolder%

REM 检查目标文件夹是否存在
if not exist "%targetFolder%\" (
    echo 错误：目标文件夹不存在！
    
    REM 清理复制的xaero文件夹
    if exist "%parentDir%\xaero\" (
        echo 正在清理复制的xaero文件夹...
        rmdir /s /q "%parentDir%\xaero" 2>nul
    )
    
    pause
    exit /b 1
)

echo 正在移动xaero文件夹...

    REM 方法2：先复制再删除
    xcopy "%parentDir%\xaero" "%targetFolder%\xaero\" /E /I /Y /Q
    if errorlevel 1 (
        echo xcopy复制失败！
        
        REM 清理复制的xaero文件夹
        if exist "%parentDir%\xaero\" (
            echo 正在清理复制的xaero文件夹...
            rmdir /s /q "%parentDir%\xaero" 2>nul
        )
        
        pause
        exit /b 1
    )
    
    echo 复制完成，正在删除源文件夹...
    rmdir /s /q "%parentDir%\xaero" 2>nul
    if exist "%parentDir%\xaero\" (
        echo 警告：无法完全删除源文件夹，但文件已复制到目标位置。
        echo 您可能需要手动删除：%parentDir%\xaero
    )
)

echo.
echo ========================================
echo 操作完成！
echo ========================================

pause