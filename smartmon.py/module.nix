{ config, lib, pkgs, ... }: let cfg = config.services.smartmonpy; in {

	options.services.smartmonpy = {
		enable = lib.mkEnableOption "Enable Smartmon.py";

		package = lib.mkOption {
			description = "which program path to point to";
			default = pkgs.smartmon-py;
			type = lib.types.package;
		};
		extraOptions = lib.mkOption {
			description = "Extra arguments passed to smartmonpy";
			default = "";
			type = with lib.types; listOf str;
		};

		outFile = lib.mkOption {
			description = "Which filepath the metrics output should be written";
			default = "/var/lib/smartd-exporter/smartd.prom";
			type = lib.types.path;
		};

	};

	config = lib.mkIf cfg.enable {
	systemd.services.smartmonpy = {
		description = "S.M.A.R.T.(smartmon py) prometheus collector";
		wantedBy = [ "multi-user.target" ];
		serviceConfig.ExecStart = "${cfg.package.meta.mainProgram} ${lib.concatStringsSep " " cfg.extraOptions} > ${cfg.outFile}";
	};};
}