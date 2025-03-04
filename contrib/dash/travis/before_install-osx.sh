#!/bin/bash
set -ev

if [[ -n $TRAVIS_TAG ]]; then
    PYTHON_VERSION=3.7.9
    PYFTP=https://www.python.org/ftp/python/$PYTHON_VERSION
    PYPKG_NAME=python-$PYTHON_VERSION-macosx10.9.pkg
    PY_SHA256=bf54a14eef23467991e8c7a88c7307762e484c024a94ec1ee292ac1db3d41fc9
    echo "$PY_SHA256  $PYPKG_NAME" > $PYPKG_NAME.sha256
    curl -O $PYFTP/$PYPKG_NAME
    shasum -a256 -s -c $PYPKG_NAME.sha256
    sudo installer -pkg $PYPKG_NAME -target /
    rm $PYPKG_NAME $PYPKG_NAME.sha256
fi

cd build
cp /usr/local/Cellar/libusb/1.0.*/lib/libusb-1.0.dylib .

LSECP256K1_PATH=https://github.com/Bertrand256/secp256k1/
LSECP256K1_PATH=${LSECP256K1_PATH}releases/download/210521
LSECP256K1_FILE=libsecp256k1-210521-osx.tgz
LIB_SHA256=51c861bfb894ec520cc1ee0225fae00447aa86096782a1acd1fc6e338a576ea7
echo "$LIB_SHA256  $LSECP256K1_FILE" > $LSECP256K1_FILE.sha256
curl -O -L ${LSECP256K1_PATH}/${LSECP256K1_FILE}
shasum -a256 -s -c $LSECP256K1_FILE.sha256
tar -xzf ${LSECP256K1_FILE} && rm ${LSECP256K1_FILE}
rm -f libsecp256k1.0.dylib
cp libsecp256k1/libsecp256k1.0.dylib .

brew install gettext libtool automake pkg-config

if [[ -n $TRAVIS_TAG ]]; then
    echo "Building ZBar dylib..."
    rm -f libzbar.0.dylib
    export MACOSX_DEPLOYMENT_TARGET=10.13
    ./contrib/make_zbar.sh
    rm -rf contrib/zbar/
fi
