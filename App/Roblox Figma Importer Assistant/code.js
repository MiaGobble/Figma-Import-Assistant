/*
    Original author: Rawblocky (@Rawblocky on Twitter)
    Forked by: Mia Gobble (@iGottic_Real on Twitter)

    Forked to work with iGottic's Roblox Figma Importer Assistant plugin.
*/

"use strict";
// This plugin will open a window to prompt the user to enter a number, and
// it will then create that many rectangles on the screen.
// This file holds the main code for the plugins. It has access to the *document*.
// You can access browser APIs in the <script> tag inside "ui.html" which has a
// full browser environment (see documentation).
// This shows the HTML page in "ui.html".
figma.showUI(__html__);
figma.ui.resize(500, 300);
// Calls to "parent.postMessage" from within the HTML page will trigger this
// callback. The callback will be passed the "pluginMessage" property of the
// posted message.

figma.ui.onmessage = msg => {
    // One way of distinguishing between different types of messages sent from
    // your HTML page is to use an object with a "type" property like this.

    const currentPage = figma.currentPage;
    let FigmaExportData = [];

    function ReadNode(node) {
        if ("opacity" in node || "frame" in node) {
            let NodeExportData = {
                type: node.type,
                
                name: node.name,
                //visible: node.visible,
                
                width: node.width,
                height: node.height,
                x: node.x,
                y: node.y,
                strokeWeight: node.strokeWeight,
                opacity: node.opacity,
                
                //rotation: node.rotation,
                clipsContent: node.clipsContent,
                // fills: node.fills,
                // cornerRadius: node.cornerRadius,
                // strokeWeight: node.strokeWeight,
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

        return FigmaExportData
    }

    // Make sure to close the plugin when you're done. Otherwise the plugin will
    // keep running, which shows the cancel button at the bottom of the screen.
    // figma.closePlugin();
};
