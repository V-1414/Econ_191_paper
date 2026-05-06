"""
Generate PDF versions of the two paper diagrams using matplotlib.
Run: python3 generate_diagrams.py
Outputs: diagram_data_pipeline.pdf, diagram_boundary_hierarchy.pdf
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import matplotlib.patheffects as pe
import os

OUT = os.path.dirname(os.path.abspath(__file__))

# ── Shared helpers ─────────────────────────────────────────────────────────────

def rounded_box(ax, x, y, w, h, text, facecolor, edgecolor,
                fontsize=8.5, bold_first=False, text_color='black', lw=1.3, zorder=3):
    box = FancyBboxPatch((x - w/2, y - h/2), w, h,
                         boxstyle="round,pad=0.02", linewidth=lw,
                         edgecolor=edgecolor, facecolor=facecolor, zorder=zorder)
    ax.add_patch(box)
    lines = text.split('\n')
    if bold_first and lines:
        ax.text(x, y + (len(lines)-1)*0.055, lines[0],
                ha='center', va='center', fontsize=fontsize,
                fontweight='bold', color=text_color, zorder=zorder+1)
        body = '\n'.join(lines[1:])
        if body:
            ax.text(x, y - 0.06, body,
                    ha='center', va='center', fontsize=fontsize-0.5,
                    color=text_color, zorder=zorder+1, linespacing=1.35)
    else:
        ax.text(x, y, text, ha='center', va='center', fontsize=fontsize,
                color=text_color, zorder=zorder+1, linespacing=1.35)
    return box

def arrow(ax, x0, y0, x1, y1, color='#555555', lw=1.5, style='->', dashed=False):
    ls = (0, (4, 3)) if dashed else 'solid'
    ax.annotate('', xy=(x1, y1), xytext=(x0, y0),
                arrowprops=dict(arrowstyle=style, color=color,
                                lw=lw, linestyle=ls),
                zorder=4)

def label(ax, x, y, text, fontsize=7.5, color='#666666', ha='center', style='italic'):
    ax.text(x, y, text, ha=ha, va='center', fontsize=fontsize,
            color=color, fontstyle=style)


# ══════════════════════════════════════════════════════════════════════════════
# DIAGRAM 1 — Data Pipeline
# ══════════════════════════════════════════════════════════════════════════════

def draw_pipeline():
    fig, ax = plt.subplots(figsize=(14, 11))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 11)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    # ── Colours ──────────────────────────────────────────────────────────────
    SRC   = ('#D2E4FF', '#3C64B4')   # blue
    CROSS = ('#E6D7FF', '#6E3CB4')   # purple
    PROC  = ('#FFEBC8', '#C87814')   # amber
    MATCH = ('#D2F0DC', '#288246')   # green
    FINAL = ('#FFD7D3', '#B43228')   # red

    # ── Row 1: source files (y=9.5) ─────────────────────────────────────────
    y1 = 9.5
    src_positions = [1.6, 4.5, 8.2, 11.7]
    src_texts = [
        "nrega.dta\nKjelsrud replication\n151,660 GP-years\n(treatment, controls, FE)",
        "gp_id_names.dta\nGP name strings\nfor name-matching\n151,660 GPs",
        "mis_avg_sc_st_data.csv\nMittal SC/ST person-days\n(targeting ratio\nnumerator)",
        "panchayat_category.csv\nMittal SC/ST population\n(targeting ratio\ndenominator)",
    ]
    for xc, txt in zip(src_positions, src_texts):
        rounded_box(ax, xc, y1, 2.7, 1.1, txt, SRC[0], SRC[1], bold_first=True)

    # Source files header band
    ax.add_patch(FancyBboxPatch((0.1, 8.85), 13.8, 1.35,
                 boxstyle="round,pad=0.04", lw=1.0,
                 edgecolor='#3C64B4', facecolor='#EAF1FF', zorder=1, alpha=0.5))
    ax.text(7.0, 10.28, 'Raw Source Files', ha='center', va='center',
            fontsize=8.5, fontweight='bold', color='#3C64B4')

    # ── SHRUG crosswalk (y=7.7, centred under gpnames) ───────────────────────
    y_shrug = 7.7
    rounded_box(ax, 4.5, y_shrug, 2.9, 1.0,
                "SHRUG Crosswalk\npc11r_shrid_key.csv\n+ shrid_loc_names.csv\nNumeric codes → name strings",
                CROSS[0], CROSS[1], bold_first=True)
    arrow(ax, 4.5, y1-0.55, 4.5, y_shrug+0.5, color=CROSS[1])

    # ── Row 3: collapse + two name-matches (y=6.35) ──────────────────────────
    y3 = 6.35
    rounded_box(ax, 1.6, y3, 2.7, 1.05,
                "Collapse to GP level\nDrop duplicate years;\nkeep time-invariant\ncovariates\n150,413 unique GPs",
                PROC[0], PROC[1], bold_first=True)
    arrow(ax, 1.6, y1-0.55, 1.6, y3+0.52, color=PROC[1])

    rounded_box(ax, 7.2, y3, 3.5, 1.05,
                "3-key name match\n(state, district, GP name)\nExact match after cleaning\n~119K matched (79%)\nDuplicates: keep max PD",
                MATCH[0], MATCH[1], bold_first=True)

    rounded_box(ax, 11.4, y3, 3.2, 1.05,
                "3-key name match\n(state, district, GP name)\nExact match after cleaning\n~65K matched (43%)\n← Binding constraint",
                MATCH[0], MATCH[1], bold_first=True)

    # Arrows shrug → match1, shrug → match2
    arrow(ax, 5.0, y_shrug-0.5, 6.4, y3+0.52, color=MATCH[1])
    arrow(ax, 5.8, y_shrug-0.5, 10.5, y3+0.52, color=MATCH[1])

    # Arrows mis → match1, pancat → match2
    arrow(ax, 8.2, y1-0.55, 7.5, y3+0.52, color=MATCH[1])
    arrow(ax, 11.7, y1-0.55, 11.5, y3+0.52, color=MATCH[1])

    # ── Row 4: merge (y=4.85) ─────────────────────────────────────────────────
    y4 = 4.85
    rounded_box(ax, 7.0, y4, 8.5, 0.85,
                "Left-merge all sources onto nrega frame on gp_id\n"
                "Unmatched GPs retain NaN for Mittal-derived columns",
                PROC[0], PROC[1], bold_first=True)
    arrow(ax, 1.6,  y3-0.52, 3.0, y4+0.42, color=PROC[1])
    arrow(ax, 7.2,  y3-0.52, 7.2, y4+0.42, color=PROC[1])
    arrow(ax, 11.4, y3-0.52, 10.5, y4+0.42, color=PROC[1])

    # ── Row 5: targeting ratios (y=3.7) ──────────────────────────────────────
    y5 = 3.7
    rounded_box(ax, 7.0, y5, 10.5, 0.85,
                "Construct targeting ratios (SC, ST, SC+ST)\n"
                "TargetingRatio(G,j) = (person-day share of G) / (population share of G)"
                "   ·   Winsorise [1st, 99th pct] → log-transform",
                PROC[0], PROC[1], bold_first=True)
    arrow(ax, 7.0, y4-0.42, 7.0, y5+0.42, color=PROC[1])

    # ── Row 6: restrictions (y=2.6) ──────────────────────────────────────────
    y6 = 2.6
    rounded_box(ax, 7.0, y6, 10.5, 0.85,
                "Standardise treatment & apply sample restrictions\n"
                "Standardise fragmentation_2004_past → zero mean, unit SD\n"
                "Keep: non-missing treatment + pc_dist FE + all 9 controls + ≥1 outcome",
                PROC[0], PROC[1], bold_first=True)
    arrow(ax, 7.0, y5-0.42, 7.0, y6+0.42, color=PROC[1])

    # ── Row 7: final dataset (y=1.45) ─────────────────────────────────────────
    y7 = 1.45
    rounded_box(ax, 7.0, y7, 11.5, 1.05,
                "Final Analysis Dataset:   gp_analysis_dataset.csv\n"
                "47,995 GPs  ×  33 columns   |   14 states\n"
                "SC: 44,915 GPs   ·   ST (pop ≥5%): 18,563 GPs   ·   SC+ST: 47,995 GPs",
                FINAL[0], FINAL[1], bold_first=True, fontsize=9.5)
    arrow(ax, 7.0, y6-0.42, 7.0, y7+0.52, color=FINAL[1], lw=2.0)

    # ── Legend ────────────────────────────────────────────────────────────────
    lx, ly = 0.55, 4.2
    for i, (clr, lbl) in enumerate([(SRC, 'Raw source file'),
                                     (CROSS, 'Crosswalk / lookup'),
                                     (MATCH, 'Name-matching step'),
                                     (PROC, 'Processing / aggregation'),
                                     (FINAL, 'Final analysis dataset')]):
        oy = ly - i * 0.42
        ax.add_patch(FancyBboxPatch((lx-0.03, oy-0.13), 0.36, 0.27,
                     boxstyle="round,pad=0.02", lw=1.0,
                     edgecolor=clr[1], facecolor=clr[0], zorder=5))
        ax.text(lx + 0.48, oy, lbl, ha='left', va='center', fontsize=7.5, color='#333333')

    ax.text(lx + 0.18, ly + 0.35, 'Legend', ha='center', va='center',
            fontsize=8.5, fontweight='bold', color='#333333')
    ax.add_patch(FancyBboxPatch((lx-0.2, ly-1.9), 2.55, 2.55,
                 boxstyle="round,pad=0.04", lw=0.8,
                 edgecolor='#aaaaaa', facecolor='white', zorder=2))

    fig.suptitle('Data Linking and Dataset Building Procedure',
                 fontsize=13, fontweight='bold', y=0.98)

    plt.tight_layout(rect=[0, 0, 1, 0.97])
    out = os.path.join(OUT, 'diagram_data_pipeline.pdf')
    fig.savefig(out, dpi=200, bbox_inches='tight', facecolor='white')
    print(f'Saved: {out}')
    plt.close()


# ══════════════════════════════════════════════════════════════════════════════
# DIAGRAM 2 — Indian Boundary Hierarchy
# ══════════════════════════════════════════════════════════════════════════════

def draw_hierarchy():
    fig, ax = plt.subplots(figsize=(13, 13))
    ax.set_xlim(0, 13)
    ax.set_ylim(0, 13)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    ADM   = ('#D2E4FF', '#3264B4')   # blue  — administrative
    ELEC  = ('#FFD5D0', '#B43228')   # red   — electoral
    GP    = ('#E1D2FF', '#5A32AA')   # purple — GP (unit of analysis)
    FE    = ('#D2F0DC', '#288246')   # green — FE cell
    OVL   = ('#FFF8C8', '#B48C00')   # yellow — overlap note

    BW = 4.0   # box width
    BH = 1.05  # box height
    GAP = 0.62 # vertical gap between boxes

    # ── Column x-centres ─────────────────────────────────────────────────────
    xA = 3.0   # administrative
    xE = 9.5   # electoral

    # ── Column headers ────────────────────────────────────────────────────────
    rounded_box(ax, xA, 12.3, BW+0.3, 0.7,
                "Administrative Hierarchy\n(Census / Territorial)",
                ADM[0], ADM[1], bold_first=False, fontsize=9.5)
    rounded_box(ax, xE, 12.3, BW+0.3, 0.7,
                "Electoral Hierarchy\n(Lok Sabha / Vidhan Sabha)",
                ELEC[0], ELEC[1], bold_first=False, fontsize=9.5)

    # ── Administrative levels ─────────────────────────────────────────────────
    adm_levels = [
        (11.35, "State\n28 states + 8 UTs nationwide\n14 states in this sample"),
        (10.05, "District\n~640 nationwide\nFully contained within a State"),
        (8.75,  "Sub-district  (Tehsil / Taluka / Block)\nFully contained within a District"),
        (7.45,  "Census Village\n~640,000 nationwide\nFully contained within a Sub-district"),
    ]
    for yc, txt in adm_levels:
        rounded_box(ax, xA, yc, BW, BH, txt, ADM[0], ADM[1], bold_first=True)

    # GP box
    gp_y = 6.15
    rounded_box(ax, xA, gp_y, BW, BH,
                "Gram Panchayat (GP)\nGroups 3–15 villages\n~250,000 nationwide\nUnit of analysis in this paper",
                GP[0], GP[1], bold_first=True)

    # Arrows admin column
    for (ya, _), (yb, _) in zip(adm_levels, adm_levels[1:]):
        arrow(ax, xA, ya - BH/2, xA, yb + BH/2, color=ADM[1])
        label(ax, xA + BW/2 + 0.15, (ya + yb)/2, 'fully nested', color=ADM[1])

    arrow(ax, xA, adm_levels[-1][0] - BH/2, xA, gp_y + BH/2, color=GP[1])
    label(ax, xA + BW/2 + 0.15, (adm_levels[-1][0] + gp_y)/2, 'grouped into', color=GP[1])

    # ── Electoral levels ──────────────────────────────────────────────────────
    elec_levels = [
        (11.35, "State\nPC boundaries drawn\nwithin each state"),
        (9.7,   "Parliamentary Constituency (PC)\n543 Lok Sabha seats nationwide\nRedrawn by 2008 Delimitation Act\n⚠  Crosses district boundaries"),
        (8.0,   "Assembly Constituency (AC)\nVidhan Sabha seat\nFully nested within one PC"),
    ]
    for yc, txt in elec_levels:
        rounded_box(ax, xE, yc, BW, BH, txt, ELEC[0], ELEC[1], bold_first=True)

    arrow(ax, xE, elec_levels[0][0] - BH/2, xE, elec_levels[1][0] + BH/2, color=ELEC[1])
    label(ax, xE + BW/2 + 0.15, (elec_levels[0][0] + elec_levels[1][0])/2,
          'PC within state', color=ELEC[1])
    arrow(ax, xE, elec_levels[1][0] - BH/2, xE, elec_levels[2][0] + BH/2, color=ELEC[1])
    label(ax, xE + BW/2 + 0.15, (elec_levels[1][0] + elec_levels[2][0])/2,
          'fully nested', color=ELEC[1])

    # ── Cross-column overlap arrow (PC ↔ District) ────────────────────────────
    # from PC left edge → district right edge
    pc_y  = elec_levels[1][0]
    dis_y = adm_levels[1][0]
    # midpoint connector
    ax.annotate('', xy=(xA + BW/2, dis_y + 0.1), xytext=(xE - BW/2, pc_y + 0.1),
                arrowprops=dict(arrowstyle='<->', color=OVL[1], lw=1.8,
                                linestyle=(0, (5,3)),
                                connectionstyle='arc3,rad=-0.25'),
                zorder=5)
    ax.text(6.25, 10.35, 'can span\nmultiple districts', ha='center', va='center',
            fontsize=7.5, color=OVL[1], fontstyle='italic',
            bbox=dict(boxstyle='round,pad=0.3', facecolor=OVL[0], edgecolor=OVL[1], lw=0.8))

    # ── Overlap summary box ────────────────────────────────────────────────────
    rounded_box(ax, 6.5, 4.85, 11.5, 0.95,
                "Key overlap:  A District can contain parts of several PCs; "
                "a PC can span parts of several Districts.\n"
                "The 2008 Delimitation Act redrew PC boundaries → "
                "24.4% of GPs reassigned to a new PC  (change_pc = 1)",
                OVL[0], OVL[1], bold_first=True)
    arrow(ax, xA, gp_y - BH/2, xA, 5.22, color=OVL[1], lw=1.3)
    arrow(ax, xE, elec_levels[2][0] - BH/2, xE, 5.22, color=OVL[1], lw=1.3)

    # ── FE cell box ───────────────────────────────────────────────────────────
    rounded_box(ax, 6.5, 3.65, 11.5, 1.0,
                "Fixed Effects Cell  (pc_dist)  —  used in all regressions in this paper\n"
                "pc_dist  =  pre-delimitation PC  ×  District  interaction  (~1,260 unique cells)\n"
                "Absorbs all variation common to GPs sharing a PC and a district, "
                "identifying the effect of political competition changes at delimitation",
                FE[0], FE[1], bold_first=True, fontsize=8.5)
    arrow(ax, 6.5, 4.85 - 0.48, 6.5, 3.65 + 0.5, color=FE[1], lw=1.8)

    # ── Notes box ─────────────────────────────────────────────────────────────
    notes_text = (
        "Notes on containment:\n"
        "  •  Fully nested:  the lower unit is always entirely within the higher unit\n"
        "  •  Crosses / overlaps:  a unit at one level can span parts of multiple units at the other level\n"
        "  •  Grouped into:  multiple census villages form one Gram Panchayat; villages stay within their sub-district\n"
        "  •  PCs are within states (each seat is state-specific) but cross district lines — "
        "hence the PC × District FE cell"
    )
    ax.add_patch(FancyBboxPatch((0.5, 0.25), 12.0, 2.6,
                 boxstyle="round,pad=0.04", lw=1.0,
                 edgecolor='#bbbbbb', facecolor='#f8f8f8', zorder=2))
    ax.text(6.5, 1.55, notes_text, ha='center', va='center',
            fontsize=7.8, color='#333333', linespacing=1.5)
    arrow(ax, 6.5, 3.65 - 0.5, 6.5, 2.88, color='#aaaaaa', lw=1.2)

    # ── Legend ────────────────────────────────────────────────────────────────
    lx, ly = 11.5, 6.5
    for i, (clr, lbl) in enumerate([(ADM, 'Administrative unit'),
                                     (ELEC, 'Electoral unit'),
                                     (GP,  'Unit of analysis (GP)'),
                                     (FE,  'FE cell (regression)'),
                                     (OVL, 'Overlap / cross-cutting')]):
        oy = ly - i * 0.44
        ax.add_patch(FancyBboxPatch((lx-0.02, oy-0.14), 0.4, 0.28,
                     boxstyle="round,pad=0.02", lw=1.0,
                     edgecolor=clr[1], facecolor=clr[0], zorder=5))
        ax.text(lx + 0.58, oy, lbl, ha='left', va='center', fontsize=7.5, color='#333333')

    ax.add_patch(FancyBboxPatch((lx-0.25, ly-2.0), 3.2, 2.68,
                 boxstyle="round,pad=0.04", lw=0.8,
                 edgecolor='#aaaaaa', facecolor='white', zorder=2))
    ax.text(lx + 1.35, ly + 0.38, 'Legend', ha='center', va='center',
            fontsize=8.5, fontweight='bold', color='#333333')

    # Containment vs overlap arrow legend entries
    ax.annotate('', xy=(lx + 0.42, ly-2.28), xytext=(lx-0.0, ly-2.28),
                arrowprops=dict(arrowstyle='->', color=ADM[1], lw=1.4))
    ax.text(lx + 0.58, ly-2.28, 'Fully nested', ha='left', va='center', fontsize=7.5, color='#333333')

    ax.annotate('', xy=(lx + 0.42, ly-2.72), xytext=(lx-0.0, ly-2.72),
                arrowprops=dict(arrowstyle='->', color=OVL[1], lw=1.4,
                                linestyle=(0, (4,3))))
    ax.text(lx + 0.58, ly-2.72, 'Overlaps / crosses', ha='left', va='center', fontsize=7.5, color='#333333')

    # Background panels
    ax.add_patch(FancyBboxPatch((0.55, 5.55), 5.1, 7.25,
                 boxstyle="round,pad=0.04", lw=0.8,
                 edgecolor=ADM[1], facecolor=ADM[0], alpha=0.15, zorder=1))
    ax.add_patch(FancyBboxPatch((7.3, 7.35), 5.0, 5.45,
                 boxstyle="round,pad=0.04", lw=0.8,
                 edgecolor=ELEC[1], facecolor=ELEC[0], alpha=0.15, zorder=1))

    fig.suptitle('Structure of Indian Boundary Hierarchies',
                 fontsize=14, fontweight='bold', y=0.99)
    plt.tight_layout(rect=[0, 0, 1, 0.98])
    out = os.path.join(OUT, 'diagram_boundary_hierarchy.pdf')
    fig.savefig(out, dpi=200, bbox_inches='tight', facecolor='white')
    print(f'Saved: {out}')
    plt.close()


if __name__ == '__main__':
    draw_pipeline()
    draw_hierarchy()
    print('Done.')
