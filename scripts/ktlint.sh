#!/usr/bin/env bash

echo "##################################################################"
echo " installing ktlint"
echo "##################################################################"

mkdir -p tmp/
cd tmp/

if [ ! -f "ktlint" ]; then
  curl -sSLo ktlint "https://github.com/pinterest/ktlint/releases/download/1.7.1/ktlint"
  chmod +x ktlint
fi

PLATFORM="$(uname -s)"
ARCH="$(uname -m)"

if [ ! -f "jdk/bin/java" ]; then
  mkdir -p jdk
  if [[ "$PLATFORM" == "Darwin" && ("$ARCH" == "arm64" || "$ARCH" == "aarch64") ]]; then
    curl -L -o jdk.tar.gz "https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jre25.0.0-macosx_aarch64.tar.gz"
  elif [[ "$PLATFORM" == "Darwin" && "$ARCH" == "x86_64" ]]; then
    curl -L -o jdk.tar.gz "https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jre25.0.8-macosx_x64.zip"
  elif [[ "$PLATFORM" == "Linux" && "$ARCH" == "x86_64" ]]; then
    curl -L -o jdk.tar.gz "https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jre25.0.0-linux_x64.tar.gz"
  else
    echo "Unsupported platform: $PLATFORM $ARCH"
    exit 1
  fi

    tar -xzf jdk.tar.gz -C jdk --strip-components=1
    rm jdk.tar.gz
fi

cd ..

args=""
for arg in "$@"; do
	if [[ ! $arg == "-F" ]] && [[ ! $arg == "--force" ]] ; then
		args="$args $arg"
	fi
done

./tmp/jdk/bin/java -jar ./tmp/ktlint --color --format $args || (./tmp/jdk/bin/java -jar ./tmp/ktlint -F --color --format $args; test 1 == 0)
