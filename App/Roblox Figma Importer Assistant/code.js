"use strict";

figma.showUI(__html__);
figma.ui.resize(860, 720);

const TAGS = [
    "GROUP",
    "IGNORE",
    "TEXT",
    "TYPE_IMAGE",
    "TYPE_BUTTON",
    "TYPE_FRAME",
    "TYPE_SCROLLING_FRAME",
];

function splitNameAndTags(rawName) {
    const parts = rawName.split("@");
    const baseName = (parts.shift() || "").trim();
    const tags = parts
        .map((part) => part.trim())
        .filter((tag) => tag.length > 0);

    return { baseName, tags };
}

function composeName(baseName, tags) {
    if (tags.length === 0) {
        return baseName;
    }

    return `${baseName}@${tags.join("@")}`;
}

function hasTag(nodeName, tag) {
    const { tags } = splitNameAndTags(nodeName);
    return tags.includes(tag);
}

function safeNumber(value, fallback = 0) {
    if (typeof value === "number" && Number.isFinite(value)) {
        return value;
    }

    return fallback;
}

function normalizedFontNameForNode(node) {
    if (node.type !== "TEXT") {
        return null;
    }

    let fontName = node.fontName;

    if (fontName === figma.mixed) {
        if (typeof node.characters === "string" && node.characters.length > 0) {
            try {
                fontName = node.getRangeFontName(0, 1);
            } catch (_error) {
                fontName = null;
            }
        } else {
            fontName = null;
        }
    }

    if (!fontName || typeof fontName !== "object") {
        return null;
    }

    if (typeof fontName.family !== "string") {
        return null;
    }

    return {
        family: fontName.family,
        style: typeof fontName.style === "string" ? fontName.style : "Regular",
    };
}

function textPropsForNode(node) {
    if (node.type !== "TEXT") {
        return null;
    }

    return {
        characters: node.characters,
        textAlignHorizontal: node.textAlignHorizontal,
        textAlignVertical: node.textAlignVertical,
        textAutoResize: node.textAutoResize,
        fontSize: typeof node.fontSize === "number" ? node.fontSize : 14,
        fontName: normalizedFontNameForNode(node),
        lineHeight: node.lineHeight,
        letterSpacing: node.letterSpacing,
    };
}

function autoLayoutPropsForNode(node) {
    if (!("layoutMode" in node)) {
        return null;
    }

    return {
        layoutMode: node.layoutMode,
        layoutWrap: node.layoutWrap,
        primaryAxisSizingMode: node.primaryAxisSizingMode,
        counterAxisSizingMode: node.counterAxisSizingMode,
        primaryAxisAlignItems: node.primaryAxisAlignItems,
        counterAxisAlignItems: node.counterAxisAlignItems,
        itemSpacing: safeNumber(node.itemSpacing, 0),
        paddingTop: safeNumber(node.paddingTop, 0),
        paddingBottom: safeNumber(node.paddingBottom, 0),
        paddingLeft: safeNumber(node.paddingLeft, 0),
        paddingRight: safeNumber(node.paddingRight, 0),
    };
}

async function readNode(node, mode) {
    if (!("opacity" in node || "fills" in node || "children" in node)) {
        return null;
    }

    if (hasTag(node.name, "IGNORE")) {
        return null;
    }

    const exportData = {
        id: node.id,
        type: node.type,
        mode,
        name: node.name,
        visible: node.visible,
        width: safeNumber(node.width, 0),
        height: safeNumber(node.height, 0),
        x: safeNumber(node.x, 0),
        y: safeNumber(node.y, 0),
        strokeWeight: safeNumber(node.strokeWeight, 0),
        opacity: safeNumber(node.opacity, 1),
        rotation: safeNumber(node.rotation, 0),
        clipsContent: typeof node.clipsContent === "boolean" ? node.clipsContent : true,
        fills: "fills" in node ? node.fills : [],
        strokes: "strokes" in node ? node.strokes : [],
        effects: "effects" in node ? node.effects : [],
        cornerRadius: safeNumber(node.cornerRadius, 0),
        text: textPropsForNode(node),
        autoLayout: autoLayoutPropsForNode(node),
        children: [],
    };

    if ("children" in node) {
        for (const child of node.children) {
            const childExportData = await readNode(child, mode);
            if (childExportData) {
                exportData.children.push(childExportData);
            }
        }
    }

    return exportData;
}

async function exportSelection(mode) {
    const selectedRoots = figma.currentPage.selection;

    if (selectedRoots.length === 0) {
        throw new Error("Select at least one root node before exporting.");
    }

    const nodes = [];
    for (const root of selectedRoots) {
        const exported = await readNode(root, mode);
        if (exported) {
            nodes.push(exported);
        }
    }

    return nodes;
}

function tagSelection(tag, action) {
    if (!TAGS.includes(tag)) {
        throw new Error(`Unsupported tag: ${tag}`);
    }

    const selection = figma.currentPage.selection;
    if (selection.length === 0) {
        throw new Error("Select at least one node first.");
    }

    let changed = 0;

    for (const node of selection) {
        if (typeof node.name !== "string") {
            continue;
        }

        const { baseName, tags } = splitNameAndTags(node.name);
        const set = new Set(tags);

        if (action === "add") {
            set.add(tag);
        } else {
            set.delete(tag);
        }

        const nextName = composeName(baseName, [...set]);
        if (nextName !== node.name) {
            node.name = nextName;
            changed += 1;
        }
    }

    return changed;
}

figma.ui.onmessage = async (message) => {
    try {
        if (!message || typeof message !== "object") {
            return;
        }

        if (message.type === "export") {
            const mode = message.mode === "opportunistic" ? "opportunistic" : "classic";
            const payload = await exportSelection(mode);
            const payloadString = JSON.stringify(payload, null, 2);

            figma.ui.postMessage({
                type: "exportResult",
                payload: payloadString,
                nodeCount: payload.length,
            });
            return;
        }

        if (message.type === "tag") {
            const changed = tagSelection(message.tag, message.action);

            figma.ui.postMessage({
                type: "tagResult",
                message: `Updated ${changed} selected node(s).`,
            });
            return;
        }
    } catch (error) {
        figma.ui.postMessage({
            type: "error",
            message: error instanceof Error ? error.message : "Unexpected plugin error.",
        });
    }
};
