"""Derive the game's labour constants from the simulation's audited config and code (read-only).

Run:  python3 tools/derive_numbers.py  [path/to/config_full_audited.yaml]
Prints a JSON block that is pasted into game/data/model_numbers.gd (documented in DESIGN.md).
"""
import json, math, os, sys
import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
STAGE = os.environ.get("MODEL_DIR", os.path.abspath(os.path.join(HERE, "..", "..", "model")))  # path to the simulation code (config/ and code/)
cfg_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(STAGE, "config", "config_full_audited.yaml")
sys.path.insert(0, os.path.join(STAGE, "code"))
import lit  # the model's own functions (cone_course_weights, ramp_ph_per_tower, oxen_yokes)
import numpy as np

cfg = yaml.safe_load(open(cfg_path))
L = cfg["lit_scenarios"]
tp = cfg["transport"]
md = L["webster_md_per_tower"]
H = cfg["v11"]["webster_day_hours"]
t_tower = cfg["stone"]["tonnes_per_tower"]
blk = cfg["stone"]["block_median_kg"]
n_blocks = int(round(t_tower * 1000 / blk))          # Webster: ~3,000 blocks
vol = t_tower * 1000 / L["webster_density_kg_m3"]

webster = {s: md[s] * H[s] for s in ("quarry", "dress", "build")}
share = L["lift_share_of_build"]
w = lit.cone_course_weights(L)
lift = {
    "webster": webster["build"] * share,
    "lever": n_blocks * float(np.sum(w * np.arange(w.size))) * L["lever_ph_per_block_course"],
    "stair": n_blocks * (1.0 - w[0]) * L["lever_ph_per_block_course"] * (L["stair_lever_last_m"] / L["geometry"]["course_height_m"]),
    "ramp": lit.ramp_ph_per_tower(L)[1],
}
quarry = {"webster": webster["quarry"], "joints_low": L["quarry_ph_m3"]["joints_low"] * vol,
          "scree": L["quarry_ph_m3"]["scree"] * vol}

def crew(mu):
    pull = tp["pull_kg_per_person"] if mu == L["baseline_mu"] else L["f_person_kgf"] / mu
    return pull, math.ceil(blk / pull)

o = L["oxen"]
yokes = int(lit.oxen_yokes(np.array([float(blk)]), o)[0])
out = {
    "hours_per_day": cfg["hours_per_day"],
    "season_days": cfg["alliance"]["season_days"],
    "tonnes_per_tower": t_tower, "block_median_kg": blk, "blocks_per_tower": n_blocks, "stone_m3_per_tower": vol,
    "ph_quarry": quarry, "ph_dress_webster": webster["dress"],
    "ph_build_without_lift": webster["build"] * (1 - share), "ph_lift": lift,
    "sledge_dry_mu": 0.38, "pull_kg_per_person_dry": crew(0.38)[0], "crew_per_block_dry": crew(0.38)[1],
    "pull_kg_per_person_base": crew(0.3)[0], "crew_per_block_base": crew(0.3)[1],
    "drag_speed_ms": tp["drag_speed_ms"], "return_walk_ms": tp["return_walk_ms"], "load_unload_h": tp["load_unload_h"],
    "oxen_yokes_per_block": yokes, "oxen_men_per_team": o["men_per_team"], "oxen_speed_ms": o["speed_ms"],
    "oxen_return_speed_ms": o["return_speed_ms"],
    "builders_base": cfg["builders"]["base"], "builders_per_extra_tower": cfg["builders"]["per_extra_tower"],
    "residents_by_towers": cfg["mr_work_party"]["residents_by_towers"] if "mr_work_party" in cfg else None,
    "adult_share": cfg["mr_work_party"]["adult_share"] if "mr_work_party" in cfg else None,
    "trust0": cfg["alliance"]["trust0"], "delta_up": cfg["alliance"]["delta_up"], "delta_down": cfg["alliance"]["delta_down"],
    "beta": [cfg["alliance"][k] for k in ("beta0", "beta1", "beta2", "beta3")], "R_m": cfg["alliance"]["R_m"],
    "max_asks": cfg["alliance"]["max_asks"],
}
print(json.dumps(out, indent=1, default=float))
