{ config, lib, pkgs, ... }: let cfg = config.services.smartmonpy; in {

	options.services.smartmonpy = {
		enable = lib.mkEnableOption "Enable Smartmon.py";

		package = lib.mkOption {
			description = "which program path to point to";
			default = pkgs.smartmon-py;
			type = lib.types.package;
		};
		program = lib.mkOption {
			type = lib.types.path;
			default = "${cfg.package}/bin/smartmonpy.py";
		};
		extraOptions = lib.mkOption {
			description = "Extra arguments passed to smartmonpy";
			default = [];
			type = with lib.types; listOf str;
		};

		outFile = lib.mkOption {
			description = "Which filepath the metrics output should be written";
			default = "/var/lib/smartd-exporter/smartd.prom";
			type = lib.types.path;
		};

	};

	config = lib.mkIf cfg.enable {
	systemd.services.smartmonpy = let 
	wrapper = pkgs.writeShellScript "smartmonpy" ''
	${cfg.package.meta.mainProgram} ${lib.concatStringsSep " " cfg.extraOptions} > ${cfg.outFile}
	''; in {
		path = [ pkgs.smartmontools ];
		description = "S.M.A.R.T.(smartmon py) prometheus collector";
		wantedBy = [ "multi-user.target" ];
		
		serviceConfig.Type = "oneshot";
		serviceConfig.ExecStart = wrapper;
		
	};

	systemd.timers.smartmonpy-timer = {
			wantedBy = [ "timers.target" ];
			partOf = [ "smartmonpy.service" ];
			timerConfig.OnCalendar = "*:00/30:00";
			timerConfig.Persistent = true;
	};
	};
}