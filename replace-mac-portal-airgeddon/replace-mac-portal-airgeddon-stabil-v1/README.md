Baik 🙂. Aku akan membuatkan file **README.md** yang profesional, rapi, dan mudah dipahami untuk skrip **WiFi Portal Updater** yang sudah kita buat.
README ini akan mencakup:

* Deskripsi proyek
* Fitur-fitur
* Persyaratan
* Cara instalasi & penggunaan
* Contoh alur penggunaan
* Struktur folder

Berikut **README.md**-nya:

```markdown
# WiFi Portal Updater

![Bash](https://img.shields.io/badge/Script-Bash-green?logo=gnu-bash)
![Linux](https://img.shields.io/badge/OS-Linux-blue?logo=linux)
![Aircrack-ng](https://img.shields.io/badge/Dependency-Aircrack--ng-orange?logo=wifi)

---

## 📌 Deskripsi
**WiFi Portal Updater** adalah skrip berbasis **Bash** yang digunakan untuk:
- **Melakukan scan jaringan WiFi** secara otomatis menggunakan `airodump-ng`.
- Menampilkan daftar hasil scan dan menyimpannya dalam file `.csv`.
- Mengubah **MAC Address (BSSID)** dan **SSID** pada file `check.htm` dan `index.htm` di portal WiFi.
- Membuat **backup otomatis** sebelum perubahan dilakukan.

Skrip ini cocok digunakan pada sistem Linux dengan dukungan mode monitor seperti Kali Linux, Parrot OS, atau distro lainnya.

---

## ✨ Fitur Utama

### 🔍 1. Scan WiFi Otomatis
- Menggunakan `airodump-ng` untuk mendeteksi WiFi di sekitar.
- Hasil scan disimpan dalam folder `scan_results/` dalam format `.csv`.
- Hasil scan terbaru langsung digunakan untuk proses berikutnya.

### 🗂 2. Pilih File Hasil Scan Lama
- Jika tidak ingin scan baru, pengguna bisa memilih dari daftar file hasil scan yang sudah ada.

### 📝 3. Update BSSID & SSID
- Skrip akan memindai file `check.htm` dan `index.htm` dalam portal WiFi.
- Mengganti **MAC Address** dan **SSID** dengan target WiFi yang dipilih.

### 💾 4. Backup Otomatis
- Sebelum melakukan perubahan, skrip otomatis membuat backup dengan format:
```

backup-portal/backup-\[nama\_folder]-\[SSID]-\[timestamp]/

````

### 🎨 5. Tampilan Berwarna & Interaktif
- Output terminal lebih rapi dan informatif.
- Menampilkan tabel untuk hasil scan WiFi.
- Menggunakan simbol ✔ dan ✘ untuk mempermudah membaca status.

---

## 📦 Persyaratan

Sebelum menggunakan skrip ini, pastikan Anda sudah menginstal:

- **Aircrack-ng** (untuk `airodump-ng`)
- **Grep**, **Sed**, **Awk** (umumnya sudah ada di Linux)
- Akses **root** atau **sudo**

Instalasi Aircrack-ng di Debian/Kali:
```bash
sudo apt update && sudo apt install aircrack-ng -y
````

---

## ⚙️ Instalasi

```bash
# Clone repository
git clone https://github.com/username/wifi-portal-updater.git

# Masuk ke folder
cd wifi-portal-updater

# Berikan izin eksekusi
chmod +x wifi_portal_updater.sh
```

---

## 🚀 Cara Penggunaan

### **1. Jalankan Skrip**

```bash
./wifi_portal_updater.sh
```

### **2. Pilih Folder Target**

Skrip akan menampilkan daftar folder yang berisi `check.htm` dan `index.htm`.
Masukkan nomor folder yang ingin diubah.

### **3. Pilih Mode Scan**

* **Y / y** → Melakukan scan WiFi baru.
* **N / n** → Melewati scan dan langsung menggunakan daftar file scan lama.

### **4. Pilih Target WiFi**

Skrip akan menampilkan daftar WiFi hasil scan dalam bentuk tabel:

| NO | ESSID      | BSSID                  | CH |
| -- | ---------- | ---------------------- | -- |
| 1  | MyWiFi     | AA\:BB\:CC\:DD\:EE\:FF | 6  |
| 2  | Cafe\_Free | 11:22:33:44:55:66      | 11 |

Masukkan nomor WiFi target.

### **5. Proses Update**

* Backup otomatis dibuat.
* File `check.htm` dan `index.htm` diperbarui sesuai WiFi target.
* Notifikasi sukses ditampilkan.

---

## 📂 Struktur Folder

```
wifi-portal-updater/
├── wifi_portal_updater.sh      # Skrip utama
├── backup-portal/              # Folder penyimpanan backup otomatis
│   ├── backup-[folder]-[SSID]-[timestamp]/
├── scan_results/               # Folder hasil scan WiFi (.csv)
└── README.md                   # Dokumentasi
```

---

## ⚠️ Catatan Penting

* Gunakan skrip ini **hanya untuk keperluan pribadi atau pembelajaran**.
* Pastikan memiliki hak akses terhadap jaringan WiFi yang ingin dipantau.
* Gunakan pada sistem berbasis Linux dengan dukungan **mode monitor**.

---

## 🧑‍💻 Kontribusi

Jika ingin berkontribusi, silakan lakukan **pull request** atau ajukan **issue** di repository.

---

## 📄 Lisensi

Skrip ini dirilis di bawah lisensi **MIT**.
Silakan gunakan, modifikasi, dan distribusikan sesuai kebutuhan.

---

**Dibuat dengan ❤️ oleh \[Nama Kamu]**

```

---

Kalau mau lebih lengkap, aku bisa tambahkan **contoh screenshot** hasil scan dan proses update agar README ini lebih menarik.  
Mau saya tambahkan?
```
