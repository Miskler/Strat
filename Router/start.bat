@chcp 1251
@echo off
title Server kHUTER
echo.
start cmd.exe /c "uvicorn main:app --reload --host 127.0.0.1 --port 9999"