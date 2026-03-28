Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form -Property @{
    TopMost = $true
    StartPosition = 'CenterScreen'
    Size = New-Object System.Drawing.Size(380, 180)
    Text = 'Claude Code'
    FormBorderStyle = 'FixedDialog'
    MaximizeBox = $false
    MinimizeBox = $false
    ShowInTaskbar = $true
    BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    ForeColor = [System.Drawing.Color]::White
}
$icon = New-Object System.Drawing.Icon([System.Drawing.SystemIcons]::Information, 24, 24)
$form.Icon = $icon

$lblTitle = New-Object System.Windows.Forms.Label -Property @{
    Text = 'Task Completed'
    Location = New-Object System.Drawing.Point(60, 15)
    Size = New-Object System.Drawing.Size(280, 30)
    Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
    ForeColor = [System.Drawing.Color]::White
}
$lblMsg = New-Object System.Windows.Forms.Label -Property @{
    Text = 'Claude Code has finished working. Check your terminal.'
    Location = New-Object System.Drawing.Point(60, 50)
    Size = New-Object System.Drawing.Size(280, 40)
    Font = New-Object System.Drawing.Font('Segoe UI', 10)
    ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
}
$btnOk = New-Object System.Windows.Forms.Button -Property @{
    Text = 'OK'
    Location = New-Object System.Drawing.Point(140, 105)
    Size = New-Object System.Drawing.Size(100, 32)
    BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    ForeColor = [System.Drawing.Color]::White
    FlatStyle = 'Flat'
    Font = New-Object System.Drawing.Font('Segoe UI', 10)
}
$btnOk.Add_Click({ $form.Close() })

$form.Controls.AddRange(@($lblTitle, $lblMsg, $btnOk))

# Auto-close after 8 seconds
$timer = New-Object System.Windows.Forms.Timer -Property @{ Interval = 8000 }
$timer.Add_Tick({ $form.Close() })
$timer.Start()

[System.Windows.Forms.Application]::Run($form)
