{ scripts, python3Packages }: python3Packages.buildPythonPackage {
  pname = "smartmon.py";
  version = "1";
  src = (toString scripts);

  Python = true;
  format = "other";

  installPhase = ''
  mkdir -p $out/bin
  cp $src/smartmon.py $out/bin/
  '';

  meta.mainProgram = "${placeholder "out"}/bin/smartmon.py";
}
