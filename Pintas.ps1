# ==============================================================================
# Nama Skrip : Pintas.ps1
# Deskripsi  : Otomatisasi instalasi aplikasi standar Windows via WinGet
# ==============================================================================

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "        SKRIP INSTALASI APLIKASI WINDOWS          " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------------------
# LOKASI 1: Cek apakah PowerShell terpasang dan berjalan dengan benar
# ------------------------------------------------------------------------------
Write-Host "[1/3] Memeriksa status PowerShell..." -ForegroundColor Yellow

$psValid = $false
try {
    if ($PSVersionTable.PSVersion -and $PSVersionTable.PSVersion.Major -ge 5) {
        $psValid = $true
    }
} catch {
    $psValid = $false
}

if (-not $psValid) {
    Write-Host "[!] ERROR: PowerShell tidak terdeteksi atau rusak!" -ForegroundColor Red
    Write-Host "    Silakan pasang/perbarui PowerShell via Microsoft Store atau perbaiki instalasi Windows Anda." -ForegroundColor Red
    
    # Mencoba membuka Microsoft Store ke halaman PowerShell jika memungkinkan
    Start-Process "ms-windows-store://pdp/?productid=9MZ1SNWT0N58" -ErrorAction SilentlyContinue
    
    Write-Host ""
    Read-Host "Tekan Enter untuk keluar..."
    exit
} else {
    Write-Host "[✓] PowerShell terpasang dan berfungsi dengan benar (Versi: $($PSVersionTable.PSVersion))." -ForegroundColor Green
}

Write-Host ""

# ------------------------------------------------------------------------------
# LOKASI 2: Cek apakah WinGet terpasang dengan benar
# ------------------------------------------------------------------------------
Write-Host "[2/3] Memeriksa status WinGet..." -ForegroundColor Yellow

$wingetInstalled = Get-Command winget -ErrorAction SilentlyContinue

if (-not $wingetInstalled) {
    Write-Host "[!] ERROR: WinGet (App Installer) tidak terpasang atau rusak!" -ForegroundColor Red
    Write-Host "    Membuka Microsoft Store untuk mengunduh 'App Installer' (WinGet)..." -ForegroundColor Yellow
    
    # Mengarahkan pengguna ke halaman Microsoft Store untuk "App Installer" (WinGet)
    Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1" -ErrorAction SilentlyContinue
    
    Write-Host "    Harap pasang/perbaiki WinGet melalui Microsoft Store lalu jalankan kembali skrip Pintas ini." -ForegroundColor Red
    Write-Host ""
    Read-Host "Tekan Enter untuk keluar..."
    exit
} else {
    Write-Host "[✓] WinGet terpasang dan siap digunakan." -ForegroundColor Green
}

Write-Host ""

# ------------------------------------------------------------------------------
# LOKASI 3: Instalasi Daftar Aplikasi dari WinGet
# ------------------------------------------------------------------------------
Write-Host "[3/3] Memulai proses instalasi aplikasi..." -ForegroundColor Yellow
Write-Host "--------------------------------------------------" -ForegroundColor System

# Daftar aplikasi sesuai flowchart
$daftarAplikasi = @(
    @{ Nama = "Google Chrome";      ID = "Google.Chrome" },
    @{ Nama = "LibreOffice";         ID = "LibreOffice.LibreOffice" },
    @{ Nama = "Paint.NET";           ID = "dotPDNLLC.paint.net" },
    @{ Nama = "VLC Media Player";    ID = "VideoLAN.VLC" },
    @{ Nama = "WinRAR";              ID = "RARLab.WinRAR" },
    @{ Nama = "Sumatra PDF";         ID = "SumatraPDF.SumatraPDF" },
    @{ Nama = "Notepad++";           ID = "Notepad++.Notepad++" },
    @{ Nama = "WhatsApp Desktop";    ID = "WhatsApp.WhatsApp" },
    @{ Nama = "Winamp";              ID = "Winamp.Winamp" }
)

$nomor = 1
foreach ($app in $daftarAplikasi) {
    Write-Host "[$nomor/$($daftarAplikasi.Count)] Menginstal $($app.Nama)..." -ForegroundColor Cyan
    
    # Mengabaikan lisensi secara otomatis agar instalasi berjalan lancar tanpa pop-up
    winget install --id $app.ID -e --silent --accept-source-agreements --accept-package-agreements

    if ($LASTEXITCODE -eq 0) {
        Write-Host "    [✓] $($app.Nama) berhasil terinstal." -ForegroundColor Green
    } else {
        Write-Host "    [!] $($app.Nama) gagal terinstal atau sudah terpasang." -ForegroundColor Yellow
    }
    
    Write-Host ""
    $nomor++
}

# ------------------------------------------------------------------------------
# Selesai
# ------------------------------------------------------------------------------
Write-Host "==================================================" -ForegroundColor Green
Write-Host "       PROSES INSTALASI PINTAS SELESAI!           " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Read-Host "Tekan Enter untuk menutup..."
