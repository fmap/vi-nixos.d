{ stdenv, fetchhg, ncurses, which, perl
, autoconf
, automake
, sslSupport ? true
, imapSupport ? true
, headerCache ? true
, saslSupport ? true
, gpgmeSupport ? true
, gdbm ? null
, openssl ? null
, cyrus_sasl ? null
, gpgme ? null
, patches ? []
}:

assert headerCache -> gdbm != null;
assert sslSupport -> openssl != null;
assert saslSupport -> cyrus_sasl != null;

let
  version = "1.5.22";
in
stdenv.mkDerivation rec {
  name = "mutt-${version}";
  
  src = fetchhg {
    url    = "https://bitbucket.org/mutt/mutt";
    rev    = "8f62001";
  };

  buildInputs = [
    ncurses which perl autoconf automake
    (if headerCache then gdbm else null)
    (if sslSupport then openssl else null)
    (if saslSupport then cyrus_sasl else null)
    (if gpgmeSupport then gpgme else null)
  ];

  preConfigure = ''
    autoreconf --install
  '';
  
  configureFlags = [
    "--with-mailpath=" "--enable-smtp"

    # This allows calls with "-d N", that output debug info into ~/.muttdebug*
    "--enable-debug"

    "--enable-pop" "--enable-imap"

    # The next allows building mutt without having anything setgid
    # set by the installer, and removing the need for the group 'mail'
    # I set the value 'mailbox' because it is a default in the configure script
    "--with-homespool=mailbox"
    (if headerCache then "--enable-hcache" else "--disable-hcache")
    (if sslSupport then "--with-ssl" else "--without-ssl")
    (if imapSupport then "--enable-imap" else "--disable-imap")
    (if saslSupport then "--with-sasl" else "--without-sasl")
    (if gpgmeSupport then "--enable-gpgme" else "--disable-gpgme")
  ];

  patches = [];

  meta = with stdenv.lib; {
    description = "A small but very powerful text-based mail client";
    homepage = http://www.mutt.org;
    license = "GPLv2+";
    platforms = platforms.unix;
    maintainers = [];
  };
}

