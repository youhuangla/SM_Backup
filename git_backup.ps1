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

"�ӷ�������ȡͬ��״̬..."
git pull
$pullCode = $LASTEXITCODE

"git ͬ�����������ƶ˰汾�������ļ���ͬ����һ������ʾ�հף�
"
$statusOutput = cmd /c git status --porcelain=v1
if ($null -ne $statusOutput -or $pullCode) {
    $statusOutput
    "`r`n���������ļ��䶯�б�ȷ�ϱ���ͬ������"
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
        Read-Host -Prompt "���ڣ����� Enter �󽫿��� SuperMemo ����ѧϰ֮�� "
    }
} else {
    "All OK - proceeding"
}

"`r`n������ SM�������ڽ��Զ���С��
�����ڽ����� SM �ر�ʱ�ϴ��޸�
����㲻ϣ���رպ��ϴ�����رձ�����
"
& $args[0] $args[1] | Out-Null # start SM from provided path (&) and wait for it to close (Out-Null)
"��⵽ SM �ر�"

if ($proMode) {
    Remove-UselessFiles
}

"���ڴ����ϴ�����... 
����ɺ��Զ��رձ����ڣ�

"
Add-GitFiles
git commit -m "Jigsaw's �ű�����"

"..."
git pull
$pullCode = $LASTEXITCODE

"..."
git push -u

if ($pullCode -or $LASTEXITCODE) {
    Read-Host "`r`nNon standard git output - double check above"
}