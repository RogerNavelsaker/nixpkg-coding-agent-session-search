{ bash, fetchFromGitHub, lib, lld, makeWrapper, onnxruntime, openssl, perl, pkg-config, python3, runCommand, rustPlatform }:

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

  # Phase 1: Gather and prep all sources into a unified structure
  prepSource = runCommand "${manifest.binary.name}-${manifest.source.version}-prep-source" {
    nativeBuildInputs = [ python3 ];
  } ''
    # Work in a temporary directory
    BUILD_DIR=$(mktemp -d)
    cd "$BUILD_DIR"

    # Copy all sources
    cp -R ${upstreamSrc}/. ./
    mkdir -p siblings
    cp -R ${frankensqliteSrc}/. ./siblings/frankensqlite/
    cp -R ${frankenAgentDetectionSrc}/. ./siblings/franken_agent_detection/
    cp -R ${frankensearchSrc}/. ./siblings/frankensearch/
    cp -R ${fastCmaesSrc}/. ./siblings/fast_cmaes/
    cp -R ${asupersyncSrc}/. ./siblings/asupersync/
    cp -R ${toonRustSrc}/. ./siblings/toon_rust/
    cp -R ${frankentuiSrc}/. ./siblings/frankentui/

    # Ensure everything is writable
    chmod -R +w .

    # We use [patch] sections to override git dependencies workspace-wide.
    # This is critical to avoid workspace inheritance errors! If we used `path = ...` 
    # directly in `[dependencies]`, Cargo would merge these external crates into our 
    # workspace and they would fail to find their own `[workspace.package]` configs.
    
    # Remove any existing patch sections to avoid conflicts
    sed -i '/\[patch\."https:\/\/github\.com\/Dicklesworthstone/,$d' Cargo.toml
    
    # Append fresh patch sections pointing to our prepped siblings
    cat >> Cargo.toml <<EOF

[patch."https://github.com/Dicklesworthstone/asupersync"]
asupersync = { path = "./siblings/asupersync" }
franken-decision = { path = "./siblings/asupersync/franken_decision" }
franken-evidence = { path = "./siblings/asupersync/franken_evidence" }
franken-kernel = { path = "./siblings/asupersync/franken_kernel" }

[patch."https://github.com/Dicklesworthstone/frankensqlite"]
fsqlite = { path = "./siblings/frankensqlite/crates/fsqlite" }
fsqlite-types = { path = "./siblings/frankensqlite/crates/fsqlite-types" }

[patch."https://github.com/Dicklesworthstone/franken_agent_detection"]
franken-agent-detection = { path = "./siblings/franken_agent_detection" }

[patch."https://github.com/Dicklesworthstone/frankensearch"]
frankensearch = { path = "./siblings/frankensearch/frankensearch" }

[patch."https://github.com/Dicklesworthstone/toon_rust"]
tru = { path = "./siblings/toon_rust" }

[patch."https://github.com/Dicklesworthstone/frankentui"]
ftui = { path = "./siblings/frankentui/crates/ftui" }
ftui-runtime = { path = "./siblings/frankentui/crates/ftui-runtime" }
ftui-tty = { path = "./siblings/frankentui/crates/ftui-tty" }
ftui-extras = { path = "./siblings/frankentui/crates/ftui-extras" }
EOF

    # Patch siblings that have relative paths to other repos
    # frankensearch/tools/optimize_params/Cargo.toml expects fast_cmaes at ../../../fast_cmaes
    sed -i 's|\.\./\.\./\.\./fast_cmaes|../../../fast_cmaes|g' siblings/frankensearch/tools/optimize_params/Cargo.toml

    # Downgrade json5 in fsqlite-ext-json to match the older Cargo.lock version
    sed -i 's|json5 = "1.3"|json5 = "0.4.1"|g' siblings/frankensqlite/crates/fsqlite-ext-json/Cargo.toml

    # Downgrade lru in ftui-text to match the older Cargo.lock version
    sed -i 's|lru = "0.17.0"|lru = "0.16.4"|g' siblings/frankentui/crates/ftui-text/Cargo.toml

    # Patch Cargo.lock to remove git sources so the Nix vendor script treats them as path dependencies
    python3 -c '
import os
import re
if os.path.exists("Cargo.lock"):
    with open("Cargo.lock", "r") as f: content = f.read()
    content = re.sub(r"source\s*=\s*\"git\+https://github\.com/Dicklesworthstone/[^\"]*\"\n", "", content)
    with open("Cargo.lock", "w") as f: f.write(content)
'

    # Move finalized source to $out
    mkdir -p "$out"
    cp -R . "$out/"
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
  src = prepSource;

  # By using cargoHash = lib.fakeHash, we trigger a vendoring phase
  # Since all git dependencies were patched and their sources removed from Cargo.lock,
  # Cargo will vendor the registry dependencies and use the local paths for the rest.
  cargoHash = "sha256-6EApfqOydImGkH0sMAH48OQAO5aGyt9uzhPteKff1kY=";

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
