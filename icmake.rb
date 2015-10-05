class Icmake < Formula
  desc "Icmake: a `make` alternative"
  homepage "http://icmake.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/icmake/icmake/7.22.01/icmake_7.22.01.orig.tar.gz"
  sha256 "b522e7937e9d4f0bec738dfce371673e3c4a8bc9f4d209a51631e5ed59ba66c7"

  depends_on "gnu-sed"

  patch :DATA

  def install
    # Completely overwrite their config file, since it is not programatically
    # configurable
    (buildpath/"INSTALL.im").atomic_write <<-EOS.undent
      #define BINDIR      "#{bin}"
      #define SKELDIR     "#{share}/icmake"
      #define MANDIR      "#{man}"
      #define LIBDIR      "#{libexec}"
      #define CONFDIR     "#{etc}/icmake"
      #define DOCDIR      "#{doc}"
      #define DOCDOCDIR   "#{doc}/icmake-doc"
    EOS

    # icmake's sed calls require GNU-specific behavior
    inreplace ["scripts/convert", "scripts/conversions", "scripts/icmstart.in"] do |s|
      s.gsub! /\bsed\b/, "gsed"
    end

    # lexer.c should be rebuilt, because it was created for a linux system.
    # See also the patch.
    system "flex", "-o", "comp/lexer.c", "comp/lexer"
    system "./icm_bootstrap", "/"

    system "./icm_install", "all"
  end

  test do
    # Have to use "; true" because their `-a` returns error status
    assert_match /ICMAKE consists of a set of five programs/,
      shell_output("icmake -a 2>&1; true")
  end
end

__END__
diff --git a/comp/iccomp.h b/comp/iccomp.h
index a2a40ec..1e47b47 100644
--- a/comp/iccomp.h
+++ b/comp/iccomp.h
@@ -149,9 +149,11 @@ extern FILE
 extern int
     initialization,                         /* for initialization expr. */
     yy_init,                                /* yylex() initializer: 1 to init. */
-    yyleng,                                 /* strlen(yytext) */
     yynerrs;                                /* number of parse errors so far */
 
+extern size_t
+    yyleng;                                 /* strlen(yytext) */
+
 extern int
     yylineno;                               /* yylex() line counter */

