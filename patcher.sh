#!/bin/bash
mmcroot="$HOME/.local/share/multimc"

debug="0"

if [ $debug == "1" ]; then
	#set -x
	echo "[DEBUG] DEBUG is enabled!"
fi

if which java 2> /dev/null > /dev/null; then
	javaarch=$(java -version 2>&1 | grep -io "..-Bit" | cut -d- -f1)
fi

archsuffix=

case $(uname -m) in
	x86_64)
		if [[ $javaarch == 32 ]]; then
			echo "[ERROR] 32-bit x86 is not supported."
			exit 1
		fi
		;;
	aarch64)
		if [[ $javaarch == 64 ]]; then
			archsuffix=-arm64
		else
			archsuffix=-arm32
		fi
		;;
	armhf)
		archsuffix=-arm32
		;;
	*)
		echo "[ERROR] This architecture is not supported."
		exit 1
		;;
esac
if [ $debug == "1" ]; then
	echo "[DEBUG] System architecture: $(uname -m)"
	echo "[DEBUG] JVM architecture: $javaarch-bit"
fi
if [[ "$#" -ne 1 ]]; then
	echo "[ERROR] Incorrect Usage!"
	echo "[INFO] Usage: $0 <instance-name>"
	exit 1
fi

instancedir="${mmcroot}/instances/$1"
if [[ ! -d "$instancedir" ]]; then
	echo "[ERROR] Could not find instance $1! ($instancedir)"
	exit 1
fi

# FIXME this is fragile
mcline=$(awk '/net.minecraft/{ print NR; exit }' "$instancedir/mmc-pack.json")
mcver=$(tail -n +$mcline "$instancedir/mmc-pack.json" | \
	grep version | head -n 1 | cut -d\" -f4)

mkdir -p "$instancedir/patches"
cp "$mmcroot/meta/net.minecraft/$mcver.json" \
	"$instancedir/patches/net.minecraft.json"

lwjglver="$(grep suggests < "$instancedir/patches/net.minecraft.json" | cut -d\" -f4)"
lwjglvernum="$(echo "$lwjglver" | sed "s/\.//g" | cut -d\- -f1)"

if [[ $lwjglvernum -le 300 ]]; then
	if [ $debug == 1 ]; then
		echo "[DEBUG] Using patch for LWJGL2"
	fi
	cp  $mmcroot/patches/org.lwjgl.json $instancedir/patches/
  echo "Done Minecraft 1.12.2 and under should work now :D"
  fi
