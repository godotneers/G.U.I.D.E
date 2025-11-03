---
layout: page
title: "Recipes"
permalink: /usage/recipes
description: "A collection of recipes for G.U.I.D.E"
---

## Introduction
G.U.I.D.E is a powerful tool that can be used in many different ways. While a documentation can only cover what is available, it doesn't really tell you how to use it to solve real world problems. Therefore this page contains a collection of recipes that show you how to use G.U.I.D.E to solve common problems. 

## Recipes
{% for page in site.recipes %}
- [{{ page.title }}]({{site.baseurl}}{{ page.url }}) - {{ page.description }}
{% endfor %}