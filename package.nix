{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
}:

let
  version = "2.1.269";

  hashes = {
    darwin-arm64 = "c942e1228b93cb4d52183b3dfbc77f28264f35aa947acd9c0853d029164cf450";
    darwin-x64 = "5a8c02f9ff48f1917b38e86d837114b8d5cbbf534ce72bc6aa106eb17eb3a90f";
  };

  platform =
    {
      aarch64-darwin = "darwin-arm64";
      x86_64-darwin = "darwin-x64";
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "claude-code: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "claude-code";
  inherit version;

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-code-releases/${version}/${platform}/claude";
    sha256 = hashes.${platform};
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/libexec/claude-code/claude"
    makeWrapper "$out/libexec/claude-code/claude" "$out/bin/claude" \
      --set DISABLE_AUTOUPDATER 1
    runHook postInstall
  '';

  meta = {
    description = "Claude Code, Anthropic's agentic coding tool (native binary)";
    homepage = "https://code.claude.com";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
