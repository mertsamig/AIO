#!/system/bin/sh



cleanup() {
	rm -rf "$MODPATH/common"
	rm -rf "$MODPATH/LICENSE"
	rm -rf "$MODPATH/README.md"
}

abort() {
	ui_print "$1"
	rm -rf "$MODPATH"
	rm -rf "$TMPDIR"
	exit 1
}

cp_ch() {
	opt=$(getopt -o nr -- "$@") BAK=true UBAK=true FOL=false
	eval set -- "$opt"
	while true; do
		case "$1" in
			-n)
				UBAK=false
				shift
				;;
			-r)
				FOL=true
				shift
				;;
			--)
				shift
				break
				;;
			*) abort "Invalid cp_ch argument $1! Aborting!" ;;
		esac
	done
	SRC="$1" DEST="$2" OFILES="$1"
	"$FOL" && OFILES=$(find "$SRC" -type f)
	[[ -z "$3" ]] && PERM=0777 || PERM="$3"
	case "$DEST" in
		"$TMPDIR"/* | "$MODULEROOT"/* | "$NVBASE/modules/$MODID"/*) BAK=false ;;
	esac
	for OFILE in "$OFILES"; do
		"$FOL" && {
			[[ "$(basename "$SRC")" == "$(basename "$DEST")" ]] && FILE=$(echo "$OFILE" | sed "s|$SRC|$DEST|") || FILE=$(echo "$OFILE" | sed "s|$SRC|$DEST/$(basename "$SRC")|")
		} || [[ -d "$DEST" ]] && FILE="$DEST/$(basename "$SRC")" || FILE="$DEST"
		"$BAK" && "$UBAK" && {
			[[ ! "$(grep "$FILE"$ "$INFO")" ]] && echo "$FILE" >>"$INFO"
			[[ -f "$FILE" -a ! -f $FILE~ ]] && {
			mv -f "$FILE" "$FILE"~
			echo "$FILE"~ >>"$INFO"
		} || "$BAK" && [[ ! "$(grep "$FILE"$ "$INFO")" ]] && echo "$FILE" >>"$INFO"
	}
		install -D -m "$PERM" "$OFILE" "$FILE"
	done
}

install_script() {
	case "$1" in
		-l)
			shift
			INPATH="$NVBASE/service.d"
			;;
		-p)
			shift
			INPATH="$NVBASE/post-fs-data.d"
			;;
		*) INPATH="$NVBASE/service.d" ;;
	esac
	[[ "$(grep "#!/system/bin/sh" "$1")" ]] || sed -i "1i #!/system/bin/sh" "$1"
	for i in "MODPATH" "LIBDIR" "MODID" "INFO" "MODDIR"; do
		case "$i" in
			"MODPATH") sed -i "1a $i=$NVBASE/modules/$MODID" "$1" ;;
			"MODDIR") sed -i "1a $i=\${0%/*}" "$1" ;;
			*) sed -i "1a $i=$(eval echo \$$i)" "$1" ;;
		esac
	done
	[[ "$1" == "$MODPATH/uninstall.sh" ]] && return 0
	case $(basename "$1") in
		post-fs-data.sh | service.sh) ;;
		*) cp_ch -n "$1" "$INPATH"/"$(basename "$1")" 0777 ;;
	esac
}

"$DEBUG" && {
	ui_print "[*] Debug mode"
	ui_print "    Module install log will include debug info"
	ui_print ""
	set -x
}

unzip -o "$ZIPFILE" -x 'META-INF/*' 'common/functions.sh' -d "$MODPATH" >&2

ui_print "[*] Removing old files..."

[[ -f "$INFO" ]] && {
	while read LINE; do
		[[ "$(echo -n "$LINE" | tail -c 1)" == "~" ]] && continue || [[ -f $LINE~ ]] && mv -f "$LINE"~ "$LINE" || rm -f "$LINE"
			while true; do
				LINE=$(dirname "$LINE")
				[[ "$(ls -A "$LINE")" ]] && break 1 || rm -rf "$LINE"
			done
	done <"$INFO"
	rm -f "$INFO"
}

ui_print "[*] Installing for $ARCH SDK $API device..."
for i in $(find "$MODPATH" -type f -name *.sh -o -name *.prop -o -name *.rule); do
	[[ -f "$i" ]] && {
		sed -i -e "/^#/d" -e "/^ *$/d" "$i"
		[[ "$(tail -1 "$i")" ]] && echo "" >>"$i"
	} || continue
	case "$i" in
		"$MODPATH/service.sh") install_script -l "$i" ;;
		"$MODPATH/post-fs-data.sh") install_script -p "$i" ;;
		"$MODPATH/uninstall.sh") [[ -s "$INFO" ]] || [[ "$(head -1 "$MODPATH/uninstall.sh")" != "# Don't modify anything after this" ]] && install_script "$MODPATH/uninstall.sh" || rm -f "$INFO" "$MODPATH"/uninstall.sh ;;
	esac
done

ui_print " "
ui_print "[*] Setting Permissions..."
set_perm_recursive "$MODPATH" 0 0 0777 0777
[[ -d "$MODPATH/system/bin" ]] && set_perm_recursive "$MODPATH/system/bin" 0 0 0777 0777 u:object_r:system_bin_file:s0

cleanup