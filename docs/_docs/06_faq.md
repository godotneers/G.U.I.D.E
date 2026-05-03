---
layout: page
title: Frequently Asked Questions
permalink: /faq
description: "This page contains answers to frequently asked questions about G.U.I.D.E."
---

## The autoload fails to load after installing G.U.I.D.E from the AssetLib

This is a known issue ([#161]({{site.issue_tracker}}/161)) caused by a bug in certain versions of Godot. After installing G.U.I.D.E from the AssetLib, the `GUIDE` autoload may fail to load with an error like `Failed to create an autoload, can't load from UID or path`.

The workaround is to restart the Godot editor after the AssetLib installation completes, and only then enable the plugin in the project settings. This gives Godot a chance to properly register all files before the plugin is activated. If you have already enabled the plugin and are seeing the error, disable the plugin, restart the editor, and re-enable it.

This bug has been fixed in Godot's master branch and the fix will be included in a future stable release.

## I'm getting an error message when trying to use G.U.I.D.E in my project

In general if this happens it is caused by one of the following reasons:

- The plugin is not enabled in the project settings or the editor has not been restarted after enabling the plugin. Please make sure to follow the [installation instructions]({{site.baseurl}}/installation) carefully.
- You are running G.U.I.D.E code in an autoload. If your autoload executes code that uses G.U.I.D.E before the `GUIDE` autoload is initialized, you will get an error. Make sure to check the autoload order in the project settings and make sure that the `GUIDE` autoload is loaded before any autoload that uses G.U.I.D.E.
- You are using some plugins that might interfere with G.U.I.D.E. If you get strange errors, try disabling other plugins to see if they are causing the issue. If you find a plugin that causes issues, please [report it]({{site.issue_tracker}}) so I can investigate.

If none of these steps help, please [report the issue in the issue tracker]({{site.issue_tracker}}) and I will try to help you. Be sure to include as much information as possible about your setup and the error message you are getting.

## Does G.U.I.D.E have C# support?

G.U.I.D.E has no native support for C#, if you'd like to use it with C#, there is a community-maintained [C# wrapper](https://phlegmlee.github.io/G.U.I.D.E-CSharp/).

## The plugin doesn't work with the latest Godot preview version

This can happen because in general the aim of the plugin is to work with the latest stable version of Godot. Preview versions of Godot usually are not that stable and trying to make the plugin work with them can be a moving target. If you find an issue with a preview version of Godot, please [report it]({{site.issue_tracker}}), so I can investigate, but a fix might not materialize until the stable version is released.

## Where can I ask questions about how to use G.U.I.D.E?

You can ask questions in the [GitHub issue tracker]({{site.issue_tracker}}). Questions about how to use the plugin are marked with the `Knowledge` label, which allows you to easily [find every question]({{site.issue_tracker}}?q=is%3Aissue%20label%3Aknowledge%20) that has been asked before.

## Why don't you have a Discord server for support?

I'm a solo developer and I don't have the bandwidth to monitor a Discord server and to answer questions in real-time. Also, I find having a Discord running all day to be very distracting which negatively affects my productivity. The GitHub issue tracker is currently the best way for me to keep track of questions and issues and to answer them in a timely manner.