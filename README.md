# <h1 align="center">:computer_mouse:Pintas  </h1>

<p align="center">
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://learn.microsoft.com/powershell/"><img src="https://img.shields.io/badge/PowerShell-%E2%89%A5%205.0-blue.svg?logo=powershell&logoColor=white" alt="PowerShell"></a>
  <a href="https://www.microsoft.com/windows"><img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg?logo=windows&logoColor=white" alt="Platform"></a>
  <a href="https://learn.microsoft.com/windows/package-manager/winget/"><img src="https://img.shields.io/badge/Package%20Manager-WinGet-0078D4.svg?logo=windows&logoColor=white" alt="Package Manager"></a>
  <br>
 <a href="https://www.microsoft.com/windows/comprehensive-security"><img src="https://img.shields.io/badge/Security-Windows%20Defender-00A4EF.svg?logo=windows-defender&logoColor=white" alt="Defender"></a>
  <a href="#"><img src="https://img.shields.io/badge/Provisioning-Automated-brightgreen.svg" alt="Automated Provisioning"></a>
</p>  

---  

## 1. Lingkup dan Tujuan
Dokumen ini menyediakan spesifikasi teknis, pedoman instalasi, serta panduan penggunaan untuk skrip Pintas (`Pintas.ps1`). Dokumentasi ini disusun berdasarkan standar **ISO/IEC/IEEE 26510:2018** (*Systems and software engineering — Requirements for acquirers and suppliers of user documentation*).

### 1.1 Pernyataan Masalah & Solusi
Proses provisi perangkat lunak pasca-instalasi (*post-installation provisioning*) pada sistem operasi Microsoft Windows secara manual memerlukan waktu dan sering kali tidak konsisten. Penanganannya rentan terhadap kesalahan manusia (*human error*), risiko pengunduhan berkas biner tidak terverifikasi, serta ketidakseragaman versi perangkat lunak.

**Pintas** dikembangkan sebagai perkakas otomatisasi berbasis PowerShell untuk melakukan provisi aplikasi secara terpusat (*batch installation*) menggunakan manajer paket resmi Windows Package Manager (**WinGet**). Skrip ini juga memperbarui definisi proteksi antivirus Windows Defender secara otomatis.

---

## 2. Arsitektur dan Komponen Sistem
Skrip `Pintas.ps1` dirancang menggunakan modul eksekusi berurutan (*sequential execution pipeline*) yang memenuhi aspek keandalan (*reliability*) dan efisiensi (*efficiency*).

```text
+-----------------------------------------------------------------+
|                           Pintas.ps1                            |
+-----------------------------------------------------------------+
                                 |
     +---------------------------+---------------------------+
     |                           |                           |
     v                           v                           v
[Modul Validasi Pre-req]   [Modul Package Manager]    [Modul Deployment & Sec]
 - Elevasi UAC Auto         - Cek Ketersediaan WinGet  - Update Defender Signature
 - Cek Versi PowerShell     - Auto-Fix WinGet Corrupt  - Auto-Install Apps Paket
 - Cek Koneksi Internet     - Evaluasi Exit Codes      - Tampilan Status Execution
```  

### 2.1 Fitur Utama Skrip  
* **Elevasi Hak Akses Otomatis:** Memeriksa dan meminta hak akses Administrator (*Elevated Privileges*) secara otomatis saat skrip dijalankan.  
* **Pemeriksaan Lingkungan Pre-flight:** Memvalidasi versi minimal PowerShell (v5.0) dan melakukan verifikasi koneksi internet berbasis Web Request yang stabil.  
* **Auto-healing Engine WinGet:** Memeriksa ketersediaan serta integritas perintah `winget`. Jika tidak terdeteksi atau corrupt, skrip mengunduh dan memasang perbaikan secara otomatis.  
* **Optimasi Keamanan:** Melakukan pembaruan definisi virus Windows Defender (`Update-MpSignature`) sebelum proses pengunduhan aplikasi.
* **Instalasi Senyap & Aman (Unattended):** Memasang daftar aplikasi secara terautomasi menggunakan parameter silent installer (`--silent`, `--accept-source-agreements`, `--accept-package-agreements`).
* **Handling Exit Code:** Membedakan status keberhasilan, keberadaan aplikasi versi terbaru, ketersediaan pembaruan, hingga kegagalan instalasi.   
## 3. Daftar Paket Aplikasi yang Dideploy   
Tabel berikut memuat daftar aplikasi bawaan yang dipasang oleh skrip Pintas.ps1:   
| No | Nama Aplikasi | WinGet Package ID | Deskripsi Kategori |
| :-: | :--- | :--- | :--- |
| 1 | Opera Browser | `XP8CF6S8G2D5T6` | Peramban Web |
| 2 | ONLYOFFICE | `ONLYOFFICE.DesktopEditors` | Paket Produktivitas Perkantoran |
| 3 | Pixlr E | `9NWJ8JHT6WGW` | Pengolah Grafis / Gambar |
| 4 | VLC Media Player | `VideoLAN.VLC` | Pemutar Media Audio & Video |
| 5 | WinRAR | `RARLab.WinRAR` | Pengarsip Berkas / Kompresi |
| 6 | Foxit Reader | `Foxit.FoxitReader` | Pembaca Dokumen PDF |
| 7 | Notepad++ | `Notepad++.Notepad++` | Editor Teks & Kode Sumber |
| 8 | PC Manager | `9PM860492SZD` | Perkakas Optimasi Sistem |
| 9 | Winamp | `Winamp.Winamp` | Pemutar Audio |

## 4. Persyaratan Sistem  
| Komponen | Persyaratan Minimum | Rekomendasi |
| :--- | :--- | :--- |
| **Sistem Operasi** | Microsoft Windows 10 (64-bit) | Microsoft Windows 10 / 11 (64-bit) |
| **Lingkungan Eksekusi** | PowerShell 5.0 (Desktop Edition) | PowerShell 5.1 / PowerShell 7.x |
| **Package Manager** | WinGet (Windows Package Manager) | WinGet versi terbaru |
| **Akses Jaringan** | Koneksi Internet Aktif (HTTP/HTTPS) | Broadband / High-speed Internet |
| **Hak Akses** | Administrator (*Elevated Privileges*) | Administrator (*Elevated Privileges*) |

## 5. Panduan Penggunaan   
### 5.1 Prasyarat Eksekusi  
Sebelum menjalankan skrip, buka terminal PowerShell sebagai Administrator, lalu aktifkan kebijakan eksekusi skrip (Execution Policy):   



```PowerShell  
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```  

### 5.2 Cara Eksekusi  
**Metode A: Eksekusi Langsung via Remote URL (Paling Cepat)**  
Jalankan satu baris perintah berikut di PowerShell Administrator:  



```PowerShell
iwr -useb https://raw.githubusercontent.com/narendra-akmal/Pintas/refs/heads/main/Pintas.ps1 | iex
```  

**Metode B: Unduh dan Jalankan Lokal** 
Unduh berkas skrip Pintas.ps1 dari repositori:
```PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/narendra-akmal/Pintas/refs/heads/main/Pintas.ps1" -OutFile "Pintas.ps1"
```  

Jalankan skrip:  
```PowerShell  
.\Pintas.ps1
```  

## 6. Pengujian dan Verifikasi  
Berdasarkan standar verifikasi dan validasi, keberhasilan instalasi paket dapat diperiksa melalui perintah berikut di terminal PowerShell:



```PowerShell
# 1. Memeriksa daftar aplikasi terpasang melalui WinGet
winget list --source winget

# 2. Verifikasi status pembaruan definisi Windows Defender
Get-MpComputerStatus | Select-Object AntivirusSignatureAge, AntivirusSignatureLastUpdated
```

## 7. Lisensi dan Hak Cipta  
Dokumen dan kode sumber ini didistribusikan di bawah MIT License. Hak Cipta (c) N. Akmal.
