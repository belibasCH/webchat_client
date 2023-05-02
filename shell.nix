let
  pkgs = import <nixpkgs> {};
  
in with pkgs;
  stdenv.mkDerivation {
    name = "ws-env";
    buildInputs = [ elmPackages.elm nodejs-19_x ];
    
  }
