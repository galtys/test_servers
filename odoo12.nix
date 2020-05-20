{ pkgs ? import <nixpkgs> {} }:

let

#with import <nixpkgs> {};
#python.withPackages (ps: with ps; [ numpy toolz ])
#ebaysdk num2words pyldap vatnumber xlswriter
#libsass
  #libsass-python

    my_libsaass = pkgs.python35.pkgs.buildPythonPackage rec {
      pname = "libsass";
      version = "0.12.3";
   
      src = pkgs.python35.pkgs.fetchPypi {
        inherit pname version;
        #sha256 = "15dyw3xm1sf22c52vbznjdj2hxn09i3h8awqw1adk8afghd6snwb";  0.19
        sha256 = "1c3kcr0hhqvyxkxp8qab97wpmlkpb95gyr9dv4pbffv9kjpn4rr3";
        
      };
      propagatedBuildInputs = [ pkgs.python35.pkgs.six pkgs.python35.pkgs.suds-jurko] ;
#      src=pkgs.fetchFromGitHub {
#        owner = "sass";
#        repo = "libsass-python" ;
#        rev = "58e19c041f2ff15a2eafced81e3b5f752f73abf9";
#        sha256 = "0ahibbcmm9ky4mmrmi4cq8hi803id4g4vkf05sb6a60lagibv65x";
#      };
      doCheck = false;

      meta = {
        homepage = "https://github.com/sass/libsass-python/";
        description = "libsass-python: Sass/SCSS for Python";
      };
    };
  
#pyldap, vatnumber, pypiwin32 my_libsaass
  mypython = pkgs.python35.buildEnv.override {
  extraLibs = with pkgs.python35Packages; [Babel chardet decorator docutils feedparser gevent greenlet html2text jinja2   lxml Mako markupsafe mock num2words ofxparse passlib pillow psutil psycopg2 pydot  pyparsing pypdf2 pyserial python-dateutil pytz pyusb qrcode reportlab requests suds-jurko vobject werkzeug XlsxWriter xlwt xlrd polib setuptools pip my_libsaass];  
  ignoreCollisions = true;
  };

in

pkgs.stdenv.mkDerivation rec {
  name = "env";
  env = pkgs.buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    mypython
    pkgs.python35Packages.ipython
    pkgs.lxc
    pkgs.lessc
 #   pkgs.nodejs
#    pkgs.sassc
    pkgs.wkhtmltopdf
    #pkgs.python
    #pkgs.python27Packages.virtualenv
    #pkgs.python27Packages.pip
    #pkgs.go_1_4
    #pkgs.lua5_3
  ];
}
