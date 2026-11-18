
--run on the global primary

--SQLCOMMAND MODE > Query (top of ssms) > SQLCMD Mode

GO
:SETVAR AGSource AG-P2P-STG
:SETVAR AGDest AG-CP-SBX-2017
:SETVAR ListenerSource STG-LS-P2P
:SETVAR ListenerDest  AWS-LS-CP2-SBX

ALTER AVAILABILITY GROUP [DAG_$(ListenerSource)-$(ListenerDest)] SET (ROLE = secondary);




