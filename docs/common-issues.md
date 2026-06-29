---
sidebar_position: 5
---

# Common Issues
Sometimes with automatic (or sometimes manual) importing, you might have issues with sizing, positioning, etc.

## Shadows Causing Problems
**Problem**: Sometimes when exporting stuff with shadows, you might get position or sizing issues.

**Reason**: This issue has an unknown cause, but it is an issue on the plugin’s end and not yours. It will be fixed soon.

**Solution**: You’ll need to manually adjust your Studio Figma plugin properties to fix this.

## Device Resolutions Affecting Position
**Problem**: When you import interface, different device resolutions (e.g. ultrawide, mobile, etc) could cause your UI to be positioned incorrectly.

**Reason**: This actually is an issue with UIAspectRatio constraints, and believe it or not, this is expected behavior!

**Solution**: You can do one of two things: either disable the aspect ratio, or set the alignment to `0.5, 0.5` using the plugin.

## Sizing Issues
**Problem**: You expect something to have a certain size, but it doesn't size correctly.

**Reason**: Again, this is expected behavior of UIAspectRatio constraints.

**Solution**: Disable aspect ratio.

## Elements Not Importing as Correct Types
**Problem**: You expect instances imported from Figma to be correct class types.

**Reason**: You are not using tags.

**Solution**: Use import tags. See [Auto Importing](./auto-importing.md) for more info.

# Issue Not Here?
If you don't see your issue here, it may be a bug. Please report it.