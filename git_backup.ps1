function Add-GitFiles {
    git add -A *
}

function Clear-CurrentFolder {
    Add-GitFiles
    git stash
    git reset --hard
    git pull
    Read-Host "Current folder is now clean. Google `"git stash`" if you need to get your changes back. (Enter to continue)"
}

function Remove-UselessFiles {
    $cmdOutput = git status --porcelain=v1
    $cmdOutput
    if ($cmdOutput.Count -le 5) { # less or equals
        $userInput = Read-Host -Prompt "It seems that SM was opened and closed without performing many actions. Type cl to clear them."
        if ($userInput -eq "cl") {
            Clear-CurrentFolder
        }
    }
}

if ($args[$args.Count - 1] -eq "--pro") {
    $proMode = $true
    $args[$args.Count - 1] = $null;
}

"从服务器拉取同步状态..."
git pull
$pullCode = $LASTEXITCODE

"git 同步：本地与云端版本有以下文件不同（若一致则显示空白）
"
$statusOutput = cmd /c git status --porcelain=v1
if ($null -ne $statusOutput -or $pullCode) {
    $statusOutput
    "`r`n请检查以上文件变动列表，确认保持同步连贯"
    if ($proMode) {
        $userInput = Read-Host -Prompt "Type:`r`ncl if you want to clear any unsaved changes (backup will be stashed)`r`ndiff if you want to see what's actually changed (q to quit - if needed)"
        while ($userInput -eq "diff") {
            git diff
            $userInput = Read-Host -Prompt "Type:`r`ncl if you want to clear any unsaved changes (backup will be stashed)`r`ndiff if you want to see what's actually changed (q to quit - if needed)"
        }
        if ($userInput -eq "cl") {
            Clear-CurrentFolder
        }	
    } else {
        Read-Host -Prompt "现在，按下 Enter 后将开启 SuperMemo 终身学习之旅 "
    }
} else {
    "All OK - proceeding"
}

"`r`n已启动 SM，本窗口将自动最小化
本窗口将会在 SM 关闭时上传修改
如果你不希望关闭后上传，请关闭本窗口
"
& $args[0] $args[1] | Out-Null # start SM from provided path (&) and wait for it to close (Out-Null)
"检测到 SM 关闭"

if ($proMode) {
    Remove-UselessFiles
}

"正在处理并上传更改... 
（完成后将自动关闭本窗口）

"
Add-GitFiles
git commit -m "Jigsaw's 脚本更新"

"..."
git pull
$pullCode = $LASTEXITCODE

"..."
git push -u

if ($pullCode -or $LASTEXITCODE) {
    Read-Host "`r`nNon standard git output - double check above"
}