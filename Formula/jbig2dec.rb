class Jbig2dec < Formula
  desc "JBIG2 decoder and library (for monochrome documents)"
  homepage "https://ghostscript.com/jbig2dec.html"
  url "http://downloads.ghostscript.com/public/jbig2dec/jbig2dec-0.13.tar.gz"
  sha256 "5aaca0070992cc2e971e3bb2338ee749495613dcecab4c868fc547b4148f5311"

  bottle do
    cellar :any
    rebuild 1
    sha256 "a46edad05083874510463f4638100765a4f2fb451fad2cfad4b5276cdcb632f7" => :sierra
    sha256 "38ad008992a9c273162238783b31bbcc4be8558d82c0a87b947ef0be699c437c" => :el_capitan
    sha256 "d1de5bcbceaca8669c847ec754e7d44b844ad08abdef377efdd704e768d13c86" => :yosemite
    sha256 "e42e117812549edeae1f60e1900b0692994c75ebae186f611e16528fe0521c89" => :mavericks
    sha256 "42039ee0b62ad6b4a153c5a5e93609ac1b668626b044a23a450a58d4d71338a5" => :mountain_lion
  end

  depends_on "libpng" => :optional

  # These are all upstream already, remove on next release.
  patch do
    url "https://mirrors.ocf.berkeley.edu/debian/pool/main/j/jbig2dec/jbig2dec_0.13-4.debian.tar.xz"
    mirror "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/j/jbig2dec/jbig2dec_0.13-4.debian.tar.xz"
    sha256 "c4776c27e4633a7216e02ca6efcc19039ca757e8bd8fe0a7fbfdb07fa4c30d23"
    apply "patches/020160518~1369359.patch",
          "patches/020161212~e698d5c.patch",
          "patches/020161214~9d2c4f3.patch"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-silent-rules
    ]

    args << "--without-libpng" if build.without? "libpng"

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdint.h>
      #include <stdlib.h>
      #include <jbig2.h>

      int main()
      {
        Jbig2Ctx *ctx;
        Jbig2Image *image;
        ctx = jbig2_ctx_new(NULL, 0, NULL, NULL, NULL);
        image = jbig2_image_new(ctx, 10, 10);
        jbig2_image_release(ctx, image);
        jbig2_ctx_free(ctx);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-DJBIG_NO_MEMENTO", "-L#{lib}", "-ljbig2dec", "-o", "test"
    system "./test"
  end
end
