# Tags
Tags are attached to the names of Figma nodes to modify import behavior. Below are the current tags usable for imports. Incorrect tagging is ignored and won't error.

> [!TIP]
> Tags are written in `@UPPERCASE` format! For example, the "group" tag is written as `@GROUP`. Tags can be stacked, separated by `@`.

### `@GROUP`
Groups a node in export. This means that no children will be exported under it.

### `@IGNORE`
Nodes with `@IGNORE` in the name will not be included in exports.

### `@TYPE_FRAME`
Declares the exported node to be a `Frame` class type in Studio.

### `@TYPE_SCROLLING_FRAME`
Declares the exported node to be a `ScrollingFrame` class type in Studio.

### `@TYPE_BUTTON`
Declares the exported node to be an `ImageButton` class type in Studio.

### `@TYPE_TEXT_BUTTON`
Declares the exported node to be a `TextButton` class type in Studio.

### `@TYPE_IMAGE`
Declares the exported node to be a `ImageLabel` class type in Studio. This is the default behind the scenes.