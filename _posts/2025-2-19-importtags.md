---
title: Import Tags
categories: [Importing, Tags]
tags: [importing, auto-importing, tags]
description: Learn how to utilize tags to upgrade your workflow
date: 2025-2-19 10:00:00 +0300
---

# What Are Tags?
Tags are attached to the names of Figma nodes to modify import behavior. Below are the current tags usable for imports. Incorrect tagging is ignored and won't error.

<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
> This page is incomplete, stay tuned for upcoming changes.
{: .prompt-warning }
<!-- markdownlint-restore -->

<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
> Tags are written in `@UPPERCASE` format! For example, the "group" tag is written as `@GROUP`. Tags can be stacked, separated by `@`.
{: .prompt-tip }
<!-- markdownlint-restore -->

## Tags
Below are the tags used for auto-importing.

### GROUP
Groups a node in export. This means that no children will be exported under it.

### IGNORE
Nodes with `@IGNORE` in the name will not be included in exports.

### TYPE_FRAME
Declares the exported node to be a `Frame` class type in Studio.

### TYPE_SCROLLING_FRAME
Declares the exported node to be a `ScrollingFrame` class type in Studio.

### TYPE_BUTTON
Declares the exported node to be an `ImageButton` class type in Studio.

### TYPE_TEXT_BUTTON
Declares the exported node to be a `TextButton` class type in Studio.

### TYPE_IMAGE
Declares the exported node to be a `ImageLabel` class type in Studio. This is the default behind the scenes.