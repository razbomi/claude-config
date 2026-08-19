{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
}:

let
  version = "2.1.235";

  hashes = {
    darwin-arm64 = "83b8f806f6f2eea316cfe246628e6c23374711d868f1fd0409db551b877b7748";
    darwin-x64 = "325a2dbc166ba8361a913ce588dce4a236789502060239acea52072bb51a54f1";
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
