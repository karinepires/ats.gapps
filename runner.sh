#!/system/bin/sh
#This file is part of The Open GApps script of @mfonville.
#
#    The Open GApps scripts are free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version, w/Open GApps installable zip exception.
#
#    These scripts are distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    This Open GApps installer-runtime is because of the Open GApps installable
#    zip exception de-facto LGPLv3 licensed.
#
#Edited for AiC:
# - hardcode x86 (test is failing otherwise)
# - put a different tmp dir (/tmp doesn’t exist within android)
# - change chmod +x to chmod 777
# - replace install -d with mkdir -p

export OPENGAZIP="$3"
export OUTFD="/proc/self/fd/$2"
export TMP="/data/upgrade"
export BINARCH="x86"
bb="$TMP/busybox-$BINARCH"
l="$TMP/bin"
setenforce 0
for f in app_densities.txt app_sizes.txt bkup_tail.sh gapps-remove.txt g.prop installer.sh busybox-x86 tar-x86 unzip-x86 zip-x86; do
  unzip -o "$OPENGAZIP" "$f" -d "$TMP";
done
for f in  busybox-x86 tar-x86 unzip-x86 zip-x86; do
  chmod 777 "$TMP/$f";
done
if [ -e "$bb" ]; then
  mkdir -p "$l"
  for i in $($bb --list); do
    if ! ln -s "$bb" "$l/$i" && ! $bb ln -sf "$bb" "$l/$i" && ! $bb ln -f "$bb" "$l/$i" ; then
      # create script wrapper if symlinking and hardlinking failed because of restrictive selinux policy
      if ! echo "#!$bb" > "$l/$i" || ! chmod 777 "$l/$i" ; then
        echo "ui_print ERROR 10: Failed to set-up Open GApps' pre-bundled busybox" > "$OUTFD"
        echo "ui_print" > "$OUTFD"
        echo "ui_print Please use TWRP as recovery instead" > "$OUTFD"
        echo "ui_print" > "$OUTFD"
        exit 1
      fi
    fi
  done
  PATH="$l:$PATH" $bb ash "$TMP/installer.sh" "$@"
  exit "$?"
else
  echo "ui_print ERROR 64: Wrong architecture to set-up Open GApps' pre-bundled busybox" > "$OUTFD"
  echo "ui_print" > "$OUTFD"
  exit 1
fi
