#!/bin/sh
SODIUM_VERSION="1.0.18"
PLATFORMS=(macos ios watchos ubuntu)

SCRIPT_DIR=$(cd `dirname "$0"`; pwd)
PROJECT_DIR="$SCRIPT_DIR/.."
BUILD_DIR="$PROJECT_DIR/.build-CSodium"
SODIUM_TARBALL="$PROJECT_DIR/libsodium-$SODIUM_VERSION.tar.gz"
SODIUM_SRC="$BUILD_DIR/sodium"

cd "$PROJECT_DIR"

for PLATFORM in ${PLATFORMS[@]}; do
	echo "Building for $PLATFORM"
	SODIUM_PREFIX="$BUILD_DIR/$PLATFORM"
	SODIUM_INSTALL="$PROJECT_DIR/Libs/$PLATFORM"
	# check whether libsodium.a already exists - we'll only build if it does not
	if [ -f  "$SODIUM_INSTALL/libsodium.a" ]; then
	    echo "Using previously-built libary $SODIUM_INSTALL/libsodium.a - skipping build"
		continue
	else
	    echo "No previously-built libary present at $SODIUM_INSTALL/libsodium.a - building"
	fi

	if [ ! -d "$SODIUM_SRC" ]; then

		if [ ! -f "$SODIUM_TARBALL" ]; then
		    echo "Downloading libsodium-$SODIUM_VERSION.tar.gz"
		    curl -O "https://download.libsodium.org/libsodium/releases/libsodium-$SODIUM_VERSION.tar.gz" || exit 1
		fi

		echo "Extracting $SODIUM_TARBALL..."
		mkdir -p "$SODIUM_SRC"
		tar -C "$SODIUM_SRC" --strip-components=1 -zxf "$SODIUM_TARBALL" || exit 1				
	fi

	pushd "$SODIUM_SRC" > /dev/null
	
	make distclean > /dev/null
	
	install_lib() {
		if [ ! -f "$SODIUM_PREFIX/lib/libsodium.a" ]; then 
			echo "Building for $PLATFORM failed"
			exit 1
		fi
	
		mkdir -p "$SODIUM_INSTALL"
		cp "$SODIUM_PREFIX/lib/libsodium.a" "$SODIUM_INSTALL"
	}
	
	if [ "$PLATFORM" = "macos" ]; then
		./configure --prefix "$SODIUM_PREFIX" && make -j install
		install_lib
	elif [ "$PLATFORM" = "ios" ]; then
		LIBSODIUM_FULL_BUILD=1 bash -c "$SODIUM_SRC/dist-build/ios.sh"
		mkdir -p "$SODIUM_PREFIX"
		cp -r "$SODIUM_SRC/libsodium-ios/"* "$SODIUM_PREFIX"
		install_lib
	elif [ "$PLATFORM" = "watchos" ]; then
		LIBSODIUM_FULL_BUILD=1 bash -c "$SODIUM_SRC/dist-build/watchos.sh"
		mkdir -p "$SODIUM_PREFIX"
		cp -r "$SODIUM_SRC/libsodium-watchos/"* "$SODIUM_PREFIX"
		install_lib
	elif [ "$PLATFORM" = "ubuntu" ]; then
		#TODO: For some reason the current folder is mounted on the docker image with incorrect permissions, so we use sudo for now to get around it
		"$SCRIPT_DIR"/dockbuild-ubuntu1804-gcc7-latest bash -c "sudo ./configure --prefix \$(pwd)/libsodium-ubuntu && sudo make -j install"
		mkdir -p "$SODIUM_PREFIX"
		cp -r "$SODIUM_SRC/libsodium-ubuntu/"* "$SODIUM_PREFIX"
		install_lib
	fi
	
	popd > /dev/null
	
done






exit 0









if [ -z "$LIBSODIUM_FULL_BUILD" ]; then
	LIBSODIUM_ENABLE_MINIMAL_FLAG="--enable-minimal"
else
	LIBSODIUM_ENABLE_MINIMAL_FLAG=""
fi

SODIUM_OPTIONS="$LIBSODIUM_ENABLE_MINIMAL_FLAG --prefix=$SODIUM_INSTALL"

NPROCESSORS=$(getconf NPROCESSORS_ONLN 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)
PROCESSORS=${NPROCESSORS:-3}

echo "Creating $LIB_PRODUCT_NAME with $SODIUM_OPTIONS for architectures: $ARCHS"

for BUILDARCH in $ARCHS
do
    echo "Building $BUILDARCH"
	
	make distclean > /dev/null
	
	CFLAGS="-arch $BUILDARCH -O2"
	LDFLAGS="-arch $BUILDARCH"
	
	if [ "$PLATFORM_NAME" = "macosx" ]; then
		CONFIGURE_OPTIONS="$SODIUM_OPTIONS"

	elif [ "$PLATFORM_NAME" = "iphoneos" ]; then
				
		if [[ "$BUILDARCH" = "armv"* ]]; then
			CFLAGS="$CFLAGS -fembed-bitcode -mthumb -isysroot $SDKROOT -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
			LDFLAGS="$LDFLAGS -fembed-bitcode -mthumb -isysroot $SDKROOT -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
		elif [ "$BUILDARCH" = "arm64" ]; then
			CFLAGS="$CFLAGS -fembed-bitcode -isysroot $SDKROOT -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
			LDFLAGS="$LDFLAGS -fembed-bitcode -isysroot $SDKROOT -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
		fi

		CONFIGURE_OPTIONS="$SODIUM_OPTIONS --host=arm-apple-darwin10 --disable-shared"

	elif [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
		# Build for the simulator
		CFLAGS="$CFLAGS -isysroot $SDKROOT -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
		LDFLAGS="$LDFLAGS -isysroot $SDKROOT -mios-version-min=${IPHONEOS_DEPLOYMENT_TARGET}"
		
		if [ "$BUILDARCH" = "i386" ]; then
			CONFIGURE_OPTIONS="$SODIUM_OPTIONS --host=i686-apple-darwin10 --disable-shared"
		elif [ "$BUILDARCH" = "x86_64" ]; then
			CONFIGURE_OPTIONS="$SODIUM_OPTIONS --host=x86_64-apple-darwin10 --disable-shared"
		fi

	else
		echo "Unsupported platform $PLATFORM_NAME"
		exit 1
	fi
	
	rm -rf "$SODIUM_INSTALL"
	mkdir -p "$SODIUM_INSTALL"
	
	export CFLAGS="$CFLAGS"
	export LDFLAGS="$LDFLAGS"
	export PATH="$PLATFORM_DEVELOPER_BIN_DIR:$PLATFORM_DEVELOPER_USR_DIR/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
	export CC="xcrun -sdk $PLATFORM_NAME cc $CFLAGS"
    ./configure $CONFIGURE_OPTIONS


	make -j${PROCESSORS} install || exit 1

	echo "Creating $LIB_PRODUCT_NAME for $BUILDARCH in $TARGET_TEMP_DIR"
	cp "$SODIUM_INSTALL/lib/libsodium.a" "$TARGET_TEMP_DIR/$BUILDARCH-$LIB_PRODUCT_NAME"
done


echo "Creating universal archive in $TARGET_BUILD_DIR"
mkdir -p "$TARGET_BUILD_DIR"
lipo -create "$TARGET_TEMP_DIR/"*-$LIB_PRODUCT_NAME -output "$TARGET_BUILD_DIR/$LIB_PRODUCT_NAME"

echo "Executing ranlib"
ranlib "$TARGET_BUILD_DIR/$LIB_PRODUCT_NAME"

echo "Copying Headers"
mkdir -p "$TARGET_BUILD_DIR/headers"
cp -RLf "$SODIUM_INSTALL/include/" "$TARGET_BUILD_DIR/headers"

make distclean > /dev/null
