# ==============================================================================
# Nama Skrip : Pintas.ps1
# Deskripsi  : Otomatisasi instalasi aplikasi standar Windows via WinGet
# ==============================================================================

# Prioritas Utama: Elevasi ke Administrator jika belum
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Meminta hak akses Administrator..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "          SKRIP INSTALASI APLIKASI WINDOWS        " -ForegroundColor Cyan
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
    Read-Host "Tekan Enter untuk keluar..."
    exit
}
Write-Host "[✓] PowerShell v$($PSVersionTable.PSVersion) terdeteksi." -ForegroundColor Green

# Cek Koneksi Internet
try {
    $null = Test-Connection -ComputerName "8.8.8.8" -Count 1 -ErrorAction Stop
    Write-Host "[✓] Koneksi internet terhubung." -ForegroundColor Green
} catch {
    Write-Host "[!] ERROR: Tidak ada koneksi internet. Sambungkan internet lalu coba lagi." -ForegroundColor Red
    Read-Host "Tekan Enter untuk keluar..."
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
    Write-Host "    Membuka Microsoft Store untuk mengunduh 'App Installer'..." -ForegroundColor Yellow
    Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1" -ErrorAction SilentlyContinue
    Read-Host "Tekan tombol apa saja untuk keluar..."
    exit
} else {
    # Pengujian eksekusi langsung untuk memastikan WinGet tidak corrupt
    $null = winget --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] ERROR: WinGet terdeteksi namun bermasalah/corrupt." -ForegroundColor Red
        Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1" -ErrorAction SilentlyContinue
        Read-Host "Tekan tombol apa saja  untuk keluar..."
        exit
    }
    Write-Host "[✓] WinGet siap digunakan." -ForegroundColor Green
}

Write-Host ""

# ------------------------------------------------------------------------------
# LOKASI 3: Instalasi Daftar Aplikasi
# ------------------------------------------------------------------------------
Write-Host "[3/4] Memulai proses instalasi aplikasi..." -ForegroundColor Yellow
Write-Host "--------------------------------------------------" -ForegroundColor System

$daftarAplikasi = @(
    @{ Nama = "Google Chrome";     ID = "Google.Chrome" },
    @{ Nama = "LibreOffice";        ID = "LibreOffice.LibreOffice" },
    @{ Nama = "Paint.NET";          ID = "dotPDNLLC.paint.net" },
    @{ Nama = "VLC Media Player";   ID = "VideoLAN.VLC" },
    @{ Nama = "WinRAR";             ID = "RARLab.WinRAR" },
    @{ Nama = "Sumatra PDF";        ID = "SumatraPDF.SumatraPDF" },
    @{ Nama = "Notepad++";          ID = "Notepad++.Notepad++" },
    @{ Nama = "WhatsApp Desktop";   ID = "WhatsApp.WhatsApp" },
    @{ Nama = "Winamp";             ID = "Winamp.Winamp" }
)

$nomor = 1
foreach ($app in $daftarAplikasi) {
    Write-Host "[$nomor/$($daftarAplikasi.Count)] Menginstal $($app.Nama)..." -ForegroundColor Cyan
    
    # Jalankan proses instalasi
    $process = Start-Process -FilePath "winget" -ArgumentList "install --id `"$($app.ID)`" -e --silent --accept-source-agreements --accept-package-agreements" -NoNewWindow -Wait -PassThru

    # Pengecekan status Exit Code
    switch ($process.ExitCode) {
        0 { 
            Write-Host "    [✓] $($app.Nama) berhasil terinstal." -ForegroundColor Green 
        }
        -1978335189 { 
            Write-Host "    [i] $($app.Nama) sudah terpasang (versi terbaru)." -ForegroundColor Gray 
        }
        -1978335188 { 
            Write-Host "    [i] $($app.Nama) sudah terpasang, tetapi ada pembaruan." -ForegroundColor Yellow 
        }
        default { 
            Write-Host "    [!] $($app.Nama) gagal terinstal (Kode Status: $($process.ExitCode))." -ForegroundColor Red 
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
Write-Host "        PROSES INSTALASI PINTAS SELESAI!           " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Read-Host "Tekan tombol apa saja  untuk keluar..."
