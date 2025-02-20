---
title: Import Cleanup
categories: [Post-Importing, Cleanup]
tags: [post-importing, cleanup]
description: Clean up any issues with imported UI.
date: 2025-2-20 09:15:00
---

# What Is Cleanup? Why Is This A Thing?
Sometimes with automatic (or sometimes manual) importing, you might have issues with sizing, positioning, etc. A lot of these issues are caused by this plugin being in early stages of development, so much of the friction now will soon be patched up.

# Issues And Solutions
Below are some issues you might run into and their solutions.

### Stretched Text
**Problem:** When exporting text as an image and importing it into studio as an `ImageLabel`, you might have stretched text.

**Reason:** This exists because the Figma plugin doesn't get text content size, and instead gets the element size. Often times, the element size is different than the content size.

**Solution:** Before exporting the text as an image, flatten it in Figma.

### Imported Stroke Value of 1
**Problem:** Sometimes, automatically imported elements will have the stroke property set to `1` when it's instead of `0`.

**Reason:** This issue has an unknown cause, but it is an issue on the plugin's end and not yours. It will be fixed soon.

**Solution:** Simply set it to `0` in Studio and press *Apply*.

### Shadows Causing Problems
**Problem:** Sometimes when exporting stuff with shadows, you might get position or sizing issues.

**Reason:** This issue has an unknown cause, but it is an issue on the plugin's end and not yours. It will be fixed soon.

**Solution:** You'll need to manually adjust your Studio Figma plugin properties to fix this.

### Device Resolutions Affecting Position
**Problem:** When you import interface, different device resolutions (e.g. ultrawide, mobile, etc) could cause your UI to be positioned incorrectly.

**Reason:** This actually is an issue with `UIAspectRatio` constraints, and believe it or not, this is expected behavior!

**Solution:** You can do one of two things: either disable the aspect ratio, or set the alignment to `0.5, 0.5`.

## Cannot Auto-Export As TextLabel
**Problem:** There is no auto-export tag for `TextLabel` instances.

**Reason:** This is an oversight on my end when creating tags to begin with, and I personally also feel the friction of this issue. This will be fixed with a future update, which will include the proper tag and introduce in-house conversion options.

**Solution:** When exporting, export without any "type" tags. In Studio, cleanup and then use a plugin to convert the instance to a `TextLabel`.

# I'm Having Another Issue
If you're having another issue, or an above solution doesn't work, you can do any of the following to report it:
* DM me on the Roblox Creator Forums (username: iGottic)
* DM me on Discord, if you are able to (username: igottic)
* Create a GitHub issue

When you report it, I will post a temporary solution here and then fix it on my end as soon as possible!