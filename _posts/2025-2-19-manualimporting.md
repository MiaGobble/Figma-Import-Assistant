---
title: Manual Importing
categories: [Importing, Methods]
tags: [importing, manual-importing]
description: How to import UI manually into Studio from Figma
date: 2025-2-19 10:00:00 +0200
---

# Initial Setup
To begin, if you haven't already, create a `ScreenGui` instance under `StarterGui`. Open the Roblox plugin and select it. Once you do, you should see something like this:

![image](/assets/docs/manualimporting/selectedguiexample.png)

In Figma, your imported UI **must** be in a parent frame. For example, if you're exporting a settings window, place that settings window in a 1920x1080 frame to simulate a 16:9 viewport.

<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
> If your parent frame is already 1920x1080, then don't worry about changing any values! It is defaulted to this for `ScreenGui`.
{: .prompt-tip }
<!-- markdownlint-restore -->

You'll see that the top section, *Figma Properties*, has width, height, and name parameters. You can change these as needed.
The width and height you set on the `ScreenGui` will determine how children are scaled!

# Instance Building
We can begin our workflow by creating an `ImageLabel` via the plugin. With the `ScreenGui` selected and the plugin open, open the *Instance Building* section and click "Create Child Image Label", like so:

![image](/assets/docs/manualimporting/createimagelabel.png)

You can also create any other instance!

# Understanding Properties
For each UI instance, you'll have associated importer properties when selected. Here is a continuiation of our `ImageLabel` example earlier:

![image](/assets/docs/manualimporting/exampleblankproperties.png)

Here is a breakdown of the *Figma Properties* section:
* "X Pos" is the x-position of the related element from Figma
* "Y Pos" is the y-position of the related element from Figma
* The same goes for "Width", "Height", "Shadow X", etc up until "Name" and "Image"
* "Name" is the instance name you would like to set
* "Image" is the image id for a selected `ImageLabel`, if applicable

Right after, you'll see a settings section:

![image](/assets/docs/manualimporting/settingssection.png)

It's pretty self-explanatory:
* Keep aspect ratio, when checked, will maintain the aspect ratio of UI elements
* Same goes for how it affects the instance `ClipsDescendants` property

Finally, you'll see the alignment section:

![image](/assets/docs/manualimporting/alignmentsection.png)

Setting the X and Y alignment values will change the `AnchorPoint` of the selected instance and automatically move it to stay in the same location. Changing anchor points can be useful for fixing issues or preparing for UI animations.

<!-- markdownlint-capture -->
<!-- markdownlint-disable -->
> *Figma Properties*, *Settings*, and *Alignment* all have unique values for each instance!
{: .prompt-tip }
<!-- markdownlint-restore -->

When you set properties, make sure to click the *Apply* button at the bottom of the screen.

# Importing A Single Element
Let's teleport an example square `ImageLabel` image, which looks like this in Figma:

![image](/assets/docs/manualimporting/exampleExport.png)

Note that the element is inside of a 1920x1080 parent viewport frame, which we will not be exporting.

Let's export the square image to our files, create an `ImageLabel`, and set the `Image` property to the asset id of the uploaded image. Here is what you should see:

![image](/assets/docs/manualimporting/uploadImageStep.png)

Let's propogate our property values over to the plugin. In Figma, these are our properties:

![image](/assets/docs/manualimporting/objectFigmaProperties.png)

And if we apply them in Studio, it looks like this:

![image](/assets/docs/manualimporting/appliedProperties.png)

And that's it!

# Importing More?
If you're importing much more, you might want to take the automatic route. Head over to the [automatic importing page](../automaticimporting/) to learn about automated batch importing to make your Figma and Studio UI a few clicks apart