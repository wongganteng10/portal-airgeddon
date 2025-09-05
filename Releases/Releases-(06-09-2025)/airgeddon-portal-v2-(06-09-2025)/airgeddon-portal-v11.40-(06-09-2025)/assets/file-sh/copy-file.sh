#!/bin/bash
# =====================================================================================
# Script  : copy-file.sh
# Fungsi  : Menyalin file dari folder portal yang dipilih user ke folder tujuan.
#           - Menampilkan daftar folder & subfolder portal
#           - Menampilkan detail folder sebelum copy
#           - Jika file sudah ada → replace otomatis
#           - Mendukung opsi otomatis (-y, -b, -a)
# =====================================================================================

set -o pipefail

# -----------------------------#
#  Warna Terminal
# -----------------------------#
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
BOLD='\033[1m'
RESET='\033[0m'

# -----------------------------#
#  Variabel Utama
# -----------------------------#
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PORTAL_DIR="$BASE_DIR/assets/portal"
TARGET_DIR="/tmp/ag1/www"

AUTO_CREATE=0    # otomatis buat folder tujuan jika belum ada
AUTO_COPY=0      # skip konfirmasi
COPY_ALL=0       # copy semua file + subfolder

# -----------------------------#
#  Fungsi bantuan
# -----------------------------#
show_help() {
  cat <<EOF
${BOLD}Penggunaan:${RESET}
  ./copy-file.sh [TARGET_DIR] [opsi]

${BOLD}Opsi:${RESET}
  ${GREEN}-b, --buat${RESET}       : Buat folder target jika belum ada
  ${GREEN}-y, --yes${RESET}        : Lewati konfirmasi (langsung copy)
  ${GREEN}-a, --all-files${RESET}  : Salin semua file & subfolder

${BOLD}Contoh:${RESET}
  ./copy-file.sh                       # interaktif, target default
  ./copy-file.sh ~/backup              # interaktif, target=~/backup
  ./copy-file.sh ~/backup -b -y        # buat folder + skip konfirmasi
EOF
}

# -----------------------------#
#  Parsing argumen
# -----------------------------#
for arg in "$@"; do
  case "$arg" in
    -h|--help) show_help; exit 0 ;;
    -b|--buat) AUTO_CREATE=1 ;;
    -y|--yes)  AUTO_COPY=1 ;;
    -a|--all-files) COPY_ALL=1 ;;
    *)
      # kalau bukan opsi, anggap sebagai target folder
      TARGET_DIR="$arg"
      ;;
  esac
done

# Jika tidak ada target, pakai default
TARGET_DIR="${TARGET_DIR:-$BASE_DIR/assets/Tujuan-Copy}"

# -----------------------------#
#  Pastikan folder portal ada
# -----------------------------#
if [[ ! -d "$PORTAL_DIR" ]]; then
  echo -e "${RED}❌ Folder portal tidak ditemukan:${RESET} $PORTAL_DIR"
  exit 1
fi

# -----------------------------#
#  Validasi / Buat folder target
# -----------------------------#
if [[ ! -d "$TARGET_DIR" ]]; then
  if [[ "$AUTO_CREATE" -eq 1 ]]; then
    echo "📂 Membuat folder tujuan: $TARGET_DIR"
    mkdir -p "$TARGET_DIR" || {
      echo -e "${RED}❌ Gagal membuat folder tujuan.${RESET}"
      exit 1
    }
  else
    echo -e "\n❌ ${RED}Folder tujuan tidak ditemukan:${RESET}"
    echo -e "   ${CYAN}$TARGET_DIR${RESET}"
    echo -e "\n⚠️  ${YELLOW}Solusi:${RESET}"
    echo -e "   • Buat folder manual, atau"
    echo -e "   • Jalankan:\n"
    echo -e "     ${GREEN}./copy-file.sh \"$TARGET_DIR\" -b${RESET}\n"
    exit 1
  fi
fi

# -----------------------------#
#  Fungsi wrap teks panjang
# -----------------------------#
wrap_text() {
  local text="$1"
  local cols
  cols=$(tput cols)
  echo "$text" | fold -s -w "$cols"
}

# -----------------------------#
#  Fungsi tampilkan daftar folder portal
# -----------------------------#
tampilkan_daftar_folder() {
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${CYAN}${BOLD}                DAFTAR FOLDER${RESET}"
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

  mapfile -t folders < <(find "$PORTAL_DIR" -mindepth 1 -type d | sort)

  if [[ ${#folders[@]} -eq 0 ]]; then
    echo "❌ Tidak ada folder yang bisa dipilih."
    exit 1
  fi

  for i in "${!folders[@]}"; do
    folder_name=$(realpath --relative-to="$PORTAL_DIR" "${folders[$i]}")
    printf " ${YELLOW}%2d.${RESET} %s\n" "$((i + 1))" "$folder_name"
  done

  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# -----------------------------#
#  Fungsi tampilkan detail folder
# -----------------------------#
tampilkan_info_folder() {
  local folder="$1"
  echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "📂 ${BOLD}Informasi Folder Terpilih:${RESET}"
  echo -e "Path Lengkap   : ${CYAN}$(wrap_text "$folder")${RESET}"
  echo -e "Ukuran Total   : $(du -sh "$folder" | cut -f1)"
  echo -e "Jumlah File    : $(find "$folder" -type f | wc -l)"
  echo -e "Jumlah Subdir  : $(find "$folder" -type d | wc -l)"
  echo -e "Terakhir Ubah  : $(stat -c '%y' "$folder" | cut -d'.' -f1)"
  echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# -----------------------------#
#  Proses pemilihan folder
# -----------------------------#
while true; do
  tampilkan_daftar_folder

  read -p "Pilih nomor folder yang ingin disalin: " pilihan
  [[ -z "$pilihan" ]] && { echo "⚠️  Input tidak boleh kosong."; continue; }
  [[ ! "$pilihan" =~ ^[0-9]+$ ]] && { echo "⚠️  Input harus berupa angka."; continue; }

  mapfile -t folders < <(find "$PORTAL_DIR" -mindepth 1 -type d | sort)
  if (( pilihan < 1 || pilihan > ${#folders[@]} )); then
    echo "⚠️  Pilihan tidak valid. Masukkan angka 1..${#folders[@]}."
    continue
  fi

  SELECTED_FOLDER="${folders[$((pilihan - 1))]}"
  tampilkan_info_folder "$SELECTED_FOLDER"

  [[ "$AUTO_COPY" -eq 1 ]] && break

  read -p "Apakah pilihan ini sudah benar? (y/n): " konfirmasi
  if [[ "$konfirmasi" =~ ^[Yy]$ ]]; then
    break
  else
    echo "🔄 Kembali ke daftar folder..."
    sleep 1
  fi
done

# -----------------------------#
#  Proses penyalinan file
# -----------------------------#
echo ""
echo -e "📂 Menyalin file dari : ${CYAN}\"$SELECTED_FOLDER\"${RESET}"
echo -e "📂 Ke folder tujuan   : ${CYAN}\"$TARGET_DIR\"${RESET}"
echo ""

shopt -s nullglob
if [[ "$COPY_ALL" -eq 1 ]]; then
  cp -rf "$SELECTED_FOLDER"/* "$TARGET_DIR"/
  echo -e "✅ ${GREEN}Semua file & subfolder berhasil disalin.${RESET}"
else
  files=("$SELECTED_FOLDER"/*)
  count=0
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      cp -f -- "$file" "$TARGET_DIR"/
      echo "🔄 Menyalin: $(basename "$file")"
      ((count++))
    fi
  done

  if (( count == 0 )); then
    echo "⚠️  Tidak ada file di \"$SELECTED_FOLDER\" untuk disalin."
  else
    echo -e "✅ ${GREEN}$count file berhasil disalin ke \"$TARGET_DIR\".${RESET}"
  fi
fi

echo ""
echo -e "📄 ${BOLD}Daftar isi di \"$TARGET_DIR\":${RESET}"
tree "$TARGET_DIR" 2>/dev/null || ls -R "$TARGET_DIR"
