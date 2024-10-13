/*
    Original author: Rawblocky (@Rawblocky on Twitter)
    Forked by: Mia Gobble (@iGottic_Real on Twitter)

    Forked to work with iGottic's Roblox Figma Importer Assistant plugin.
*/

"use strict";

figma.showUI(__html__);
figma.ui.resize(500, 300);

figma.ui.onmessage = msg => {
    const currentPage = figma.currentPage;
    let FigmaExportData = [];

    function ReadNode(node) {
        if ("opacity" in node || "frame" in node) {
            let NodeExportData = {
                type: node.type,
                
                name: node.name,
                visible: node.visible,
                
                width: node.width,
                height: node.height,
                x: node.x,
                y: node.y,
                strokeWeight: node.strokeWeight,
                opacity: node.opacity,
                
                rotation: node.rotation,
                clipsContent: node.clipsContent,
                //fills: node.fills,
                cornerRadius: node.cornerRadius,
                // strokes: node.strokes,
                
                children: []
            }

            // if (node.type == "TEXT") {
            //     NodeExportData.textAlignHorizontal = node.textAlignHorizontal
            //     NodeExportData.textAlignVertical = node.textAlignVertical
            //     NodeExportData.textAutoResize = node.textAutoResize
            //     NodeExportData.characters = node.characters
            //     NodeExportData.fontSize = node.fontSize
            //     NodeExportData.fontName = node.fontName
            // }

            if ("children" in node){
                for (const childNode of node.children) {
                    const ReturnPackage = ReadNode(childNode)

                    if (ReturnPackage) {
                        NodeExportData.children.push(ReturnPackage)
                    }
                }
            }

            return NodeExportData
        }
    }

    if (msg === 'Run') {
        for (const node of figma.currentPage.selection) {
            const NodeExportData = ReadNode(node)

            if (NodeExportData) {
                FigmaExportData.push(NodeExportData)
            }
        }

        FigmaExportData = JSON.stringify(FigmaExportData)
        console.log(FigmaExportData)
        figma.ui.postMessage(FigmaExportData)

        // /copyToClipboardAsync(FigmaExportData);

        return FigmaExportData
    }

    // figma.closePlugin();
};
