#!/bin/bash
set -e

[ ! "${FHEM_CLEANINSTALL}" = '1' ] && exit 0

cd "$(readlink -f "$(dirname "${BASH_SOURCE}")")"/..

# Creating PKI group
echo " - Creating group for PKI access"
groupadd --force --gid ${PKI_GROUP_ID} ${PKI_GROUP} 2>&1>/dev/null
adduser --quiet fhem ${PKI_GROUP} 2>&1>/dev/null

# Add sources
echo " - Adding sources to controls.txt"
cp /src/controls.txt ${FHEM_DIR}/FHEM/controls.txt

# Enable sources
echo " - Running initial update, this may take a while"
RET=$( cd ${FHEM_DIR}; perl fhem.pl fhem.cfg )
while ! nc -z localhost 7072; do
  sleep 0.5
done
rm -rf "${FHEM_DIR}/docs/commandref*"
RET=$( cd ${FHEM_DIR}; perl fhem.pl 7072 "attr global autosave 0;defmod WEB FHEMWEB 8083;defmod WEBphone FHEMWEB 8084;defmod WEBtablet FHEMWEB 8085;update all;" 2>&1>/dev/null )
while ! [ -s "${FHEM_DIR}/docs/commandref.html" ]; do
  sleep 1
done
RET=$( cd ${FHEM_DIR}; perl fhem.pl 7072 "shutdown" 2>&1>/dev/null )

# update fhem.cfg
echo " - Pre-configuring fhem.cfg"
mkdir -p ${FHEM_DIR}/certs
[ -s ${FHEM_DIR}/certs/server-cert.pem ] && ln -sf /certs/pki/ecc/fhem.full.crt ${FHEM_DIR}/certs/server-cert.pem
[ -s ${FHEM_DIR}/certs/server-key.pem ] && ln -sf /certs/pki/ecc/fhem.key ${FHEM_DIR}/certs/server-key.pem
cp -n /src/db.conf ${FHEM_DIR}/db.conf
cp -n ${FHEM_DIR}/www/tablet/index-example.html ${FHEM_DIR}/www/tablet/index.html
cp -f ${FHEM_DIR}/fhem.cfg ${FHEM_DIR}/fhem.cfg.default-dhas
perl /fhem-merge-config.pl "/src/fhem.cfg.tmpl/*.cfg" "${FHEM_DIR}/fhem.cfg"

# clear motd
sed -i "/^attr global motd .*/d" "${FHEM_DIR}/fhem.cfg"

exit 0
