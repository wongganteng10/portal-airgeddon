#!/bin/bash
# ================================================================================================
#  Script : WiFi Portal Updater
#  Fungsi : Mengganti MAC Address (BSSID) & SSID pada file check.htm dan index.htm
#  Update : Menambahkan fitur scan WiFi menggunakan airodump-ng
# ================================================================================================

# -----------------------------#
#  Warna Terminal
# -----------------------------#
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# -----------------------------#
#  Direktori & Backup
# -----------------------------#
SCRIPT_DIR=$(dirname "$(realpath "$0")")
BACKUP_ROOT="$SCRIPT_DIR/backup-portal"
SCAN_DIR="$SCRIPT_DIR/scan_results"
mkdir -p "$BACKUP_ROOT" "$SCAN_DIR"

# -----------------------------#
#  Cari file check.htm/index.htm
# -----------------------------#
FILES=($(find "$SCRIPT_DIR" -type f \( -name "check.htm" -o -name "index.htm" \)))

if [ ${#FILES[@]} -eq 0 ]; then
    echo -e "${RED}✘ Tidak ada check.htm atau index.htm ditemukan di $SCRIPT_DIR${NC}"
    exit 1
fi

# -----------------------------#
#  List folder target
# -----------------------------#
declare -A FOLDER_MAP
declare -A NUM_TO_FOLDER
NUM=1

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW} Daftar Folder yang Berisi check.htm / index.htm${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

for F in "${FILES[@]}"; do
    DIR=$(dirname "$F")
    if [[ -z "${FOLDER_MAP[$DIR]}" ]]; then
        FOLDER_MAP[$DIR]=1
        echo -e " ${GREEN}$NUM.${NC} $DIR"
        NUM_TO_FOLDER[$NUM]="$DIR"
        ((NUM++))
    fi
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "Pilih nomor folder yang ingin diubah: " FOLDER_SEL
TARGET_DIR="${NUM_TO_FOLDER[$FOLDER_SEL]}"

if [ -z "$TARGET_DIR" ]; then
    echo -e "${RED}✘ Nomor folder tidak valid!${NC}"
    exit 1
fi

# -----------------------------#
#  Ambil MAC & SSID lama
# -----------------------------#
OLD_BSSID=""
OLD_ESSID=""
for F in "$TARGET_DIR"/*; do
    FILE_NAME=$(basename "$F")
    if [[ "$FILE_NAME" == "check.htm" ]]; then
        OLD_BSSID=$(grep -oE '\b([0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5})\b' "$F" | head -n1)
    elif [[ "$FILE_NAME" == "index.htm" ]]; then
        OLD_ESSID=$(grep -oP '(?<=<b><span>).*?(?=</span></b>)' "$F" | head -n1)
    fi
done

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW} Informasi Data Lama${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
printf " ${BLUE}%-15s${NC}: %s\n" "MAC Address Lama" "$OLD_BSSID"
printf " ${BLUE}%-15s${NC}: %s\n" "SSID Lama" "$OLD_ESSID"

# -----------------------------#
#  Backup Folder
# -----------------------------#
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/backup-$(basename "$TARGET_DIR")-$OLD_ESSID-$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
cp -r "$TARGET_DIR"/* "$BACKUP_DIR"/

echo -e "\n${GREEN}✔ Backup berhasil!${NC}"
echo -e "Lokasi backup: ${BLUE}$BACKUP_DIR${NC}"

# =================================================================================================
#  Tanya apakah mau melakukan scan WiFi
# =================================================================================================
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "Apakah Anda ingin melakukan scan WiFi terlebih dahulu? (y/n): " scan_choice

INTERFACE="wlan0"
MON_INTERFACE="wlan0mon"
NEW_SCAN_FILE=""

if [[ "$scan_choice" =~ ^[Yy]$ ]]; then
    echo -e "\n${YELLOW}▶ Memulai mode monitor pada ${BLUE}$INTERFACE${NC}..."
    sudo airmon-ng start "$INTERFACE" >/dev/null 2>&1

    echo -e "${YELLOW}▶ Scanning WiFi, tekan ${GREEN}CTRL+C${YELLOW} jika ingin menghentikan...${NC}"
    sudo airodump-ng \
        --write-interval 1 \
        --output-format csv \
        --write "$SCAN_DIR/scan" \
        "$MON_INTERFACE"

    echo -e "\n${YELLOW}▶ Menghentikan mode monitor pada ${BLUE}$MON_INTERFACE${NC}..."
    sudo airmon-ng stop "$MON_INTERFACE" >/dev/null 2>&1

    # Ambil file scan terbaru
    NEW_SCAN_FILE=$(ls -t "$SCAN_DIR"/*.csv 2>/dev/null | head -n1)
    if [ -z "$NEW_SCAN_FILE" ]; then
        echo -e "${RED}✘ Hasil scan tidak ditemukan!${NC}"
        exit 1
    fi
    echo -e "\n${GREEN}✔ Scan selesai!${NC}"
    echo -e "Hasil disimpan di: ${BLUE}$NEW_SCAN_FILE${NC}"

    FILE_TERPILIH="$NEW_SCAN_FILE"
else
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW} Daftar File Hasil Scan${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    mapfile -t FILES < <(find "$SCRIPT_DIR" -type f -name "*scan*.csv" | sort)

    if [ ${#FILES[@]} -eq 0 ]; then
        echo -e "${RED}✘ Tidak ada file hasil scan ditemukan di $SCRIPT_DIR${NC}"
        exit 1
    fi

    for i in "${!FILES[@]}"; do
        fname=$(basename "${FILES[$i]}")
        echo -e " ${GREEN}$((i+1)).${NC} $fname"
    done

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -p "Pilih nomor file scan: " pilihan

    if ! [[ "$pilihan" =~ ^[0-9]+$ ]] || [ "$pilihan" -lt 1 ] || [ "$pilihan" -gt ${#FILES[@]} ]; then
        echo -e "${RED}✘ Nomor tidak valid.${NC}"
        exit 1
    fi

    FILE_TERPILIH="${FILES[$((pilihan-1))]}"
fi

echo -e "\n${GREEN}✔ File hasil scan yang digunakan:${NC} $FILE_TERPILIH"

# -----------------------------#
#  Parsing file hasil scan
# -----------------------------#
declare -a MAP
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW} Daftar WiFi yang Terdeteksi${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
#  Pilih target WiFi
# -----------------------------#
read -p "Pilih nomor target WiFi: " SEL
SEL_INDEX=$((SEL-1))
TARGET_INFO="${MAP[$SEL_INDEX]}"
TARGET_BSSID=$(echo "$TARGET_INFO" | cut -d',' -f1)
TARGET_ESSID=$(echo "$TARGET_INFO" | cut -d',' -f2)

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW} Target Dipilih${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
printf " ${BLUE}%-15s${NC}: %s\n" "MAC Baru" "$TARGET_BSSID"
printf " ${BLUE}%-15s${NC}: %s\n" "SSID Baru" "$TARGET_ESSID"

# -----------------------------#
#  Ganti MAC & SSID pada file
# -----------------------------#
echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW} Mengubah Data pada check.htm & index.htm${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

for F in "$TARGET_DIR"/*; do
    FILE_NAME=$(basename "$F")
    if [[ "$FILE_NAME" == "check.htm" ]]; then
        sed -i "s|[0-9a-fA-F:]\{17\}|$TARGET_BSSID|g" "$F"
        echo -e "${GREEN}✔ MAC diganti di${NC} $F"
    elif [[ "$FILE_NAME" == "index.htm" ]]; then
        sed -i "s|<b><span>.*</span></b>|<b><span>$TARGET_ESSID</span></b>|g" "$F"
        echo -e "${GREEN}✔ SSID diganti di${NC} $F"
    fi
done

echo -e "\n${GREEN}✔ Proses selesai.${NC}"

