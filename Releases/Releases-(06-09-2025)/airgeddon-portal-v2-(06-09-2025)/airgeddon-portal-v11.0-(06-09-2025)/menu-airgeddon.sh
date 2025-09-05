#!/bin/bash
# =====================================================================================
# Script  : utama.sh
# Fungsi  : Menjalankan menu interaktif:
#           1. replace-mac-portal.sh → mengganti konfigurasi portal
#           2. copy-file.sh → menyalin file portal
#           3. Menjalankan airgeddon di terminal baru TANPA memblokir proses utama
# Penulis : IT Project
# =====================================================================================

set -e

# -------------------------------
# Warna ANSI
# -------------------------------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
RESET='\033[0m'

# -------------------------------
# Path Script
# -------------------------------
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_DIR="$BASE_DIR/assets/file-sh"
PORTAL_DIR="$BASE_DIR/assets/portal"
TARGET_DIR="/tmp/ag1/www"

# -------------------------------
# Fungsi Deteksi Terminal Emulator
# -------------------------------
function detect_terminal() {
    for term in qterminal xfce4-terminal gnome-terminal konsole tilix alacritty kitty terminator xterm; do
        if command -v "$term" &>/dev/null; then
            echo "$term"
            return 0
        fi
    done
    return 1
}

# -------------------------------
# Fungsi Header Menu
# -------------------------------
function header_menu() {
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "                ${MAGENTA}📌 MENU UTAMA${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${YELLOW}1.${RESET} Replace MAC Portal       → ${BLUE}replace-mac-portal.sh${RESET}"
    echo -e "  ${YELLOW}2.${RESET} Copy Portal            → ${BLUE}copy-file.sh${RESET}"
    echo -e "  ${YELLOW}3.${RESET} Jalankan Airgeddon     → ${BLUE}terminal baru${RESET}"
    echo -e "  ${YELLOW}0.${RESET} Keluar"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# -------------------------------
# Fungsi Replace MAC Portal
# -------------------------------
function replace_mac_portal() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "🔄  ${YELLOW}Menjalankan proses replace-mac-portal.sh...${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    bash "$SCRIPT_DIR/replace-mac-portal.sh" "$PORTAL_DIR"
    echo -e "\n${GREEN}✅ Proses replace selesai.${RESET}\n"
    read -rp "Tekan [Enter] untuk kembali ke menu..."
}


# -------------------------------
# Fungsi Copy Portal
# -------------------------------
function copy_file_portal() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "📂  ${YELLOW}Menyalin file dari portal ke Tujuan-Copy...${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # Jalankan script copy-file.sh di subshell terisolasi
    # Jika copy-file.sh exit 1, utama.sh TIDAK AKAN keluar
    bash -c "sudo bash \"$SCRIPT_DIR/copy-file.sh\" \"$PORTAL_DIR\" \"$TARGET_DIR\"" || STATUS=$?
    
    # Kalau belum ada STATUS (berarti sukses), isi manual
    STATUS=${STATUS:-0}

    # Cek status hasil eksekusi
    if [[ $STATUS -eq 0 ]]; then
        echo -e "\n${GREEN}✅ Semua file berhasil disalin ke:${RESET} ${CYAN}$TARGET_DIR${RESET}\n"
    else
        echo -e "\n${RED}❌ Proses penyalinan GAGAL.${RESET}"
        echo -e "${YELLOW}⚠ Periksa pesan error di atas.${RESET}\n"
    fi

    read -rp "Tekan [Enter] untuk kembali ke menu..."
}




# -------------------------------
# Fungsi Jalankan Airgeddon dengan Judul Terminal
# -------------------------------
function jalankan_airgeddon() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "🚀  ${YELLOW}Membuka terminal baru untuk menjalankan airgeddon...${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    TERMINAL=$(detect_terminal)

    if [[ -z "$TERMINAL" ]]; then
        echo -e "${RED}❌ Tidak ada terminal emulator yang tersedia.${RESET}"
        echo -e "Silakan install salah satu terminal: qterminal, xfce4-terminal, gnome-terminal, konsole, xterm"
        return
    fi

    TITLE="Airgeddon"

    case "$TERMINAL" in
        qterminal)
            qterminal --title "$TITLE" -e "sudo airgeddon" & disown
            ;;
        xfce4-terminal)
            xfce4-terminal --title="$TITLE" -- bash -c "sudo airgeddon" & disown
            ;;
        gnome-terminal)
            gnome-terminal --title="$TITLE" -- bash -c "sudo airgeddon" & disown
            ;;
        konsole)
            konsole --title "$TITLE" -e "bash -c 'sudo airgeddon'" & disown
            ;;
        tilix)
            tilix --title="$TITLE" -e "bash -c 'sudo airgeddon'" & disown
            ;;
        alacritty)
            alacritty --title "$TITLE" -e sudo airgeddon & disown
            ;;
        kitty)
            kitty --title "$TITLE" sudo airgeddon & disown
            ;;
        terminator)
            terminator --title="$TITLE" -e "sudo airgeddon" & disown
            ;;
        xterm)
            xterm -T "$TITLE" -e "sudo airgeddon" & disown
            ;;
        *)
            echo -e "${RED}❌ Terminal emulator tidak dikenali.${RESET}"
            return
            ;;
    esac

    echo -e "${GREEN}✅ Airgeddon berjalan di terminal baru: ${YELLOW}$TERMINAL${RESET}"
    sleep 1
}

# -------------------------------
# Loop Menu Utama
# -------------------------------
while true; do
    header_menu
    read -rp "Pilih Nomor : " pilihan
    case "$pilihan" in
        1) replace_mac_portal ;;
        2) copy_file_portal ;;
        3) jalankan_airgeddon ;;
        0) echo -e "${GREEN}Keluar dari program. 👋${RESET}"; exit 0 ;;
        *) echo -e "${RED}❌ Pilihan tidak valid. Coba lagi.${RESET}"; sleep 1 ;;
    esac
done
