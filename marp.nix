{ stdenv
, fetchFromGitHub
, nodejs
, yarn
, nodeDependencies
}:
stdenv.mkDerivation rec {
  pname = "marp";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "marp-team";
    repo = "marp-cli";
    rev = "v${version}";
    sha256 = "5NW8xh7Ycjg0hG9EyzyVWjYA7+TY7AL+HiPZfF1mq0k=";
  };

  nativeBuildInputs = [
    nodejs
    yarn
  ];

  buildPhase = ''
    ln -s ${nodeDependencies}/lib/node_modules ./node_modules
    export PATH="${nodeDependencies}/bin:$PATH"
    npm run build --no-update-notifier
  '';

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${nodeDependencies}/lib/node_modules $out/bin/node_modules
    cp -r lib $out/bin
    chmod +x marp-cli.js
    patchShebangs marp-cli.js
    cp marp-cli.js $out/bin/marp
  '';
}
