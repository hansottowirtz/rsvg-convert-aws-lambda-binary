FROM lambci/lambda:build-nodejs10.x

ENV PROJECT_ROOT=/var/task \
    CACHE_DIR=/var/task/build/cache \
    TARGET_DIR=/opt

ENV PKG_CONFIG_PATH="${CACHE_DIR}/lib64/pkgconfig:${CACHE_DIR}/lib/pkgconfig:${TARGET_DIR}/lib64/pkgconfig:${TARGET_DIR}/lib/pkgconfig" \
    PATH="/root/.local/bin:/root/.cargo/bin:${CACHE_DIR}/bin:/var/lang/bin:${PATH}" \
    CPPFLAGS="-I${CACHE_DIR}/include -fPIC -static" \
    LDFLAGS="-L${CACHE_DIR}/lib -L${CACHE_DIR}/lib64 -static" \
    LIBS="-static" \
    CC=clang \
    TERM=xterm-256color

WORKDIR /var/task/build

RUN yum install -y gcc gcc-c++ intltool flex bison shared-mime-info gperf \
		ninja-build libmount-devel gobject-introspection-devel fribidi-devel \
        libuuid-devel libxml2-devel libcroco-devel libjpeg-devel \
        libpng-devel libtiff-devel fontconfig-devel pango-devel \
        bzip2-static glibc-static && \
	yum remove -y cmake && \
	pip3 install --user meson && \
	curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN mkdir -p ${CACHE_DIR} && mkdir -p ${TARGET_DIR}

ENV CMAKE_VERSION=3.15.0-rc1 \
    GLIB_VERSION=2.61.1 \
    GLIB_MINOR_VERSION=2.61 \
    FREETYPE_VERSION=2.10.0 \
    HARFBUZZ_VERSION=2.5.0 \
    PIXMAN_VERSION=0.38.4 \
    CAIRO_VERSION=1.17.2 \
    LIBRSVG_VERSION=2.45.6 \
    LIBRSVG_MINOR_VERSION=2.45 \
    GDK_PIXBUF_VERSION=2.38.1 \
    GDK_PIXBUF_MINOR_VERSION=2.38 \
    LIBFFI_VERSION=3.2.1 \
    BZIP2_VERSION=1.0.6 \
    UTIL_LINUX_VERSION=2.33 \
    LIBPNG_VERSION=1.6.37 \
    OPENJP2_VERSION=2.3.1 \
    LIBTIFF_VERSION=4.0.10 \
    LIBCROCO_VERSION=0.6.8 \
    LIBCROCO_MINOR_VERSION=0.6 \
    FONTCONFIG_VERSION=2.13.0 \
    LIBJPEG_VERSION=9c \ 
    PANGO_VERSION=1.43.0 \
    PANGO_MINOR_VERSION=1.43 \
    LIBXML2_VERSION=2.9.9

ENV CMAKE_SOURCE=cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
    GLIB_SOURCE=glib-${GLIB_VERSION}.tar.xz \
    FREETYPE_SOURCE=freetype-${FREETYPE_VERSION}.tar.gz \
    HARFBUZZ_SOURCE=harfbuzz-${HARFBUZZ_VERSION}.tar.xz \
    PIXMAN_SOURCE=pixman-${PIXMAN_VERSION}.tar.gz \
    CAIRO_SOURCE=cairo-${CAIRO_VERSION}.tar.xz \
    LIBRSVG_SOURCE=librsvg-${LIBRSVG_VERSION}.tar.xz \
    GDK_PIXBUF_SOURCE=gdk-pixbuf-${GDK_PIXBUF_VERSION}.tar.xz \
    LIBFFI_SOURCE=libffi-${LIBFFI_VERSION}.tar.gz \
    BZIP2_SOURCE=bzip2-${BZIP2_VERSION}.tar.gz \
    UTIL_LINUX_SOURCE=util-linux-${UTIL_LINUX_VERSION}.tar.xz \
    LIBPNG_SOURCE=libpng-${LIBPNG_VERSION}.tar.xz \
    OPENJP2_SOURCE=openjpeg-v${OPENJP2_VERSION}-linux-x86_64.tar.gz \
    LIBTIFF_SOURCE=tiff-${LIBTIFF_VERSION}.tar.gz \
    LIBCROCO_SOURCE=libcroco-${LIBCROCO_VERSION}.tar.xz \
    FONTCONFIG_SOURCE=fontconfig-${FONTCONFIG_VERSION}.tar.bz2 \
    LIBJPEG_SOURCE=jpegsrc.v${LIBJPEG_VERSION}.tar.gz \
    PANGO_SOURCE=pango-${PANGO_VERSION}.tar.xz \
    LIBXML2_SOURCE=libxml2-${LIBXML2_VERSION}.tar.gz

RUN curl -LOf https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/${CMAKE_SOURCE} && \
    curl -LOf https://download.savannah.gnu.org/releases/freetype/${FREETYPE_SOURCE} && \
    curl -LOf https://www.freedesktop.org/software/harfbuzz/release/${HARFBUZZ_SOURCE} && \
    curl -LOf https://ftp.gnome.org/pub/gnome/sources/glib/${GLIB_MINOR_VERSION}/${GLIB_SOURCE} && \
    curl -LOf https://www.cairographics.org/releases/${PIXMAN_SOURCE} && \
    curl -LOf https://www.cairographics.org/snapshots/${CAIRO_SOURCE} && \
    curl -LOf https://ftp.gnome.org/pub/GNOME/sources/librsvg/${LIBRSVG_MINOR_VERSION}/${LIBRSVG_SOURCE} && \
    curl -LOf https://ftp.gnome.org/pub/GNOME/sources/gdk-pixbuf/${GDK_PIXBUF_MINOR_VERSION}/${GDK_PIXBUF_SOURCE} && \
    curl -LOf https://sourceware.org/pub/libffi/${LIBFFI_SOURCE} && \
    curl -LOf http://prdownloads.sourceforge.net/bzip2/${BZIP2_SOURCE} && \
    curl -LOf https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${UTIL_LINUX_VERSION}/${UTIL_LINUX_SOURCE} && \
    curl -LOf https://prdownloads.sourceforge.net/libpng/${LIBPNG_SOURCE} && \
    curl -LOf https://github.com/uclouvain/openjpeg/releases/download/v${OPENJP2_VERSION}/${OPENJP2_SOURCE} && \
    curl -LOf https://download.osgeo.org/libtiff/${LIBTIFF_SOURCE} && \
    curl -LOf https://ftp.gnome.org/pub/GNOME/sources/libcroco/${LIBCROCO_MINOR_VERSION}/${LIBCROCO_SOURCE} && \
    curl -LOf https://www.freedesktop.org/software/fontconfig/release/${FONTCONFIG_SOURCE} && \
    curl -LOf http://ijg.org/files/${LIBJPEG_SOURCE} && \
    curl -LOf https://ftp.gnome.org/pub/GNOME/sources/pango/${PANGO_MINOR_VERSION}/${PANGO_SOURCE} && \
    curl -LOf ftp://xmlsoft.org/libxml2/${LIBXML2_SOURCE}

ENV LD_LIBRARY_PATH="/var/task/build/cache/lib64:/var/task/build/cache/lib"

# Install CMake 3
RUN sh ${CMAKE_SOURCE} --skip-license --prefix=${CACHE_DIR} && \
	sh ${CMAKE_SOURCE} --skip-license

# Install libffi
RUN tar xf ${LIBFFI_SOURCE} && \
	cd libffi-* && \
    ./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath && \
	make && \
	make install

# Force -fPIC and clang everywhere
ENV CC="clang -fPIC"

# Install bzip2
# Replace gcc with gcc -fPIC in bzip2 Makefile as CC is not respected
RUN tar xf ${BZIP2_SOURCE} && \
	cd bzip2-* && \
    sed -i 's/gcc/gcc -fPIC/g' Makefile && \
	make PREFIX=${CACHE_DIR} install

# Install libuuid from util-linux
RUN tar xf ${UTIL_LINUX_SOURCE} && \
	cd util-linux-* && \
    ./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath \
		--disable-all-programs \
		--enable-libuuid && \
	make && \
	make install

# Also install util linux here as "-luuid" doesnt work

# ENV LD_LIBRARY_PATH="/usr/lib64:/usr/lib:/lib"
# ENV CPPFLAGS="-I/usr/lib64/include -I/usr/lib/include -I${CACHE_DIR}/include -fPIC -static" \
#     LDFLAGS="-I/usr/lib64 -I/usr/lib -L${CACHE_DIR}/lib -L${CACHE_DIR}/lib64 -static" 

# ENV ZLIB_VERSION=1.2.11
# ENV ZLIB_SOURCE=zlib-${ZLIB_VERSION}.tar.gz

# RUN curl -LOf https://zlib.net/${ZLIB_SOURCE}

# RUN tar xf ${ZLIB_SOURCE} && \
#     cd zlib-* && \
#     CC=gcc ./configure --prefix ${CACHE_DIR} --static && \
#     make && \
#     make install

ENV CPPFLAGS="-I${CACHE_DIR}/include -fPIC" \
    LDFLAGS="-L${CACHE_DIR}/lib -L${CACHE_DIR}/lib64" \
    LIBS=""

RUN tar xf ${LIBPNG_SOURCE} && \
    cd libpng-* && \
    ./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath && \
    make && \
    make install

# RUN curl -LOf https://sourceware.org/elfutils/ftp/elfutils-latest.tar.bz2

# RUN tar xf elfutils-latest.tar.bz2 && \
#     cd elfutils-* && \
#     CC=gcc ./configure --prefix=${CACHE_DIR} --with-zlib --disable-dependency-tracking && \
#     make && \
#     make install

# ENV CPPFLAGS="-I${CACHE_DIR}/include -fPIC" \
#     LDFLAGS="-L${CACHE_DIR}/lib -L${CACHE_DIR}/lib64" \
#     LIBS=""

# RUN CPPFLAGS="-I${CACHE_DIR}/include -fPIC -static" \
#     LDFLAGS="-L${CACHE_DIR}/lib -L${CACHE_DIR}/lib64 -static" \
#     LIBS="-static"

RUN tar xf ${GLIB_SOURCE} && \
    cd glib-* && \
    meson --prefix ${CACHE_DIR} _build -Dman=false -Dinternal_pcre=true -Dselinux=disabled \
        -Ddefault_library=static -Dnls=disabled -Dlibmount=false -Dxattr=false && \
    ninja-build -v -C _build && \
    ninja-build -C _build install

# RUN CPPFLAGS="-I${CACHE_DIR}/include -fPIC -static" \
#     LDFLAGS="-L${CACHE_DIR}/lib -L${CACHE_DIR}/lib64 -static" \
#     LIBS="-static"

# build libtiff here, before gdk pixbuf
    
RUN tar xf ${GDK_PIXBUF_SOURCE} && \
    cd gdk-pixbuf-* && \
    meson --prefix ${CACHE_DIR} _build -Dgir=false -Dx11=false -Ddefault_library=static \
        -Drelocatable=true -Dgio_sniffing=false -Dbuiltin_loaders=true -Dinstalled_tests=false && \
    ninja-build -C _build && \
    ninja-build -C _build install

ENV FREETYPE_WITHOUT_HB_DIR=${PROJECT_ROOT}/build/freetype-${FREETYPE_VERSION}-without-harfbuzz

RUN tar xf ${FREETYPE_SOURCE} -C /tmp && \
	rm -rf ${FREETYPE_WITHOUT_HB_DIR} && \
	mv /tmp/freetype-${FREETYPE_VERSION} ${FREETYPE_WITHOUT_HB_DIR} && \
	cd ${FREETYPE_WITHOUT_HB_DIR} && \
    ./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath \
        --without-harfbuzz && \
	make && \
	make install

RUN tar xf ${HARFBUZZ_SOURCE} && \
	cd harfbuzz-* && \
    ./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath \
        --with-freetype && \
	make && \
	make install

RUN tar xf ${FREETYPE_SOURCE} && \
	cd freetype-* && \
    ./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath \
        --with-harfbuzz --with-png && \
	make distclean clean && \
	make && \
	make install

RUN tar xf ${LIBXML2_SOURCE} && \
	cd libxml2-* && \
    ./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath \
		--without-history \
		--without-python && \
	make && \
	make install

RUN	tar xf ${LIBCROCO_SOURCE} && \
	cd libcroco-* && \
    ./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath \
		--disable-gtk-doc \
		--disable-gtk-doc-html && \
	make && \
	make install

RUN tar xf ${PIXMAN_SOURCE} && \
	cd pixman-* && \
    ./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath \
        --disable-gtk && \
	make && \
	make install

RUN tar xf ${CAIRO_SOURCE} && \
    cd cairo-* && \
    ./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath \
		--disable-gtk-doc \
		--disable-gtk-doc-html \
		--disable-valgrind \
		--disable-xlib \
		--disable-xlib-xrender \
		--disable-xcb \
		--disable-xlib-xcb \
		--disable-xcb-shm \
		--disable-qt \
		--disable-quartz \
		--disable-quartz-font \
		--disable-quartz-image \
		--enable-png \
		--enable-pdf \
		--enable-svg \
		--disable-test-surfaces \
		--enable-gobject \
		--without-x \
		--disable-interpreter \
		--disable-full-testing \
		--disable-gl \
		--disable-glx \
		--disable-egl \
		--disable-wgl \
		--enable-xml \
		--disable-trace && \
    make && \
    make install

RUN	tar xf ${FONTCONFIG_SOURCE} && \
	cd fontconfig-* && \
	./configure --prefix ${CACHE_DIR} --disable-shared --enable-static --disable-dependency-tracking --disable-rpath \
        --enable-libxml2 && \
	make && \
	make install

RUN ldconfig

ENV LDFLAGS="-lpng -luuid -lxml2 -lz -lbz2 -lpixman-1 -llzma ${LDFLAGS}"

RUN tar xf ${PANGO_SOURCE} && \
	cd pango-${PANGO_VERSION} && \
    sed -i 's/xlib/xlibdontfindthis/g' meson.build && \
    meson --prefix ${CACHE_DIR} _build -Dgir=false -Ddefault_library=static && \
    ninja-build -C _build && \
    ninja-build -C _build install

RUN	tar xf ${LIBRSVG_SOURCE} && \
    cd librsvg-* && \
    ./configure \
        --enable-option-checking \
		--disable-dependency-tracking \
		--disable-shared \
		--enable-static \
		--disable-pixbuf-loader \
		--disable-gtk-theme \
		--disable-gtk-doc \
        --prefix=${TARGET_DIR} && \
    make all && \
    make install

RUN rm /opt/lib/*.so*

ENV LDFLAGS=-Wl,-rpath=/opt/lib

RUN npm install node-pre-gyp librsvg-prebuilt --prefix ${TARGET_DIR}/nodejs --no-package-lock --build-from-source

RUN node -e "require('librsvg-prebuilt')"