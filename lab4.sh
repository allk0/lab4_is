#!/bin/bash
if [ $# -ne 1 ]; then
	echo "Błąd! wprowadź ściężkę do obrazu jako argument"
	exit 1
fi
NASZ_OBRAZ="$1"
if [ ! -f "$NASZ_OBRAZ" ]; then
	echo "Bład! nie ma takiego pliku"
	exit 1
fi
DYREKTYWA="$(dirname "$(readlink -f "$0")")/kopia"
MONTOWANIE="${DYREKTYWA}/mnt"
mkdir -p "$DYREKTYWA"
mkdir -p "$MONTOWANIE"
FORMAT_DATY=$(date +"%Y:%m:%d:%H:%M:%S")
NAZWA_PLIKU=$(basename "$NASZ_OBRAZ" .iso)
NASZA_KOPIA="${DYREKTYWA}/${NAZWA_PLIKU}_kopia_$FORMAT_DATY.iso"
dd if="$NASZ_OBRAZ" of="$NASZA_KOPIA" bs=4M status=progress
SHA1_ORIG=$(sha1sum "$NASZ_OBRAZ" | awk '{print $1}')
SHA1_KOPI=$(sha1sum "$NASZA_KOPIA" | awk '{print $1}')
MD5_ORIG=$(md5sum "$NASZ_OBRAZ" | awk '{print $1}')
MD5_KOPI=$(md5sum "$NASZA_KOPIA" | awk '{print $1}')
PLIK_KONTROLNY="sumy_kontrolne_$FORMAT_DATY.txt"
{
	echo "~~~SUMY KONTROLNE~~~"
	echo "	SHA1"
	echo "Obraz oryginalny: $SHA1_ORIG"
	echo "Kopia	      : $SHA1_KOPI"
	if [ "$SHA1_ORIG" == "$SHA1_KOPI" ]; then
		echo "Sumy kontrolne SHA1 się zgadzają"
	else
		echo "Sumy kontrolne SHA1 są różne"
	fi
	echo "	MD5"
	echo "Obraz oryginalny: $MD5_ORIG"
	echo "Kopia	      : $MD5_KOPI"
	if [ "$MD5_ORIG" == "$MD5_KOPI" ]; then
		echo "Sumy kontrolne MD5 się zgadzają"
	else
		echo "Sumy kontrolne MD5 się nie zgadzają"
	fi
} > "${DYREKTYWA}/${PLIK_KONTROLNY}" 

sudo  mount -o loop,ro "$NASZ_OBRAZ" "$MONTOWANIE"
