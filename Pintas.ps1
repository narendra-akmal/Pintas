# ==============================================================================
# Nama Skrip : Pintas.ps1
# Deskripsi  : Otomatisasi instalasi aplikasi standar Windows via WinGet
# ==============================================================================

# ------------------------------------------------------------------------------
# ELEVASI ADMINISTRATOR
# ------------------------------------------------------------------------------
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Meminta hak akses Administrator..." -ForegroundColor Yellow
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "           SKRIP INSTALASI APLIKASI WINDOWS        " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------------------
# LOKASI 1: Cek PowerShell Versi & Koneksi Internet
# ------------------------------------------------------------------------------
Write-Host "[1/4] Memeriksa lingkungan PowerShell & Internet..." -ForegroundColor Yellow

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "[!] ERROR: PowerShell versi $($PSVersionTable.PSVersion) terlalu lama!" -ForegroundColor Red
    Write-Host "    Membuka Microsoft Store untuk memperbarui..." -ForegroundColor Red
    Start-Process "ms-windows-store://pdp/?productid=9MZ1SNWT0N58" -ErrorAction SilentlyContinue
    Read-Host "Tekan Enter untuk keluar"
    exit
}
Write-Host "[✓] PowerShell v$($PSVersionTable.PSVersion) terdeteksi." -ForegroundColor Green

# Cek Koneksi Internet via Web Request (Lebih Stabil dibanding ICMP Ping)
try {
    $request = [System.Net.WebRequest]::Create("http://www.msftconnecttest.com/connecttest.txt")
    $request.Timeout = 5000
    $response = $request.GetResponse()
    $response.Close()
    Write-Host "[✓] Koneksi internet terhubung." -ForegroundColor Green
} catch {
    Write-Host "[!] ERROR: Tidak ada koneksi internet. Sambungkan internet lalu coba lagi." -ForegroundColor Red
    Read-Host "Tekan Enter untuk keluar"
    exit
}

Write-Host ""

# ------------------------------------------------------------------------------
# LOKASI 2: Cek & Validasi Eksekusi WinGet
# ------------------------------------------------------------------------------
Write-Host "[2/4] Memeriksa status WinGet..." -ForegroundColor Yellow

$wingetCheck = Get-Command winget -ErrorAction SilentlyContinue

if (-not $wingetCheck) {
    Write-Host "[!] ERROR: WinGet tidak terpasang!" -ForegroundColor Red
    Write-Host "Memlulai proses instalasi WinGet..." -ForegroundColor Yellow
    powershell -NoExit -Command "(irm https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1) | iex"
    Read-Host "Tekan Enter untuk keluar"
    exit
} else {
    # Pengujian eksekusi langsung untuk memastikan WinGet tidak corrupt
    $null = winget --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] ERROR: WinGet terdeteksi namun bermasalah/corrupt." -ForegroundColor Red
        powershell -NoExit -Command "(irm https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1) | iex"
        Read-Host "Tekan Enter untuk keluar"
        exit
    }
    Write-Host "[✓] WinGet siap digunakan." -ForegroundColor Green
}

Write-Host ""

# ------------------------------------------------------------------------------
# LOKASI 3: Instalasi Daftar Aplikasi & Konfigurasi Proteksi
# ------------------------------------------------------------------------------
Write-Host "[3/4] Memulai proses instalasi aplikasi dan optimasi keamanan..." -ForegroundColor Yellow
Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

# 1. Update Definisi Windows Defender
Write-Host "[0/10] Memperbarui definisi virus Windows Defender..." -ForegroundColor Cyan
try {
    Update-MpSignature -ErrorAction Stop
    Write-Host "    [✓] Definisi Windows Defender berhasil diperbarui." -ForegroundColor Green
} catch {
    Write-Host "    [!] Gagal/Dilewati memperbarui Windows Defender." -ForegroundColor Yellow
}
Write-Host ""

# 2. Daftar Aplikasi
$daftarAplikasi = @(
    @{ Nama = "Google Chrome";         ID = "Google.Chrome" },
    @{ Nama = "ONLYOFFICE";            ID = "ONLYOFFICE.DesktopEditors" },
    @{ Nama = "GIMP";               ID = "GIMP.GIMP" },
    @{ Nama = "VLC Media Player";        ID = "VideoLAN.VLC" },
    @{ Nama = "WinRAR";                  ID = "RARLab.WinRAR" },
    @{ Nama = "Foxit Reader";             ID = "Foxit.FoxitReader" },
    @{ Nama = "Notepad++";               ID = "Notepad++.Notepad++" },
    @{ Nama = "TweakPower";               ID = "KurtZimmermann.TweakPower" },
    @{ Nama = "Winamp";                  ID = "Winamp.Winamp" } 
)

$nomor = 1
foreach ($app in $daftarAplikasi) {
    Write-Host "[$nomor/$($daftarAplikasi.Count)] Menginstal $($app.Nama)..." -ForegroundColor Cyan
    
    # Argumen winget untuk proses instalasi yang senyap
    $arguments = "install --id `"$($app.ID)`" -e --silent --accept-source-agreements --accept-package-agreements"
    
    # Run winget process
    $process = Start-Process -FilePath "winget" -ArgumentList $arguments -NoNewWindow -Wait -PassThru

    # Evaluasi Exit Code
    switch ($process.ExitCode) {
        0 { 
            Write-Host "    [✓] $($app.Nama) berhasil terinstal." -ForegroundColor Green 
        }
        { $_ -in -1978335189, 0x8A15002B } { 
            Write-Host "    [i] $($app.Nama) sudah terpasang (versi terbaru)." -ForegroundColor Gray 
        }
        { $_ -in -1978335188, 0x8A15002C } { 
            Write-Host "    [i] $($app.Nama) sudah terpasang, tetapi ada pembaruan tersedia." -ForegroundColor Yellow 
        }
        default { 
            Write-Host "    [!] $($app.Nama) gagal terinstal (Exit Code: $($process.ExitCode))." -ForegroundColor Red 
        }
    }
    
    Write-Host ""
    $nomor++
}

# ------------------------------------------------------------------------------
# LOKASI 4: Selesai
# ------------------------------------------------------------------------------
Write-Host "[4/4] Selesai!" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Green
Write-Host "            PROSES INSTALASI SELESAI!              " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Read-Host "Tekan Enter untuk keluar"
