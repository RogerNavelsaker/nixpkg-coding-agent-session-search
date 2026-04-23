{ bash, fetchFromGitHub, lib, lld, makeWrapper, onnxruntime, openssl, perl, pkg-config, runCommand, rustPlatform }:

let
  manifest = builtins.fromJSON (builtins.readFile ./package-manifest.json);
  upstreamSrc = fetchFromGitHub {
    owner = manifest.source.owner;
    repo = manifest.source.repo;
    rev = manifest.source.rev;
    hash = manifest.source.hash;
  };
  frankensqliteSrc = fetchFromGitHub {
    owner = manifest.source.siblings.frankensqlite.owner;
    repo = manifest.source.siblings.frankensqlite.repo;
    rev = manifest.source.siblings.frankensqlite.rev;
    hash = manifest.source.siblings.frankensqlite.hash;
  };
  frankenAgentDetectionSrc = fetchFromGitHub {
    owner = manifest.source.siblings.franken_agent_detection.owner;
    repo = manifest.source.siblings.franken_agent_detection.repo;
    rev = manifest.source.siblings.franken_agent_detection.rev;
    hash = manifest.source.siblings.franken_agent_detection.hash;
  };
  frankensearchSrc = fetchFromGitHub {
    owner = manifest.source.siblings.frankensearch.owner;
    repo = manifest.source.siblings.frankensearch.repo;
    rev = manifest.source.siblings.frankensearch.rev;
    hash = manifest.source.siblings.frankensearch.hash;
  };
  fastCmaesSrc = fetchFromGitHub {
    owner = manifest.source.siblings.fast_cmaes.owner;
    repo = manifest.source.siblings.fast_cmaes.repo;
    rev = manifest.source.siblings.fast_cmaes.rev;
    hash = manifest.source.siblings.fast_cmaes.hash;
  };
  asupersyncSrc = fetchFromGitHub {
    owner = manifest.source.siblings.asupersync.owner;
    repo = manifest.source.siblings.asupersync.repo;
    rev = manifest.source.siblings.asupersync.rev;
    hash = manifest.source.siblings.asupersync.hash;
  };
  toonRustSrc = fetchFromGitHub {
    owner = manifest.source.siblings.toon_rust.owner;
    repo = manifest.source.siblings.toon_rust.repo;
    rev = manifest.source.siblings.toon_rust.rev;
    hash = manifest.source.siblings.toon_rust.hash;
  };
  frankentuiSrc = fetchFromGitHub {
    owner = manifest.source.siblings.frankentui.owner;
    repo = manifest.source.siblings.frankentui.repo;
    rev = manifest.source.siblings.frankentui.rev;
    hash = manifest.source.siblings.frankentui.hash;
  };

  # Phase 1: Gather and prep all sources
  sourceRoot = runCommand "${manifest.binary.name}-${manifest.source.version}-src" { } ''
    mkdir -p "$out/upstream" "$out/frankensqlite" "$out/franken_agent_detection" \
             "$out/frankensearch" "$out/fast_cmaes" "$out/asupersync" \
             "$out/toon_rust" "$out/frankentui"
    cp -R ${upstreamSrc}/. "$out/upstream/"
    cp -R ${frankensqliteSrc}/. "$out/frankensqlite/"
    cp -R ${frankenAgentDetectionSrc}/. "$out/franken_agent_detection/"
    cp -R ${frankensearchSrc}/. "$out/frankensearch/"
    cp -R ${fastCmaesSrc}/. "$out/fast_cmaes/"
    cp -R ${asupersyncSrc}/. "$out/asupersync/"
    cp -R ${toonRustSrc}/. "$out/toon_rust/"
    cp -R ${frankentuiSrc}/. "$out/frankentui/"
  '';

  builtBinary = manifest.binary.upstreamName or manifest.binary.name;
  aliasOutputs = manifest.binary.aliases or [ ];
  licenseMap = {
    "MIT" = lib.licenses.mit;
    "Apache-2.0" = lib.licenses.asl20;
  };
  resolvedLicense =
    if builtins.hasAttr manifest.meta.licenseSpdx licenseMap
    then licenseMap.${manifest.meta.licenseSpdx}
    else lib.licenses.unfree;
  aliasScripts = lib.concatMapStrings
    (
      alias:
      ''
        cat > "$out/bin/${alias}" <<EOF
#!${lib.getExe bash}
exec "$out/bin/${manifest.binary.name}" "\$@"
EOF
        chmod +x "$out/bin/${alias}"
      ''
    )
    aliasOutputs;
in
rustPlatform.buildRustPackage {
  pname = manifest.binary.name;
  version = manifest.package.version;
  src = sourceRoot;
  sourceRoot = "source/upstream";

  cargoLock = {
    lockFile = ../upstream/Cargo.lock;
    outputHashes = {
      "asupersync-0.2.9" = "sha256-zjY4G274+1+Hju94jW74APS5cb9jlzz7cOvTzLy6yQA=";
      "frankensqlite-0.1.2" = "sha256-CuaBArEUVQQmutFfrDmgM0Dw53rqKyo42nr2O90YY18=";
      "franken-agent-detection-0.1.3" = "sha256-9HUDckRCdL5NT3QtJ5WdWWez6j1JfccKgA7O0YrSiHg=";
      "frankensearch-0.1.0" = "sha256-4FWFxvUB4c6djekMcVec//5DcAk9w8gpnHTalxCeHSY=";
      "tru-0.2.1" = "sha256-pW3/clvSw7IAMFFlq4uf7b8qH6Yinu++a3wwP3zuQGs=";
      "ftui-0.2.1" = "sha256-vDbnVrIDUigoeUen/QfEi9HtTEVRsiqak4Ka4tO5C3Y=";
    };
  };

  cargoBuildFlags =
    (lib.optionals (manifest.binary ? package) [ "-p" manifest.binary.package ])
    ++ [ "--bin=${builtBinary}" ];

  nativeBuildInputs = [ lld makeWrapper perl pkg-config ];
  buildInputs = [ onnxruntime openssl ];
  doCheck = false;

  env = {
    ORT_LIB_LOCATION = "${lib.getLib onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
    ORT_STRATEGY = "system";
    RUSTC_BOOTSTRAP = "1";
    VERGEN_IDEMPOTENT = "1";
    VERGEN_GIT_SHA = manifest.source.rev;
    VERGEN_GIT_DIRTY = "false";
  };

  postInstall = ''
    if [ "${builtBinary}" != "${manifest.binary.name}" ]; then
      mv "$out/bin/${builtBinary}" "$out/bin/${manifest.binary.name}"
    fi
    wrapProgram "$out/bin/${manifest.binary.name}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ onnxruntime ]}" \
      --set ORT_LIB_LOCATION "${lib.getLib onnxruntime}/lib" \
      --set ORT_PREFER_DYNAMIC_LINK "1" \
      --set ORT_STRATEGY "system"
    ${aliasScripts}
  '';

  meta = with lib; {
    description = manifest.meta.description;
    homepage = manifest.meta.homepage;
    license = resolvedLicense;
    mainProgram = manifest.binary.name;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
