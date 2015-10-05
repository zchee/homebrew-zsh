class Yodl < Formula
  desc "Your Own Documentation Language"
  homepage "http://yodl.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/yodl/yodl/3.05.01/yodl_3.05.01.orig.tar.gz"
  sha256 "5a3d0e1b2abbba87217cfdc6cd354a00df8d782572495bbddbdfbd4f47fe0d3e"

  depends_on "ghostscript"
  depends_on "icmake"
  depends_on "gnu-sed"
  depends_on :tex => :optional

  # OS X portability: use GNU sed, fix BSD getopt usage, don't build .dSYM
  patch :DATA

  def install
    inreplace "INSTALL.im", %r{"/usr"}, "\"#{prefix}\""

    system "./build", "programs"
    system "./build", "macros"
    system "./build", "man"

    system "./build", "install", "programs"
    system "./build", "install", "macros"
    system "./build", "install", "man"

    if build.with? "tex"
      system "./build", "manual"
      system "./build", "install", "manual"
    end
  end

  test do
    # Yes, "yodl --version" returns an error status if successful
    assert_match "yodl version 3",
      shell_output("yodl --version; true")
  end
end

__END__
diff --git a/build b/build
index 0e897a4..191333d 100755
--- a/build
+++ b/build
@@ -1,4 +1,4 @@
-#!/usr/bin/icmake -qt/tmp/yodl
+#!/usr/bin/env icmake -qt/tmp/yodl
 
 #include "VERSION" 
 #include "INSTALL.im"
@@ -59,7 +59,7 @@ void main(int argc, list argv)
     echo(ECHO_REQUEST);
     g_cwd = chdir(".");
 
-    g_copt = setOpt(COPT + " -g", "CFLAGS");
+    g_copt = setOpt(COPT, "CFLAGS");
 
 #ifdef PROFILING
     g_copt = COPT + " -pg";
diff --git a/scripts/configreplacements b/scripts/configreplacements
index d49dd0e..e45241e 100755
--- a/scripts/configreplacements
+++ b/scripts/configreplacements
@@ -23,7 +23,7 @@ esac
     # Create the destination file, changing @... into the required
     # values
     #
-sed '
+gsed '
 s,@STD_INCLUDE@,'$STD_INCLUDE',g
 s,@YODL_BIN@,'$YODL_BIN',g
 s,@VERSION@,'$VERSION',g
diff --git a/scripts/yodl2whatever.in b/scripts/yodl2whatever.in
index 2fac89b..8ecb517 100755
--- a/scripts/yodl2whatever.in
+++ b/scripts/yodl2whatever.in
@@ -98,7 +98,7 @@ if [ "$?" == "4" ] ; then
         -- "$@"`
 else
     # Poor man's getopt. Only single-char flags supported.
-    TEMP=`getopt D:d:ghi:I:kl:m:n:o:p:r:tVvWw  -- "$@"`
+    TEMP=`getopt D:d:ghi:I:kl:m:n:o:p:r:tVvWw "$@"`
 fi
 
 if [ $? != 0 ] ; then echo "getopt error in $base" ; exit 1 ; fi
