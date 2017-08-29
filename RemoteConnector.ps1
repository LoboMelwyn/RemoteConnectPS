. .\Connect-Mstsc.ps1
Import-Module PSSQLite
Add-Type -AssemblyName System.Windows.Forms

function RemoteCon {
    param(
        [string]$ipaddress,
        [string]$type
    )
    $query = "select username,psswrd from RemoteConnection where ipaddress='$ipaddress'"
    $res = Invoke-SqliteQuery -Query $query -DataSource $database
    if ($type -eq 'SSH') {
        ssh $ipaddress -l $res.username -pw $res.psswrd
    }
    elseif ($type -eq 'RDP') {
        Connect-mstsc -ComputerName $ipaddress -user $res.username -password $res.psswrd -admin -Fullscreen
    }
    else {
        Write-Error "Wrong Info in DB: $IPaddress => $($res.username) => $($res.psswrd) => $type"
    }
}

function Add-NewConnection {
    $AddDialog = New-Object system.Windows.Forms.Form
    $AddDialog.Text = "Add a new Connection"
    $AddDialog.MaximizeBox = $false
    $AddDialog.MinimizeBox = $false
    $AddDialog.Width = 300
    $AddDialog.Height = 220
    
    $nmelbl = New-Object system.windows.Forms.Label
    $nmelbl.Text = "Name"
    $nmelbl.Width = 100
    $nmelbl.Height = 20
    $nmelbl.location = new-object system.drawing.point(5, 10)
    $nmelbl.Font = "Microsoft Sans Serif,10"
    $AddDialog.controls.Add($nmelbl)

    $nmetxt = New-Object System.Windows.Forms.TextBox
    $nmetxt.Width = 100
    $nmetxt.Height = 20
    $nmetxt.location = new-object system.drawing.point(105, 8)
    $nmetxt.Font = "Microsoft Sans Serif,10"
    $AddDialog.controls.Add($nmetxt)

    $iplbl = New-Object system.windows.Forms.Label
    $iplbl.Text = "IP Address"
    $iplbl.Width = 100
    $iplbl.Height = 20
    $iplbl.location = new-object system.drawing.point(5, 40)
    $iplbl.Font = "Microsoft Sans Serif,10"
    $AddDialog.controls.Add($iplbl)

    $iptxt = New-Object System.Windows.Forms.TextBox
    $iptxt.Text = "192.168.1.1"
    $iptxt.Width = 100
    $iptxt.Height = 20
    $iptxt.location = new-object system.drawing.point(105, 38)
    $iptxt.Font = "Microsoft Sans Serif,10"
    $AddDialog.controls.Add($iptxt)

    $usrlbl = New-Object system.windows.Forms.Label
    $usrlbl.Text = "Username"
    $usrlbl.Width = 100
    $usrlbl.Height = 20
    $usrlbl.location = new-object system.drawing.point(5, 70)
    $usrlbl.Font = "Microsoft Sans Serif,10"
    $AddDialog.controls.Add($usrlbl)

    $usrtxt = New-Object System.Windows.Forms.TextBox
    $usrtxt.Width = 100
    $usrtxt.Height = 20
    $usrtxt.location = new-object system.drawing.point(105, 68)
    $usrtxt.Font = "Microsoft Sans Serif,10"
    $AddDialog.controls.Add($usrtxt)

    $pswdlbl = New-Object system.windows.Forms.Label
    $pswdlbl.Text = "Password"
    $pswdlbl.Width = 100
    $pswdlbl.Height = 20
    $pswdlbl.location = new-object system.drawing.point(5, 100)
    $pswdlbl.Font = "Microsoft Sans Serif,10"
    $AddDialog.controls.Add($pswdlbl)

    $pswdtxt = New-Object System.Windows.Forms.MaskedTextBox
    $pswdtxt.PasswordChar = '*'
    $pswdtxt.Width = 100
    $pswdtxt.Height = 20
    $pswdtxt.location = new-object system.drawing.point(105, 98)
    $pswdtxt.Font = "Microsoft Sans Serif,10"
    $AddDialog.controls.Add($pswdtxt)

    $typelbl = New-Object system.windows.Forms.Label
    $typelbl.Text = "RC Type"
    $typelbl.Width = 100
    $typelbl.Height = 20
    $typelbl.location = new-object system.drawing.point(5, 130)
    $typelbl.Font = "Microsoft Sans Serif,10"
    $AddDialog.controls.Add($typelbl)

    $typetxt = New-Object System.Windows.Forms.ListBox
    [void] $typetxt.Items.Add("SSH")
    [void] $typetxt.Items.Add("RDP")
    $typetxt.Width = 100
    $typetxt.Height = 20
    $typetxt.location = new-object system.drawing.point(105, 128)
    $typetxt.Font = "Microsoft Sans Serif,10"
    $AddDialog.controls.Add($typetxt)

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(5, 160)
    $OKButton.AutoSize = $true
    $OKButton.Text = "OK"
    $OKButton.Add_Click( {
            $tyint = 0
            if ($typetxt.SelectedItem -eq "SSH") {
                $tyint = 2
            }
            elseif ($typetxt.SelectedItem -eq "RDP") {
                $tyint = 1
            }
            if ($nmetxt -ne '' -and $iptxt.Text -ne '' -and $usrtxt.Text -ne '' -and $pswdtxt.Text -ne '' -and $tyint -gt 0) {
                $query = "INSERT INTO RemoteConnection (name,IPaddress,Username,Psswrd,Type) VALUES ('$($nmetxt.Text)','$($iptxt.Text)','$($usrtxt.Text)', '$($pswdtxt.Text)', $tyint);"
                Invoke-SqliteQuery -Query $query -DataSource $database
                $AddDialog.Close()
                $rconnect.Dispose()
                create-main
            }
            else {
                [System.Windows.Forms.MessageBox]::Show('Entered Info Incorrect. Do not leave any textbox blank.')
            }
        })
    $AddDialog.Controls.Add($OKButton)

    [void]$AddDialog.ShowDialog();
    $AddDialog.Dispose()
}

function Update-Connection {
    $updateDialog = New-Object system.Windows.Forms.Form
    $updateDialog.Text = "Update new Connection"
    $updateDialog.MaximizeBox = $false
    $updateDialog.MinimizeBox = $false
    $updateDialog.Width = 300
    $updateDialog.Height = 220
    
    $nmelbl = New-Object system.windows.Forms.Label
    $nmelbl.Text = "Name"
    $nmelbl.Width = 100
    $nmelbl.Height = 20
    $nmelbl.location = new-object system.drawing.point(5, 10)
    $nmelbl.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($nmelbl)

    $nmetxt = New-Object System.Windows.Forms.TextBox
    $nmetxt.Width = 100
    $nmetxt.Height = 20
    $nmetxt.location = new-object system.drawing.point(105, 8)
    $nmetxt.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($nmetxt)

    $iplbl = New-Object system.windows.Forms.Label
    $iplbl.Text = "IP Address"
    $iplbl.Width = 100
    $iplbl.Height = 20
    $iplbl.location = new-object system.drawing.point(5, 40)
    $iplbl.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($iplbl)

    $iptxt = New-Object System.Windows.Forms.TextBox
    $iptxt.Text = "192.168.1.1"
    $iptxt.Width = 100
    $iptxt.Height = 20
    $iptxt.location = new-object system.drawing.point(105, 38)
    $iptxt.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($iptxt)

    $usrlbl = New-Object system.windows.Forms.Label
    $usrlbl.Text = "Username"
    $usrlbl.Width = 100
    $usrlbl.Height = 20
    $usrlbl.location = new-object system.drawing.point(5, 70)
    $usrlbl.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($usrlbl)

    $usrtxt = New-Object System.Windows.Forms.TextBox
    $usrtxt.Width = 100
    $usrtxt.Height = 20
    $usrtxt.location = new-object system.drawing.point(105, 68)
    $usrtxt.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($usrtxt)

    $pswdlbl = New-Object system.windows.Forms.Label
    $pswdlbl.Text = "Password"
    $pswdlbl.Width = 100
    $pswdlbl.Height = 20
    $pswdlbl.location = new-object system.drawing.point(5, 100)
    $pswdlbl.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($pswdlbl)

    $pswdtxt = New-Object System.Windows.Forms.MaskedTextBox
    $pswdtxt.PasswordChar = '*'
    $pswdtxt.Width = 100
    $pswdtxt.Height = 20
    $pswdtxt.location = new-object system.drawing.point(105, 98)
    $pswdtxt.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($pswdtxt)

    $typelbl = New-Object system.windows.Forms.Label
    $typelbl.Text = "RC Type"
    $typelbl.Width = 100
    $typelbl.Height = 20
    $typelbl.location = new-object system.drawing.point(5, 130)
    $typelbl.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($typelbl)

    $typetxt = New-Object System.Windows.Forms.ListBox
    [void] $typetxt.Items.Add("RDP")
    [void] $typetxt.Items.Add("SSH")
    $typetxt.Width = 100
    $typetxt.Height = 20
    $typetxt.location = new-object system.drawing.point(105, 128)
    $typetxt.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($typetxt)

    $uplist = New-Object System.Windows.Forms.ListBox
    $query = "select ipaddress from RemoteConnection;"
    $results = Invoke-SqliteQuery -Query $query -DataSource $database
    foreach ($r in $results) {
        [void] $uplist.Items.Add($r.ipaddress)
    }
    $uplist.Width = 100
    $uplist.Height = 20
    $uplist.location = new-object system.drawing.point(5, 163)
    $uplist.Font = "Microsoft Sans Serif,10"
    $updateDialog.controls.Add($uplist)

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(120, 160)
    $OKButton.AutoSize = $true
    $OKButton.Text = "OK"
    $OKButton.Add_Click( {
            $ipaddr = $uplist.SelectedItem
            if ($ipaddr -ne $null) {
                $query = "select * from RemoteConnection where ipaddress = '$ipaddr';"
                $d = Invoke-SqliteQuery -Query $query -DataSource $database
                $iptxt.Text = $d.ipaddress
                $usrtxt.Text = $d.username
                $pswdtxt.Text = $d.psswrd
                $typetxt.SetSelected($d.type-1,$true)
                $nmetxt.Text = $d.name
            }
        })
    $updateDialog.Controls.Add($OKButton)

    $upButton = New-Object System.Windows.Forms.Button
    $upButton.Location = New-Object System.Drawing.Size(200, 160)
    $upButton.AutoSize = $true
    $upButton.Text = "Update"
    $upButton.Add_Click( {
            $tyint = 0
            if ($typetxt.SelectedItem -eq "SSH") {
                $tyint = 2
            }
            elseif ($typetxt.SelectedItem -eq "RDP") {
                $tyint = 1
            }
            if ($nmetxt.Text -ne '' -and $iptxt.Text -ne '' -and $usrtxt.Text -ne '' -and $pswdtxt.Text -ne '' -and $tyint -gt 0 -and $uplist.SelectedItem -ne $null) {
                $query = "UPDATE RemoteConnection SET Name = '$($nmetxt.Text)', IPaddress = '$($iptxt.Text)', Username = '$($usrtxt.Text)', Psswrd = '$($pswdtxt.Text)', Type = $tyint where IPaddress = '$($uplist.SelectedItem)';"
                Invoke-SqliteQuery -Query $query -DataSource $database
                $updateDialog.Close()
                $rconnect.Dispose()
                create-main
            }
            else {
                [System.Windows.Forms.MessageBox]::Show('Entered Info Incorrect. Do not leave any textbox blank.')
            }
        })
    $updateDialog.Controls.Add($upButton)

    [void]$updateDialog.ShowDialog();
    $updateDialog.Dispose()
}

function create-main {
    $x = 10; $y = 5;
    $query = "select ipaddress, type, name from RemoteConnection"
    $results = Invoke-SqliteQuery -Query $query -DataSource $database
    $rconnect = New-Object system.Windows.Forms.Form
    $rconnect.Text = "Remote Connector"
    $rconnect.AutoScroll = $true
    $rconnect.MaximizeBox = $false
    $rconnect.Icon = New-Object system.drawing.icon("icon.ico")
    $rconnect.Width = 400
    $rconnect.Height = 500

    foreach ($r in $results) {
        [int]$t = $r.type
        $b = New-Object system.windows.Forms.Button
        $b.Name = "$($r.ipaddress):$($ConType.$t)"
        $b.Text = "Connect $($r.name) via $($ConType.$t)"
        $b.Width = 250
        $b.Height = 50
        $b.location = new-object system.drawing.point($x, $y)
        $b.Add_Click( {
                $n = $this.Name -split ':'
                RemoteCon -ipaddress $n[0] -type $n[1]

            })
        $b.Font = "Microsoft Sans Serif,10"
        $rconnect.controls.Add($b)
        $y += 55
    }

    $acon = New-Object system.windows.Forms.Button
    $acon.Text = "Add New Connection"
    $acon.Width = 100
    $acon.Height = 50
    $acon.location = new-object system.drawing.point(270, 5)
    $acon.Add_Click( {
            Add-NewConnection
        })
    $acon.Font = "Microsoft Sans Serif,10"
    $rconnect.controls.Add($acon)

    $ucon = New-Object system.windows.Forms.Button
    $ucon.Text = "Update Existing Connection"
    $ucon.Width = 100
    $ucon.Height = 50
    $ucon.location = new-object system.drawing.point(270, 60)
    $ucon.Add_Click( {
            Update-Connection
        })
    $acon.Font = "Microsoft Sans Serif,10"
    $rconnect.controls.Add($ucon)

    [void]$rconnect.ShowDialog()
    $rconnect.Dispose()
}

$database = ".\RCDB.db"
Set-Alias ssh .\putty.exe
$ConType = @{1 = "RDP"; 2 = "SSH"; "RDP" = 1 ; "SSH" = 2}
create-main
