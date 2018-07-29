#!/bin/bash

#cd "$(readlink -f "$(dirname "${BASH_SOURCE}")")"/..

FHEM_DIR="/opt/fhem"

# Add sources
echo " - Adding sources to controls.txt"
cp /src/controls.txt ${FHEM_DIR}/FHEM/controls.txt

# Enable sources
echo " - Installing add-ons"
RET=$( cd ${FHEM_DIR}; perl fhem.pl fhem.cfg )
while ! nc -z localhost 7072; do
  sleep 0.5
done
for LINE in "$( cat ${FHEM_DIR}/FHEM/controls.txt | tail -n +2 )"; do
  RET=$( cd ${FHEM_DIR}; perl fhem.pl 7072 "update all $(echo ${LINE##*/controls_} | cut -d . -f 1)" 2>&1>/dev/null )
done
RET=$( cd ${FHEM_DIR}; perl fhem.pl 7072 "shutdown" 2>&1>/dev/null )

# update fhem.cfg
echo " - Pre-configuring fhem.cfg"
cp -f ${FHEM_DIR}/fhem.cfg ${FHEM_DIR}/fhem.cfg.default-dhas
perl /fhem-merge-config.pl "/src/fhem.cfg.tmpl/*.cfg" "${FHEM_DIR}/fhem.cfg"
