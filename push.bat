@echo off

    cd %cd%
    setlocal enableextensions disabledelayedexpansion

    set /p ver="Input your version and press ENTER: "
    set /p com="Input your comment and press ENTER: "
    git tag -d %ver%
    git push origin :refs/tags/%ver%
    git add *
    git commit -m %com%
    git tag "%ver%"
    git push origin master --tag
pause