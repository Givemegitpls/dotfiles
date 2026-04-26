#!/usr/bin/env bash

tmp_dir="/tmp/cliphist"
rm -rf "$tmp_dir"

if [[ -n "$ROFI_INFO" ]]; then
  cliphist decode "$ROFI_INFO" | wl-copy
  exit
fi

mkdir -p "$tmp_dir"

read -r -d '' prog <<EOF
/^[0-9]+\s<meta http-equiv=/ { next }
match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
    system("echo " grp[1] "\\\\\t | cliphist decode >$tmp_dir/"grp[1]"."grp[3])
    
    line = \$0
    sub(/^[0-9]+\t/, "", line)
    
    print line "\0info\x1f" grp[1] "\x1ficon\x1f$tmp_dir/"grp[1]"."grp[3]
    next
}
{
    id = \$0
    sub(/\t.*/, "", id)
    line = \$0
    sub(/^[0-9]+\t/, "", line)
    print line "\0info\x1f" id
}
EOF
cliphist list | gawk "$prog"
