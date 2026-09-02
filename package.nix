{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
}:

let
  version = "2.1.258";

  hashes = {
    darwin-arm64 = "b63136194160791c27cfa7b0403060d85eb0752991625fde8c09f9acacb17c78";
    darwin-x64 = "c857db5cd712865623bd61e806cf3f7e8e279c9e5c7c0af5eca06ca6717fc7fb";
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
