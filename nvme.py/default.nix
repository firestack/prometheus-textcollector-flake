{ python3Packages, nvme-cli }: let nvme-metrics = python3Packages.buildPythonPackage {
  pname = "nvme-metrics.py";
  version = "1";
  src = ./.;

  Python = true;
  format = "other";
  propogatedBuildInputs = [ nvme-cli ];
  
  installPhase = ''
    mkdir -p $out/bin
    cp $src/nvme-metrics.py $out/bin/
  '';

  meta.mainProgram = "${nvme-metrics}/bin/nvme-metrics.py";

}; in nvme-metrics
