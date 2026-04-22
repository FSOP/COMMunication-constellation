from __future__ import annotations

from typing import Any

import win32com.client

from .config import STKConfig


class STKClient:
    def __init__(self, stk_config: STKConfig) -> None:
        self.stk_config = stk_config
        self.uiapp = None
        self.root = None

    def connect(self) -> None:
        try:
            self.uiapp = win32com.client.GetActiveObject("STK12.Application")
            self.root = self.uiapp.Personality2
            if self.root.Children.Count == 0:
                self.uiapp.Visible = 1
                self.root.NewScenario(self.stk_config.scenario_name)
        except Exception:
            self.uiapp = win32com.client.Dispatch("STK12.Application")
            self.root = self.uiapp.Personality2
            self.uiapp.Visible = 1
            self.root.NewScenario(self.stk_config.scenario_name)

        self.exec(
            f'SetAnalysisTimePeriod * "{self.stk_config.analysis_epoch}" "{self.stk_config.analysis_period}"'
        )

    def exec(self, command: str) -> Any:
        if self.root is None:
            raise RuntimeError("STK is not connected. Call connect() first.")
        return self.root.ExecuteCommand(command)

    def clear_scenario_objects(self) -> None:
        for cmd in [
            "UnloadMulti / */Facility/*",
            "UnloadMulti / */Satellite/*",
            "UnloadMulti / */Constellation/*",
            "UnloadMulti / */AreaTarget/*",
            "UnloadMulti / */CoverageDefinition/*",
        ]:
            try:
                self.exec(cmd)
            except Exception:
                pass
