#!/bin/bash
# =====================================================================================
# Script  : replace-mac-portal.sh
# Fungsi  : Mengganti MAC Address (BSSID) & SSID pada check.htm & index.htm
#           - Menampilkan daftar folder portal
#           - Backup otomatis sebelum mengubah file
#           - Scan WiFi & pilih target BSSID/SSID
# =====================================================================================

set -o pipefail

# -----------------------------#
#  Warna Terminal
# -----------------------------#
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
RESET='\033[0m'

# -----------------------------#
#  Path Utama
# -----------------------------#
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PORTAL_DIR="$BASE_DIR/assets/portal"
SCAN_DIR="$BASE_DIR/assets/scan_results"
BACKUP_ROOT="$BASE_DIR/assets/portal/backup-portal"
mkdir -p "$SCAN_DIR" "$BACKUP_ROOT"

# -----------------------------#
#  Fungsi Wrap Text Panjang
# -----------------------------#
wrap_text() {
  local text="$1"
  local cols
  cols=$(tput cols)
  echo "$text" | fold -s -w "$cols"
}

# -----------------------------#
#  Menampilkan Daftar Folder
# -----------------------------#
tampilkan_daftar_folder() {
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${CYAN}${BOLD}                DAFTAR FOLDER${RESET}"
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  mapfile -t folders < <(find "$PORTAL_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

  if [[ ${#folders[@]} -eq 0 ]]; then
    echo "❌ Tidak ada folder yang bisa dipilih."
    exit 1
  fi

  for i in "${!folders[@]}"; do
    folder_name=$(basename "${folders[$i]}")
    printf " ${YELLOW}%2d.${RESET} %s\n" "$((i + 1))" "$folder_name"
  done

  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# -----------------------------#
#  Menampilkan Informasi Folder
# -----------------------------#
tampilkan_info_folder() {
  local folder="$1"
  echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "📂 ${BOLD}Informasi Folder Terpilih:${RESET}"
  echo -e "Path Lengkap   : ${CYAN}$(wrap_text "$folder")${RESET}"
  echo -e "Ukuran Total   : $(du -sh "$folder" | cut -f1)"
  echo -e "Jumlah File    : $(find "$folder" -maxdepth 1 -type f | wc -l)"
  echo -e "Jumlah Subdir  : $(find "$folder" -mindepth 1 -type d | wc -l)"
  echo -e "Terakhir Ubah  : $(stat -c '%y' "$folder" | cut -d'.' -f1)"
  echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# -----------------------------#
#  Pemilihan Folder Portal
# -----------------------------#
while true; do
  tampilkan_daftar_folder

  read -p "Pilih nomor folder yang ingin diubah: " pilihan
  [[ -z "$pilihan" ]] && { echo "⚠️  Input tidak boleh kosong."; continue; }
  [[ ! "$pilihan" =~ ^[0-9]+$ ]] && { echo "⚠️  Input harus berupa angka."; continue; }

  mapfile -t folders < <(find "$PORTAL_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
  if (( pilihan < 1 || pilihan > ${#folders[@]} )); then
    echo "⚠️  Pilihan tidak valid. Masukkan angka 1..${#folders[@]}."
    continue
  fi

  SELECTED_FOLDER="${folders[$((pilihan - 1))]}"
  tampilkan_info_folder "$SELECTED_FOLDER"
  read -p "Apakah pilihan ini sudah benar? (y/n): " konfirmasi
  if [[ "$konfirmasi" =~ ^[Yy]$ ]]; then
    break
  fi
done

# -----------------------------#
#  Ambil MAC & SSID Lama
# -----------------------------#
OLD_BSSID=""
OLD_ESSID=""
for F in "$SELECTED_FOLDER"/*; do
  FILE_NAME=$(basename "$F")
  if [[ "$FILE_NAME" == "check.htm" ]]; then
    OLD_BSSID=$(grep -oE '\b([0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5})\b' "$F" | head -n1)
  elif [[ "$FILE_NAME" == "index.htm" ]]; then
    OLD_ESSID=$(grep -oP '(?<=<b><span>).*?(?=</span></b>)' "$F" | head -n1)
  fi
done

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW} Informasi Data Lama${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
printf " ${BLUE}%-15s${RESET}: %s\n" "MAC Lama" "$OLD_BSSID"
printf " ${BLUE}%-15s${RESET}: %s\n" "SSID Lama" "$OLD_ESSID"

# -----------------------------#
#  Scan WiFi
# -----------------------------#
INTERFACE="wlan0"
MON_INTERFACE="wlan0mon"
FILE_TERPILIH=""

do_scan() {
  echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${YELLOW} Scanning WiFi${RESET}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  echo -e "${YELLOW}▶ Mengaktifkan mode monitor pada ${BLUE}$INTERFACE${RESET}..."
  sudo airmon-ng start "$INTERFACE" >/dev/null 2>&1

  echo -e "${YELLOW}▶ Scanning WiFi, tekan ${GREEN}CTRL+C${YELLOW} untuk menghentikan...${RESET}"
  sudo airodump-ng \
    --write-interval 1 \
    --output-format csv \
    --write "$SCAN_DIR/scan" \
    "$MON_INTERFACE"

  echo -e "\n${YELLOW}▶ Menonaktifkan mode monitor pada ${BLUE}$MON_INTERFACE${RESET}..."
  sudo airmon-ng stop "$MON_INTERFACE" >/dev/null 2>&1

  NEW_SCAN_FILE=$(ls -t "$SCAN_DIR"/*.csv 2>/dev/null | head -n1)
  if [ -z "$NEW_SCAN_FILE" ]; then
    echo -e "${RED}✘ Hasil scan tidak ditemukan!${RESET}"
    exit 1
  fi

  FILE_TERPILIH="$NEW_SCAN_FILE"
}

mapfile -t FILES_SCAN < <(find "$SCAN_DIR" -type f -name "*scan*.csv" | sort)
if [ ${#FILES_SCAN[@]} -eq 0 ]; then
  echo -e "\n${YELLOW}⚠ Tidak ada hasil scan, memulai scan otomatis...${RESET}"
  do_scan
else
  echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  read -p "Apakah ingin scan WiFi baru? (y/n): " scan_choice
  if [[ "$scan_choice" =~ ^[Yy]$ ]]; then
    do_scan
  else
    echo -e "\n${CYAN} Daftar File Hasil Scan${RESET}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    for i in "${!FILES_SCAN[@]}"; do
      fname=$(basename "${FILES_SCAN[$i]}")
      echo -e " ${YELLOW}$((i+1)).${RESET} $fname"
    done
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    while true; do
      read -p "Pilih nomor file scan: " pilihan
      if [[ "$pilihan" =~ ^[0-9]+$ ]] && (( pilihan >= 1 && pilihan <= ${#FILES_SCAN[@]} )); then
        FILE_TERPILIH="${FILES_SCAN[$((pilihan-1))]}"
        break
      else
        echo -e "${RED}✘ Nomor tidak valid, ulangi.${RESET}"
      fi
    done
  fi
fi

# -----------------------------#
#  Parsing File Scan
# -----------------------------#
declare -a MAP
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW} Daftar WiFi Terdeteksi${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
printf "%-3s %-30s %-20s %-3s\n" "NO" "ESSID" "BSSID" "CH"

COUNT=1
while IFS= read -r LINE; do
  [[ "$LINE" == "BSSID"* || -z "$LINE" ]] && continue
  [[ "$LINE" == "Station MAC"* ]] && break
  BSSID=$(echo "$LINE" | cut -d',' -f1 | xargs)
  CH=$(echo "$LINE" | cut -d',' -f4 | xargs)
  ESSID=$(echo "$LINE" | awk -F',' '{for(i=14;i<=NF;i++){printf "%s ", $i}}' | xargs)
  printf "%-3s %-30s %-20s %-3s\n" "$COUNT." "$ESSID" "$BSSID" "$CH"
  MAP+=("$BSSID,$ESSID")
  ((COUNT++))
done < <(tail -n +2 "$FILE_TERPILIH")

# -----------------------------#
#  Pilih Target WiFi
# -----------------------------#
while true; do
  read -p "Pilih nomor target WiFi: " SEL
  if [[ "$SEL" =~ ^[0-9]+$ ]] && (( SEL >= 1 && SEL < COUNT )); then
    TARGET_INFO="${MAP[$((SEL-1))]}"
    TARGET_BSSID=$(echo "$TARGET_INFO" | cut -d',' -f1)
    TARGET_ESSID=$(echo "$TARGET_INFO" | cut -d',' -f2)
    break
  else
    echo -e "${RED}✘ Nomor tidak valid, ulangi.${RESET}"
  fi
done

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW} Target Dipilih${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
printf " ${BLUE}%-15s${RESET}: %s\n" "MAC Baru" "$TARGET_BSSID"
printf " ${BLUE}%-15s${RESET}: %s\n" "SSID Baru" "$TARGET_ESSID"

# -----------------------------#
#  Backup Folder Sebelum Ubah
# -----------------------------#
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/backup-$(basename "$SELECTED_FOLDER")-$OLD_ESSID-$TIMESTAMP"
cp -r "$SELECTED_FOLDER" "$BACKUP_DIR"
echo -e "\n${GREEN}✔ Backup berhasil!${RESET}"
echo -e "Lokasi backup: ${BLUE}$BACKUP_DIR${RESET}"

# -----------------------------#
#  Ganti MAC & SSID di File
# -----------------------------#
for F in "$SELECTED_FOLDER"/*; do
  FILE_NAME=$(basename "$F")
  if [[ "$FILE_NAME" == "check.htm" ]]; then
    sed -i "s|[0-9a-fA-F:]\{17\}|$TARGET_BSSID|g" "$F"
    echo -e "${GREEN}✔ MAC diganti di${RESET} $F"
  elif [[ "$FILE_NAME" == "index.htm" ]]; then
    sed -i "s|<b><span>.*</span></b>|<b><span>$TARGET_ESSID</span></b>|g" "$F"
    echo -e "${GREEN}✔ SSID diganti di${RESET} $F"
  fi
done

echo -e "\n${GREEN}✅ Proses selesai!${RESET}"
