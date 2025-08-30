Baik 🙂
Saya akan buatkan **README.md** untuk script ini agar terlihat profesional, rapi, dan mudah dipahami.

Berikut isinya:

````markdown
# WiFi Portal Updater

**WiFi Portal Updater** adalah script **Bash** untuk mempermudah proses pembaruan **MAC Address (BSSID)** dan **SSID** pada file **check.htm** dan **index.htm** di folder portal WiFi.  
Script ini juga memiliki fitur **scan jaringan WiFi** menggunakan `airodump-ng`, sehingga Anda dapat langsung memilih target jaringan yang ingin digunakan.

---

## ✨ Fitur Utama
- 🔍 **Pencarian Otomatis**  
  Mendeteksi semua folder yang berisi `check.htm` dan/atau `index.htm`.
- 📂 **Daftar Folder Rapi**  
  Menampilkan **nama folder saja**, bukan path lengkap, agar tampilan lebih bersih.
- 🗂 **Backup Otomatis**  
  Membuat backup folder sebelum melakukan perubahan.
- 📡 **Scan WiFi**  
  Terintegrasi dengan `airodump-ng` untuk memindai jaringan WiFi di sekitar.
- 🛠 **Update Otomatis**  
  Mengganti MAC Address & SSID di `check.htm` dan `index.htm` sesuai target WiFi yang dipilih.
- 📜 **Hasil Scan Tersimpan**  
  File hasil scan otomatis disimpan dan dapat digunakan ulang tanpa melakukan scan baru.

---

## 📌 Persyaratan

Pastikan Anda sudah menginstal paket berikut:

- **bash** → biasanya sudah tersedia di Linux
- **aircrack-ng** → untuk scan WiFi
- **sed** & **grep** → untuk memproses teks
- **sudo** → dibutuhkan untuk menjalankan mode monitor WiFi

Untuk menginstal `aircrack-ng` di Debian/Ubuntu:

```bash
sudo apt update && sudo apt install aircrack-ng -y
````

---

## 📥 Instalasi

Clone repository ini:

```bash
git clone https://github.com/username/wifi-portal-updater.git
cd wifi-portal-updater
```

Pastikan script dapat dieksekusi:

```bash
chmod +x wifi_portal_updater.sh
```

---

## 🚀 Cara Menggunakan

Jalankan script dengan perintah:

```bash
./wifi_portal_updater.sh
```

### 1️⃣ Pilih Folder Target

Script akan menampilkan daftar **folder yang berisi `check.htm` atau `index.htm`**.
Contoh tampilan:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Daftar Folder yang Berisi check.htm / index.htm
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 1. Portal_A
 2. Portal_B
 3. Portal_C
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pilih nomor folder yang ingin diubah: 2

✔ Folder dipilih: /home/user/project/Portal_B
```

---

### 2️⃣ Lihat Data Lama

Script otomatis menampilkan **MAC Address lama** dan **SSID lama** dari folder tersebut:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Informasi Data Lama
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 MAC Address Lama : AA:BB:CC:DD:EE:FF
 SSID Lama        : MyWiFi
```

---

### 3️⃣ Lakukan Scan WiFi (Opsional)

Anda akan ditanya apakah ingin melakukan scan WiFi:

```
Apakah Anda ingin melakukan scan WiFi terlebih dahulu? (y/n):
```

* Jika memilih **y** → script akan memulai **mode monitor** dan menjalankan `airodump-ng`
* Jika memilih **n** → Anda bisa memilih dari **file hasil scan sebelumnya**

---

### 4️⃣ Pilih Target WiFi

Setelah scan selesai, daftar WiFi akan ditampilkan:

```
NO  ESSID                          BSSID                CH
1   RumahKu                        00:11:22:33:44:55    6
2   KantorNet                      AA:BB:CC:DD:EE:FF    11
3   CafeFree                       11:22:33:44:55:66    1
```

Masukkan nomor WiFi target.
Script akan mengganti **BSSID** dan **SSID** di file `check.htm` dan `index.htm`.

---

### 5️⃣ Backup Otomatis

Sebelum mengubah file, script akan membuat **backup otomatis**:

```
✔ Backup berhasil!
Lokasi backup: /home/user/wifi-portal-updater/backup-portal/backup-Portal_B-MyWiFi-2025XXXX_XXXXXX
```

---

## 📂 Struktur Folder

```
wifi-portal-updater/
├── wifi_portal_updater.sh      # Script utama
├── backup-portal/              # Folder backup otomatis
├── scan_results/               # Hasil scan WiFi disimpan di sini
└── README.md                   # Dokumentasi
```

---

## ⚠️ Catatan Penting

* Script ini **harus dijalankan dengan akses sudo** jika ingin melakukan scan WiFi.
* Pastikan adapter WiFi Anda mendukung **monitor mode**.
* Jangan gunakan script ini pada jaringan yang bukan milik Anda.
  **Gunakan secara etis dan legal.**

---

## 🧑‍💻 Kontribusi

Jika ingin menambahkan fitur atau menemukan bug, silakan buka **Pull Request** atau laporkan **Issue**.

---

## 📜 Lisensi

Script ini dirilis di bawah lisensi **MIT**.
Anda bebas menggunakannya, memodifikasi, dan menyebarkannya.

---

## 💡 Tips

Jika ingin **mempercepat proses update**, Anda bisa langsung menggunakan hasil scan sebelumnya tanpa melakukan scan ulang.
Caranya, jawab **n** ketika diminta melakukan scan WiFi.

```
Apakah Anda ingin melakukan scan WiFi terlebih dahulu? (y/n): n
```

---

## 🏷 Versi

* **Versi Terbaru:** v1.2
* **Update:** 31 Agustus 2025
* **Perubahan Terbaru:**

  * ✅ Menampilkan **nama folder saja** di daftar
  * ✅ Menampilkan **path lengkap** setelah folder dipilih
  * ✅ Perbaikan tampilan agar lebih bersih dan rapi

---

## 👨‍💻 Pembuat

**Author**: \[Nama Kamu]
**Email**: \[email kamu]
**GitHub**: [https://github.com/username](https://github.com/username)

```

---

Kalau kamu mau, saya bisa menambahkan **preview screenshot** contoh tampilan terminal di README supaya lebih menarik dan profesional.  
Mau saya tambahkan sekalian?
```
